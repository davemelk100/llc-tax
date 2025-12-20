<template>
  <div class="reports-page">
    <div class="reports-header">
      <div class="header-top">
        <button @click="$emit('close')" class="back-btn">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M19 12H5M12 19l-7-7 7-7"/>
          </svg>
          Back
        </button>
        <h1>Financial Reports</h1>
      </div>
    </div>

    <div class="reports-content">
      <div class="filters-section">
        <h2>Export Options</h2>
        <div class="filter-row">
          <div class="filter-group">
            <label>Start Date</label>
            <input v-model="startDate" type="date" class="filter-input" />
          </div>
          <div class="filter-group">
            <label>End Date</label>
            <input v-model="endDate" type="date" class="filter-input" />
          </div>
          <div class="filter-group">
            <label>Category</label>
            <select v-model="selectedCategory" class="filter-input">
              <option value="">All Categories</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                {{ cat.name }}
              </option>
            </select>
          </div>
        </div>
        <div class="filter-actions">
          <button @click="clearFilters" class="clear-btn">Clear Filters</button>
          <button @click="exportToCSV" class="export-btn" :disabled="loading">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="7 10 12 15 17 10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            Export to CSV
          </button>
        </div>
      </div>

      <div v-if="loading" class="loading-section">
        <div class="spinner"></div>
        <p>Loading report data...</p>
      </div>

      <div v-else class="summary-section">
        <h2>Summary</h2>
        <div class="summary-grid">
          <div class="summary-card">
            <div class="summary-label">Total Expenses</div>
            <div class="summary-value">${{ filteredTotal.toFixed(2) }}</div>
          </div>
          <div class="summary-card">
            <div class="summary-label">Total Documents</div>
            <div class="summary-value">{{ filteredDocuments.length }}</div>
          </div>
          <div class="summary-card">
            <div class="summary-label">Date Range</div>
            <div class="summary-value small">
              {{ dateRangeDisplay }}
            </div>
          </div>
        </div>

        <div class="category-breakdown">
          <h3>Breakdown by Category</h3>
          <div class="breakdown-list">
            <div v-for="item in categoryBreakdown" :key="item.categoryId" class="breakdown-item">
              <div class="breakdown-info">
                <span class="breakdown-name">{{ item.categoryName }}</span>
                <span class="breakdown-count">{{ item.count }} {{ item.count === 1 ? 'document' : 'documents' }}</span>
              </div>
              <div class="breakdown-amount">${{ item.total.toFixed(2) }}</div>
            </div>
          </div>
        </div>
      </div>

      <div class="preview-section">
        <h2>Preview</h2>
        <div class="table-wrapper">
          <table class="preview-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Category</th>
                <th>Title</th>
                <th>Description</th>
                <th>Amount</th>
                <th>Type</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="doc in filteredDocuments" :key="doc.id">
                <td>{{ formatDate(doc.date) }}</td>
                <td>{{ getCategoryName(doc.category_id) }}</td>
                <td>{{ doc.title }}</td>
                <td>{{ doc.description || '-' }}</td>
                <td>${{ (doc.amount || 0).toFixed(2) }}</td>
                <td>{{ doc.document_type }}</td>
              </tr>
              <tr v-if="filteredDocuments.length === 0">
                <td colspan="6" class="no-data">No documents match the selected filters</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useSupabase, type ExpenseCategory, type ExpenseDocument } from '../composables/useSupabase';

defineEmits(['close']);

const supabase = useSupabase();
const categories = ref<ExpenseCategory[]>([]);
const documents = ref<ExpenseDocument[]>([]);
const loading = ref(true);

const startDate = ref('');
const endDate = ref('');
const selectedCategory = ref('');

const filteredDocuments = computed(() => {
  return documents.value.filter(doc => {
    let matches = true;

    if (startDate.value && doc.date < startDate.value) {
      matches = false;
    }

    if (endDate.value && doc.date > endDate.value) {
      matches = false;
    }

    if (selectedCategory.value && doc.category_id !== selectedCategory.value) {
      matches = false;
    }

    return matches;
  });
});

const filteredTotal = computed(() => {
  return filteredDocuments.value.reduce((sum, doc) => sum + (doc.amount || 0), 0);
});

const dateRangeDisplay = computed(() => {
  if (!filteredDocuments.value.length) return 'No data';

  const dates = filteredDocuments.value.map(d => d.date).sort();
  const earliest = formatDate(dates[0]);
  const latest = formatDate(dates[dates.length - 1]);

  if (earliest === latest) return earliest;
  return `${earliest} - ${latest}`;
});

const categoryBreakdown = computed(() => {
  const breakdown = new Map<string, { categoryName: string; categoryId: string; total: number; count: number }>();

  filteredDocuments.value.forEach(doc => {
    const existing = breakdown.get(doc.category_id);
    if (existing) {
      existing.total += doc.amount || 0;
      existing.count += 1;
    } else {
      breakdown.set(doc.category_id, {
        categoryId: doc.category_id,
        categoryName: getCategoryName(doc.category_id),
        total: doc.amount || 0,
        count: 1
      });
    }
  });

  return Array.from(breakdown.values()).sort((a, b) => b.total - a.total);
});

const getCategoryName = (categoryId: string): string => {
  const category = categories.value.find(c => c.id === categoryId);
  return category ? category.name : 'Unknown';
};

const formatDate = (dateStr: string): string => {
  if (!dateStr) return '-';
  const date = new Date(dateStr + 'T00:00:00');
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
};

const clearFilters = () => {
  startDate.value = '';
  endDate.value = '';
  selectedCategory.value = '';
};

const exportToCSV = () => {
  const headers = ['Date', 'Category', 'Title', 'Description', 'Amount', 'Document Type', 'URL'];

  const rows = filteredDocuments.value.map(doc => [
    doc.date,
    getCategoryName(doc.category_id),
    doc.title,
    doc.description || '',
    (doc.amount || 0).toFixed(2),
    doc.document_type,
    doc.url
  ]);

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => {
      const escaped = String(cell).replace(/"/g, '""');
      return escaped.includes(',') || escaped.includes('"') || escaped.includes('\n')
        ? `"${escaped}"`
        : escaped;
    }).join(','))
  ].join('\n');

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);

  const dateStr = new Date().toISOString().split('T')[0];
  const filename = `melkonian-expenses-${dateStr}.csv`;

  link.setAttribute('href', url);
  link.setAttribute('download', filename);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const loadData = async () => {
  loading.value = true;
  try {
    [categories.value, documents.value] = await Promise.all([
      supabase.getCategories(),
      supabase.getDocuments(),
    ]);

    documents.value.sort((a, b) => b.date.localeCompare(a.date));
  } catch (e: any) {
    console.error('Failed to load data:', e);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.reports-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: #6394c1;
  z-index: 1000;
  overflow-y: auto;
}

.reports-header {
  background: rgba(99, 148, 193, 0.95);
  backdrop-filter: blur(10px);
  padding: 1.5rem 2rem;
  position: sticky;
  top: 0;
  z-index: 10;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.header-top {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 500;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.reports-header h1 {
  margin: 0;
  font-size: 2rem;
  color: white;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.reports-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
}

.filters-section,
.summary-section,
.preview-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.filters-section h2,
.summary-section h2,
.preview-section h2 {
  margin: 0 0 1.5rem 0;
  color: #3d6f9e;
  font-size: 1.5rem;
  font-weight: 700;
}

.filter-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.filter-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #3d6f9e;
  font-size: 0.875rem;
  text-transform: uppercase;
}

.filter-input {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  font-family: 'Roboto', sans-serif;
  transition: border-color 0.2s;
}

.filter-input:focus {
  outline: none;
  border-color: #5691c4;
}

.filter-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

.clear-btn,
.export-btn {
  padding: 0.875rem 1.5rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.clear-btn {
  background: white;
  color: #666;
  border: 2px solid #e0e0e0;
}

.clear-btn:hover {
  background: #f5f5f5;
  border-color: #ccc;
}

.export-btn {
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
}

.export-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(86, 145, 196, 0.4);
}

.export-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: #3d6f9e;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #e0e0e0;
  border-top-color: #5691c4;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.summary-card {
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  padding: 1.5rem;
  border-radius: 12px;
  color: white;
}

.summary-label {
  font-size: 0.875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.75rem;
  opacity: 0.9;
}

.summary-value {
  font-size: 2rem;
  font-weight: 700;
}

.summary-value.small {
  font-size: 1.25rem;
}

.category-breakdown {
  margin-top: 2rem;
}

.category-breakdown h3 {
  margin: 0 0 1rem 0;
  color: #3d6f9e;
  font-size: 1.25rem;
  font-weight: 700;
}

.breakdown-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.breakdown-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #f5f5f5;
  border-radius: 8px;
  transition: background 0.2s;
}

.breakdown-item:hover {
  background: #e8e8e8;
}

.breakdown-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.breakdown-name {
  font-weight: 600;
  color: #3d6f9e;
}

.breakdown-count {
  font-size: 0.875rem;
  color: #666;
}

.breakdown-amount {
  font-size: 1.25rem;
  font-weight: 700;
  color: #3d6f9e;
}

.table-wrapper {
  overflow-x: auto;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
}

.preview-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.preview-table thead {
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
}

.preview-table th {
  padding: 1rem;
  text-align: left;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
}

.preview-table td {
  padding: 0.875rem 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.preview-table tbody tr:hover {
  background: #f5f5f5;
}

.preview-table tbody tr:last-child td {
  border-bottom: none;
}

.no-data {
  text-align: center;
  color: #999;
  font-style: italic;
  padding: 2rem !important;
}

@media (max-width: 768px) {
  .reports-content {
    padding: 1rem;
  }

  .filters-section,
  .summary-section,
  .preview-section {
    padding: 1.5rem;
  }

  .filter-row {
    grid-template-columns: 1fr;
  }

  .filter-actions {
    flex-direction: column;
  }

  .clear-btn,
  .export-btn {
    width: 100%;
    justify-content: center;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }

  .preview-table {
    font-size: 0.8rem;
  }

  .preview-table th,
  .preview-table td {
    padding: 0.5rem;
  }
}
</style>
