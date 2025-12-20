<template>
  <div class="profile-page">
    <div class="profile-header">
      <button @click="$emit('close')" class="back-btn">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="19" y1="12" x2="5" y2="12"></line>
          <polyline points="12 19 5 12 12 5"></polyline>
        </svg>
        Back to Expenses
      </button>
      <div class="title-row">
        <h1>Company Profile</h1>
        <button @click="$emit('open-admin')" class="admin-btn" title="Admin Panel">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
          </svg>
        </button>
      </div>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Loading profile...</p>
    </div>

    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <button @click="loadProfile" class="retry-btn">Retry</button>
    </div>

    <div v-else-if="profile" class="profile-content">
      <div class="profile-card">
        <div class="card-section">
          <h2>Company Information</h2>
          <div class="info-grid">
            <div class="info-item">
              <label>Company Name</label>
              <div v-if="!editing" class="info-value">{{ profile.company_name }}</div>
              <input v-else v-model="editForm.company_name" type="text" class="form-input" />
            </div>
            <div class="info-item">
              <label>Filing Number</label>
              <div v-if="!editing" class="info-value">{{ profile.filing_number }}</div>
              <input v-else v-model="editForm.filing_number" type="text" class="form-input" />
            </div>
            <div class="info-item full-width">
              <label>Address</label>
              <div v-if="!editing" class="info-value">{{ profile.address }}</div>
              <input v-else v-model="editForm.address" type="text" class="form-input" />
            </div>
          </div>
        </div>

        <div class="card-section">
          <h2>Contact Details</h2>
          <div class="info-grid">
            <div class="info-item">
              <label>Phone</label>
              <div v-if="!editing" class="info-value">{{ profile.phone || 'Not provided' }}</div>
              <input v-else v-model="editForm.phone" type="tel" class="form-input" />
            </div>
            <div class="info-item">
              <label>Email</label>
              <div v-if="!editing" class="info-value">{{ profile.email || 'Not provided' }}</div>
              <input v-else v-model="editForm.email" type="email" class="form-input" />
            </div>
            <div class="info-item full-width">
              <label>Website</label>
              <div v-if="!editing" class="info-value">{{ profile.website || 'Not provided' }}</div>
              <input v-else v-model="editForm.website" type="url" class="form-input" />
            </div>
          </div>
        </div>

        <div class="card-section">
          <h2>Additional Information</h2>
          <div class="info-grid">
            <div class="info-item">
              <label>Formation Date</label>
              <div v-if="!editing" class="info-value">{{ profile.formation_date ? formatDate(profile.formation_date) : 'Not provided' }}</div>
              <input v-else v-model="editForm.formation_date" type="date" class="form-input" />
            </div>
            <div class="info-item">
              <label>EIN</label>
              <div v-if="!editing" class="info-value">{{ profile.ein || 'Not provided' }}</div>
              <input v-else v-model="editForm.ein" type="text" class="form-input" />
            </div>
          </div>
        </div>

        <div class="card-actions">
          <button v-if="!editing" @click="startEdit" class="edit-btn">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
            </svg>
            Edit Profile
          </button>
          <template v-else>
            <button @click="cancelEdit" class="cancel-btn">Cancel</button>
            <button @click="saveEdit" class="save-btn" :disabled="saving">
              {{ saving ? 'Saving...' : 'Save Changes' }}
            </button>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useSupabase, type CompanyProfile } from '../composables/useSupabase';

const supabase = useSupabase();
const profile = ref<CompanyProfile | null>(null);
const loading = ref(false);
const error = ref('');
const editing = ref(false);
const saving = ref(false);
const editForm = ref({
  company_name: '',
  filing_number: '',
  address: '',
  phone: '',
  email: '',
  website: '',
  formation_date: '',
  ein: ''
});

defineEmits(['close', 'open-admin']);

const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
};

const loadProfile = async () => {
  loading.value = true;
  error.value = '';
  try {
    profile.value = await supabase.getCompanyProfile();
  } catch (e: any) {
    error.value = e.message || 'Failed to load company profile.';
  } finally {
    loading.value = false;
  }
};

const startEdit = () => {
  if (!profile.value) return;
  editing.value = true;
  editForm.value = {
    company_name: profile.value.company_name,
    filing_number: profile.value.filing_number,
    address: profile.value.address,
    phone: profile.value.phone,
    email: profile.value.email,
    website: profile.value.website,
    formation_date: profile.value.formation_date || '',
    ein: profile.value.ein
  };
};

const cancelEdit = () => {
  editing.value = false;
  editForm.value = {
    company_name: '',
    filing_number: '',
    address: '',
    phone: '',
    email: '',
    website: '',
    formation_date: '',
    ein: ''
  };
};

const saveEdit = async () => {
  if (!profile.value) return;

  saving.value = true;
  try {
    profile.value = await supabase.updateCompanyProfile(profile.value.id, editForm.value);
    editing.value = false;
  } catch (e: any) {
    alert('Failed to update profile: ' + (e.message || 'Unknown error'));
  } finally {
    saving.value = false;
  }
};

onMounted(() => {
  loadProfile();
});
</script>

<style scoped>
.profile-page {
  min-height: 100vh;
  padding: 2rem;
}

.profile-header {
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

.title-row {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.profile-header h1 {
  font-size: 3rem;
  color: white;
  margin: 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.admin-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}

.admin-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
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

.profile-content {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
}

.profile-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1),
              inset 0 1px 0 rgba(255, 255, 255, 0.5);
  overflow: hidden;
  width: 100%;
}

.card-section {
  padding: 2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.card-section:last-of-type {
  border-bottom: none;
}

.card-section h2 {
  margin: 0 0 1.5rem 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: white;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-item.full-width {
  grid-column: 1 / -1;
}

.info-item label {
  font-size: 0.75rem;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.8);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.info-value {
  font-size: 1.125rem;
  color: white;
  padding: 0.75rem 0;
  min-height: 2.5rem;
}

.form-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  font-size: 1rem;
  font-family: 'Roboto', sans-serif;
  background: rgba(255, 255, 255, 0.9);
  transition: border-color 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: #5691c4;
}

.form-textarea {
  resize: vertical;
  font-family: 'Roboto', sans-serif;
}

.card-actions {
  padding: 1.5rem 2rem;
  background: rgba(255, 255, 255, 0.05);
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.edit-btn,
.save-btn,
.cancel-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.edit-btn {
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
}

.edit-btn:hover,
.save-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(86, 145, 196, 0.4);
}

.save-btn {
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
}

.cancel-btn {
  background: white;
  color: #666;
  border: 2px solid rgba(255, 255, 255, 0.5);
}

.cancel-btn:hover {
  background: rgba(255, 255, 255, 0.9);
  border-color: #ccc;
}

@media (max-width: 768px) {
  .profile-page {
    padding: 1rem;
  }

  .profile-header h1 {
    font-size: 2rem;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .card-section {
    padding: 1.5rem;
  }

  .card-actions {
    flex-direction: column-reverse;
  }

  .edit-btn,
  .save-btn,
  .cancel-btn {
    width: 100%;
    justify-content: center;
  }
}
</style>
