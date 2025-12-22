<template>
  <router-view />
</template>

<script setup lang="ts">
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
</style>
