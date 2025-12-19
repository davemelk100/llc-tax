<template>
  <div class="admin-panel">
    <div class="admin-header">
      <h1>Admin Panel</h1>
      <button @click="$emit('close')" class="close-btn">✕</button>
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
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
}

.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 3rem;
  background: linear-gradient(135deg, #4a8bb8 0%, #3d6f9e 100%);
  color: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.admin-header h1 {
  margin: 0;
  font-size: 1.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid white;
  color: white;
  font-size: 0.875rem;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  transition: all 0.2s;
  text-transform: uppercase;
  font-weight: 600;
}

.close-btn:hover {
  background: white;
  color: #3d6f9e;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.admin-tabs {
  display: flex;
  background: white;
  border-bottom: 2px solid #dee2e6;
  padding: 0 3rem;
  gap: 1rem;
}

.admin-tabs button {
  padding: 1.25rem 2rem;
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  color: #6c757d;
  transition: all 0.2s;
  text-transform: uppercase;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
}

.admin-tabs button.active {
  color: #5691c4;
  border-bottom-color: #5691c4;
}

.admin-tabs button:hover:not(.active) {
  color: #495057;
}

.admin-content {
  flex: 1;
  overflow-y: auto;
  padding: 3rem;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
}
</style>
