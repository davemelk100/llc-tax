<template>
  <div class="app">
    <div v-if="!isAuthenticated" class="passcode-screen">
      <div class="passcode-card">
        <h2>Enter Passcode</h2>
        <input
          v-model="passcodeInput"
          type="password"
          placeholder="Enter passcode"
          @keyup.enter="checkPasscode"
          class="passcode-input"
          autofocus
        />
        <p v-if="passcodeError" class="passcode-error">{{ passcodeError }}</p>
        <button @click="checkPasscode" class="passcode-btn">Submit</button>
      </div>
    </div>

    <template v-else>
      <AdminPanel
        v-if="showAdmin"
        @close="showAdmin = false"
        @updated="loadData"
      />

      <CompanyProfile
        v-else-if="showProfile"
        @close="showProfile = false"
      />

      <template v-else>
        <header class="app-header">
          <div class="header-content">
            <h1>Melkonian Industries LLC</h1>
            <div class="header-actions">
              <button @click="showProfile = true" class="profile-btn">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                  <circle cx="12" cy="7" r="4"></circle>
                </svg>
              </button>
              <button @click="showAdmin = true" class="admin-btn">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
                </svg>
              </button>
              <button @click="logout" class="logout-btn">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                  <polyline points="16 17 21 12 16 7"></polyline>
                  <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
              </button>
            </div>
          </div>
        </header>

        <main class="app-main">
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>Loading expense data...</p>
        </div>

        <div v-else-if="error" class="error-state">
          <p>{{ error }}</p>
          <button @click="loadData" class="retry-btn">Retry</button>
        </div>

        <div v-else class="expenses-grid">
          <ExpenseCard
            v-for="category in sortedCategories"
            :key="category.id"
            :category="category"
            :documents="getDocumentsForCategory(category.id)"
            @edit-document="openEditDialog"
            @add-document="openAddDialog"
          />
        </div>

        <div v-if="!loading && !error" class="totals-card">
          <div class="totals-content">
            <h2>Total Expenses</h2>
            <div class="totals-amount">${{ totalAmount.toFixed(2) }}</div>
            <div class="totals-meta">
              <span>{{ totalDocuments }} {{ totalDocuments === 1 ? 'document' : 'documents' }}</span>
              <span class="separator">•</span>
              <span>{{ categories.length }} {{ categories.length === 1 ? 'category' : 'categories' }}</span>
            </div>
          </div>
        </div>
      </main>

      <footer class="app-footer">
        <p>&copy; {{ currentYear }} Melkonian Industries LLC. All rights reserved.</p>
      </footer>

        <div v-if="showEditDialog" class="modal-overlay" @click="closeEditDialog">
          <div class="modal-content" @click.stop>
            <div class="modal-header">
              <h2>{{ isAddMode ? 'Add New Expense' : 'Manage Documents' }}</h2>
              <button @click="closeEditDialog" class="close-btn">&times;</button>
            </div>
            <div class="modal-body">
              <div class="form-group">
                <label>CATEGORY *</label>
                <select v-model="editForm.category_id" class="form-input" :disabled="!isAddMode">
                  <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                    {{ cat.name }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label>TITLE *</label>
                <input v-model="editForm.title" type="text" class="form-input" />
              </div>
              <div class="form-group">
                <label>DESCRIPTION</label>
                <textarea v-model="editForm.description" class="form-input form-textarea" rows="3"></textarea>
              </div>
              <div class="form-group">
                <label>DOCUMENT TYPE *</label>
                <select v-model="editForm.document_type" class="form-input">
                  <option value="PDF">PDF</option>
                  <option value="link">Link</option>
                  <option value="image">Image</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <div v-if="isAddMode" class="form-group">
                <label>FILES * (You can select multiple)</label>
                <input type="file" @change="handleMultipleFilesChange" class="form-input" accept=".pdf,.jpg,.jpeg,.png" multiple />
                <p v-if="selectedFiles.length > 0" class="file-count">{{ selectedFiles.length }} file(s) selected</p>
              </div>
              <div v-else>
                <div class="form-group">
                  <label>URL *</label>
                  <input v-model="editForm.url" type="text" class="form-input" />
                </div>
                <div class="form-group">
                  <label>ADD MORE FILES (Optional)</label>
                  <input type="file" @change="handleMultipleFilesChange" class="form-input" accept=".pdf,.jpg,.jpeg,.png" multiple />
                  <p v-if="selectedFiles.length > 0" class="file-count">{{ selectedFiles.length }} file(s) selected to add</p>
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label>AMOUNT</label>
                  <input v-model.number="editForm.amount" type="number" step="0.01" class="form-input" />
                </div>
                <div class="form-group">
                  <label>DATE</label>
                  <input v-model="editForm.date" type="date" class="form-input" />
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button @click="closeEditDialog" class="cancel-btn">CANCEL</button>
              <button @click="isAddMode ? saveAdd() : saveEdit()" class="save-btn" :disabled="saving">
                {{ saving ? 'SAVING...' : (isAddMode ? 'ADD EXPENSE' : 'UPDATE DOCUMENT') }}
              </button>
            </div>
          </div>
        </div>
      </template>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import ExpenseCard from './components/ExpenseCard.vue';
import AdminPanel from './components/admin/AdminPanel.vue';
import CompanyProfile from './components/CompanyProfile.vue';
import { useSupabase, type ExpenseCategory, type ExpenseDocument } from './composables/useSupabase';

const CORRECT_PASSCODE = '6231839';
const AUTH_KEY = 'melkonian_auth';

const supabase = useSupabase();
const categories = ref<ExpenseCategory[]>([]);
const documents = ref<ExpenseDocument[]>([]);
const loading = ref(false);
const error = ref('');
const showAdmin = ref(false);
const showProfile = ref(false);
const isAuthenticated = ref(false);
const passcodeInput = ref('');
const passcodeError = ref('');
const showEditDialog = ref(false);
const editingDocument = ref<ExpenseDocument | null>(null);
const isAddMode = ref(false);
const selectedFiles = ref<File[]>([]);
const saving = ref(false);
const editForm = ref({
  category_id: '',
  title: '',
  description: '',
  document_type: '',
  url: '',
  amount: 0,
  date: ''
});

const currentYear = new Date().getFullYear();

const checkExistingAuth = () => {
  const authData = localStorage.getItem(AUTH_KEY);
  if (authData) {
    const authDate = new Date(authData);
    const today = new Date();
    if (
      authDate.getFullYear() === today.getFullYear() &&
      authDate.getMonth() === today.getMonth() &&
      authDate.getDate() === today.getDate()
    ) {
      isAuthenticated.value = true;
      return;
    }
  }
  isAuthenticated.value = false;
};

const checkPasscode = () => {
  if (passcodeInput.value === CORRECT_PASSCODE) {
    isAuthenticated.value = true;
    passcodeError.value = '';
    localStorage.setItem(AUTH_KEY, new Date().toISOString());
    loadData();
  } else {
    passcodeError.value = 'Incorrect passcode';
    passcodeInput.value = '';
  }
};

const logout = () => {
  localStorage.removeItem(AUTH_KEY);
  isAuthenticated.value = false;
  passcodeInput.value = '';
  passcodeError.value = '';
};

const sortedCategories = computed(() => {
  return [...categories.value].sort((a, b) => a.display_order - b.display_order);
});

const getDocumentsForCategory = (categoryId: string): ExpenseDocument[] => {
  return documents.value.filter((doc) => doc.category_id === categoryId);
};

const totalAmount = computed(() => {
  return documents.value.reduce((sum, doc) => sum + (doc.amount || 0), 0);
});

const totalDocuments = computed(() => {
  return documents.value.length;
});

const loadData = async () => {
  loading.value = true;
  error.value = '';
  try {
    [categories.value, documents.value] = await Promise.all([
      supabase.getCategories(),
      supabase.getDocuments(),
    ]);
  } catch (e: any) {
    error.value = e.message || 'Failed to load data from database.';
  } finally {
    loading.value = false;
  }
};

const openAddDialog = (category: ExpenseCategory) => {
  isAddMode.value = true;
  editingDocument.value = null;
  selectedFiles.value = [];
  editForm.value.category_id = category.id;
  editForm.value.title = '';
  editForm.value.description = '';
  editForm.value.document_type = 'PDF';
  editForm.value.url = '';
  editForm.value.amount = 0;
  editForm.value.date = new Date().toISOString().split('T')[0];
  showEditDialog.value = true;
};

const openEditDialog = (document: ExpenseDocument) => {
  isAddMode.value = false;
  editingDocument.value = document;
  editForm.value.category_id = document.category_id;
  editForm.value.title = document.title;
  editForm.value.description = document.description;
  editForm.value.document_type = document.document_type;
  editForm.value.url = document.url;
  editForm.value.amount = document.amount || 0;
  editForm.value.date = document.date;
  showEditDialog.value = true;
};

const handleMultipleFilesChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files.length > 0) {
    selectedFiles.value = Array.from(target.files);
  }
};

const closeEditDialog = () => {
  showEditDialog.value = false;
  editingDocument.value = null;
  isAddMode.value = false;
  selectedFiles.value = [];
  editForm.value.category_id = '';
  editForm.value.title = '';
  editForm.value.description = '';
  editForm.value.document_type = '';
  editForm.value.url = '';
  editForm.value.amount = 0;
  editForm.value.date = '';
};

const saveAdd = async () => {
  if (selectedFiles.value.length === 0) {
    alert('Please select at least one file');
    return;
  }

  if (!editForm.value.title.trim()) {
    alert('Please enter a title');
    return;
  }

  saving.value = true;
  try {
    const uploadedUrls = await supabase.uploadMultipleFiles(selectedFiles.value);
    const firstUrl = uploadedUrls[0];

    const newDocument = await supabase.createDocument({
      category_id: editForm.value.category_id,
      title: editForm.value.title,
      description: editForm.value.description,
      document_type: editForm.value.document_type,
      url: firstUrl,
      amount: editForm.value.amount || undefined,
      date: editForm.value.date || new Date().toISOString().split('T')[0]
    });

    for (let i = 0; i < selectedFiles.value.length; i++) {
      const file = selectedFiles.value[i];
      await supabase.createAttachment({
        document_id: newDocument.id,
        url: uploadedUrls[i],
        file_name: file.name,
        file_type: file.type,
        file_size: file.size,
        display_order: i
      });
    }

    await loadData();
    closeEditDialog();
  } catch (e: any) {
    alert('Failed to add expense: ' + (e.message || 'Unknown error'));
  } finally {
    saving.value = false;
  }
};

const saveEdit = async () => {
  if (!editingDocument.value) return;

  saving.value = true;
  try {
    await supabase.updateDocument(editingDocument.value.id, {
      title: editForm.value.title,
      description: editForm.value.description,
      document_type: editForm.value.document_type,
      url: editForm.value.url,
      amount: editForm.value.amount,
      date: editForm.value.date
    });

    if (selectedFiles.value.length > 0) {
      const uploadedUrls = await supabase.uploadMultipleFiles(selectedFiles.value);
      const existingAttachments = await supabase.getAttachments(editingDocument.value.id);
      const maxOrder = existingAttachments.length > 0
        ? Math.max(...existingAttachments.map(a => a.display_order))
        : -1;

      for (let i = 0; i < selectedFiles.value.length; i++) {
        const file = selectedFiles.value[i];
        await supabase.createAttachment({
          document_id: editingDocument.value.id,
          url: uploadedUrls[i],
          file_name: file.name,
          file_type: file.type,
          file_size: file.size,
          display_order: maxOrder + i + 1
        });
      }
    }

    await loadData();
    closeEditDialog();
  } catch (e: any) {
    alert('Failed to update document: ' + (e.message || 'Unknown error'));
  } finally {
    saving.value = false;
  }
};

onMounted(() => {
  checkExistingAuth();
  if (isAuthenticated.value) {
    loadData();
  }
});
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Roboto', sans-serif;
  background: #6394c1;
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
}

body::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background:
    radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.15) 0%, transparent 50%),
    radial-gradient(circle at 80% 80%, rgba(74, 139, 184, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 40% 20%, rgba(61, 111, 158, 0.2) 0%, transparent 50%);
  animation: backgroundShift 15s ease-in-out infinite;
  pointer-events: none;
  z-index: 0;
}

@keyframes backgroundShift {
  0%, 100% {
    opacity: 1;
    transform: scale(1) translate(0, 0);
  }
  50% {
    opacity: 0.8;
    transform: scale(1.1) translate(-2%, 2%);
  }
}

.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  position: relative;
  z-index: 1;
}

.app-header {
  position: sticky;
  top: 0;
  background: rgba(99, 148, 193, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  padding: 0.5rem;
  z-index: 100;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  padding: 0 2rem;
}

.header-content h1 {
  margin: 0;
  font-size: 32px;
  color: #abc9e4;
  text-shadow: rgba(99, 149, 193, 0.9) -1px -1px 1px, rgba(0, 0, 0, 0.2) 1px 1px 2px, rgba(99, 149, 193, 0.5) 0px 0px 1px;
  text-transform: uppercase;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.profile-btn,
.admin-btn,
.logout-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem;
  background: transparent;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
}

.profile-btn:hover,
.admin-btn:hover,
.logout-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}

.passcode-screen {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.passcode-card {
  background: white;
  border-radius: 16px;
  padding: 3rem;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 400px;
  text-align: center;
}

.passcode-card h2 {
  margin-bottom: 2rem;
  color: #3d6f9e;
  font-size: 1.75rem;
}

.passcode-input {
  width: 100%;
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1.125rem;
  font-family: 'Roboto', sans-serif;
  transition: border-color 0.2s;
  text-align: center;
  letter-spacing: 0.25rem;
}

.passcode-input:focus {
  outline: none;
  border-color: #5691c4;
}

.passcode-error {
  color: #d32f2f;
  margin-top: 1rem;
  font-size: 0.875rem;
}

.passcode-btn {
  width: 100%;
  margin-top: 1.5rem;
  padding: 1rem;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.125rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  text-transform: uppercase;
}

.passcode-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(86, 145, 196, 0.4);
}

.app-main {
  flex: 1;
  padding: 2rem;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
}

.loading-state,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  color: white;
  text-align: center;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.error-state p {
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

.retry-btn {
  padding: 0.75rem 1.5rem;
  background: white;
  color: #5691c4;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: transform 0.2s;
  text-transform: uppercase;
}

.retry-btn:hover {
  transform: translateY(-2px);
}

.expenses-grid {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.totals-card {
  margin-top: 3rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15),
              inset 0 1px 0 rgba(255, 255, 255, 0.6);
  overflow: hidden;
}

.totals-content {
  padding: 2.5rem;
  text-align: left;
  position: relative;
}

.totals-content h2 {
  margin: 0 0 1.5rem 0;
  font-size: 1.75rem;
  font-weight: 600;
  color: #ffffff;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.totals-amount {
  font-size: 3.5rem;
  font-weight: 700;
  color: #ffffff;
  margin-bottom: 1rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.totals-meta {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 1rem;
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

.totals-meta .separator {
  color: rgba(255, 255, 255, 0.5);
  font-weight: 700;
}

.app-footer {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  color: white;
  padding: 1.5rem;
  margin-top: 2rem;
}

.app-footer p {
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  padding: 0 2rem;
  text-align: left;
  text-transform: uppercase;
  color: #abc9e4;
  text-shadow: rgba(99, 149, 193, 0.9) -1px -1px 1px, rgba(0, 0, 0, 0.2) 1px 1px 2px, rgba(99, 149, 193, 0.5) 0px 0px 1px;
  font-size: 1.2rem;
}

@media (max-width: 640px) {
  .header-content {
    padding: 0 1rem;
    gap: 1rem;
  }

  .header-content h1 {
    font-size: 28px;
  }

  .app-main {
    padding: 1rem;
  }

  .expenses-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .totals-card {
    margin-top: 2rem;
  }

  .totals-content {
    padding: 1.5rem;
  }

  .totals-content h2 {
    font-size: 1.25rem;
    margin-bottom: 1rem;
  }

  .totals-amount {
    font-size: 2.5rem;
  }

  .totals-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .totals-meta .separator {
    display: none;
  }

  .app-footer p {
    padding: 0 1rem;
    font-size: 0.875rem;
  }

  .modal-content {
    max-width: calc(100% - 2rem);
  }

  .modal-header {
    padding: 1rem 1.5rem;
  }

  .modal-header h2 {
    font-size: 1.25rem;
  }

  .modal-body {
    padding: 1.5rem;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .modal-footer {
    padding: 1rem 1.5rem;
    flex-direction: column-reverse;
  }

  .cancel-btn,
  .save-btn {
    width: 100%;
  }

  .passcode-card {
    padding: 2rem 1.5rem;
  }

  .passcode-card h2 {
    font-size: 1.5rem;
  }
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 600px;
  width: 100%;
  overflow: hidden;
  border: 2px solid rgba(86, 145, 196, 0.3);
}

.modal-header {
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: white;
}

.close-btn {
  background: transparent;
  border: none;
  font-size: 2rem;
  color: white;
  cursor: pointer;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background 0.2s;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.modal-body {
  padding: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 700;
  color: #3d6f9e;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.file-count {
  margin-top: 0.5rem;
  font-size: 0.875rem;
  color: #3d6f9e;
  font-weight: 500;
}

.form-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  font-family: 'Roboto', sans-serif;
  transition: border-color 0.2s;
  background: white;
}

.form-input:focus {
  outline: none;
  border-color: #5691c4;
}

.form-textarea {
  resize: vertical;
  font-family: 'Roboto', sans-serif;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.modal-footer {
  padding: 1.5rem 2rem;
  border-top: 1px solid #e0e0e0;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  background: #f5f5f5;
}

.cancel-btn,
.save-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
}

.cancel-btn {
  background: white;
  color: #666;
  border: 2px solid #e0e0e0;
}

.cancel-btn:hover {
  background: #f5f5f5;
  border-color: #ccc;
}

.save-btn {
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
}

.save-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(86, 145, 196, 0.4);
}
</style>
