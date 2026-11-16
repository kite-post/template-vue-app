import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    // Ліниве завантаження: кожна сторінка — окремий чанк, тож перший екран
    // не тягне за собою весь застосунок.
    component: () => import('../views/HomeView.vue'),
  },
]

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})
