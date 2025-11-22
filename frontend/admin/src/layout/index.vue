<template>
  <div class="layout-container">
    <el-container>
      <el-aside width="240px" class="layout-aside">
        <div class="logo-container">
          <div class="logo-icon">
            <el-icon size="24" color="#fff"><Bowl /></el-icon>
          </div>
          <h1 class="logo-text">智慧食堂系统</h1>
        </div>
        
        <el-menu
          :default-active="activeMenu"
          class="side-menu"
          :collapse="false"
          background-color="#1f2937"
          text-color="#9ca3af"
          active-text-color="#ffffff"
          router
        >
          <el-menu-item index="/dashboard">
            <el-icon><DataLine /></el-icon>
            <span>数据概览</span>
          </el-menu-item>
          
          <div class="menu-group-title">业务管理</div>
          
          <el-menu-item index="/order">
            <el-icon><List /></el-icon>
            <span>订单管理</span>
          </el-menu-item>
          
          <el-menu-item index="/food">
            <el-icon><Food /></el-icon>
            <span>菜品管理</span>
          </el-menu-item>
          
          <el-menu-item index="/category">
            <el-icon><Menu /></el-icon>
            <span>分类管理</span>
          </el-menu-item>

          <div class="menu-group-title">系统设置</div>

          <el-menu-item index="/member">
            <el-icon><User /></el-icon>
            <span>员工管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <el-container>
        <el-header class="layout-header">
          <div class="header-left">
            <div class="page-title">{{ pageTitle }}</div>
          </div>
          <div class="header-right">
            <div class="user-info">
              <el-avatar :size="32" class="user-avatar">{{ userInfo.name?.[0] || 'A' }}</el-avatar>
              <el-dropdown @command="handleCommand">
                <span class="el-dropdown-link">
                  {{ userInfo.name || '管理员' }}
                  <el-icon class="el-icon--right"><ArrowDown /></el-icon>
                </span>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                    <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
        </el-header>
        
        <el-main class="layout-main">
          <router-view v-slot="{ Component }">
            <transition name="fade-transform" mode="out-in">
              <component :is="Component" />
            </transition>
          </router-view>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { logoutApi } from '@/api/login'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()

const activeMenu = computed(() => route.path)
const pageTitle = computed(() => route.meta.title || '智慧食堂')
const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await logoutApi()
      localStorage.removeItem('userInfo')
      ElMessage.success('已退出登录')
      router.push('/login')
    } catch (error) {
      console.error(error)
    }
  }
}
</script>

<style scoped lang="scss">
.layout-container {
  height: 100vh;
  background-color: #f3f4f6;
}

.el-container {
  height: 100%;
}

.layout-aside {
  background-color: #1f2937;
  box-shadow: 2px 0 8px rgba(0,0,0,0.15);
  display: flex;
  flex-direction: column;
  z-index: 10;

  .logo-container {
    height: 64px;
    display: flex;
    align-items: center;
    padding: 0 20px;
    background-color: #111827;
    
    .logo-icon {
      width: 32px;
      height: 32px;
      background: #4f46e5;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 12px;
    }

    .logo-text {
      color: #fff;
      font-size: 18px;
      font-weight: 600;
      margin: 0;
    }
  }

  .side-menu {
    border-right: none;
    flex: 1;
    padding-top: 10px;

    .menu-group-title {
      padding: 12px 20px 8px;
      font-size: 12px;
      color: #6b7280;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    :deep(.el-menu-item) {
      margin: 4px 10px;
      border-radius: 6px;
      height: 46px;
      line-height: 46px;

      &.is-active {
        background-color: #4f46e5;
        font-weight: 500;
      }

      &:hover:not(.is-active) {
        background-color: #374151;
      }
    }
  }
}

.layout-header {
  height: 64px;
  background-color: #fff;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.03);
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 20px;
  transition: background 0.2s;

  &:hover {
    background-color: #f3f4f6;
  }

  .user-avatar {
    background-color: #4f46e5;
    margin-right: 8px;
  }

  .el-dropdown-link {
    font-size: 14px;
    color: #374151;
    display: flex;
    align-items: center;
  }
}

.layout-main {
  padding: 24px;
  overflow-y: auto;
}

/* Transitions */
.fade-transform-enter-active,
.fade-transform-leave-active {
  transition: all 0.3s;
}

.fade-transform-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.fade-transform-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>
