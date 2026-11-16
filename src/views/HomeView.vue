<script setup lang="ts">
import { onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

import InfoCard from '../components/InfoCard.vue'
import { useInfoStore } from '../stores/info'

const { t } = useI18n()
const info = useInfoStore()

onMounted(() => {
  void info.load()
})
</script>

<template>
  <h1>{{ t('app.title') }}</h1>
  <p v-if="info.error" class="error">{{ t('app.error') }}</p>
  <InfoCard v-else :service="info.service" :version="info.version" :loading="info.loading" />
</template>

<style scoped>
.error {
  color: #b00020;
}
</style>
