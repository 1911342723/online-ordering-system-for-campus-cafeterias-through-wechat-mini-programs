<template>
  <div class="app-container">
    <div class="card-header-action">
      <div class="left">
        <el-input v-model="queryParams.name" placeholder="搜索菜品名称" prefix-icon="Search" style="width: 240px" clearable />
        <el-select v-model="queryParams.categoryId" placeholder="菜品分类" style="width: 150px; margin-left: 10px;" clearable>
          <el-option v-for="cat in categoryList" :key="cat.id" :label="cat.name" :value="cat.id" />
        </el-select>
        <el-button type="primary" @click="fetchData" style="margin-left: 10px;">查询</el-button>
      </div>
      <div class="right">
        <el-button type="success" icon="Plus" @click="handleAdd">新建菜品</el-button>
      </div>
    </div>

    <el-card shadow="never" class="table-card">
      <el-table :data="tableData" v-loading="loading" style="width: 100%">
        <el-table-column prop="image" label="图片" width="100">
          <template #default="{ row }">
            <el-image 
              style="width: 60px; height: 60px; border-radius: 8px;" 
              :src="getImageUrl(row.image)" 
              :preview-src-list="[getImageUrl(row.image)]"
              fit="cover"
            >
              <template #error>
                <div class="image-slot">
                  <el-icon><Picture /></el-icon>
                </div>
              </template>
            </el-image>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="菜品名称" min-width="120" />
        <el-table-column prop="categoryName" label="分类" width="120">
          <template #default="{ row }">
            <el-tag effect="plain">{{ row.categoryName }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="price" label="价格" width="120">
          <template #default="{ row }">
            <span class="price-text">¥{{ (row.price / 100).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
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
        <el-table-column prop="updateTime" label="最后更新" width="180" />
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-popconfirm
              title="确认删除该菜品吗？"
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
        label-width="100px"
      >
        <el-form-item label="菜品名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入菜品名称" />
        </el-form-item>
        <el-form-item label="菜品分类" prop="categoryId">
          <el-select v-model="formData.categoryId" placeholder="请选择菜品分类" style="width: 100%">
            <el-option v-for="cat in categoryList" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="菜品价格" prop="price">
          <el-input-number 
            v-model="formData.price" 
            :min="0" 
            :precision="2"
            :step="0.1"
            placeholder="请输入价格"
            controls-position="right"
            style="width: 100%"
          />
          <span style="margin-left: 10px; color: #909399;">元</span>
        </el-form-item>
        <el-form-item label="菜品图片" prop="image">
          <el-upload
            class="dish-uploader"
            :action="uploadUrl"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
          >
            <img v-if="formData.image" :src="getImageUrl(formData.image)" class="dish-image" />
            <el-icon v-else class="dish-uploader-icon"><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">建议上传尺寸400x400的图片，大小不超过2M</div>
        </el-form-item>
        <el-form-item label="菜品描述" prop="description">
          <el-input 
            v-model="formData.description" 
            type="textarea" 
            :rows="3"
            placeholder="请输入菜品描述"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status" v-if="isEdit">
          <el-radio-group v-model="formData.status">
            <el-radio :label="1">在售</el-radio>
            <el-radio :label="0">停售</el-radio>
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
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getDishPage, changeDishStatus, deleteDish, addDish, updateDish, getDishById } from '@/api/dish'
import { getCategoryList } from '@/api/category'
import { getMerchantByEmployeeId } from '@/api/merchant'
import { getImageUrl } from '@/api/common'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const categoryList = ref([])
const dialogVisible = ref(false)
const submitLoading = ref(false)
const formRef = ref(null)
const isEdit = ref(false)
const currentMerchantId = ref(null)

// 上传地址
const uploadUrl = import.meta.env.VITE_API_BASE_URL ? 
  `${import.meta.env.VITE_API_BASE_URL}/common/upload` : 
  '/api/common/upload'

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  name: '',
  categoryId: null
})

const formData = reactive({
  id: null,
  name: '',
  categoryId: null,
  merchantId: null,
  price: 0,
  image: '',
  description: '',
  status: 1
})

const dialogTitle = computed(() => isEdit.value ? '编辑菜品' : '新建菜品')

const formRules = {
  name: [
    { required: true, message: '请输入菜品名称', trigger: 'blur' },
    { min: 2, max: 50, message: '菜品名称长度在2-50个字符', trigger: 'blur' }
  ],
  categoryId: [{ required: true, message: '请选择菜品分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入菜品价格', trigger: 'blur' }],
  image: [{ required: true, message: '请上传菜品图片', trigger: 'change' }]
}

// 获取分类列表
const fetchCategoryList = async () => {
  try {
    const res = await getCategoryList({ type: 1 }) // type=1表示菜品分类
    if (res.code === 1) {
      categoryList.value = res.data
    }
  } catch (err) {
    console.error(err)
  }
}

// 获取数据
const fetchData = async () => {
  loading.value = true
  try {
    const res = await getDishPage({
      page: queryParams.page,
      pagesize: queryParams.pageSize,
      name: queryParams.name,
      categoryId: queryParams.categoryId
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

const handleStatusChange = async (row) => {
  try {
    const res = await changeDishStatus(row.status, [row.id])
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

const handleDelete = async (row) => {
  try {
    const res = await deleteDish([row.id])
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

const handleAdd = () => {
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

const handleEdit = async (row) => {
  isEdit.value = true
  try {
    const res = await getDishById(row.id)
    if (res.code === 1) {
      Object.assign(formData, {
        id: res.data.id,
        name: res.data.name,
        categoryId: res.data.categoryId,
        merchantId: res.data.merchantId || currentMerchantId.value, // 使用菜品的merchantId或当前商家ID
        price: res.data.price / 100, // 分转元
        image: res.data.image,
        description: res.data.description,
        status: res.data.status
      })
      dialogVisible.value = true
    }
  } catch (err) {
    console.error(err)
    ElMessage.error('获取菜品详情失败')
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
        const submitData = {
          ...formData,
          price: Math.round(formData.price * 100) // 元转分
        }
        
        let res
        if (isEdit.value) {
          res = await updateDish(submitData)
        } else {
          res = await addDish(submitData)
        }
        
        if (res.code === 1) {
          ElMessage.success(isEdit.value ? '编辑成功' : '新建成功')
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

// 获取当前商家信息
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

// 重置表单
const resetForm = () => {
  Object.assign(formData, {
    id: null,
    name: '',
    categoryId: null,
    merchantId: currentMerchantId.value, // 保持商家ID
    price: 0,
    image: '',
    description: '',
    status: 1
  })
  formRef.value?.clearValidate()
}

onMounted(() => {
  fetchCategoryList()
  fetchMerchantInfo() // 获取商家信息
  fetchData()
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

.image-slot {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  background: #f5f7fa;
  color: #909399;
  font-size: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.dish-uploader {
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

  .dish-image {
    width: 178px;
    height: 178px;
    display: block;
    object-fit: cover;
  }

  .dish-uploader-icon {
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
</style>
