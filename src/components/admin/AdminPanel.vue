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
  position: fixed;
  top: 0;
  right: 0;
  width: 500px;
  height: 100vh;
  background: white;
  box-shadow: -4px 0 20px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: linear-gradient(135deg, #4a8bb8 0%, #3d6f9e 100%);
  color: white;
}

.admin-header h1 {
  margin: 0;
  font-size: 1.5rem;
}

.close-btn {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.5rem;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: background 0.2s;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.admin-tabs {
  display: flex;
  background: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.admin-tabs button {
  flex: 1;
  padding: 1rem;
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  color: #6c757d;
  transition: all 0.2s;
}

.admin-tabs button.active {
  background: white;
  color: #5691c4;
  border-bottom: 3px solid #5691c4;
}

.admin-tabs button:hover:not(.active) {
  background: #e9ecef;
}

.admin-content {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
}
</style>
