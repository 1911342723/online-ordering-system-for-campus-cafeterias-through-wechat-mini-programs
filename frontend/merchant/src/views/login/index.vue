<template>
  <div class="login-container">
    <div class="login-content">
      <div class="login-left">
        <div class="brand-intro">
          <img src="@/assets/logo-white.svg" class="brand-logo" alt="Logo" v-if="false" />
          <h1>商家管理后台</h1>
          <p class="subtitle">Merchant Management System</p>
          <ul class="features">
            <li><el-icon><DataAnalysis /></el-icon> 数据可视化看板</li>
            <li><el-icon><Food /></el-icon> 菜品智能管理</li>
            <li><el-icon><List /></el-icon> 订单实时监控</li>
          </ul>
        </div>
      </div>
      <div class="login-right">
        <div class="login-form-box">
          <h2>商家登录</h2>
          <p class="form-subtitle">请登录商家管理后台</p>
          
          <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" size="large">
            <el-form-item prop="username">
              <el-input 
                v-model="loginForm.username" 
                placeholder="请输入账号" 
                prefix-icon="User"
              />
            </el-form-item>
            <el-form-item prop="password">
              <el-input 
                v-model="loginForm.password" 
                type="password" 
                placeholder="请输入密码" 
                prefix-icon="Lock"
                show-password
                @keyup.enter="handleLogin"
              />
            </el-form-item>
            <el-form-item>
              <el-button 
                type="primary" 
                :loading="loading" 
                class="login-btn"
                @click="handleLogin"
              >
                登 录
              </el-button>
            </el-form-item>
          </el-form>

          <div class="quick-login">
            <div class="divider">
              <span>快速登录 (演示用)</span>
            </div>
            <div class="account-tags">
              <el-tag 
                v-for="(account, index) in quickAccounts" 
                :key="index"
                effect="plain"
                class="account-tag"
                @click="fillAccount(account)"
              >
                {{ account.label }}
              </el-tag>
            </div>
          </div>

          <div class="register-link">
            <el-divider />
            <p>还没有账号？ <a @click="router.push('/merchant-register')">商家入驻申请</a></p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { loginApi } from '@/api/login'

const router = useRouter()
const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const quickAccounts = [
  { label: '老张川菜', u: 'zhangsan', p: '123456' },
  { label: '李记面馆', u: 'lisi', p: '123456' }
]

const fillAccount = (account) => {
  loginForm.username = account.u
  loginForm.password = account.p
  ElMessage.success(`已填入${account.label}账号`)
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const res = await loginApi(loginForm)
        if (res.code === 1) {
          ElMessage.success('登录成功')
          localStorage.setItem('userInfo', JSON.stringify(res.data))
          router.push('/')
        } else {
          ElMessage.error(res.msg || '登录失败')
        }
      } catch (error) {
        console.error(error)
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped lang="scss">
.login-container {
  height: 100vh;
  width: 100vw;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #f0f2f5;
  background-image: 
    radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), 
    radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%), 
    radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
  background-size: cover;
}

.login-content {
  width: 1000px;
  height: 600px;
  background: #ffffff;
  border-radius: 20px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
  display: flex;
  overflow: hidden;
}

.login-left {
  flex: 1;
  background: linear-gradient(135deg, #1a1c20 0%, #2d3436 100%);
  padding: 60px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  color: #ffffff;
  position: relative;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: url('https://images.unsplash.com/photo-1550989460-0adf9ea622e2?q=80&w=1000&auto=format&fit=crop') no-repeat center/cover;
    opacity: 0.1;
  }

  .brand-intro {
    position: relative;
    z-index: 1;
  }

  h1 {
    font-size: 48px;
    margin: 0;
    font-weight: 800;
    letter-spacing: 2px;
    background: linear-gradient(to right, #fff, #a5b4fc);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .subtitle {
    font-size: 18px;
    color: #a1a1aa;
    margin-top: 10px;
    margin-bottom: 40px;
  }

  .features {
    list-style: none;
    padding: 0;
    margin: 0;

    li {
      display: flex;
      align-items: center;
      font-size: 16px;
      margin-bottom: 20px;
      color: #e4e4e7;

      .el-icon {
        margin-right: 12px;
        font-size: 20px;
        color: #6366f1;
      }
    }
  }
}

.login-right {
  flex: 1;
  padding: 60px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  background: #fff;
}

.login-form-box {
  width: 100%;
  max-width: 360px;
  margin: 0 auto;

  h2 {
    font-size: 32px;
    color: #18181b;
    margin: 0;
    margin-bottom: 8px;
  }

  .form-subtitle {
    color: #71717a;
    margin-bottom: 40px;
    font-size: 14px;
  }
}

.login-btn {
  width: 100%;
  height: 44px;
  font-size: 16px;
  background: linear-gradient(to right, #4f46e5, #6366f1);
  border: none;
  border-radius: 8px;
  margin-top: 10px;
  transition: all 0.3s;

  &:hover {
    opacity: 0.9;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
  }
}

.quick-login {
  margin-top: 40px;
  
  .divider {
    display: flex;
    align-items: center;
    text-align: center;
    margin-bottom: 20px;
    
    &::before,
    &::after {
      content: '';
      flex: 1;
      border-bottom: 1px solid #e4e4e7;
    }
    
    span {
      padding: 0 10px;
      color: #a1a1aa;
      font-size: 12px;
    }
  }

  .account-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    justify-content: center;
  }

  .account-tag {
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
      transform: scale(1.05);
      border-color: #6366f1;
      color: #6366f1;
    }
  }
}

.register-link {
  margin-top: 24px;
  text-align: center;

  p {
    color: #606266;
    font-size: 14px;

    a {
      color: #409eff;
      cursor: pointer;
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }
  }
}
</style>
