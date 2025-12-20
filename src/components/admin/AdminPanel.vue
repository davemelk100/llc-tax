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
  background: #6394c1;
  display: flex;
  flex-direction: column;
  position: relative;
}

.admin-panel::before {
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

.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 3rem;
  background: rgba(99, 148, 193, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.admin-header h1 {
  margin: 0;
  font-size: 1.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #ffffff;
  text-shadow: rgba(99, 149, 193, 0.9) -1px -1px 1px, rgba(0, 0, 0, 0.2) 1px 1px 2px;
}

.close-btn {
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.4);
  color: #ffffff;
  font-size: 0.875rem;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  transition: all 0.2s;
  text-transform: uppercase;
  font-weight: 600;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.admin-tabs {
  display: flex;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-bottom: 2px solid rgba(255, 255, 255, 0.2);
  padding: 0 3rem;
  gap: 1rem;
  position: relative;
  z-index: 10;
}

.admin-tabs button {
  padding: 1.25rem 2rem;
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  color: rgba(255, 255, 255, 0.7);
  transition: all 0.2s;
  text-transform: uppercase;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
}

.admin-tabs button.active {
  color: #ffffff;
  border-bottom-color: #ffffff;
}

.admin-tabs button:hover:not(.active) {
  color: rgba(255, 255, 255, 0.9);
}

.admin-content {
  flex: 1;
  overflow-y: auto;
  padding: 3rem;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  position: relative;
  z-index: 1;
}
</style>
