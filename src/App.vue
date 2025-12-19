<template>
  <div class="app">
    <div v-if="!isAuthenticated" class="passcode-screen">
      <div class="passcode-card">
        <h2>Enter Passcode</h2>
        <input
          v-model="passcodeInput"
          type="password"
          placeholder="Enter passcode"
          @keyup.enter="checkPasscode"
          class="passcode-input"
          autofocus
        />
        <p v-if="passcodeError" class="passcode-error">{{ passcodeError }}</p>
        <button @click="checkPasscode" class="passcode-btn">Submit</button>
      </div>
    </div>

    <template v-else>
      <AdminPanel
        v-if="showAdmin"
        @close="showAdmin = false"
        @updated="loadData"
      />

      <template v-else>
        <header class="app-header">
          <div class="header-content">
            <h1>Melkonian Industries LLC</h1>
          </div>
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

        <div v-if="!loading && !error" class="totals-card">
          <div class="totals-content">
            <h2>Total Expenses</h2>
            <div class="totals-amount">${{ totalAmount.toFixed(2) }}</div>
            <div class="totals-meta">
              <span>{{ totalDocuments }} {{ totalDocuments === 1 ? 'document' : 'documents' }}</span>
              <span class="separator">•</span>
              <span>{{ categories.length }} {{ categories.length === 1 ? 'category' : 'categories' }}</span>
            </div>
          </div>
        </div>
      </main>

      <footer class="app-footer">
        <p>&copy; {{ currentYear }} Melkonian Industries LLC. All rights reserved.</p>
      </footer>

        <a href="#" @click.prevent="showAdmin = true" class="admin-link">A</a>
      </template>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import ExpenseCard from './components/ExpenseCard.vue';
import AdminPanel from './components/admin/AdminPanel.vue';
import { useSupabase, type ExpenseCategory, type ExpenseDocument } from './composables/useSupabase';

const CORRECT_PASSCODE = '6231839';
const AUTH_KEY = 'melkonian_auth';

const supabase = useSupabase();
const categories = ref<ExpenseCategory[]>([]);
const documents = ref<ExpenseDocument[]>([]);
const loading = ref(false);
const error = ref('');
const showAdmin = ref(false);
const isAuthenticated = ref(false);
const passcodeInput = ref('');
const passcodeError = ref('');

const currentYear = new Date().getFullYear();

const checkExistingAuth = () => {
  const authData = localStorage.getItem(AUTH_KEY);
  if (authData) {
    const authDate = new Date(authData);
    const today = new Date();
    if (
      authDate.getFullYear() === today.getFullYear() &&
      authDate.getMonth() === today.getMonth() &&
      authDate.getDate() === today.getDate()
    ) {
      isAuthenticated.value = true;
      return;
    }
  }
  isAuthenticated.value = false;
};

const checkPasscode = () => {
  if (passcodeInput.value === CORRECT_PASSCODE) {
    isAuthenticated.value = true;
    passcodeError.value = '';
    localStorage.setItem(AUTH_KEY, new Date().toISOString());
    loadData();
  } else {
    passcodeError.value = 'Incorrect passcode';
    passcodeInput.value = '';
  }
};

const sortedCategories = computed(() => {
  return [...categories.value].sort((a, b) => a.display_order - b.display_order);
});

const getDocumentsForCategory = (categoryId: string): ExpenseDocument[] => {
  return documents.value.filter((doc) => doc.category_id === categoryId);
};

const totalAmount = computed(() => {
  return documents.value.reduce((sum, doc) => sum + (doc.amount || 0), 0);
});

const totalDocuments = computed(() => {
  return documents.value.length;
});

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
  checkExistingAuth();
  if (isAuthenticated.value) {
    loadData();
  }
});
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Roboto', sans-serif;
  background: #6394c1;
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
  position: sticky;
  top: 0;
  background: #6394c1;
  opacity: 1;
  padding: 0.5rem;
  z-index: 100;
}

.header-content {
  text-align: center;
}

.header-content h1 {
  display: inline-block;
  margin: 0;
  font-size: 48px;
  color: #6395c1;
  text-shadow: rgba(99, 149, 193, 0.9) -1px -1px 1px, rgba(0, 0, 0, 0.2) 1px 1px 2px, rgba(99, 149, 193, 0.5) 0px 0px 1px;
  text-transform: uppercase;
}

.admin-link {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  z-index: 1000;
  transition: color 0.2s;
}

.admin-link:hover {
  color: rgba(255, 255, 255, 0.9);
}

.passcode-screen {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.passcode-card {
  background: white;
  border-radius: 16px;
  padding: 3rem;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 400px;
  text-align: center;
}

.passcode-card h2 {
  margin-bottom: 2rem;
  color: #3d6f9e;
  font-size: 1.75rem;
}

.passcode-input {
  width: 100%;
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1.125rem;
  font-family: 'Roboto', sans-serif;
  transition: border-color 0.2s;
  text-align: center;
  letter-spacing: 0.25rem;
}

.passcode-input:focus {
  outline: none;
  border-color: #5691c4;
}

.passcode-error {
  color: #d32f2f;
  margin-top: 1rem;
  font-size: 0.875rem;
}

.passcode-btn {
  width: 100%;
  margin-top: 1.5rem;
  padding: 1rem;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.125rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  text-transform: uppercase;
}

.passcode-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(86, 145, 196, 0.4);
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
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: transform 0.2s;
  text-transform: uppercase;
}

.retry-btn:hover {
  transform: translateY(-2px);
}

.expenses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 2rem;
}

.totals-card {
  margin-top: 3rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  border: 2px solid rgba(255, 255, 255, 0.4);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15),
              inset 0 1px 0 rgba(255, 255, 255, 0.6);
  overflow: hidden;
}

.totals-content {
  padding: 2.5rem;
  text-align: center;
  position: relative;
}

.totals-content h2 {
  margin: 0 0 1.5rem 0;
  font-size: 1.75rem;
  font-weight: 600;
  color: #ffffff;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.totals-amount {
  font-size: 3.5rem;
  font-weight: 700;
  color: #ffffff;
  margin-bottom: 1rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.totals-meta {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

.totals-meta .separator {
  color: rgba(255, 255, 255, 0.5);
  font-weight: 700;
}

.app-footer {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  color: white;
  text-align: center;
  padding: 1.5rem;
  margin-top: 2rem;
}

@media (max-width: 768px) {
  .expenses-grid {
    grid-template-columns: 1fr;
  }
}
</style>
