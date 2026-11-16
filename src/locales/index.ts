import { createI18n } from 'vue-i18n'

import { en } from './en'
import { uk } from './uk'

export const i18n = createI18n({
  legacy: false,
  locale: 'uk',
  fallbackLocale: 'uk',
  messages: { uk, en },
})
