<template>
  <div class="app-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="总评价数" :value="stats.total" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="平均评分" :value="stats.avgRating" :precision="1" suffix="分" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="好评率" :value="stats.goodRate" suffix="%" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <el-statistic title="待回复" :value="stats.pending">
            <template #suffix>
              <el-tag type="warning" size="small">条</el-tag>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
    </el-row>

    <!-- 筛选和表格 -->
    <el-card shadow="never" style="margin-top: 20px;">
      <div class="filter-bar">
        <el-radio-group v-model="queryParams.rating" @change="fetchData" style="margin-right: 20px;">
          <el-radio-button :label="null">全部评价</el-radio-button>
          <el-radio-button :label="5">5星</el-radio-button>
          <el-radio-button :label="4">4星</el-radio-button>
          <el-radio-button :label="3">3星</el-radio-button>
          <el-radio-button :label="2">2星及以下</el-radio-button>
        </el-radio-group>
        
        <el-select v-model="queryParams.hasReply" placeholder="回复状态" style="width: 150px; margin-right: 10px;" clearable @change="fetchData">
          <el-option label="未回复" :value="0" />
          <el-option label="已回复" :value="1" />
        </el-select>
        
        <el-button type="primary" icon="Refresh" @click="fetchData">刷新</el-button>
      </div>

      <el-table :data="tableData" v-loading="loading" style="width: 100%; margin-top: 20px;">
        <el-table-column prop="orderNumber" label="订单号" width="180" />
        <el-table-column label="评分" width="150">
          <template #default="{ row }">
            <el-rate v-model="row.rating" disabled show-score text-color="#ff9900" />
          </template>
        </el-table-column>
        <el-table-column prop="content" label="评价内容" min-width="200" show-overflow-tooltip />
        <el-table-column label="评价详情" width="120">
          <template #default="{ row }">
            <div style="font-size: 12px; color: #909399;">
              <div>口味: {{ row.tasteRating }}分</div>
              <div>服务: {{ row.serviceRating }}分</div>
              <div>速度: {{ row.speedRating }}分</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="userName" label="用户" width="100" />
        <el-table-column prop="createTime" label="评价时间" width="180" />
        <el-table-column label="回复状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.merchantReply" type="success">已回复</el-tag>
            <el-tag v-else type="warning">待回复</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleViewDetail(row)">查看</el-button>
            <el-button v-if="!row.merchantReply" link type="success" @click="handleReply(row)">回复</el-button>
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

    <!-- 回复对话框 -->
    <el-dialog v-model="replyVisible" title="回复评价" width="600px">
      <div v-if="currentReview" class="review-detail">
        <div class="review-info">
          <el-rate v-model="currentReview.rating" disabled show-score />
          <p class="review-content">{{ currentReview.content }}</p>
          <div class="review-meta">
            <span>用户：{{ currentReview.userName }}</span>
            <span style="margin-left: 20px;">时间：{{ currentReview.createTime }}</span>
          </div>
        </div>
        
        <el-divider />
        
        <el-form :model="replyForm" label-width="80px">
          <el-form-item label="回复内容">
            <el-input
              v-model="replyForm.content"
              type="textarea"
              :rows="4"
              placeholder="请输入回复内容..."
              maxlength="200"
              show-word-limit
            />
          </el-form-item>
        </el-form>
      </div>
      
      <template #footer>
        <el-button @click="replyVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitReply" :loading="replyLoading">提交回复</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/api/request'
import { getMerchantByEmployeeId } from '@/api/merchant'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const currentMerchantId = ref(null)

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  rating: null,
  hasReply: null
})

const stats = reactive({
  total: 0,
  avgRating: 0,
  goodRate: 0,
  pending: 0
})

// 获取评价列表
const fetchData = async () => {
  if (!currentMerchantId.value) return
  
  loading.value = true
  try {
    const params = {
      page: queryParams.page,
      pageSize: queryParams.pageSize,
      merchantId: currentMerchantId.value
    }
    
    if (queryParams.rating !== null) {
      if (queryParams.rating === 2) {
        params.maxRating = 2
      } else {
        params.rating = queryParams.rating
      }
    }
    
    if (queryParams.hasReply !== null) {
      params.hasReply = queryParams.hasReply
    }
    
    const res = await request({
      url: '/review/merchant/page',
      method: 'get',
      params
    })
    
    if (res.code === 1) {
      tableData.value = res.data.records
      total.value = res.data.total
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('获取评价列表失败')
  } finally {
    loading.value = false
  }
}

// 获取统计数据
const fetchStats = async () => {
  if (!currentMerchantId.value) return
  
  try {
    const res = await request({
      url: `/review/merchant/${currentMerchantId.value}/stats`,
      method: 'get'
    })
    
    if (res.code === 1 && res.data) {
      stats.total = res.data.totalReviews || 0
      stats.avgRating = res.data.avgRating || 0
      stats.goodRate = res.data.totalReviews > 0 
        ? Math.round(((res.data.star5Count + res.data.star4Count) / res.data.totalReviews) * 100)
        : 0
      // TODO: 获取待回复数量
      stats.pending = 0
    }
  } catch (error) {
    console.error(error)
  }
}

// 回复相关
const replyVisible = ref(false)
const currentReview = ref(null)
const replyLoading = ref(false)
const replyForm = reactive({
  content: ''
})

const handleViewDetail = (row) => {
  currentReview.value = row
  replyVisible.value = true
  if (row.merchantReply) {
    replyForm.content = row.merchantReply
  } else {
    replyForm.content = ''
  }
}

const handleReply = (row) => {
  currentReview.value = row
  replyForm.content = ''
  replyVisible.value = true
}

const handleSubmitReply = async () => {
  if (!replyForm.content.trim()) {
    ElMessage.warning('请输入回复内容')
    return
  }
  
  replyLoading.value = true
  try {
    const res = await request({
      url: '/review/reply',
      method: 'post',
      data: {
        reviewId: currentReview.value.id,
        reply: replyForm.content
      }
    })
    
    if (res.code === 1) {
      ElMessage.success('回复成功')
      replyVisible.value = false
      fetchData()
      fetchStats()
    } else {
      ElMessage.error(res.msg || '回复失败')
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('回复失败')
  } finally {
    replyLoading.value = false
  }
}

// 初始化
const init = async () => {
  try {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    if (userInfo.id) {
      const res = await getMerchantByEmployeeId(userInfo.id)
      if (res.code === 1 && res.data) {
        currentMerchantId.value = res.data.id
        fetchData()
        fetchStats()
      }
    }
  } catch (error) {
    console.error(error)
  }
}

onMounted(() => {
  init()
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 20px;
}

.stats-row {
  margin-bottom: 20px;
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

.review-detail {
  .review-info {
    padding: 10px;
    background: #f5f7fa;
    border-radius: 4px;
    
    .review-content {
      margin: 10px 0;
      color: #303133;
      line-height: 1.6;
    }
    
    .review-meta {
      font-size: 12px;
      color: #909399;
    }
  }
}
</style>

