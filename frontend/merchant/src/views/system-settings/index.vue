<template>
  <div class="app-container">
    <el-card shadow="never">
      <template #header>
        <h2>系统设置</h2>
      </template>

      <el-tabs v-model="activeTab">
        <!-- 账号信息 -->
        <el-tab-pane label="账号信息" name="account">
          <el-form :model="accountInfo" label-width="120px">
            <el-form-item label="用户名">
              <span>{{ accountInfo.username }}</span>
            </el-form-item>
            <el-form-item label="姓名">
              <span>{{ accountInfo.name }}</span>
            </el-form-item>
            <el-form-item label="手机号">
              <span>{{ accountInfo.phone }}</span>
            </el-form-item>
            <el-form-item label="角色">
              <el-tag type="success">商家</el-tag>
            </el-form-item>
            <el-form-item label="创建时间">
              <span>{{ accountInfo.createTime }}</span>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 修改密码 -->
        <el-tab-pane label="修改密码" name="password">
          <el-form 
            ref="passwordFormRef"
            :model="passwordForm" 
            :rules="passwordRules"
            label-width="120px"
            style="max-width: 500px;"
          >
            <el-form-item label="原密码" prop="oldPassword">
              <el-input 
                v-model="passwordForm.oldPassword" 
                type="password"
                placeholder="请输入原密码"
                show-password
              />
            </el-form-item>
            <el-form-item label="新密码" prop="newPassword">
              <el-input 
                v-model="passwordForm.newPassword" 
                type="password"
                placeholder="请输入新密码"
                show-password
              />
            </el-form-item>
            <el-form-item label="确认密码" prop="confirmPassword">
              <el-input 
                v-model="passwordForm.confirmPassword" 
                type="password"
                placeholder="请再次输入新密码"
                show-password
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleChangePassword" :loading="passwordLoading">
                修改密码
              </el-button>
              <el-button @click="resetPasswordForm">重置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 消息通知 -->
        <el-tab-pane label="消息通知" name="notification">
          <el-form :model="notificationSettings" label-width="150px">
            <el-form-item label="新订单提醒">
              <el-switch 
                v-model="notificationSettings.newOrder"
                @change="saveNotificationSettings"
              />
              <span style="margin-left: 10px; color: #909399; font-size: 12px;">
                开启后将收到新订单通知
              </span>
            </el-form-item>
            
            <el-form-item label="订单状态变更">
              <el-switch 
                v-model="notificationSettings.orderStatus"
                @change="saveNotificationSettings"
              />
              <span style="margin-left: 10px; color: #909399; font-size: 12px;">
                订单状态变化时接收通知
              </span>
            </el-form-item>
            
            <el-form-item label="用户评价提醒">
              <el-switch 
                v-model="notificationSettings.review"
                @change="saveNotificationSettings"
              />
              <span style="margin-left: 10px; color: #909399; font-size: 12px;">
                收到新评价时接收通知
              </span>
            </el-form-item>
            
            <el-form-item label="系统公告">
              <el-switch 
                v-model="notificationSettings.announcement"
                @change="saveNotificationSettings"
              />
              <span style="margin-left: 10px; color: #909399; font-size: 12px;">
                接收系统重要公告
              </span>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 数据备份 -->
        <el-tab-pane label="数据与安全" name="data">
          <div style="max-width: 600px;">
            <el-alert
              title="数据安全提示"
              type="info"
              description="定期备份您的数据可以有效防止数据丢失，建议每周进行一次数据导出。"
              :closable="false"
              style="margin-bottom: 20px;"
            />
            
            <el-card shadow="never" style="margin-bottom: 20px;">
              <h3>数据导出</h3>
              <p style="color: #606266; margin: 10px 0;">导出店铺数据，包括订单、菜品、营业数据等</p>
              <el-button type="primary" icon="Download">导出数据</el-button>
            </el-card>
            
            <el-card shadow="never">
              <h3>清理缓存</h3>
              <p style="color: #606266; margin: 10px 0;">清理浏览器缓存可以解决一些显示异常问题</p>
              <el-button @click="clearCache" icon="Delete">清理缓存</el-button>
            </el-card>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

const activeTab = ref('account')
const passwordFormRef = ref(null)
const passwordLoading = ref(false)

// 账号信息
const accountInfo = reactive({
  username: '',
  name: '',
  phone: '',
  createTime: ''
})

// 获取账号信息
const loadAccountInfo = () => {
  const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
  accountInfo.username = userInfo.username || '-'
  accountInfo.name = userInfo.name || '-'
  accountInfo.phone = userInfo.phone || '-'
  accountInfo.createTime = userInfo.createTime || '-'
}

// 修改密码表单
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 验证确认密码
const validateConfirmPassword = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入新密码'))
  } else if (value !== passwordForm.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在6-20个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

// 修改密码
const handleChangePassword = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      passwordLoading.value = true
      try {
        // TODO: 调用修改密码API
        await new Promise(resolve => setTimeout(resolve, 1000))
        ElMessage.success('密码修改成功，请重新登录')
        // 清除登录信息，跳转到登录页
        setTimeout(() => {
          localStorage.removeItem('userInfo')
          window.location.href = '/login'
        }, 1500)
      } catch (error) {
        ElMessage.error('密码修改失败')
      } finally {
        passwordLoading.value = false
      }
    }
  })
}

// 重置密码表单
const resetPasswordForm = () => {
  passwordForm.oldPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
  passwordFormRef.value?.clearValidate()
}

// 消息通知设置
const notificationSettings = reactive({
  newOrder: true,
  orderStatus: true,
  review: true,
  announcement: true
})

// 加载通知设置
const loadNotificationSettings = () => {
  const saved = localStorage.getItem('notificationSettings')
  if (saved) {
    Object.assign(notificationSettings, JSON.parse(saved))
  }
}

// 保存通知设置
const saveNotificationSettings = () => {
  localStorage.setItem('notificationSettings', JSON.stringify(notificationSettings))
  ElMessage.success('通知设置已保存')
}

// 清理缓存
const clearCache = () => {
  // 清除localStorage中的缓存数据（保留登录信息）
  const userInfo = localStorage.getItem('userInfo')
  localStorage.clear()
  if (userInfo) {
    localStorage.setItem('userInfo', userInfo)
  }
  
  ElMessage.success('缓存已清理，页面将自动刷新')
  setTimeout(() => {
    window.location.reload()
  }, 1000)
}

// 初始化
loadAccountInfo()
loadNotificationSettings()
</script>

<style scoped lang="scss">
.app-container {
  padding: 20px;
}

h3 {
  margin: 0 0 10px 0;
  font-size: 16px;
  color: #303133;
}
</style>

