<template>
  <Transition name="dialog">
    <div v-if="show" class="confirm-overlay" @click="handleCancel">
      <div class="confirm-dialog" @click.stop>
        <div class="confirm-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>
        </div>
        <h2>{{ title }}</h2>
        <p>{{ message }}</p>
        <div class="confirm-actions">
          <button @click="handleCancel" class="btn-cancel">{{ cancelText }}</button>
          <button @click="handleConfirm" class="btn-confirm">{{ confirmText }}</button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { ref } from 'vue';

interface ConfirmDialogProps {
  title?: string;
  message?: string;
  confirmText?: string;
  cancelText?: string;
}

withDefaults(defineProps<ConfirmDialogProps>(), {
  title: 'Confirm Action',
  message: 'Are you sure you want to proceed?',
  confirmText: 'Confirm',
  cancelText: 'Cancel'
});

const show = ref(false);
let resolvePromise: ((value: boolean) => void) | null = null;

const open = (): Promise<boolean> => {
  show.value = true;
  return new Promise((resolve) => {
    resolvePromise = resolve;
  });
};

const handleConfirm = () => {
  show.value = false;
  if (resolvePromise) {
    resolvePromise(true);
    resolvePromise = null;
  }
};

const handleCancel = () => {
  show.value = false;
  if (resolvePromise) {
    resolvePromise(false);
    resolvePromise = null;
  }
};

defineExpose({
  open
});
</script>

<style scoped>
.confirm-overlay {
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
  z-index: 3000;
  padding: 1rem;
}

.confirm-dialog {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 450px;
  width: 100%;
  overflow: hidden;
  border: 2px solid rgba(86, 145, 196, 0.3);
  text-align: center;
  padding: 2.5rem 2rem 2rem;
}

.confirm-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  margin: 0 auto 1.5rem;
  background: linear-gradient(135deg, #5691c4 0%, #3d6f9e 100%);
  border-radius: 50%;
  color: white;
  animation: scaleIn 0.3s ease-out;
}

@keyframes scaleIn {
  from {
    transform: scale(0);
  }
  to {
    transform: scale(1);
  }
}

.confirm-dialog h2 {
  margin: 0 0 1rem 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: #3d6f9e;
}

.confirm-dialog p {
  margin: 0 0 2rem 0;
  font-size: 1rem;
  color: #666;
  line-height: 1.6;
}

.confirm-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
}

.btn-cancel,
.btn-confirm {
  padding: 0.875rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  min-width: 120px;
}

.btn-cancel {
  background: white;
  color: #666;
  border: 2px solid #e0e0e0;
}

.btn-cancel:hover {
  background: #f5f5f5;
  border-color: #ccc;
  transform: translateY(-2px);
}

.btn-confirm {
  background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
  color: white;
}

.btn-confirm:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(231, 76, 60, 0.4);
}

.dialog-enter-active {
  animation: dialogFadeIn 0.2s ease-out;
}

.dialog-leave-active {
  animation: dialogFadeOut 0.15s ease-in;
}

@keyframes dialogFadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes dialogFadeOut {
  from {
    opacity: 1;
  }
  to {
    opacity: 0;
  }
}

.dialog-enter-active .confirm-dialog {
  animation: dialogSlideIn 0.3s ease-out;
}

.dialog-leave-active .confirm-dialog {
  animation: dialogSlideOut 0.2s ease-in;
}

@keyframes dialogSlideIn {
  from {
    transform: translateY(-30px) scale(0.95);
    opacity: 0;
  }
  to {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
}

@keyframes dialogSlideOut {
  from {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
  to {
    transform: translateY(-20px) scale(0.95);
    opacity: 0;
  }
}

@media (max-width: 640px) {
  .confirm-dialog {
    padding: 2rem 1.5rem 1.5rem;
  }

  .confirm-icon {
    width: 64px;
    height: 64px;
    margin-bottom: 1rem;
  }

  .confirm-icon svg {
    width: 32px;
    height: 32px;
  }

  .confirm-dialog h2 {
    font-size: 1.25rem;
  }

  .confirm-dialog p {
    font-size: 0.95rem;
    margin-bottom: 1.5rem;
  }

  .confirm-actions {
    flex-direction: column-reverse;
  }

  .btn-cancel,
  .btn-confirm {
    width: 100%;
    min-width: unset;
  }
}
</style>
