<template>
  <div v-if="isOpen" class="modal-overlay" @click="close">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>Demo Mode</h2>
        <button @click="close" class="close-btn">&times;</button>
      </div>
      <div class="modal-body">
        <div class="icon-container">
          <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="16" x2="12" y2="12"></line>
            <line x1="12" y1="8" x2="12.01" y2="8"></line>
          </svg>
        </div>
        <p class="message">{{ message }}</p>
      </div>
      <div class="modal-footer">
        <button @click="close" class="ok-btn">OK</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const isOpen = ref(false);
const message = ref('');

const open = (msg: string) => {
  message.value = msg;
  isOpen.value = true;
};

const close = () => {
  isOpen.value = false;
  message.value = '';
};

defineExpose({ open, close });
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 500px;
  width: 100%;
  border: 2px solid rgba(86, 145, 196, 0.3);
  display: flex;
  flex-direction: column;
}

.modal-header {
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
  border-radius: 16px 16px 0 0;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: white;
}

.close-btn {
  background: transparent;
  border: none;
  font-size: 2rem;
  color: white;
  cursor: pointer;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background 0.2s;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.modal-body {
  padding: 2rem;
  text-align: center;
}

.icon-container {
  display: flex;
  justify-content: center;
  margin-bottom: 1.5rem;
  color: #5691c4;
}

.message {
  font-size: 1.125rem;
  color: #333;
  line-height: 1.6;
  margin: 0;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e0e0e0;
  display: flex;
  justify-content: center;
  background: #f5f5f5;
  border-radius: 0 0 16px 16px;
}

.ok-btn {
  padding: 0.625rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  color: white;
}

.ok-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(86, 145, 196, 0.4);
}

@media (max-width: 640px) {
  .modal-content {
    max-width: calc(100% - 2rem);
  }

  .modal-header {
    padding: 1rem 1.25rem;
  }

  .modal-header h2 {
    font-size: 1.125rem;
  }

  .modal-body {
    padding: 1.5rem 1.25rem;
  }

  .icon-container svg {
    width: 48px;
    height: 48px;
  }

  .message {
    font-size: 1rem;
  }

  .modal-footer {
    padding: 1rem 1.25rem;
  }
}
</style>
