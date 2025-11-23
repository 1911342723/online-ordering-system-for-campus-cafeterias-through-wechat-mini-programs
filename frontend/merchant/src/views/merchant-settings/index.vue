<template>
  <div class="app-container">
    <el-card shadow="never">
      <template #header>
        <h2>店铺设置</h2>
      </template>

      <el-tabs v-model="activeTab">
        <!-- 基本信息 -->
        <el-tab-pane label="基本信息" name="basic">
          <el-form :model="merchantInfo" label-width="120px">
            <el-form-item label="商家名称">
              <span>{{ merchantInfo.name }}</span>
            </el-form-item>
            <el-form-item label="所属食堂">
              <el-select 
                v-model="merchantInfo.canteenId" 
                placeholder="请选择所属食堂"
                style="width: 300px;"
                @change="handleCanteenChange"
              >
                <el-option 
                  v-for="canteen in canteenList" 
                  :key="canteen.id" 
                  :label="canteen.name" 
                  :value="canteen.id"
                />
                <el-option label="校外商户（不属于任何食堂）" :value="null" />
              </el-select>
              <el-text type="info" style="margin-left: 10px; font-size: 12px;">
                {{ merchantInfo.canteenName || '校外商户' }}
              </el-text>
            </el-form-item>
            <el-form-item label="联系人">
              <span>{{ merchantInfo.contact }}</span>
            </el-form-item>
            <el-form-item label="联系电话">
              <span>{{ merchantInfo.phone }}</span>
            </el-form-item>
            <el-form-item label="窗口号">
              <span>{{ merchantInfo.windowNumber || '-' }}</span>
            </el-form-item>
            <el-form-item label="营业状态">
              <el-tag :type="merchantInfo.status === 1 ? 'success' : 'danger'">
                {{ merchantInfo.status === 1 ? '营业中' : '停业中' }}
              </el-tag>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 订单设置 -->
        <el-tab-pane label="订单设置" name="order">
          <el-form :model="settings" label-width="120px" v-loading="loading">
            <el-form-item label="自动接单">
              <el-switch 
                v-model="autoAcceptOrder" 
                @change="handleToggleAutoAccept"
                active-text="开启"
                inactive-text="关闭"
              />
              <el-text type="info" style="margin-left: 20px; font-size: 12px;">
                开启后，用户下单将自动进入制作中状态
              </el-text>
            </el-form-item>

            <el-form-item label="订单提示音">
              <el-switch 
                v-model="noticeSound" 
                @change="saveSettings"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="起送金额">
              <el-input-number 
                v-model="settings.minOrderAmount" 
                :min="0" 
                :step="1"
                :precision="2"
                @change="saveSettings"
              />
              <span style="margin-left: 10px;">元</span>
            </el-form-item>

            <el-form-item label="营业时间">
              <el-time-picker
                v-model="businessHoursStart"
                placeholder="开始时间"
                format="HH:mm"
                @change="saveSettings"
              />
              <span style="margin: 0 10px;">至</span>
              <el-time-picker
                v-model="businessHoursEnd"
                placeholder="结束时间"
                format="HH:mm"
                @change="saveSettings"
              />
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/api/request'

const activeTab = ref('basic')
const loading = ref(false)
const merchantInfo = ref({})
const canteenList = ref([])
const settings = ref({
  autoAcceptOrder: 0,
  noticeSound: 1,
  minOrderAmount: 0,
  businessHoursStart: null,
  businessHoursEnd: null
})

const autoAcceptOrder = computed({
  get: () => settings.value.autoAcceptOrder === 1,
  set: (val) => settings.value.autoAcceptOrder = val ? 1 : 0
})

const noticeSound = computed({
  get: () => settings.value.noticeSound === 1,
  set: (val) => settings.value.noticeSound = val ? 1 : 0
})

const businessHoursStart = computed({
  get: () => settings.value.businessHoursStart ? new Date(`2000-01-01 ${settings.value.businessHoursStart}`) : null,
  set: (val) => settings.value.businessHoursStart = val ? val.toTimeString().slice(0, 8) : null
})

const businessHoursEnd = computed({
  get: () => settings.value.businessHoursEnd ? new Date(`2000-01-01 ${settings.value.businessHoursEnd}`) : null,
  set: (val) => settings.value.businessHoursEnd = val ? val.toTimeString().slice(0, 8) : null
})

// 获取食堂列表
const fetchCanteenList = async () => {
  try {
    const res = await request({
      url: '/canteen/list',
      method: 'get'
    })
    if (res.code === 1) {
      canteenList.value = res.data
    }
  } catch (error) {
    console.error(error)
  }
}

// 获取商家信息
const fetchMerchantInfo = async () => {
  try {
    const userInfo = JSON.parse(localStorage.getItem('userInfo'))
    if (!userInfo || !userInfo.id) {
      ElMessage.error('获取商家信息失败')
      return
    }
    
    const res = await request({
      url: `/merchant/byEmployee/${userInfo.id}`,
      method: 'get'
    })
    if (res.code === 1) {
      merchantInfo.value = res.data
    }
  } catch (error) {
    console.error(error)
  }
}

// 更改所属食堂
const handleCanteenChange = async () => {
  try {
    const res = await request({
      url: '/merchant',
      method: 'put',
      data: {
        id: merchantInfo.value.id,
        canteenId: merchantInfo.value.canteenId
      }
    })
    if (res.code === 1) {
      ElMessage.success('所属食堂已更新')
      fetchMerchantInfo()
    } else {
      ElMessage.error(res.msg || '更新失败')
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('更新失败')
  }
}

// 获取设置
const fetchSettings = async () => {
  loading.value = true
  try {
    const res = await request({
      url: '/merchantSettings',
      method: 'get'
    })
    if (res.code === 1) {
      settings.value = res.data
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('获取设置失败')
  } finally {
    loading.value = false
  }
}

// 保存设置
const saveSettings = async () => {
  loading.value = true
  try {
    const res = await request({
      url: '/merchantSettings',
      method: 'put',
      data: settings.value
    })
    if (res.code === 1) {
      ElMessage.success('设置已保存')
    } else {
      ElMessage.error(res.msg || '保存失败')
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('保存失败')
  } finally {
    loading.value = false
  }
}

// 切换自动接单
const handleToggleAutoAccept = async () => {
  loading.value = true
  try {
    const res = await request({
      url: '/merchantSettings/toggleAutoAccept',
      method: 'put'
    })
    if (res.code === 1) {
      settings.value.autoAcceptOrder = res.data ? 1 : 0
      ElMessage.success(res.data ? '自动接单已开启' : '自动接单已关闭')
    } else {
      // 恢复原状态
      settings.value.autoAcceptOrder = settings.value.autoAcceptOrder === 1 ? 0 : 1
      ElMessage.error(res.msg || '操作失败')
    }
  } catch (error) {
    console.error(error)
    // 恢复原状态
    settings.value.autoAcceptOrder = settings.value.autoAcceptOrder === 1 ? 0 : 1
    ElMessage.error('操作失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchCanteenList()
  fetchMerchantInfo()
  fetchSettings()
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 20px;
}
</style>

