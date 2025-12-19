<template>
  <div class="expense-card">
    <div class="card-header">
      <h2>{{ category.name }}</h2>
      <p v-if="category.description" class="description">{{ category.description }}</p>
    </div>
    <div class="card-body">
      <div v-if="documents.length === 0" class="no-documents">
        No documents yet
      </div>
      <div v-else class="documents-list">
        <div v-for="doc in documents" :key="doc.id" class="document-item">
          <div class="document-info">
            <h3>{{ doc.title }}</h3>
            <p v-if="doc.description" class="doc-description">{{ doc.description }}</p>
            <div class="doc-meta">
              <span v-if="doc.amount" class="doc-amount">${{ doc.amount.toFixed(2) }}</span>
              <span v-if="doc.amount" class="doc-separator">•</span>
              <span class="doc-date">{{ formatDate(doc.date) }}</span>
            </div>
          </div>
          <div class="icon-actions">
            <a :href="doc.url" target="_blank" rel="noopener noreferrer" class="icon-btn" title="Open in new window">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
                <polyline points="15 3 21 3 21 9"></polyline>
                <line x1="10" y1="14" x2="21" y2="3"></line>
              </svg>
            </a>
            <a :href="doc.url" :download="doc.title" class="icon-btn" title="Download">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
              </svg>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { ExpenseCategory, ExpenseDocument } from '../composables/useSupabase';

defineProps<{
  category: ExpenseCategory;
  documents: ExpenseDocument[];
}>();

const formatDate = (dateString: string): string => {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
};
</script>

<style scoped>
.expense-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1),
              inset 0 1px 0 rgba(255, 255, 255, 0.5);
  overflow: hidden;
  position: relative;
}

.card-header {
  background: linear-gradient(135deg,
    rgba(74, 139, 184, 0.4) 0%,
    rgba(61, 111, 158, 0.4) 100%
  );
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: #000000;
  padding: 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  overflow: hidden;
}

.card-header::after {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle,
    rgba(255, 255, 255, 0.1) 0%,
    transparent 70%
  );
  animation: liquidMove 8s ease-in-out infinite;
}

@keyframes liquidMove {
  0%, 100% {
    transform: translate(0, 0) scale(1);
  }
  33% {
    transform: translate(-10%, -10%) scale(1.1);
  }
  66% {
    transform: translate(10%, 10%) scale(0.9);
  }
}

.card-header h2 {
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
  font-weight: 600;
  position: relative;
  z-index: 1;
  color: #ffffff;
}

.description {
  margin: 0;
  opacity: 0.95;
  font-size: 0.9rem;
  position: relative;
  z-index: 1;
  color: #ffffff;
}

.card-body {
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.05);
}

.no-documents {
  text-align: center;
  padding: 2rem;
  color: #000000;
  font-style: italic;
}

.documents-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.document-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
}

.document-item:hover {
  background: rgba(255, 255, 255, 0.35);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

.document-info {
  flex: 1;
}

.document-info h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #000000;
  line-height: 1.3;
}

.doc-description {
  margin: 0 0 0.75rem 0;
  font-size: 0.95rem;
  color: rgba(0, 0, 0, 0.75);
  line-height: 1.5;
}

.doc-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.9rem;
  color: rgba(0, 0, 0, 0.7);
}

.doc-amount {
  font-weight: 700;
  font-size: 1.1rem;
  color: #000000;
}

.doc-separator {
  color: rgba(0, 0, 0, 0.4);
  font-weight: 700;
}

.icon-actions {
  display: flex;
  gap: 0.5rem;
}

.icon-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.65rem;
  background: rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: #000000;
  text-decoration: none;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.4);
  transition: all 0.2s ease;
  cursor: pointer;
}

.icon-btn:hover {
  background: rgba(74, 139, 184, 0.5);
  color: #ffffff;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
</style>
