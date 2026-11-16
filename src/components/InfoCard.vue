<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

defineProps<{
  service: string
  version: string
  loading?: boolean
}>()
</script>

<template>
  <section class="card" :aria-busy="loading">
    <p v-if="loading">{{ t('app.loading') }}</p>
    <dl v-else>
      <dt>{{ t('app.service') }}</dt>
      <dd>{{ service }}</dd>
      <dt>{{ t('app.version') }}</dt>
      <dd>{{ version }}</dd>
    </dl>
  </section>
</template>

<style scoped>
.card {
  border: 1px solid #e2e5ea;
  border-radius: 0.75rem;
  padding: 1rem 1.25rem;
}

dl {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 0.25rem 1rem;
  margin: 0;
}

dt {
  color: #5b6472;
}

dd {
  margin: 0;
  font-variant-numeric: tabular-nums;
}
</style>
