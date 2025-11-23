<template>
  <div class="merchant-register-container">
    <div class="register-content">
      <div class="register-header">
        <h1>商家入驻申请</h1>
        <p class="subtitle">填写以下信息提交申请，审核通过后即可开通店铺</p>
      </div>

      <el-form 
        ref="formRef" 
        :model="form" 
        :rules="rules" 
        label-width="120px"
        class="register-form"
      >
        <el-card shadow="never" class="form-section">
          <template #header>
            <h3><el-icon><Shop /></el-icon> 基本信息</h3>
          </template>
          
          <el-form-item label="所属食堂" prop="canteenId">
            <el-select v-model="form.canteenId" placeholder="请选择食堂" style="width: 100%">
              <el-option 
                v-for="canteen in canteens" 
                :key="canteen.id" 
                :label="canteen.name" 
                :value="canteen.id"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="商家名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入商家名称" />
          </el-form-item>

          <el-form-item label="窗口号" prop="windowNumber">
            <el-input v-model="form.windowNumber" placeholder="例如: 1号窗口" />
          </el-form-item>

          <el-form-item label="商家简介" prop="description">
            <el-input 
              v-model="form.description" 
              type="textarea" 
              :rows="4"
              placeholder="请简要介绍您的商家特色、招牌菜等"
            />
          </el-form-item>

          <el-form-item label="人均消费" prop="avgPrice">
            <el-input-number 
              v-model="form.avgPrice" 
              :min="1" 
              :step="1"
              :precision="2"
              placeholder="单位:元"
            />
            <span style="margin-left: 10px; color: #909399;">元</span>
          </el-form-item>
        </el-card>

        <el-card shadow="never" class="form-section">
          <template #header>
            <h3><el-icon><User /></el-icon> 经营者信息</h3>
          </template>

          <el-form-item label="经营者姓名" prop="ownerName">
            <el-input v-model="form.ownerName" placeholder="请输入真实姓名" />
          </el-form-item>

          <el-form-item label="身份证号" prop="idCard">
            <el-input v-model="form.idCard" placeholder="请输入身份证号" maxlength="18" />
          </el-form-item>

          <el-form-item label="联系人" prop="contact">
            <el-input v-model="form.contact" placeholder="请输入联系人姓名" />
          </el-form-item>

          <el-form-item label="联系电话" prop="phone">
            <el-input v-model="form.phone" placeholder="请输入手机号" maxlength="11" />
          </el-form-item>
        </el-card>

        <el-card shadow="never" class="form-section">
          <template #header>
            <h3><el-icon><Lock /></el-icon> 登录账号</h3>
          </template>

          <el-form-item label="登录用户名" prop="username">
            <el-input v-model="form.username" placeholder="用于登录商家后台，建议6-20位字母数字" />
          </el-form-item>

          <el-form-item label="登录密码" prop="password">
            <el-input 
              v-model="form.password" 
              type="password" 
              placeholder="建议8位以上，包含字母数字"
              show-password
            />
          </el-form-item>

          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input 
              v-model="form.confirmPassword" 
              type="password" 
              placeholder="请再次输入密码"
              show-password
            />
          </el-form-item>
        </el-card>

        <el-form-item class="submit-btn-container">
          <el-button @click="router.push('/login')">返回登录</el-button>
          <el-button type="primary" :loading="loading" @click="handleSubmit">
            提交申请
          </el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { submitMerchantApplication } from '@/api/merchant'
import request from '@/api/request'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const canteens = ref([])

const form = reactive({
  canteenId: null,
  name: '',
  windowNumber: '',
  contact: '',
  phone: '',
  description: '',
  avgPrice: 20,
  idCard: '',
  ownerName: '',
  username: '',
  password: '',
  confirmPassword: ''
})

// 验证身份证号
const validateIdCard = (rule, value, callback) => {
  const idCardReg = /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/
  if (!idCardReg.test(value)) {
    callback(new Error('请输入正确的身份证号'))
  } else {
    callback()
  }
}

// 验证手机号
const validatePhone = (rule, value, callback) => {
  const phoneReg = /^1[3-9]\d{9}$/
  if (!phoneReg.test(value)) {
    callback(new Error('请输入正确的手机号'))
  } else {
    callback()
  }
}

// 验证确认密码
const validateConfirmPassword = (rule, value, callback) => {
  if (value !== form.password) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  canteenId: [{ required: true, message: '请选择所属食堂', trigger: 'change' }],
  name: [
    { required: true, message: '请输入商家名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  contact: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { validator: validatePhone, trigger: 'blur' }
  ],
  ownerName: [{ required: true, message: '请输入经营者姓名', trigger: 'blur' }],
  idCard: [
    { required: true, message: '请输入身份证号', trigger: 'blur' },
    { validator: validateIdCard, trigger: 'blur' }
  ],
  username: [
    { required: true, message: '请输入登录用户名', trigger: 'blur' },
    { min: 4, max: 20, message: '长度在 4 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入登录密码', trigger: 'blur' },
    { min: 6, max: 50, message: '长度在 6 到 50 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

// 获取食堂列表
const fetchCanteens = async () => {
  try {
    const res = await request({
      url: '/canteen/list',
      method: 'get'
    })
    if (res.code === 1) {
      canteens.value = res.data
    }
  } catch (error) {
    console.error(error)
  }
}

// 提交申请
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const res = await submitMerchantApplication(form)
        if (res.code === 1) {
          ElMessage.success('申请提交成功，请等待审核')
          setTimeout(() => {
            router.push('/login')
          }, 1500)
        } else {
          ElMessage.error(res.msg || '提交失败')
        }
      } catch (error) {
        console.error(error)
        ElMessage.error('提交失败，请稍后重试')
      } finally {
        loading.value = false
      }
    }
  })
}

onMounted(() => {
  fetchCanteens()
})
</script>

<style scoped lang="scss">
.merchant-register-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;
}

.register-content {
  max-width: 800px;
  margin: 0 auto;
  background: #fff;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.register-header {
  text-align: center;
  margin-bottom: 40px;

  h1 {
    font-size: 32px;
    color: #303133;
    margin: 0 0 10px 0;
  }

  .subtitle {
    color: #909399;
    font-size: 14px;
  }
}

.form-section {
  margin-bottom: 24px;

  :deep(.el-card__header) {
    padding: 16px 20px;
    background: #f5f7fa;

    h3 {
      margin: 0;
      font-size: 16px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
  }

  :deep(.el-card__body) {
    padding: 20px;
  }
}

.submit-btn-container {
  margin-top: 32px;
  text-align: center;

  .el-button {
    min-width: 120px;
  }
}
</style>

