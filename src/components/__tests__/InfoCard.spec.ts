import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { createI18n } from 'vue-i18n'

import InfoCard from '../InfoCard.vue'
import { uk } from '../../locales/uk'

const i18n = createI18n({ legacy: false, locale: 'uk', messages: { uk } })

describe('InfoCard', () => {
  it('показує сервіс і версію', () => {
    const wrapper = mount(InfoCard, {
      props: { service: 'kite-web', version: 'v1.2.3' },
      global: { plugins: [i18n] },
    })

    expect(wrapper.text()).toContain('kite-web')
    expect(wrapper.text()).toContain('v1.2.3')
  })

  it('поки вантажиться — показує лоадер, а не дані', () => {
    const wrapper = mount(InfoCard, {
      props: { service: 'kite-web', version: 'v1.2.3', loading: true },
      global: { plugins: [i18n] },
    })

    expect(wrapper.text()).not.toContain('kite-web')
    expect(wrapper.attributes('aria-busy')).toBe('true')
  })
})
