<template>
  <div class="app-container">
    <!-- Header Actions -->
    <div class="card-header-action">
      <div class="left">
        <el-input 
          v-model="queryParams.name" 
          placeholder="搜索商家名称" 
          prefix-icon="Search" 
          style="width: 200px"
          clearable
        />
        <el-select 
          v-model="queryParams.status" 
          placeholder="审核状态" 
          style="width: 150px; margin-left: 10px;"
          clearable
        >
          <el-option label="待审核" :value="0" />
          <el-option label="已通过" :value="1" />
          <el-option label="已拒绝" :value="2" />
        </el-select>
        <el-button type="primary" @click="fetchData" style="margin-left: 10px;">查询</el-button>
      </div>
      <div class="right">
        <el-button icon="Refresh" @click="fetchData">刷新</el-button>
      </div>
    </div>

    <!-- Table Card -->
    <el-card shadow="never" class="table-card">
      <el-table :data="tableData" v-loading="loading" style="width: 100%">
        <el-table-column prop="name" label="商家名称" width="150" />
        <el-table-column prop="canteenName" label="所属食堂" width="120" />
        <el-table-column prop="windowNumber" label="窗口号" width="100" />
        <el-table-column prop="contact" label="联系人" width="100" />
        <el-table-column prop="phone" label="联系电话" width="120" />
        <el-table-column prop="ownerName" label="经营者" width="100" />
        <el-table-column prop="username" label="登录账号" width="120" />
        <el-table-column prop="status" label="审核状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" effect="plain">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="申请时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleViewDetail(row)">详情</el-button>
            <el-button 
              v-if="row.status === 0" 
              link 
              type="success" 
              @click="handleApprove(row)"
            >
              通过
            </el-button>
            <el-button 
              v-if="row.status === 0" 
              link 
              type="danger" 
              @click="handleReject(row)"
            >
              拒绝
            </el-button>
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

    <!-- Detail Dialog -->
    <el-dialog 
      v-model="detailVisible" 
      title="申请详情" 
      width="800px"
    >
      <div v-if="currentRow" class="detail-content">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="商家名称">{{ currentRow.name }}</el-descriptions-item>
          <el-descriptions-item label="所属食堂">{{ currentRow.canteenName }}</el-descriptions-item>
          <el-descriptions-item label="窗口号">{{ currentRow.windowNumber || '-' }}</el-descriptions-item>
          <el-descriptions-item label="人均消费">¥{{ currentRow.avgPrice }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ currentRow.contact }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentRow.phone }}</el-descriptions-item>
          <el-descriptions-item label="经营者姓名">{{ currentRow.ownerName }}</el-descriptions-item>
          <el-descriptions-item label="身份证号">{{ currentRow.idCard }}</el-descriptions-item>
          <el-descriptions-item label="登录账号">{{ currentRow.username }}</el-descriptions-item>
          <el-descriptions-item label="申请状态">
            <el-tag :type="getStatusType(currentRow.status)">
              {{ getStatusText(currentRow.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="商家简介" :span="2">
            {{ currentRow.description || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="申请时间" :span="2">{{ currentRow.createTime }}</el-descriptions-item>
          <el-descriptions-item v-if="currentRow.status !== 0" label="审核时间" :span="2">
            {{ currentRow.auditTime || '-' }}
          </el-descriptions-item>
          <el-descriptions-item v-if="currentRow.status !== 0" label="审核备注" :span="2">
            {{ currentRow.auditRemark || '-' }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button 
          v-if="currentRow && currentRow.status === 0" 
          type="danger"
          @click="handleReject(currentRow); detailVisible = false"
        >
          拒绝
        </el-button>
        <el-button 
          v-if="currentRow && currentRow.status === 0" 
          type="success"
          @click="handleApprove(currentRow); detailVisible = false"
        >
          通过
        </el-button>
      </template>
    </el-dialog>

    <!-- Audit Dialog -->
    <el-dialog 
      v-model="auditVisible" 
      :title="auditType === 'approve' ? '审核通过' : '拒绝申请'" 
      width="500px"
    >
      <el-form ref="auditFormRef" :model="auditForm" label-width="80px">
        <el-form-item label="审核备注">
          <el-input 
            v-model="auditForm.remark" 
            type="textarea" 
            :rows="4"
            :placeholder="auditType === 'approve' ? '选填，可添加审核说明' : '必填，请说明拒绝理由'"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="auditVisible = false">取消</el-button>
        <el-button 
          :type="auditType === 'approve' ? 'success' : 'danger'"
          @click="confirmAudit"
        >
          确认
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  getMerchantApplicationPage, 
  getMerchantApplicationById,
  auditMerchantApplication 
} from '@/api/merchant'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const detailVisible = ref(false)
const auditVisible = ref(false)
const currentRow = ref(null)
const auditType = ref('approve')
const auditFormRef = ref(null)

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  name: '',
  status: null
})

const auditForm = reactive({
  remark: ''
})

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    0: '待审核',
    1: '已通过',
    2: '已拒绝'
  }
  return statusMap[status] || '未知'
}

// 获取状态类型
const getStatusType = (status) => {
  const typeMap = {
    0: 'warning',
    1: 'success',
    2: 'danger'
  }
  return typeMap[status] || 'info'
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getMerchantApplicationPage({
      page: queryParams.page,
      pageSize: queryParams.pageSize,
      name: queryParams.name,
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

// 查看详情
const handleViewDetail = async (row) => {
  try {
    const res = await getMerchantApplicationById(row.id)
    if (res.code === 1) {
      currentRow.value = res.data
      detailVisible.value = true
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('获取详情失败')
  }
}

// 通过申请
const handleApprove = (row) => {
  currentRow.value = row
  auditType.value = 'approve'
  auditForm.remark = ''
  auditVisible.value = true
}

// 拒绝申请
const handleReject = (row) => {
  currentRow.value = row
  auditType.value = 'reject'
  auditForm.remark = ''
  auditVisible.value = true
}

// 确认审核
const confirmAudit = async () => {
  if (auditType.value === 'reject' && !auditForm.remark) {
    ElMessage.warning('请填写拒绝理由')
    return
  }

  try {
    const res = await auditMerchantApplication({
      applicationId: currentRow.value.id,
      approved: auditType.value === 'approve',
      remark: auditForm.remark
    })
    if (res.code === 1) {
      ElMessage.success(res.msg || '审核成功')
      auditVisible.value = false
      fetchData()
    } else {
      ElMessage.error(res.msg || '审核失败')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('审核失败')
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

.card-header-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;

  .left {
    display: flex;
    align-items: center;
  }

  .right {
    display: flex;
    gap: 10px;
  }
}

.table-card {
  :deep(.el-card__body) {
    padding: 20px;
  }
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.detail-content {
  padding: 20px 0;
}
</style>

