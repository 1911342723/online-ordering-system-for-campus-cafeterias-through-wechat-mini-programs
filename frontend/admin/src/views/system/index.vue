<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" class="system-tabs">
      <!-- 系统配置 -->
      <el-tab-pane label="系统配置" name="config">
        <el-card shadow="never">
          <el-form :model="configForm" label-width="160px" style="max-width: 800px;">
            <el-divider content-position="left">订单设置</el-divider>
            
            <el-form-item label="自动接单">
              <el-switch 
                v-model="configForm.autoAcceptOrder"
                active-text="开启"
                inactive-text="关闭"
              />
              <div class="form-tip">开启后，用户下单将自动进入制作中状态</div>
            </el-form-item>

            <el-form-item label="订单超时时间">
              <el-input-number 
                v-model="configForm.orderTimeout" 
                :min="5" 
                :max="60"
                controls-position="right"
              />
              <span style="margin-left: 10px;">分钟</span>
              <div class="form-tip">用户下单后多久未支付自动取消</div>
            </el-form-item>

            <el-form-item label="自动完成时间">
              <el-input-number 
                v-model="configForm.autoCompleteTime" 
                :min="10" 
                :max="120"
                controls-position="right"
              />
              <span style="margin-left: 10px;">分钟</span>
              <div class="form-tip">订单派送后多久自动完成</div>
            </el-form-item>

            <el-divider content-position="left">配送设置</el-divider>

            <el-form-item label="配送费">
              <el-input-number 
                v-model="configForm.deliveryFee" 
                :min="0" 
                :max="20"
                :precision="2"
                :step="0.5"
                controls-position="right"
              />
              <span style="margin-left: 10px;">元</span>
            </el-form-item>

            <el-form-item label="免配送费金额">
              <el-input-number 
                v-model="configForm.freeDeliveryAmount" 
                :min="0" 
                :max="100"
                :precision="2"
                controls-position="right"
              />
              <span style="margin-left: 10px;">元</span>
              <div class="form-tip">订单金额达到此金额免配送费</div>
            </el-form-item>

            <el-divider content-position="left">其他设置</el-divider>

            <el-form-item label="会员积分比例">
              <el-input-number 
                v-model="configForm.pointsRatio" 
                :min="0" 
                :max="100"
                controls-position="right"
              />
              <span style="margin-left: 10px;">%</span>
              <div class="form-tip">消费金额的百分比转为积分</div>
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="handleSaveConfig" :loading="saveLoading">
                保存配置
              </el-button>
              <el-button @click="handleResetConfig">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 操作日志 -->
      <el-tab-pane label="操作日志" name="logs">
        <el-card shadow="never">
          <div class="filter-bar">
            <el-select v-model="logQuery.type" placeholder="操作类型" style="width: 150px;" clearable>
              <el-option label="登录" value="login" />
              <el-option label="订单" value="order" />
              <el-option label="菜品" value="dish" />
              <el-option label="用户" value="user" />
              <el-option label="系统" value="system" />
            </el-select>
            <el-date-picker
              v-model="logQuery.dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              style="width: 280px; margin-left: 10px;"
            />
            <el-button type="primary" @click="fetchLogs" style="margin-left: 10px;">查询</el-button>
            <el-button @click="handleExportLogs">导出日志</el-button>
          </div>

          <el-table :data="logData" v-loading="logLoading" style="width: 100%; margin-top: 20px;">
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column prop="operator" label="操作人" width="120" />
            <el-table-column prop="type" label="操作类型" width="100">
              <template #default="{ row }">
                <el-tag :type="getLogTypeColor(row.type)">{{ row.type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="action" label="操作内容" min-width="200" />
            <el-table-column prop="ip" label="IP地址" width="140" />
            <el-table-column prop="result" label="结果" width="80">
              <template #default="{ row }">
                <el-tag :type="row.result === '成功' ? 'success' : 'danger'" size="small">
                  {{ row.result }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>

          <div class="pagination-container">
            <el-pagination
              v-model:current-page="logQuery.page"
              v-model:page-size="logQuery.pageSize"
              :page-sizes="[10, 20, 50, 100]"
              layout="total, sizes, prev, pager, next, jumper"
              :total="logTotal"
              @size-change="fetchLogs"
              @current-change="fetchLogs"
            />
          </div>
        </el-card>
      </el-tab-pane>

      <!-- 系统信息 -->
      <el-tab-pane label="系统信息" name="info">
        <el-card shadow="never">
          <el-descriptions title="系统信息" :column="2" border>
            <el-descriptions-item label="系统名称">智慧食堂管理系统</el-descriptions-item>
            <el-descriptions-item label="系统版本">v1.0.0</el-descriptions-item>
            <el-descriptions-item label="后端框架">Spring Boot 2.7.x</el-descriptions-item>
            <el-descriptions-item label="前端框架">Vue 3 + Element Plus</el-descriptions-item>
            <el-descriptions-item label="数据库">MySQL 8.0</el-descriptions-item>
            <el-descriptions-item label="服务器时间">{{ serverTime }}</el-descriptions-item>
            <el-descriptions-item label="运行环境">Windows / Linux</el-descriptions-item>
            <el-descriptions-item label="Java版本">JDK 1.8+</el-descriptions-item>
          </el-descriptions>

          <el-divider />

          <el-descriptions title="数据统计" :column="2" border>
            <el-descriptions-item label="总用户数">{{ systemInfo.totalUsers }}</el-descriptions-item>
            <el-descriptions-item label="总订单数">{{ systemInfo.totalOrders }}</el-descriptions-item>
            <el-descriptions-item label="总菜品数">{{ systemInfo.totalDishes }}</el-descriptions-item>
            <el-descriptions-item label="食堂数量">{{ systemInfo.totalCanteens }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getSystemConfig, updateSystemConfig, getOperationLogs } from '@/api/system'
import { ElMessage } from 'element-plus'

const activeTab = ref('config')
const saveLoading = ref(false)
const logLoading = ref(false)
const logTotal = ref(0)
const serverTime = ref(new Date().toLocaleString())

// 配置表单
const configForm = reactive({
  autoAcceptOrder: false,
  orderTimeout: 30,
  autoCompleteTime: 60,
  deliveryFee: 3,
  freeDeliveryAmount: 30,
  pointsRatio: 5
})

// 日志查询
const logQuery = reactive({
  page: 1,
  pageSize: 10,
  type: '',
  dateRange: []
})

// 模拟日志数据
const logData = ref([
  { time: '2025-11-23 14:30:25', operator: '管理员', type: '登录', action: '登录系统', ip: '192.168.1.100', result: '成功' },
  { time: '2025-11-23 14:28:15', operator: '张三', type: '订单', action: '接单 #202511230001', ip: '192.168.1.105', result: '成功' },
  { time: '2025-11-23 14:25:08', operator: '李四', type: '菜品', action: '新增菜品：麻辣香锅', ip: '192.168.1.102', result: '成功' },
  { time: '2025-11-23 14:20:33', operator: '管理员', type: '用户', action: '冻结用户 ID:1234', ip: '192.168.1.100', result: '成功' },
  { time: '2025-11-23 14:15:12', operator: '王五', type: '系统', action: '修改系统配置', ip: '192.168.1.108', result: '成功' }
])

// 系统信息
const systemInfo = reactive({
  totalUsers: 2845,
  totalOrders: 15678,
  totalDishes: 356,
  totalCanteens: 5
})

const getLogTypeColor = (type) => {
  const colorMap = {
    '登录': 'primary',
    '订单': 'success',
    '菜品': 'warning',
    '用户': 'danger',
    '系统': 'info'
  }
  return colorMap[type] || ''
}

const handleSaveConfig = async () => {
  saveLoading.value = true
  try {
    // 实际项目中调用API
    await new Promise(resolve => setTimeout(resolve, 500))
    ElMessage.success('配置保存成功')
  } catch (err) {
    console.error(err)
    ElMessage.error('配置保存失败')
  } finally {
    saveLoading.value = false
  }
}

const handleResetConfig = () => {
  Object.assign(configForm, {
    autoAcceptOrder: false,
    orderTimeout: 30,
    autoCompleteTime: 60,
    deliveryFee: 3,
    freeDeliveryAmount: 30,
    pointsRatio: 5
  })
  ElMessage.info('已重置为默认配置')
}

const fetchLogs = () => {
  logLoading.value = true
  // 实际项目中调用API
  setTimeout(() => {
    logLoading.value = false
  }, 500)
}

const handleExportLogs = () => {
  ElMessage.info('导出日志功能开发中')
}

onMounted(() => {
  // 更新服务器时间
  setInterval(() => {
    serverTime.value = new Date().toLocaleString()
  }, 1000)
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 0;
}

.system-tabs {
  :deep(.el-tabs__content) {
    padding: 0;
  }
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.filter-bar {
  display: flex;
  align-items: center;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>

