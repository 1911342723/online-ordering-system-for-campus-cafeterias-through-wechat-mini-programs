<template>
  <div class="app-container">
    <!-- Header Actions -->
    <div class="card-header-action">
      <div class="left">
        <el-input 
          v-model="queryParams.keyword" 
          placeholder="搜索商家名称/联系人" 
          prefix-icon="Search" 
          style="width: 240px"
          clearable
        />
        <el-select 
          v-model="queryParams.status" 
          placeholder="商家状态" 
          style="width: 150px; margin-left: 10px;"
          clearable
        >
          <el-option label="正常营业" :value="1" />
          <el-option label="已冻结" :value="0" />
          <el-option label="待审核" :value="2" />
        </el-select>
        <el-button type="primary" @click="fetchData" style="margin-left: 10px;">查询</el-button>
      </div>
      <div class="right">
        <el-badge :value="pendingCount" :hidden="pendingCount === 0" class="badge-item">
          <el-button type="warning" icon="DocumentChecked" @click="showPendingList">
            待审核
          </el-button>
        </el-badge>
        <el-button type="success" icon="Plus" @click="handleAdd" style="margin-left: 10px;">
          新增商家
        </el-button>
      </div>
    </div>

    <!-- Table Card -->
    <el-card shadow="never" class="table-card">
      <el-table :data="tableData" v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="商家ID" width="80" />
        <el-table-column prop="name" label="商家名称" min-width="150" />
        <el-table-column prop="contact" label="联系人" width="100" />
        <el-table-column prop="phone" label="联系电话" width="130" />
        <el-table-column prop="canteenName" label="所属食堂" width="120" />
        <el-table-column prop="windowName" label="窗口位置" width="120" />
        <el-table-column prop="status" label="商家状态" width="100" align="center">
          <template #default="{ row }">
            <el-switch 
              v-model="row.status" 
              :active-value="1" 
              :inactive-value="0"
              active-color="#13ce66"
              inactive-color="#ff4949"
              :disabled="row.status === 2"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="入驻时间" width="180" />
        <el-table-column label="操作" width="240" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleViewDetail(row)">详情</el-button>
            <el-button link type="warning" @click="handleEdit(row)">编辑</el-button>
            <el-button 
              v-if="row.status === 2" 
              link 
              type="success" 
              @click="handleApprove(row)"
            >
              审核
            </el-button>
            <el-popconfirm
              title="确认删除该商家吗？"
              @confirm="handleDelete(row)"
            >
              <template #reference>
                <el-button link type="danger">删除</el-button>
              </template>
            </el-popconfirm>
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

    <!-- Add/Edit Dialog -->
    <el-dialog 
      v-model="dialogVisible" 
      :title="dialogTitle" 
      width="700px"
      :close-on-click-modal="false"
    >
      <el-form 
        ref="formRef" 
        :model="formData" 
        :rules="formRules" 
        label-width="120px"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="商家名称" prop="name">
              <el-input v-model="formData.name" placeholder="请输入商家名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系人" prop="contact">
              <el-input v-model="formData.contact" placeholder="请输入联系人" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="联系电话" prop="phone">
              <el-input v-model="formData.phone" placeholder="请输入联系电话" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="登录账号" prop="username">
              <el-input 
                v-model="formData.username" 
                placeholder="请输入登录账号"
                :disabled="isEdit"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所属食堂" prop="canteenId">
              <el-select v-model="formData.canteenId" placeholder="请选择食堂" style="width: 100%">
                <el-option label="第一食堂" :value="1" />
                <el-option label="第二食堂" :value="2" />
                <el-option label="第三食堂" :value="3" />
                <el-option label="清真食堂" :value="4" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="窗口位置" prop="windowName">
              <el-input v-model="formData.windowName" placeholder="如：1号窗口" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="商家图片" prop="image">
          <el-upload
            class="merchant-uploader"
            :action="uploadUrl"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
          >
            <img v-if="formData.image" :src="getImageUrl(formData.image)" class="merchant-image" />
            <el-icon v-else class="merchant-uploader-icon"><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">建议上传尺寸800x600的图片，大小不超过2M</div>
        </el-form-item>

        <el-form-item label="商家简介" prop="description">
          <el-input 
            v-model="formData.description" 
            type="textarea" 
            :rows="3"
            placeholder="请输入商家简介"
          />
        </el-form-item>

        <el-form-item label="营业状态" prop="status" v-if="isEdit">
          <el-radio-group v-model="formData.status">
            <el-radio :label="1">正常营业</el-radio>
            <el-radio :label="0">已冻结</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit" :loading="submitLoading">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- Merchant Detail Dialog -->
    <el-dialog 
      v-model="detailVisible" 
      title="商家详情" 
      width="600px"
    >
      <div v-if="currentMerchant" class="merchant-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="商家ID">{{ currentMerchant.id }}</el-descriptions-item>
          <el-descriptions-item label="商家名称">{{ currentMerchant.name }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ currentMerchant.contact }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentMerchant.phone }}</el-descriptions-item>
          <el-descriptions-item label="登录账号">{{ currentMerchant.username }}</el-descriptions-item>
          <el-descriptions-item label="所属食堂">{{ currentMerchant.canteenName }}</el-descriptions-item>
          <el-descriptions-item label="窗口位置">{{ currentMerchant.windowName }}</el-descriptions-item>
          <el-descriptions-item label="商家状态">
            <el-tag :type="getStatusType(currentMerchant.status)">
              {{ getStatusText(currentMerchant.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="入驻时间" :span="2">
            {{ currentMerchant.createTime }}
          </el-descriptions-item>
          <el-descriptions-item label="商家简介" :span="2">
            {{ currentMerchant.description || '-' }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- Approve Dialog -->
    <el-dialog 
      v-model="approveVisible" 
      title="审核商家入驻" 
      width="500px"
    >
      <div v-if="currentMerchant">
        <el-alert
          title="请仔细审核商家资料"
          type="warning"
          :closable="false"
          style="margin-bottom: 20px;"
        />
        <el-descriptions :column="1" border>
          <el-descriptions-item label="商家名称">{{ currentMerchant.name }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ currentMerchant.contact }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentMerchant.phone }}</el-descriptions-item>
          <el-descriptions-item label="所属食堂">{{ currentMerchant.canteenName }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="approveVisible = false">取消</el-button>
        <el-button type="danger" @click="handleReject">驳回</el-button>
        <el-button type="success" @click="handleApproveConfirm" :loading="approveLoading">
          通过审核
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { 
  getMerchantPage, 
  addMerchant, 
  updateMerchant, 
  deleteMerchant, 
  changeMerchantStatus,
  approveMerchant 
} from '@/api/merchant'
import { getImageUrl } from '@/api/common'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const detailVisible = ref(false)
const approveVisible = ref(false)
const submitLoading = ref(false)
const approveLoading = ref(false)
const formRef = ref(null)
const isEdit = ref(false)
const currentMerchant = ref(null)
const pendingCount = ref(3) // 待审核数量

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  keyword: '',
  status: null
})

const formData = reactive({
  id: null,
  name: '',
  contact: '',
  phone: '',
  username: '',
  canteenId: null,
  windowName: '',
  image: '',
  description: '',
  status: 1
})

// 上传地址
const uploadUrl = import.meta.env.VITE_API_BASE_URL ? 
  `${import.meta.env.VITE_API_BASE_URL}/common/upload` : 
  '/api/common/upload'

const dialogTitle = computed(() => isEdit.value ? '编辑商家' : '新增商家')

const formRules = {
  name: [
    { required: true, message: '请输入商家名称', trigger: 'blur' },
    { min: 2, max: 50, message: '商家名称长度在2-50个字符', trigger: 'blur' }
  ],
  contact: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  username: [
    { required: true, message: '请输入登录账号', trigger: 'blur' },
    { min: 3, max: 20, message: '账号长度在3-20个字符', trigger: 'blur' }
  ],
  canteenId: [{ required: true, message: '请选择所属食堂', trigger: 'change' }],
  windowName: [{ required: true, message: '请输入窗口位置', trigger: 'blur' }]
}

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    0: '已冻结',
    1: '正常营业',
    2: '待审核'
  }
  return statusMap[status] || '未知'
}

// 获取状态类型
const getStatusType = (status) => {
  const typeMap = {
    0: 'danger',
    1: 'success',
    2: 'warning'
  }
  return typeMap[status] || 'info'
}

// 获取数据（模拟数据）
const fetchData = async () => {
  loading.value = true
  try {
    // 模拟数据
    setTimeout(() => {
      tableData.value = [
        {
          id: 1,
          name: '老张川菜',
          contact: '张三',
          phone: '13800138001',
          username: 'merchant001',
          canteenId: 1,
          canteenName: '第一食堂',
          windowName: '1号窗口',
          status: 1,
          description: '正宗川菜，麻辣鲜香',
          createTime: '2025-01-15 10:30:00'
        },
        {
          id: 2,
          name: '李记面馆',
          contact: '李四',
          phone: '13800138002',
          username: 'merchant002',
          canteenId: 2,
          canteenName: '第二食堂',
          windowName: '3号窗口',
          status: 1,
          description: '手工拉面，汤鲜味美',
          createTime: '2025-02-10 14:20:00'
        },
        {
          id: 3,
          name: '味道小厨',
          contact: '王五',
          phone: '13800138003',
          username: 'merchant003',
          canteenId: 1,
          canteenName: '第一食堂',
          windowName: '5号窗口',
          status: 2,
          description: '家常小炒，营养美味',
          createTime: '2025-11-20 09:00:00'
        }
      ]
      total.value = 3
      loading.value = false
    }, 500)
  } catch (err) {
    console.error(err)
    ElMessage.error('获取数据失败')
    loading.value = false
  }
}

// 状态切换（冻结/解冻）
const handleStatusChange = async (row) => {
  const action = row.status === 1 ? '解冻' : '冻结'
  try {
    // 实际项目中调用API
    ElMessage.success(`${action}成功`)
  } catch (err) {
    row.status = row.status === 1 ? 0 : 1 // revert
    ElMessage.error(`${action}失败`)
  }
}

// 查看待审核列表
const showPendingList = () => {
  queryParams.status = 2
  fetchData()
}

// 新增
const handleAdd = () => {
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(formData, {
    id: row.id,
    name: row.name,
    contact: row.contact,
    phone: row.phone,
    username: row.username,
    canteenId: row.canteenId,
    windowName: row.windowName,
    image: row.image || '',
    description: row.description,
    status: row.status
  })
  dialogVisible.value = true
}

// 查看详情
const handleViewDetail = (row) => {
  currentMerchant.value = row
  detailVisible.value = true
}

// 审核
const handleApprove = (row) => {
  currentMerchant.value = row
  approveVisible.value = true
}

// 确认审核通过
const handleApproveConfirm = async () => {
  approveLoading.value = true
  try {
    // 实际项目中调用API
    await new Promise(resolve => setTimeout(resolve, 500))
    ElMessage.success('审核通过')
    approveVisible.value = false
    pendingCount.value--
    fetchData()
  } catch (err) {
    console.error(err)
    ElMessage.error('审核失败')
  } finally {
    approveLoading.value = false
  }
}

// 驳回
const handleReject = async () => {
  try {
    ElMessage.success('已驳回申请')
    approveVisible.value = false
    pendingCount.value--
    fetchData()
  } catch (err) {
    console.error(err)
    ElMessage.error('操作失败')
  }
}

// 删除
const handleDelete = async (row) => {
  try {
    ElMessage.success('删除成功')
    fetchData()
  } catch (err) {
    console.error(err)
    ElMessage.error('删除失败')
  }
}

// 图片上传成功
const handleUploadSuccess = (response) => {
  if (response.code === 1) {
    formData.image = response.data
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error(response.msg || '图片上传失败')
  }
}

// 上传前校验
const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        // 实际项目中调用API
        await new Promise(resolve => setTimeout(resolve, 500))
        ElMessage.success(isEdit.value ? '编辑成功' : '新建成功')
        dialogVisible.value = false
        fetchData()
      } catch (err) {
        console.error(err)
        ElMessage.error('操作失败')
      } finally {
        submitLoading.value = false
      }
    }
  })
}

// 重置表单
const resetForm = () => {
  Object.assign(formData, {
    id: null,
    name: '',
    contact: '',
    phone: '',
    username: '',
    canteenId: null,
    windowName: '',
    image: '',
    description: '',
    status: 1
  })
  formRef.value?.clearValidate()
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 0;
}

.merchant-uploader {
  :deep(.el-upload) {
    border: 1px dashed #d9d9d9;
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    transition: all 0.2s;

    &:hover {
      border-color: #409eff;
    }
  }

  .merchant-image {
    width: 178px;
    height: 178px;
    display: block;
    object-fit: cover;
  }

  .merchant-uploader-icon {
    font-size: 28px;
    color: #8c939d;
    width: 178px;
    height: 178px;
    text-align: center;
    line-height: 178px;
  }
}

.upload-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 8px;
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

  .badge-item {
    margin-right: 10px;
  }
}

.table-card {
  border: none;
  border-radius: 8px;
  
  :deep(.el-card__body) {
    padding: 20px;
  }
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.merchant-detail {
  padding: 10px 0;
}
</style>

