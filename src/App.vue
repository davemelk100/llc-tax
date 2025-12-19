<template>
  <div class="app">
    <header class="app-header">
      <div class="header-content">
        <h1>Melkonian Industries LLC</h1>
        <p class="subtitle">Tax Documentation & Expense Tracking</p>
      </div>
      <button @click="showAdmin = true" class="admin-btn">
        Admin Panel
      </button>
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
        />
      </div>
    </main>

    <footer class="app-footer">
      <p>&copy; {{ currentYear }} Melkonian Industries LLC. All rights reserved.</p>
    </footer>

    <Transition name="slide">
      <AdminPanel
        v-if="showAdmin"
        @close="showAdmin = false"
        @updated="loadData"
      />
    </Transition>

    <div
      v-if="showAdmin"
      class="overlay"
      @click="showAdmin = false"
    ></div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import ExpenseCard from './components/ExpenseCard.vue';
import AdminPanel from './components/admin/AdminPanel.vue';
import { useSupabase, type ExpenseCategory, type ExpenseDocument } from './composables/useSupabase';

const supabase = useSupabase();
const categories = ref<ExpenseCategory[]>([]);
const documents = ref<ExpenseDocument[]>([]);
const loading = ref(false);
const error = ref('');
const showAdmin = ref(false);

const currentYear = new Date().getFullYear();

const sortedCategories = computed(() => {
  return [...categories.value].sort((a, b) => a.display_order - b.display_order);
});

const getDocumentsForCategory = (categoryId: string): ExpenseDocument[] => {
  return documents.value.filter((doc) => doc.category_id === categoryId);
};

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

onMounted(() => {
  loadData();
});
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Roboto Serif', serif;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
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
  background: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 2rem;
}

.header-content h1 {
  margin: 0;
  font-size: 2rem;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.subtitle {
  margin: 0.5rem 0 0 0;
  color: #6c757d;
  font-size: 1rem;
}

.admin-btn {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto Serif', serif;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  white-space: nowrap;
}

.admin-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(86, 145, 196, 0.4);
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
  font-family: 'Roboto Serif', serif;
  cursor: pointer;
  transition: transform 0.2s;
}

.retry-btn:hover {
  transform: translateY(-2px);
}

.expenses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 2rem;
}

.app-footer {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  color: white;
  text-align: center;
  padding: 1.5rem;
  margin-top: 2rem;
}

.overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

.slide-enter-active,
.slide-leave-active {
  transition: transform 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateX(100%);
}

@media (max-width: 768px) {
  .app-header {
    flex-direction: column;
    text-align: center;
  }

  .expenses-grid {
    grid-template-columns: 1fr;
  }

  .admin-panel {
    width: 100vw;
  }
}
</style>
