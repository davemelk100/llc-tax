<template>
  <div class="expense-card">
    <div class="card-header">
      <div class="header-content">
        <div>
          <h2>{{ category.name }}</h2>
          <p v-if="category.description" class="description">{{ category.description }}</p>
        </div>
        <button @click="$emit('add-document', category)" class="add-btn" title="Add expense">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
        </button>
      </div>
    </div>
    <div class="card-body">
      <div v-if="documents.length === 0" class="no-documents">
        No documents yet
      </div>
      <div v-else class="documents-list">
        <div v-for="doc in documents" :key="doc.id" class="document-wrapper">
          <div class="document-item">
            <div class="document-info">
              <h3>{{ doc.title }}</h3>
            </div>
            <span v-if="doc.amount" class="doc-amount">${{ doc.amount.toFixed(2) }}</span>
            <div class="icon-actions">
              <button
                v-if="getAttachments(doc.id).length > 0"
                @click="toggleExpand(doc.id)"
                class="icon-btn"
                :title="isExpanded(doc.id) ? 'Hide attachments' : 'Show attachments'"
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"></path>
                </svg>
                <span class="attachment-count">{{ getAttachments(doc.id).length }}</span>
              </button>
              <button @click="$emit('edit-document', doc)" class="icon-btn" title="Edit">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
                </svg>
              </button>
            </div>
          </div>
          <div v-if="isExpanded(doc.id)" class="attachments-list">
            <div v-for="attachment in getAttachments(doc.id)" :key="attachment.id" class="attachment-item">
              <div class="attachment-name">{{ attachment.file_name }}</div>
              <div class="attachment-actions">
                <a :href="attachment.url" target="_blank" rel="noopener noreferrer" class="icon-btn-small" title="Open">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
                    <polyline points="15 3 21 3 21 9"></polyline>
                    <line x1="10" y1="14" x2="21" y2="3"></line>
                  </svg>
                </a>
                <a :href="attachment.url" :download="attachment.file_name" class="icon-btn-small" title="Download">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
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
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import type { ExpenseCategory, ExpenseDocument, DocumentAttachment } from '../composables/useSupabase';
import { useSupabase } from '../composables/useSupabase';

const props = defineProps<{
  category: ExpenseCategory;
  documents: ExpenseDocument[];
}>();

const supabase = useSupabase();
const attachmentsMap = ref<Record<string, DocumentAttachment[]>>({});
const expandedDocuments = ref<Set<string>>(new Set());

const loadAttachments = async () => {
  for (const doc of props.documents) {
    try {
      const attachments = await supabase.getAttachments(doc.id);
      attachmentsMap.value[doc.id] = attachments;
    } catch (error) {
      console.error('Failed to load attachments for document', doc.id, error);
    }
  }
};

const toggleExpand = (docId: string) => {
  if (expandedDocuments.value.has(docId)) {
    expandedDocuments.value.delete(docId);
  } else {
    expandedDocuments.value.add(docId);
  }
};

const isExpanded = (docId: string) => {
  return expandedDocuments.value.has(docId);
};

const getAttachments = (docId: string): DocumentAttachment[] => {
  return attachmentsMap.value[docId] || [];
};

onMounted(() => {
  loadAttachments();
});
</script>

<style scoped>
.expense-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 16px;
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
  padding: 1.5rem 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  overflow: hidden;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  position: relative;
  z-index: 1;
  padding: 0 1.5rem;
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
  color: #ffffff;
  font-style: italic;
}

.documents-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.document-wrapper {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.document-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.25rem 1rem;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
}

.document-item:hover {
  background: rgba(255, 255, 255, 0.35);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

.attachments-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding-left: 1rem;
  margin-top: 0.5rem;
}

.attachment-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0.75rem;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 8px;
  transition: all 0.2s ease;
}

.attachment-item:hover {
  background: rgba(255, 255, 255, 0.25);
}

.attachment-name {
  flex: 1;
  font-size: 14px;
  color: #000000;
  font-weight: 300;
}

.attachment-actions {
  display: flex;
  gap: 0.5rem;
}

.attachment-count {
  position: absolute;
  top: -4px;
  right: -4px;
  background: rgba(74, 139, 184, 1);
  color: white;
  font-size: 10px;
  font-weight: 600;
  padding: 2px 5px;
  border-radius: 10px;
  min-width: 16px;
  text-align: center;
}

.icon-btn {
  position: relative;
}

.icon-btn-small {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem;
  background: transparent;
  color: #000000;
  text-decoration: none;
  border-radius: 6px;
  border: none;
  transition: all 0.2s ease;
  cursor: pointer;
}

.icon-btn-small:hover {
  color: rgba(74, 139, 184, 1);
  transform: translateY(-2px);
}

.document-info {
  flex: 1;
}

.document-info h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 300;
  color: #000000;
  line-height: 1.3;
}

.doc-amount {
  font-weight: 700;
  font-size: 18px;
  color: #000000;
  margin-right: 1rem;
  white-space: nowrap;
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
  background: transparent;
  color: #000000;
  text-decoration: none;
  border-radius: 8px;
  border: none;
  transition: all 0.2s ease;
  cursor: pointer;
}

.icon-btn:hover {
  color: rgba(74, 139, 184, 1);
  transform: translateY(-2px);
}

.add-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  padding: 0;
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: #ffffff;
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.add-btn:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

@media (max-width: 640px) {
  .card-header {
    padding: 1rem 0;
  }

  .header-content {
    padding: 0 1rem;
  }

  .card-header h2 {
    font-size: 1.25rem;
  }

  .description {
    font-size: 0.85rem;
  }

  .card-body {
    padding: 1rem;
  }

  .no-documents {
    padding: 1.5rem;
    font-size: 0.9rem;
  }

  .document-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
    padding: 1rem;
  }

  .doc-amount {
    margin-right: 0;
    align-self: flex-start;
  }

  .icon-actions {
    width: 100%;
    justify-content: flex-start;
  }

  .icon-btn {
    padding: 0.5rem;
  }
}
</style>
