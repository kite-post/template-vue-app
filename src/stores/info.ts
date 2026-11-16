import { defineStore } from 'pinia'
import { ref } from 'vue'

interface InfoResponse {
  service: string
  version: string
}

/**
 * Показує, з якого образу піднявся бекенд. Справжні стори застосунку приходять
 * на місце цього; він тут, щоб у шаблоні вже був приклад виклику через шлюз.
 */
export const useInfoStore = defineStore('info', () => {
  const service = ref('')
  const version = ref('')
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function load(): Promise<void> {
    loading.value = true
    error.value = null
    try {
      const response = await fetch('/api/v1/info')
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      const body = (await response.json()) as InfoResponse
      service.value = body.service
      version.value = body.version
    } catch (cause) {
      error.value = cause instanceof Error ? cause.message : 'unknown'
    } finally {
      loading.value = false
    }
  }

  return { service, version, loading, error, load }
})
