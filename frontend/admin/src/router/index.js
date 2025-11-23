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
    path: '/merchant-login',
    name: 'MerchantLogin',
    beforeEnter() {
      window.location.href = 'http://localhost:5174'
    }
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
        meta: { title: '数据概览', icon: 'House', role: 'all' }
      },
      {
        path: 'order',
        name: 'Order',
        component: () => import('@/views/order/index.vue'),
        meta: { title: '订单管理', icon: 'List', role: 'merchant' }
      },
      {
        path: 'food',
        name: 'Food',
        component: () => import('@/views/food/index.vue'),
        meta: { title: '菜品管理', icon: 'Food', role: 'merchant' }
      },
      {
        path: 'category',
        name: 'Category',
        component: () => import('@/views/category/index.vue'),
        meta: { title: '分类管理', icon: 'Menu', role: 'merchant' }
      },
      {
        path: 'user',
        name: 'UserManage',
        component: () => import('@/views/user/index.vue'),
        meta: { title: '用户管理', icon: 'UserFilled', role: 'admin' }
      },
      {
        path: 'merchant',
        name: 'Merchant',
        component: () => import('@/views/merchant/index.vue'),
        meta: { title: '商家管理', icon: 'OfficeBuilding', role: 'admin' }
      },
      {
        path: 'merchant-application',
        name: 'MerchantApplication',
        component: () => import('@/views/merchant-application/index.vue'),
        meta: { title: '入驻审核', icon: 'Document', role: 'admin' }
      },
      {
        path: 'canteen',
        name: 'Canteen',
        component: () => import('@/views/canteen/index.vue'),
        meta: { title: '食堂管理', icon: 'Shop', role: 'admin' }
      },
      {
        path: 'announcement',
        name: 'Announcement',
        component: () => import('@/views/announcement/index.vue'),
        meta: { title: '公告管理', icon: 'BellFilled', role: 'merchant' }
      },
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('@/views/statistics/index.vue'),
        meta: { title: '数据统计', icon: 'DataAnalysis', role: 'admin' }
      },
      {
        path: 'system',
        name: 'System',
        component: () => import('@/views/system/index.vue'),
        meta: { title: '系统设置', icon: 'Setting', role: 'admin' }
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

