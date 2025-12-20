<template>
  <div class="admin-panel">
    <div class="admin-header">
      <button @click="$emit('close')" class="back-btn">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="19" y1="12" x2="5" y2="12"></line>
          <polyline points="12 19 5 12 12 5"></polyline>
        </svg>
        Back to Expenses
      </button>
      <h1>Admin Panel</h1>
    </div>

    <div class="admin-tabs">
      <button
        :class="{ active: activeTab === 'categories' }"
        @click="activeTab = 'categories'"
      >
        Categories
      </button>
      <button
        :class="{ active: activeTab === 'documents' }"
        @click="activeTab = 'documents'"
      >
        Documents
      </button>
    </div>

    <div class="admin-content">
      <CategoryManager v-if="activeTab === 'categories'" @updated="$emit('updated')" />
      <DocumentManager v-else @updated="$emit('updated')" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import CategoryManager from './CategoryManager.vue';
import DocumentManager from './DocumentManager.vue';

defineEmits<{
  close: [];
  updated: [];
}>();

const activeTab = ref<'categories' | 'documents'>('categories');
</script>

<style scoped>
.admin-panel {
  min-height: 100vh;
  padding: 2rem;
}

.admin-header {
  margin-bottom: 2rem;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto 2rem;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  margin-bottom: 1.5rem;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.admin-header h1 {
  font-size: 3rem;
  color: white;
  margin: 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.admin-tabs {
  max-width: 1400px;
  width: 100%;
  margin: 0 auto 2rem;
  display: flex;
  gap: 1rem;
  padding: 0;
}

.admin-tabs button {
  padding: 0.75rem 1.5rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  color: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.admin-tabs button.active {
  background: rgba(255, 255, 255, 0.3);
  color: white;
  border-color: rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.admin-tabs button:hover:not(.active) {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-2px);
}

.admin-content {
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
}

@media (max-width: 768px) {
  .admin-panel {
    padding: 1rem;
  }

  .admin-header h1 {
    font-size: 2rem;
  }

  .admin-tabs {
    flex-direction: column;
  }

  .admin-tabs button {
    width: 100%;
  }
}
</style>
