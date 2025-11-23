import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/layout/index.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue')
  },
  {
    path: '/merchant-register',
    name: 'MerchantRegister',
    component: () => import('@/views/merchant-register/index.vue')
  },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '数据概览', icon: 'House' }
      },
      {
        path: 'order',
        name: 'Order',
        component: () => import('@/views/order/index.vue'),
        meta: { title: '订单管理', icon: 'List' }
      },
      {
        path: 'food',
        name: 'Food',
        component: () => import('@/views/food/index.vue'),
        meta: { title: '菜品管理', icon: 'Food' }
      },
      {
        path: 'category',
        name: 'Category',
        component: () => import('@/views/category/index.vue'),
        meta: { title: '分类管理', icon: 'Menu' }
      },
      {
        path: 'announcement',
        name: 'Announcement',
        component: () => import('@/views/announcement/index.vue'),
        meta: { title: '公告管理', icon: 'BellFilled' }
      },
      {
        path: 'settings',
        name: 'MerchantSettings',
        component: () => import('@/views/merchant-settings/index.vue'),
        meta: { title: '店铺设置', icon: 'Setting' }
      },
      {
        path: 'system',
        name: 'SystemSettings',
        component: () => import('@/views/system-settings/index.vue'),
        meta: { title: '系统设置', icon: 'Tools' }
      },
      {
        path: 'review',
        name: 'ReviewManagement',
        component: () => import('@/views/review/index.vue'),
        meta: { title: '评价管理', icon: 'ChatDotRound' }
      },
      {
        path: 'message',
        name: 'MessageCenter',
        component: () => import('@/views/message/index.vue'),
        meta: { title: '消息中心', icon: 'ChatLineRound' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const userInfo = localStorage.getItem('userInfo')
  const publicPages = ['/login', '/merchant-register']
  if (!publicPages.includes(to.path) && !userInfo) {
    next('/login')
  } else {
    next()
  }
})

export default router
