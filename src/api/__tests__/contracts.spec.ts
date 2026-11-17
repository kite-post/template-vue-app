// Контракти приходять пакетом @kite-post/contracts, а не копіями схем (5.4, п. 6).
// Якщо тест падає на імпорті — проганяй make contracts.
import { describe, expect, it } from 'vitest'
import {
  createKiteClient,
  kiteEventRegistry,
  shipmentStatusValues,
  type ShipmentStatus,
} from '@kite-post/contracts'

describe('@kite-post/contracts', () => {
  it('дає типи й значення стану відправлення', () => {
    const status: ShipmentStatus = 'READY_FOR_PICKUP'
    expect(shipmentStatusValues).toContain(status)
  })

  it('знає топік події зміни стану', () => {
    expect(kiteEventRegistry['kite.shipment.status-changed.v1'].topic).toBe('shipment.events')
  })

  it('створює типізований клієнт API', () => {
    const api = createKiteClient({ baseUrl: '/api/v1' })
    expect(typeof api.GET).toBe('function')
  })
})
