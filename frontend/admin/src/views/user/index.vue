<template>
  <div class="app-container">
    <el-card shadow="never" class="main-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <div class="page-title">用户管理</div>
          </div>
          <div class="header-right">
            <el-input 
              v-model="queryParams.keyword" 
              placeholder="搜索用户名/手机号" 
              prefix-icon="Search" 
              style="width: 200px"
              clearable
              @keyup.enter="fetchData"
            />
            <el-select 
              v-model="queryParams.status" 
              placeholder="账号状态" 
              style="width: 120px; margin-left: 12px;"
              clearable
              @change="fetchData"
            >
              <el-option label="正常" :value="1" />
              <el-option label="已冻结" :value="0" />
            </el-select>
            <el-button type="primary" icon="Search" @click="fetchData" style="margin-left: 12px;">查询</el-button>
            <el-button icon="Refresh" @click="fetchData" circle />
          </div>
        </div>
      </template>

      <el-table 
        :data="tableData" 
        v-loading="loading" 
        style="width: 100%"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
      >
        <el-table-column prop="id" label="用户ID" width="80" />
        <el-table-column prop="openid" label="OpenID" width="150" show-overflow-tooltip />
        <el-table-column prop="nickname" label="昵称" min-width="120" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="balance" label="余额" width="100" align="right">
          <template #default="{ row }">
            <span class="balance-text">¥{{ (row.balance / 100).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="points" label="积分" width="80" align="center">
          <template #default="{ row }">
            <el-tag type="warning">{{ row.points || 0 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="账号状态" width="100" align="center">
          <template #default="{ row }">
            <el-switch 
              v-model="row.status" 
              :active-value="1" 
              :inactive-value="0"
              active-color="#13ce66"
              inactive-color="#ff4949"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="180" />
        <el-table-column label="操作" width="220" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleViewDetail(row)">详情</el-button>
            <el-button link type="warning" @click="handleViewOrders(row)">订单</el-button>
            <el-button link type="info" @click="handleViewStats(row)">统计</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.page"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- User Detail Dialog -->
    <el-dialog 
      v-model="detailVisible" 
      title="用户详情" 
      width="600px"
    >
      <div v-if="currentUser" class="user-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户ID">{{ currentUser.id }}</el-descriptions-item>
          <el-descriptions-item label="OpenID">{{ currentUser.openid }}</el-descriptions-item>
          <el-descriptions-item label="昵称">{{ currentUser.nickname || '-' }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ currentUser.phone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="账户余额">
            <span class="balance-text">¥{{ (currentUser.balance / 100).toFixed(2) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="积分">{{ currentUser.points || 0 }}</el-descriptions-item>
          <el-descriptions-item label="账号状态">
            <el-tag :type="currentUser.status === 1 ? 'success' : 'danger'">
              {{ currentUser.status === 1 ? '正常' : '已冻结' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="注册时间">{{ currentUser.createTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- User Stats Dialog -->
    <el-dialog 
      v-model="statsVisible" 
      title="用户消费统计" 
      width="700px"
    >
      <div v-if="userStats" class="user-stats">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-statistic title="累计订单" :value="userStats.totalOrders || 0" />
          </el-col>
          <el-col :span="8">
            <el-statistic title="累计消费" :value="(userStats.totalAmount / 100).toFixed(2)" prefix="¥" />
          </el-col>
          <el-col :span="8">
            <el-statistic title="平均客单价" :value="(userStats.avgAmount / 100).toFixed(2)" prefix="¥" />
          </el-col>
        </el-row>
      </div>
      <template #footer>
        <el-button @click="statsVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getUserPage, changeUserStatus, getUserStats } from '@/api/user'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const detailVisible = ref(false)
const statsVisible = ref(false)
const currentUser = ref(null)
const userStats = ref(null)

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  keyword: '',
  status: null
})

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getUserPage({
      page: queryParams.page,
      pageSize: queryParams.pageSize,
      keyword: queryParams.keyword,
      status: queryParams.status
    })
    if (res.code === 1) {
      tableData.value = res.data.records
      total.value = res.data.total
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

// 状态切换（冻结/解冻）
const handleStatusChange = async (row) => {
  const action = row.status === 1 ? '解冻' : '冻结'
  try {
    const res = await changeUserStatus({
      id: row.id,
      status: row.status
    })
    if (res.code === 1) {
      ElMessage.success(`${action}成功`)
    } else {
      row.status = row.status === 1 ? 0 : 1 // revert
      ElMessage.error(res.msg || `${action}失败`)
    }
  } catch (err) {
    row.status = row.status === 1 ? 0 : 1 // revert
    ElMessage.error(`${action}失败`)
  }
}

// 查看详情
const handleViewDetail = (row) => {
  currentUser.value = row
  detailVisible.value = true
}

// 查看订单
const handleViewOrders = (row) => {
  ElMessage.info('跳转到订单列表页并筛选该用户的订单')
  // 可以跳转到订单页面并传递用户ID作为筛选条件
}

// 查看统计
const handleViewStats = async (row) => {
  try {
    const res = await getUserStats(row.id)
    if (res.code === 1) {
      userStats.value = res.data
      statsVisible.value = true
    }
  } catch (err) {
    // 如果后端没有实现，使用模拟数据
    userStats.value = {
      totalOrders: 0,
      totalAmount: 0,
      avgAmount: 0
    }
    statsVisible.value = true
    console.error(err)
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 20px;
}

.main-card {
  border-radius: 8px;
  
  :deep(.el-card__header) {
    padding: 16px 20px;
    border-bottom: 1px solid #ebeef5;
  }
  
  :deep(.el-card__body) {
    padding: 20px;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .header-left {
    .page-title {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
      position: relative;
      padding-left: 12px;
      
      &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 4px;
        height: 16px;
        background: var(--primary-color);
        border-radius: 2px;
      }
    }
  }
  
  .header-right {
    display: flex;
    align-items: center;
  }
}

.balance-text {
  color: #f56c6c;
  font-weight: bold;
  font-family: DIN, -apple-system, BlinkMacSystemFont, sans-serif;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.user-detail {
  padding: 10px 0;
}

.user-stats {
  padding: 20px 0;
}
</style>

