<template>
  <div class="app-container">
    <el-card shadow="never" class="main-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <div class="page-title">公告管理</div>
          </div>
          <div class="header-right">
            <el-input 
              v-model="queryParams.title" 
              placeholder="搜索公告标题" 
              prefix-icon="Search" 
              style="width: 200px"
              clearable
              @keyup.enter="handleSearch"
            />
            <el-button type="primary" icon="Search" @click="handleSearch" style="margin-left: 12px;">查询</el-button>
            <el-button icon="Refresh" @click="handleReset">重置</el-button>
            <el-divider direction="vertical" />
            <el-button type="primary" icon="Plus" class="add-btn" @click="handleAdd">发布公告</el-button>
          </div>
        </div>
      </template>

      <!-- 批量操作工具栏 -->
      <transition name="el-zoom-in-top">
        <div v-if="selectedRows.length > 0" class="batch-toolbar">
          <div class="batch-left">
            <el-icon class="batch-icon"><List /></el-icon>
            <span class="selected-info">已选择 <span class="num">{{ selectedRows.length }}</span> 个公告</span>
            <el-divider direction="vertical" />
            <el-button link type="primary" @click="clearSelection">取消选择</el-button>
          </div>
          <div class="batch-right">
            <el-button-group>
              <el-button type="success" plain size="small" @click="handleBatchStatus(1)">
                <el-icon><CircleCheck /></el-icon> 批量启用
              </el-button>
              <el-button type="warning" plain size="small" @click="handleBatchStatus(0)">
                <el-icon><CircleClose /></el-icon> 批量停用
              </el-button>
            </el-button-group>
            <el-popconfirm
              title="确认删除选中的公告吗？"
              @confirm="handleBatchDelete"
            >
              <template #reference>
                <el-button type="danger" plain size="small" style="margin-left: 12px;">
                  <el-icon><Delete /></el-icon> 批量删除
                </el-button>
              </template>
            </el-popconfirm>
          </div>
        </div>
      </transition>

      <el-table 
        ref="tableRef"
        :data="tableData" 
        v-loading="loading" 
        style="width: 100%"
        :header-cell-style="{ background: '#f8f9fa', color: '#606266' }"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="title" label="公告标题" min-width="200" />
        <el-table-column prop="content" label="公告内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="sort" label="优先级" width="100" align="center">
          <template #default="{ row }">
            <el-tag type="info">{{ row.sort || 0 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="生效时间" width="180">
          <template #default="{ row }">
            {{ row.startTime || '立即生效' }}
          </template>
        </el-table-column>
        <el-table-column label="失效时间" width="180">
          <template #default="{ row }">
            {{ row.endTime || '长期有效' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-switch 
              v-model="row.status" 
              :active-value="1" 
              :inactive-value="0"
              active-color="#13ce66"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-popconfirm
              title="确认删除该公告吗？"
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
          :page-sizes="[10, 20, 50]"
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
        <el-form-item label="公告标题" prop="title">
          <el-input v-model="formData.title" placeholder="请输入公告标题" maxlength="100" show-word-limit />
        </el-form-item>
        <el-form-item label="公告内容" prop="content">
          <el-input 
            v-model="formData.content" 
            type="textarea" 
            :rows="5"
            placeholder="请输入公告内容"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="优先级" prop="sort">
              <el-input-number 
                v-model="formData.sort" 
                :min="0" 
                :max="999" 
                placeholder="数字越大优先级越高"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-switch 
                v-model="formData.status" 
                :active-value="1" 
                :inactive-value="0"
                active-text="启用"
                inactive-text="停用"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="生效时间">
              <el-date-picker 
                v-model="formData.startTime" 
                type="datetime" 
                placeholder="选择生效时间"
                value-format="YYYY-MM-DD HH:mm:ss"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="失效时间">
              <el-date-picker 
                v-model="formData.endTime" 
                type="datetime" 
                placeholder="选择失效时间"
                value-format="YYYY-MM-DD HH:mm:ss"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
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
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { 
  getAnnouncementPage, 
  addAnnouncement, 
  updateAnnouncement, 
  deleteAnnouncement,
  updateAnnouncementStatus
} from '@/api/announcement'
import { getMerchantByEmployeeId } from '@/api/merchant'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableRef = ref(null)
const selectedRows = ref([])
const tableData = ref([])
const total = ref(0)
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref(null)
const isEdit = ref(false)
const currentMerchantId = ref(null)

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  title: ''
})

const formData = reactive({
  id: null,
  merchantId: null,
  title: '',
  content: '',
  sort: 0,
  startTime: null,
  endTime: null,
  status: 1
})

const dialogTitle = computed(() => isEdit.value ? '编辑公告' : '发布公告')

const formRules = {
  title: [
    { required: true, message: '请输入公告标题', trigger: 'blur' },
    { min: 2, max: 100, message: '标题长度在2-100个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入公告内容', trigger: 'blur' }
  ]
}

// 获取商家信息
const fetchMerchantInfo = async () => {
  try {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    const employeeId = userInfo.id
    
    if (employeeId) {
      const res = await getMerchantByEmployeeId(employeeId)
      if (res.code === 1) {
        currentMerchantId.value = res.data.id
        formData.merchantId = res.data.id
      }
    }
  } catch (err) {
    console.error('获取商家信息失败:', err)
  }
}

// 获取数据
const fetchData = async () => {
  if (!currentMerchantId.value) {
    return
  }
  
  loading.value = true
  try {
    const res = await getAnnouncementPage({
      page: queryParams.page,
      pageSize: queryParams.pageSize,
      merchantId: currentMerchantId.value,
      title: queryParams.title
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

// 状态切换
const handleStatusChange = async (row) => {
  try {
    const res = await updateAnnouncementStatus(row.id, row.status)
    if (res.code === 1) {
      ElMessage.success('状态更新成功')
    } else {
      row.status = row.status === 1 ? 0 : 1 // revert
      ElMessage.error(res.msg || '状态更新失败')
    }
  } catch (err) {
    row.status = row.status === 1 ? 0 : 1 // revert
    ElMessage.error('状态更新失败')
  }
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
    merchantId: row.merchantId,
    title: row.title,
    content: row.content,
    sort: row.sort || 0,
    startTime: row.startTime,
    endTime: row.endTime,
    status: row.status
  })
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  try {
    const res = await deleteAnnouncement(row.id)
    if (res.code === 1) {
      ElMessage.success('删除成功')
      fetchData()
    } else {
      ElMessage.error(res.msg || '删除失败')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('删除失败')
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        let res
        if (isEdit.value) {
          res = await updateAnnouncement(formData)
        } else {
          res = await addAnnouncement(formData)
        }
        
        if (res.code === 1) {
          ElMessage.success(isEdit.value ? '编辑成功' : '发布成功')
          dialogVisible.value = false
          fetchData()
        } else {
          ElMessage.error(res.msg || '操作失败')
        }
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
    merchantId: currentMerchantId.value,
    title: '',
    content: '',
    sort: 0,
    startTime: null,
    endTime: null,
    status: 1
  })
  formRef.value?.clearValidate()
}

// 查询按钮
const handleSearch = () => {
  queryParams.page = 1
  fetchData()
}

// 重置按钮
const handleReset = () => {
  queryParams.title = ''
  queryParams.page = 1
  fetchData()
}

// ========== 批量操作方法 ==========

// 处理表格选择变化
const handleSelectionChange = (selection) => {
  selectedRows.value = selection
}

// 清空选择
const clearSelection = () => {
  tableRef.value?.clearSelection()
  selectedRows.value = []
}

// 批量修改状态
const handleBatchStatus = async (status) => {
  if (selectedRows.value.length === 0) {
    ElMessage.warning('请先选择要操作的公告')
    return
  }
  
  const statusText = status === 1 ? '启用' : '停用'
  
  try {
    loading.value = true
    let successCount = 0
    let failCount = 0
    
    for (const row of selectedRows.value) {
      try {
        const res = await updateAnnouncementStatus(row.id, status)
        if (res.code === 1) {
          successCount++
        } else {
          failCount++
        }
      } catch {
        failCount++
      }
    }
    
    if (successCount > 0) {
      ElMessage.success(`成功${statusText} ${successCount} 个公告${failCount > 0 ? `，失败 ${failCount} 个` : ''}`)
      clearSelection()
      await fetchData()
    } else {
      ElMessage.error(`批量${statusText}失败`)
    }
  } catch (err) {
    console.error(err)
    ElMessage.error(`批量${statusText}失败`)
  } finally {
    loading.value = false
  }
}

// 批量删除
const handleBatchDelete = async () => {
  if (selectedRows.value.length === 0) {
    ElMessage.warning('请先选择要删除的公告')
    return
  }
  
  try {
    loading.value = true
    let successCount = 0
    let failCount = 0
    
    for (const row of selectedRows.value) {
      try {
        const res = await deleteAnnouncement(row.id)
        if (res.code === 1) {
          successCount++
        } else {
          failCount++
        }
      } catch {
        failCount++
      }
    }
    
    if (successCount > 0) {
      ElMessage.success(`成功删除 ${successCount} 个公告${failCount > 0 ? `，失败 ${failCount} 个` : ''}`)
      clearSelection()
      await fetchData()
    } else {
      ElMessage.error('批量删除失败')
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('批量删除失败')
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await fetchMerchantInfo()
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
    
    .add-btn {
      background: linear-gradient(to right, #4f46e5, #6366f1);
      border: none;
      
      &:hover {
        opacity: 0.9;
        transform: translateY(-1px);
      }
    }
  }
}

.batch-toolbar {
  margin-bottom: 16px;
  padding: 12px 20px;
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: 6px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .batch-left {
    display: flex;
    align-items: center;
    color: #606266;
    
    .batch-icon {
      font-size: 18px;
      color: var(--primary-color);
      margin-right: 8px;
    }
    
    .selected-info {
      font-size: 14px;
      
      .num {
        color: var(--primary-color);
        font-weight: bold;
        font-size: 16px;
        margin: 0 4px;
      }
    }
  }
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
