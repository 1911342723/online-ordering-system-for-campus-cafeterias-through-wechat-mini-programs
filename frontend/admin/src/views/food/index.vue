<template>
  <div class="app-container">
    <div class="card-header-action">
      <div class="left">
        <el-input v-model="queryParams.name" placeholder="搜索菜品名称" prefix-icon="Search" style="width: 240px" />
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
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
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

    <!-- Add/Edit Dialog would go here (simplified for now) -->
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getDishPage, changeDishStatus, deleteDish } from '@/api/dish'
import { getImageUrl } from '@/api/common'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)

const queryParams = reactive({
  page: 1,
  pageSize: 10,
  name: ''
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await getDishPage({
      page: queryParams.page,
      pagesize: queryParams.pageSize,
      name: queryParams.name
    })
    if (res.code === 1) {
      tableData.value = res.data.records
      total.value = res.data.total
    }
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}

const handleStatusChange = async (row) => {
  try {
    const res = await changeDishStatus(row.status, [row.id])
    if (res.code === 1) {
      ElMessage.success('状态更新成功')
      fetchData()
    } else {
      row.status = row.status === 1 ? 0 : 1 // revert
      ElMessage.error(res.msg)
    }
  } catch (err) {
    row.status = row.status === 1 ? 0 : 1 // revert
  }
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确认删除该菜品吗?', '提示', {
    type: 'warning'
  }).then(async () => {
    const res = await deleteDish([row.id])
    if (res.code === 1) {
      ElMessage.success('删除成功')
      fetchData()
    }
  })
}

const handleAdd = () => {
  ElMessage.info('新增功能待弹窗组件完善')
}

const handleEdit = (row) => {
  ElMessage.info('编辑功能待弹窗组件完善')
}

onMounted(() => {
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
</style>
