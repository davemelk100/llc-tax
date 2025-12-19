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
              <span class="doc-date">{{ formatDate(doc.date) }}</span>
            </div>
          </div>
          <a :href="doc.url" target="_blank" rel="noopener noreferrer" class="view-link">
            {{ doc.document_type === 'pdf' ? 'View PDF' : 'Open Link' }}
          </a>
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
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.expense-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg,
    transparent,
    rgba(255, 255, 255, 0.2),
    transparent
  );
  transition: left 0.6s ease;
}

.expense-card:hover::before {
  left: 100%;
}

.expense-card:hover {
  transform: translateY(-4px) scale(1.01);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15),
              inset 0 1px 0 rgba(255, 255, 255, 0.6);
  border-color: rgba(255, 255, 255, 0.4);
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
  padding: 1rem;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.document-item:hover {
  background: rgba(255, 255, 255, 0.35);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateX(4px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

.document-info {
  flex: 1;
}

.document-info h3 {
  margin: 0 0 0.25rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #000000;
}

.doc-description {
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
  color: #000000;
}

.doc-meta {
  display: flex;
  gap: 1rem;
  font-size: 0.85rem;
  color: #000000;
}

.doc-amount {
  font-weight: 700;
  color: #000000;
}

.view-link {
  padding: 0.65rem 1.25rem;
  background: rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: #000000;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  font-family: 'Roboto Serif', serif;
  transition: all 0.3s ease;
  white-space: nowrap;
  border: 1px solid rgba(255, 255, 255, 0.4);
}

.view-link:hover {
  background: rgba(255, 255, 255, 0.45);
  border-color: rgba(255, 255, 255, 0.6);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
</style>
