<template>
  <div class="category-manager">
    <h2>Manage Categories</h2>

    <form @submit.prevent="handleSubmit" class="category-form">
      <div class="form-group">
        <label>Category Name *</label>
        <input
          v-model="form.name"
          type="text"
          required
          placeholder="e.g., Office Supplies"
        />
      </div>

      <div class="form-group">
        <label>Description</label>
        <textarea
          v-model="form.description"
          placeholder="Optional description"
          rows="3"
        ></textarea>
      </div>

      <div class="form-group">
        <label>Display Order</label>
        <input
          v-model.number="form.displayOrder"
          type="number"
          min="0"
        />
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-primary">
          {{ editingId ? 'Update' : 'Create' }} Category
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

    <div class="categories-list">
      <h3>Existing Categories</h3>
      <div v-if="categories.length === 0" class="no-items">
        No categories yet
      </div>
      <div v-else class="category-items">
        <div
          v-for="category in categories"
          :key="category.id"
          class="category-item"
        >
          <div class="category-info">
            <strong>{{ category.name }}</strong>
            <span v-if="category.description" class="category-desc">
              {{ category.description }}
            </span>
            <span class="category-order">Order: {{ category.display_order }}</span>
          </div>
          <div class="category-actions">
            <button @click="editCategory(category)" class="btn-edit">Edit</button>
            <button @click="deleteCategory(category.id)" class="btn-delete">
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
import { useSupabase, type ExpenseCategory } from '../../composables/useSupabase';

const emit = defineEmits<{
  updated: [];
}>();

const supabase = useSupabase();
const categories = ref<ExpenseCategory[]>([]);
const loading = ref(false);
const error = ref('');
const editingId = ref('');

const form = ref({
  name: '',
  description: '',
  displayOrder: 0,
});

const loadCategories = async () => {
  loading.value = true;
  error.value = '';
  try {
    categories.value = await supabase.getCategories();
  } catch (e: any) {
    error.value = e.message || 'Failed to load categories';
  } finally {
    loading.value = false;
  }
};

const handleSubmit = async () => {
  loading.value = true;
  error.value = '';
  try {
    const submitData = {
      name: form.value.name,
      description: form.value.description,
      display_order: form.value.displayOrder,
    };

    if (editingId.value) {
      await supabase.updateCategory(editingId.value, submitData);
    } else {
      await supabase.createCategory(submitData);
    }
    await loadCategories();
    resetForm();
    emit('updated');
  } catch (e: any) {
    error.value = e.message || 'Failed to save category';
  } finally {
    loading.value = false;
  }
};

const editCategory = (category: ExpenseCategory) => {
  editingId.value = category.id;
  form.value = {
    name: category.name,
    description: category.description || '',
    displayOrder: category.display_order,
  };
};

const deleteCategory = async (id: string) => {
  if (!confirm('Are you sure you want to delete this category?')) return;

  loading.value = true;
  error.value = '';
  try {
    await supabase.deleteCategory(id);
    await loadCategories();
    emit('updated');
  } catch (e: any) {
    error.value = e.message || 'Failed to delete category';
  } finally {
    loading.value = false;
  }
};

const resetForm = () => {
  editingId.value = '';
  form.value = {
    name: '',
    description: '',
    displayOrder: 0,
  };
};

onMounted(() => {
  loadCategories();
});
</script>

<style scoped>
.category-manager h2,
.category-manager h3 {
  margin: 0 0 1rem 0;
  color: #2c3e50;
}

.category-form {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 1rem;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #5691c4;
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
  font-family: 'Roboto Serif', serif;
  cursor: pointer;
  transition: background 0.2s;
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
  font-family: 'Roboto Serif', serif;
  cursor: pointer;
  transition: background 0.2s;
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

.no-items {
  text-align: center;
  padding: 2rem;
  color: #95a5a6;
  font-style: italic;
}

.category-items {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.category-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.category-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.category-desc {
  font-size: 0.9rem;
  color: #6c757d;
}

.category-order {
  font-size: 0.85rem;
  color: #95a5a6;
}

.category-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-edit,
.btn-delete {
  padding: 0.5rem 0.75rem;
  border: none;
  border-radius: 4px;
  font-size: 0.9rem;
  font-weight: 500;
  font-family: 'Roboto Serif', serif;
  cursor: pointer;
  transition: all 0.2s;
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
