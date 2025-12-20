<template>
  <div class="category-manager">
    <h2>Manage Categories</h2>

    <ConfirmDialog
      ref="confirmDialog"
      title="Delete Category"
      message="Are you sure you want to delete this category? All documents in this category will remain but will need to be reassigned."
      confirm-text="Delete"
      cancel-text="Cancel"
    />

    <form @submit.prevent="handleSubmit" class="category-form" :class="{ editing: editingId }">
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
import ConfirmDialog from '../ConfirmDialog.vue';
import { useSupabase, type ExpenseCategory } from '../../composables/useSupabase';

const emit = defineEmits<{
  updated: [];
}>();

const supabase = useSupabase();
const categories = ref<ExpenseCategory[]>([]);
const loading = ref(false);
const error = ref('');
const editingId = ref('');
const confirmDialog = ref<InstanceType<typeof ConfirmDialog> | null>(null);

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
  window.scrollTo({ top: 0, behavior: 'smooth' });
};

const deleteCategory = async (id: string) => {
  if (!confirmDialog.value) return;

  const confirmed = await confirmDialog.value.open();
  if (!confirmed) return;

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
  color: #ffffff;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.category-form {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1), inset 0 1px 0 rgba(255, 255, 255, 0.5);
  padding: 1.5rem;
  border-radius: 16px;
  margin-bottom: 2rem;
  transition: all 0.3s;
}

.category-form.editing {
  background: rgba(255, 193, 7, 0.2);
  border: 2px solid rgba(255, 193, 7, 0.6);
  box-shadow: 0 8px 32px rgba(255, 193, 7, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.5);
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #ffffff;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  background: rgba(255, 255, 255, 0.9);
  color: #333;
  transition: all 0.2s;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: rgba(255, 255, 255, 0.6);
  background: #ffffff;
  box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1);
}

.form-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-primary {
  flex: 1;
  padding: 0.75rem;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(86, 145, 196, 0.4);
}

.btn-secondary {
  padding: 0.75rem 1rem;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 8px;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: translateY(-2px);
}

.loading,
.error {
  padding: 1rem;
  border-radius: 12px;
  margin-bottom: 1rem;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  font-weight: 500;
}

.loading {
  background: rgba(33, 150, 243, 0.2);
  border: 1px solid rgba(33, 150, 243, 0.4);
  color: #ffffff;
}

.error {
  background: rgba(239, 83, 80, 0.2);
  border: 1px solid rgba(239, 83, 80, 0.4);
  color: #ffffff;
}

.no-items {
  text-align: center;
  padding: 2rem;
  color: rgba(255, 255, 255, 0.7);
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
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
}

.category-item:hover {
  background: rgba(255, 255, 255, 0.35);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

.category-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.category-info strong {
  color: #ffffff;
  font-size: 1rem;
}

.category-desc {
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.9);
}

.category-order {
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.7);
}

.category-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-edit,
.btn-delete {
  padding: 0.5rem 0.75rem;
  border: none;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

.btn-edit {
  background: rgba(86, 145, 196, 0.8);
  color: white;
}

.btn-edit:hover {
  background: rgba(74, 123, 167, 0.9);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.btn-delete {
  background: rgba(231, 76, 60, 0.8);
  color: white;
}

.btn-delete:hover {
  background: rgba(192, 57, 43, 0.9);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}
</style>
