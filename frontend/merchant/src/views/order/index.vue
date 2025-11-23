<template>
  <div class="app-container">
    <!-- Header Actions -->
    <div class="card-header-action">
      <div class="left">
        <el-radio-group v-model="queryParams.orderType" @change="fetchData" style="margin-right: 10px;">
          <el-radio-button :label="null">全部</el-radio-button>
          <el-radio-button :label="1">即时订单</el-radio-button>
          <el-radio-button :label="2">预订单</el-radio-button>
        </el-radio-group>
        <el-input 
          v-model="queryParams.number" 
          placeholder="搜索订单号" 
          prefix-icon="Search" 
          style="width: 200px"
          clearable
        />
        <el-select 
          v-model="queryParams.status" 
          placeholder="订单状态" 
          style="width: 150px; margin-left: 10px;"
          clearable
        >
          <el-option label="待付款" :value="1" />
          <el-option label="待接单" :value="2" />
          <el-option label="制作中" :value="3" />
          <el-option label="待取餐" :value="4" />
          <el-option label="已完成" :value="5" />
          <el-option label="已取消" :value="6" />
        </el-select>
        <el-button type="primary" @click="fetchData" style="margin-left: 10px;">查询</el-button>
      </div>
      <div class="right">
        <el-badge :value="pendingCount" :hidden="pendingCount === 0" type="danger">
          <el-button icon="Bell" @click="showPendingOrders">待处理</el-button>
        </el-badge>
        <el-button icon="Refresh" @click="fetchData" style="margin-left: 10px;">刷新</el-button>
      </div>
    </div>

    <!-- Table Card -->
    <el-card shadow="never" class="table-card">
      <el-table :data="tableData" v-loading="loading" style="width: 100%">
        <el-table-column prop="number" label="订单号" width="180">
          <template #default="{ row }">
            <div>
              {{ row.number }}
              <el-tag v-if="row.orderType === 2" size="small" type="warning" style="margin-left: 5px;">预订</el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="userName" label="用户" width="120" />
        <el-table-column prop="canteenName" label="食堂" width="120" show-overflow-tooltip />
        <el-table-column prop="merchantName" label="商家" width="120" show-overflow-tooltip />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column prop="address" label="收货地址" min-width="150" show-overflow-tooltip />
        <el-table-column prop="amount" label="订单金额" width="120" align="right">
          <template #default="{ row }">
            <span class="price-text">¥{{ (row.amount / 100).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="订单状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" effect="plain">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="时间" width="180">
          <template #default="{ row }">
            <div style="font-size: 12px;">
              <div v-if="row.orderType === 2 && row.scheduledTime">
                <el-text type="warning">预约: {{ row.scheduledTime }}</el-text>
              </div>
              <div>下单: {{ row.orderTime }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleViewDetail(row)">详情</el-button>
            <el-button 
              v-if="row.status === 2" 
              link 
              type="success" 
              @click="handleAcceptOrder(row)"
            >
              接单
            </el-button>
            <el-button 
              v-if="row.status === 3" 
              link 
              type="warning" 
              @click="handleReadyForPickup(row)"
            >
              待取餐
            </el-button>
            <el-button 
              v-if="row.status === 4" 
              link 
              type="info" 
              @click="handleCompleteOrder(row)"
            >
              完成
            </el-button>
            <el-button 
              link 
              type="primary" 
              @click="handlePrint(row)"
            >
              打印
            </el-button>
            <el-popconfirm
              v-if="row.status === 2"
              title="确认取消该订单吗？"
              @confirm="handleCancelOrder(row)"
            >
              <template #reference>
                <el-button link type="danger">取消</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.page"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- Order Detail Dialog -->
    <el-dialog 
      v-model="detailVisible" 
      title="订单详情" 
      width="800px"
    >
      <div v-if="orderDetail" class="order-detail">
        <!-- 订单信息 -->
        <div class="detail-section">
          <h3>订单信息</h3>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="订单号">{{ orderDetail.number }}</el-descriptions-item>
            <el-descriptions-item label="订单状态">
              <el-tag :type="getStatusType(orderDetail.status)">
                {{ getStatusText(orderDetail.status) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="下单时间">{{ orderDetail.orderTime }}</el-descriptions-item>
            <el-descriptions-item label="结账时间">{{ orderDetail.checkoutTime || '-' }}</el-descriptions-item>
            <el-descriptions-item label="订单金额">
              <span class="price-text">¥{{ (orderDetail.amount / 100).toFixed(2) }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="支付方式">
              {{ orderDetail.payMethod === 1 ? '微信支付' : orderDetail.payMethod === 2 ? '支付宝' : '余额支付' }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 收货信息 -->
        <div class="detail-section">
          <h3>收货信息</h3>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="收货人">{{ orderDetail.consignee }}</el-descriptions-item>
            <el-descriptions-item label="手机号">{{ orderDetail.phone }}</el-descriptions-item>
            <el-descriptions-item label="收货地址" :span="2">
              {{ orderDetail.address }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 订单商品 -->
        <div class="detail-section">
          <h3>订单商品</h3>
          <el-table :data="orderDetail.orderDetails" border>
            <el-table-column prop="name" label="商品名称" min-width="150" />
            <el-table-column prop="image" label="图片" width="80">
              <template #default="{ row }">
                <el-image 
                  v-if="row.image"
                  style="width: 50px; height: 50px; border-radius: 4px;" 
                  :src="getImageUrl(row.image)" 
                  :preview-src-list="[getImageUrl(row.image)]"
                  fit="cover"
                />
              </template>
            </el-table-column>
            <el-table-column prop="number" label="数量" width="80" align="center" />
            <el-table-column prop="amount" label="单价" width="100" align="right">
              <template #default="{ row }">
                ¥{{ (row.amount / 100).toFixed(2) }}
              </template>
            </el-table-column>
            <el-table-column label="小计" width="120" align="right">
              <template #default="{ row }">
                <span class="price-text">¥{{ (row.amount * row.number / 100).toFixed(2) }}</span>
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 备注 -->
        <div class="detail-section" v-if="orderDetail.remark">
          <h3>备注信息</h3>
          <div class="remark-box">{{ orderDetail.remark }}</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getOrderPage, updateOrderStatus, getOrderById } from '@/api/order'
import { getImageUrl } from '@/api/common'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const detailVisible = ref(false)
const orderDetail = ref(null)
const pendingCount = ref(0)

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  number: '',
  status: null,
  orderType: null
})

// 获取订单状态文本
const getStatusText = (status) => {
  const statusMap = {
    1: '待付款',
    2: '待接单',
    3: '制作中',
    4: '待取餐',
    5: '已完成',
    6: '已取消'
  }
  return statusMap[status] || '未知'
}

// 获取订单状态类型
const getStatusType = (status) => {
  const typeMap = {
    1: 'info',
    2: 'warning',
    3: 'primary',
    4: '',
    5: 'success',
    6: 'danger'
  }
  return typeMap[status] || 'info'
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const params = {
      page: queryParams.page,
      pagesize: queryParams.pageSize,
      number: queryParams.number,
      status: queryParams.status
    }
    if (queryParams.orderType !== null) {
      params.orderType = queryParams.orderType
    }
    
    const res = await getOrderPage(params)
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

// 获取待处理订单数
const fetchPendingCount = async () => {
  try {
    const res = await getOrderPage({
      page: 1,
      pagesize: 1,
      status: 2
    })
    if (res.code === 1) {
      pendingCount.value = res.data.total
    }
  } catch (err) {
    console.error(err)
  }
}

// 显示待处理订单
const showPendingOrders = () => {
  queryParams.status = 2
  queryParams.orderType = null
  queryParams.page = 1
  fetchData()
}

// 查看详情
const handleViewDetail = async (row) => {
  try {
    const res = await getOrderById(row.id)
    if (res.code === 1) {
      orderDetail.value = res.data
      detailVisible.value = true
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('获取订单详情失败')
  }
}

// 接单
const handleAcceptOrder = async (row) => {
  try {
    const res = await updateOrderStatus({ id: row.id, status: 3 })
    if (res.code === 1) {
      ElMessage.success('接单成功')
      fetchData()
      fetchPendingCount()
    } else {
      ElMessage.error(res.msg || '接单失败')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('接单失败')
  }
}

// 待取餐
const handleReadyForPickup = async (row) => {
  try {
    const res = await updateOrderStatus({ id: row.id, status: 4 })
    if (res.code === 1) {
      ElMessage.success('订单已标记为待取餐')
      fetchData()
      fetchPendingCount()
    } else {
      ElMessage.error(res.msg || '操作失败')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('操作失败')
  }
}

// 打印订单
const handlePrint = (row) => {
  ElMessage.info('打印功能开发中，请稍后...')
  // TODO: 实现打印功能
}

// 完成
const handleCompleteOrder = async (row) => {
  try {
    const res = await updateOrderStatus({ id: row.id, status: 5 })
    if (res.code === 1) {
      ElMessage.success('订单已完成')
      fetchData()
      fetchPendingCount()
    } else {
      ElMessage.error(res.msg || '操作失败')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('操作失败')
  }
}

// 取消订单
const handleCancelOrder = async (row) => {
  try {
    const res = await updateOrderStatus({ id: row.id, status: 6 })
    if (res.code === 1) {
      ElMessage.success('订单已取消')
      fetchData()
    } else {
      ElMessage.error(res.msg || '取消失败')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('取消失败')
  }
}

onMounted(() => {
  fetchData()
  fetchPendingCount()
  
  // 定时刷新待处理订单数
  setInterval(() => {
    fetchPendingCount()
  }, 30000) // 每30秒刷新一次
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 0;
}

.card-header-action {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}

.table-card {
  border: none;
  border-radius: 8px;
  
  :deep(.el-card__body) {
    padding: 20px;
  }
}

.price-text {
  color: #f56c6c;
  font-weight: bold;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.order-detail {
  .detail-section {
    margin-bottom: 24px;

    &:last-child {
      margin-bottom: 0;
    }

    h3 {
      margin: 0 0 12px 0;
      font-size: 16px;
      color: #303133;
      font-weight: 600;
    }
  }

  .remark-box {
    padding: 12px;
    background: #f5f7fa;
    border-radius: 4px;
    color: #606266;
    line-height: 1.6;
  }
}
</style>
