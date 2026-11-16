<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<template>
  <main class="shell">
    <RouterView />
  </main>
</template>

<style scoped>
.shell {
  max-width: 48rem;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
