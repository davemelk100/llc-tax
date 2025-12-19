<template>
  <div class="document-manager">
    <h2>Manage Documents</h2>

    <form @submit.prevent="handleSubmit" class="document-form">
      <div class="form-group">
        <label>Category *</label>
        <select v-model="form.categoryId" required>
          <option value="">Select a category</option>
          <option v-for="cat in categories" :key="cat.id" :value="cat.id">
            {{ cat.name }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label>Title *</label>
        <input
          v-model="form.title"
          type="text"
          required
          placeholder="e.g., Monthly Receipt - January 2024"
        />
      </div>

      <div class="form-group">
        <label>Description</label>
        <textarea
          v-model="form.description"
          placeholder="Optional description"
          rows="2"
        ></textarea>
      </div>

      <div class="form-group">
        <label>Document Type *</label>
        <select v-model="form.documentType" required>
          <option value="pdf">PDF</option>
          <option value="link">Link</option>
          <option value="image">Image</option>
          <option value="other">Other</option>
        </select>
      </div>

      <div class="form-group">
        <label>Upload or Link</label>
        <div class="upload-choice">
          <label class="radio-option">
            <input type="radio" v-model="uploadMode" value="url" />
            Enter URL
          </label>
          <label class="radio-option">
            <input type="radio" v-model="uploadMode" value="file" />
            Upload File
          </label>
        </div>
      </div>

      <div v-if="uploadMode === 'url'" class="form-group">
        <label>URL *</label>
        <input
          v-model="form.url"
          type="url"
          :required="uploadMode === 'url'"
          placeholder="https://example.com/document.pdf"
        />
      </div>

      <div v-else class="form-group">
        <label>Upload File *</label>
        <input
          type="file"
          @change="handleFileChange"
          :required="uploadMode === 'file' && !form.url"
          accept=".pdf,.jpg,.jpeg,.png,.gif,.webp"
          ref="fileInput"
        />
        <div v-if="uploadProgress" class="upload-progress">
          Uploading: {{ uploadProgress }}%
        </div>
        <div v-if="form.url && uploadMode === 'file'" class="file-preview">
          File uploaded successfully
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>Amount</label>
          <input
            v-model.number="form.amount"
            type="number"
            step="0.01"
            placeholder="0.00"
          />
        </div>

        <div class="form-group">
          <label>Date</label>
          <input
            v-model="form.date"
            type="date"
          />
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-primary">
          {{ editingId ? 'Update' : 'Create' }} Document
        </button>
        <button
          v-if="editingId"
          type="button"
          @click="resetForm"
          class="btn-secondary"
        >
          Cancel
        </button>
      </div>
    </form>

    <div v-if="loading" class="loading">Loading...</div>
    <div v-else-if="error" class="error">{{ error }}</div>

    <div class="documents-list">
      <h3>Existing Documents</h3>

      <div class="filter-group">
        <label>Filter by Category:</label>
        <select v-model="filterCategoryId" @change="loadDocuments">
          <option value="">All Categories</option>
          <option v-for="cat in categories" :key="cat.id" :value="cat.id">
            {{ cat.name }}
          </option>
        </select>
      </div>

      <div v-if="documents.length === 0" class="no-items">
        No documents yet
      </div>
      <div v-else class="document-items">
        <div
          v-for="doc in documents"
          :key="doc.id"
          class="document-item"
        >
          <div class="document-info">
            <strong>{{ doc.title }}</strong>
            <span class="document-category">
              {{ getCategoryName(doc.category_id) }}
            </span>
            <span v-if="doc.description" class="document-desc">
              {{ doc.description }}
            </span>
            <div class="document-meta">
              <span class="doc-type-badge">{{ doc.document_type }}</span>
              <span v-if="doc.amount" class="doc-amount">${{ doc.amount }}</span>
              <span class="doc-date">{{ formatDate(doc.date) }}</span>
            </div>
          </div>
          <div class="document-actions">
            <a :href="doc.url" target="_blank" class="btn-view">View</a>
            <button @click="editDocument(doc)" class="btn-edit">Edit</button>
            <button @click="deleteDocument(doc.id)" class="btn-delete">
              Delete
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useSupabase, type ExpenseCategory, type ExpenseDocument } from '../../composables/useSupabase';

const emit = defineEmits<{
  updated: [];
}>();

const supabase = useSupabase();
const categories = ref<ExpenseCategory[]>([]);
const documents = ref<ExpenseDocument[]>([]);
const loading = ref(false);
const error = ref('');
const editingId = ref('');
const filterCategoryId = ref('');
const uploadMode = ref<'url' | 'file'>('url');
const uploadProgress = ref<number | null>(null);
const selectedFile = ref<File | null>(null);
const fileInput = ref<HTMLInputElement | null>(null);

const form = ref({
  categoryId: '',
  title: '',
  description: '',
  documentType: 'link',
  url: '',
  amount: null as number | null,
  date: new Date().toISOString().split('T')[0],
});

const loadCategories = async () => {
  try {
    categories.value = await supabase.getCategories();
  } catch (e: any) {
    error.value = e.message || 'Failed to load categories';
  }
};

const loadDocuments = async () => {
  loading.value = true;
  error.value = '';
  try {
    documents.value = await supabase.getDocuments(filterCategoryId.value || undefined);
  } catch (e: any) {
    error.value = e.message || 'Failed to load documents';
  } finally {
    loading.value = false;
  }
};

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files.length > 0) {
    selectedFile.value = target.files[0];
  }
};

const handleSubmit = async () => {
  loading.value = true;
  error.value = '';
  uploadProgress.value = null;

  try {
    let fileUrl = form.value.url;

    if (uploadMode.value === 'file' && selectedFile.value) {
      uploadProgress.value = 0;
      fileUrl = await supabase.uploadFile(selectedFile.value);
      uploadProgress.value = 100;
    }

    if (!fileUrl) {
      throw new Error('Please provide a URL or upload a file');
    }

    const submitData = {
      category_id: form.value.categoryId,
      title: form.value.title,
      description: form.value.description,
      document_type: form.value.documentType,
      url: fileUrl,
      amount: form.value.amount || undefined,
      date: form.value.date,
    };

    if (editingId.value) {
      await supabase.updateDocument(editingId.value, submitData);
    } else {
      await supabase.createDocument(submitData);
    }
    await loadDocuments();
    resetForm();
    emit('updated');
  } catch (e: any) {
    error.value = e.message || 'Failed to save document';
  } finally {
    loading.value = false;
    uploadProgress.value = null;
  }
};

const editDocument = (doc: ExpenseDocument) => {
  editingId.value = doc.id;
  form.value = {
    categoryId: doc.category_id,
    title: doc.title,
    description: doc.description || '',
    documentType: doc.document_type,
    url: doc.url,
    amount: doc.amount,
    date: doc.date,
  };
};

const deleteDocument = async (id: string) => {
  if (!confirm('Are you sure you want to delete this document?')) return;

  loading.value = true;
  error.value = '';
  try {
    await supabase.deleteDocument(id);
    await loadDocuments();
    emit('updated');
  } catch (e: any) {
    error.value = e.message || 'Failed to delete document';
  } finally {
    loading.value = false;
  }
};

const resetForm = () => {
  editingId.value = '';
  uploadMode.value = 'url';
  selectedFile.value = null;
  uploadProgress.value = null;
  if (fileInput.value) {
    fileInput.value.value = '';
  }
  form.value = {
    categoryId: '',
    title: '',
    description: '',
    documentType: 'link',
    url: '',
    amount: null,
    date: new Date().toISOString().split('T')[0],
  };
};

const getCategoryName = (categoryId: string): string => {
  const category = categories.value.find((c) => c.id === categoryId);
  return category ? category.name : 'Unknown';
};

const formatDate = (dateString: string): string => {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
};

onMounted(async () => {
  await loadCategories();
  await loadDocuments();
});
</script>

<style scoped>
.document-manager h2,
.document-manager h3 {
  margin: 0 0 1rem 0;
  color: #2c3e50;
}

.document-form {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 1rem;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: #5691c4;
}

.upload-choice {
  display: flex;
  gap: 1.5rem;
  margin-top: 0.5rem;
}

.radio-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-weight: 500;
}

.radio-option input[type="radio"] {
  width: auto;
  cursor: pointer;
}

.upload-progress {
  margin-top: 0.5rem;
  padding: 0.5rem;
  background: #e3f2fd;
  color: #1976d2;
  border-radius: 4px;
  font-size: 0.9rem;
  text-align: center;
}

.file-preview {
  margin-top: 0.5rem;
  padding: 0.5rem;
  background: #e8f5e9;
  color: #2e7d32;
  border-radius: 4px;
  font-size: 0.9rem;
  text-align: center;
}

.form-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-primary {
  flex: 1;
  padding: 0.75rem;
  background: #5691c4;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: background 0.2s;
  text-transform: uppercase;
}

.btn-primary:hover {
  background: #4a7ba7;
}

.btn-secondary {
  padding: 0.75rem 1rem;
  background: #95a5a6;
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: background 0.2s;
  text-transform: uppercase;
}

.btn-secondary:hover {
  background: #7f8c8d;
}

.loading,
.error {
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1rem;
}

.loading {
  background: #e3f2fd;
  color: #1976d2;
}

.error {
  background: #ffebee;
  color: #c62828;
}

.filter-group {
  margin-bottom: 1rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.filter-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.filter-group select {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 1rem;
}

.no-items {
  text-align: center;
  padding: 2rem;
  color: #95a5a6;
  font-style: italic;
}

.document-items {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.document-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.document-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.document-category {
  font-size: 0.85rem;
  color: #5691c4;
  font-weight: 600;
}

.document-desc {
  font-size: 0.9rem;
  color: #6c757d;
}

.document-meta {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.25rem;
}

.doc-type-badge {
  background: #5691c4;
  color: white;
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.doc-amount {
  font-weight: 600;
  color: #27ae60;
  font-size: 0.9rem;
}

.doc-date {
  font-size: 0.85rem;
  color: #95a5a6;
}

.document-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.btn-view,
.btn-edit,
.btn-delete {
  padding: 0.5rem 0.75rem;
  border: none;
  border-radius: 4px;
  font-size: 0.9rem;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  text-decoration: none;
  text-align: center;
  transition: all 0.2s;
  text-transform: uppercase;
}

.btn-view {
  background: #27ae60;
  color: white;
}

.btn-view:hover {
  background: #229954;
}

.btn-edit {
  background: #5691c4;
  color: white;
}

.btn-edit:hover {
  background: #4a7ba7;
}

.btn-delete {
  background: #e74c3c;
  color: white;
}

.btn-delete:hover {
  background: #c0392b;
}
</style>
