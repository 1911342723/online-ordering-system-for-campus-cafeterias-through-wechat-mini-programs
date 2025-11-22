# 前端API使用文档

## 概述

本文档说明前端如何调用后端API接口。所有API文件位于 `src/api/` 目录下。

## API文件结构

```
src/api/
├── index.js          # API统一导出
├── request.js        # Axios封装
├── login.js          # 登录相关
├── employee.js       # 员工管理
├── category.js       # 分类管理
├── dish.js           # 菜品管理
├── setmeal.js        # 套餐管理
├── order.js          # 订单管理
├── user.js           # 用户管理
├── address.js        # 地址管理
├── cart.js           # 购物车
└── common.js         # 文件上传下载
```

## 快速开始

### 方式一：按需导入（推荐）

```javascript
import { getDishPage, addDish, deleteDish } from '@/api/dish'
import { getCategoryList } from '@/api/category'

// 使用
const fetchDishes = async () => {
  const res = await getDishPage({ page: 1, pageSize: 10 })
  console.log(res.data)
}
```

### 方式二：统一导入

```javascript
import * as dishApi from '@/api/dish'
import * as categoryApi from '@/api/category'

// 使用
const res = await dishApi.getDishPage({ page: 1, pageSize: 10 })
```

### 方式三：从index导入

```javascript
import { getDishPage, getCategoryList } from '@/api'

// 使用
const res = await getDishPage({ page: 1, pageSize: 10 })
```

---

## API详细说明

### 1. 登录管理 (login.js)

```javascript
import { loginApi, logoutApi } from '@/api/login'

// 员工登录
const login = async () => {
  const res = await loginApi({
    username: 'admin',
    password: '123456'
  })
  if (res.code === 1) {
    console.log('登录成功', res.data)
  }
}

// 员工登出
const logout = async () => {
  const res = await logoutApi()
}
```

---

### 2. 员工管理 (employee.js)

```javascript
import { 
  getEmployeePage, 
  addEmployee, 
  updateEmployee, 
  getEmployeeById,
  changeEmployeeStatus 
} from '@/api/employee'

// 分页查询员工
const fetchEmployees = async () => {
  const res = await getEmployeePage({
    page: 1,
    pageSize: 10,
    name: '张三' // 可选，员工姓名搜索
  })
}

// 新增员工
const createEmployee = async () => {
  const res = await addEmployee({
    username: 'zhangsan',
    name: '张三',
    phone: '13800138000',
    sex: '1',
    idNumber: '110101199001011234'
  })
}

// 更新员工信息
const updateEmp = async () => {
  const res = await updateEmployee({
    id: 1,
    name: '张三',
    status: 1 // 0-禁用，1-启用
  })
}

// 获取员工详情
const getDetail = async (id) => {
  const res = await getEmployeeById(id)
}
```

---

### 3. 分类管理 (category.js)

```javascript
import { 
  getCategoryPage, 
  getCategoryList,
  addCategory, 
  updateCategory, 
  deleteCategory 
} from '@/api/category'

// 分页查询分类
const fetchCategories = async () => {
  const res = await getCategoryPage({
    page: 1,
    pageSize: 10
  })
}

// 获取所有分类（不分页，用于下拉选择）
const fetchAllCategories = async () => {
  const res = await getCategoryList()
}

// 新增分类
const createCategory = async () => {
  const res = await addCategory({
    name: '川菜',
    type: 1, // 1-菜品分类 2-套餐分类
    sort: 1
  })
}

// 更新分类
const updateCat = async () => {
  const res = await updateCategory({
    id: 1,
    name: '川菜',
    sort: 2
  })
}

// 删除分类
const deleteCat = async (id) => {
  const res = await deleteCategory(id)
}
```

---

### 4. 菜品管理 (dish.js)

```javascript
import { 
  getDishPage,
  getDishList,
  addDish, 
  updateDish, 
  deleteDish,
  getDishById,
  changeDishStatus 
} from '@/api/dish'

// 分页查询菜品
const fetchDishes = async () => {
  const res = await getDishPage({
    page: 1,
    pageSize: 10,
    name: '宫保鸡丁' // 可选，菜品名称搜索
  })
}

// 获取菜品列表（不分页）
const fetchDishList = async () => {
  const res = await getDishList({
    categoryId: 1, // 分类ID
    status: 1 // 1-在售 0-停售
  })
}

// 新增菜品
const createDish = async () => {
  const res = await addDish({
    name: '宫保鸡丁',
    categoryId: 1,
    price: 3800, // 单位：分
    image: 'xxx.jpg',
    description: '经典川菜',
    status: 1,
    flavors: [ // 口味
      { name: '辣度', value: '["不辣","微辣","中辣","重辣"]' },
      { name: '忌口', value: '["不要葱","不要蒜"]' }
    ]
  })
}

// 更新菜品
const updateDishInfo = async () => {
  const res = await updateDish({
    id: 1,
    name: '宫保鸡丁',
    price: 4000
  })
}

// 删除菜品（支持批量）
const deleteDishes = async () => {
  const res = await deleteDish([1, 2, 3])
}

// 获取菜品详情
const getDishDetail = async (id) => {
  const res = await getDishById(id)
}

// 修改菜品状态（起售/停售）
const changeDishSaleStatus = async (status, ids) => {
  const res = await changeDishStatus(status, ids)
}
```

---

### 5. 套餐管理 (setmeal.js)

```javascript
import { 
  getSetmealPage,
  getSetmealList,
  addSetmeal, 
  updateSetmeal, 
  deleteSetmeal,
  getSetmealById,
  changeSetmealStatus 
} from '@/api/setmeal'

// 分页查询套餐
const fetchSetmeals = async () => {
  const res = await getSetmealPage({
    page: 1,
    pageSize: 10,
    name: '工作餐' // 可选
  })
}

// 新增套餐
const createSetmeal = async () => {
  const res = await addSetmeal({
    name: '工作餐',
    categoryId: 2,
    price: 2000,
    image: 'xxx.jpg',
    description: '营养均衡',
    status: 1,
    setmealDishes: [ // 套餐包含的菜品
      { dishId: 1, copies: 1 },
      { dishId: 2, copies: 2 }
    ]
  })
}

// 删除套餐（支持批量）
const deleteSetmeals = async () => {
  const res = await deleteSetmeal([1, 2, 3])
}

// 修改套餐状态
const changeSetmealSaleStatus = async (status, ids) => {
  const res = await changeSetmealStatus(status, ids)
}
```

---

### 6. 订单管理 (order.js)

```javascript
import { 
  getOrderPage,
  getUserOrderPage,
  submitOrder,
  getOrderDetail,
  updateOrderStatus 
} from '@/api/order'

// 分页查询订单（管理端）
const fetchOrders = async () => {
  const res = await getOrderPage({
    page: 1,
    pageSize: 10
  })
}

// 分页查询订单（用户端）
const fetchUserOrders = async () => {
  const res = await getUserOrderPage({
    page: 1,
    pageSize: 5
  })
}

// 提交订单
const createOrder = async () => {
  const res = await submitOrder({
    addressBookId: 1,
    payMethod: 1, // 支付方式
    remark: '少盐少油'
  })
}

// 更新订单状态
const updateOrder = async () => {
  const res = await updateOrderStatus({
    id: 1,
    status: 2 // 订单状态
  })
}
```

---

### 7. 用户管理 (user.js)

```javascript
import { userLogin, sendCode, userLogout } from '@/api/user'

// 用户登录
const login = async () => {
  const res = await userLogin({
    phone: '13800138000',
    code: '1234' // 验证码
  })
}

// 发送验证码
const getCode = async () => {
  const res = await sendCode({
    phone: '13800138000'
  })
}
```

---

### 8. 地址管理 (address.js)

```javascript
import { 
  getAddressList,
  addAddress,
  updateAddress,
  deleteAddress,
  getAddressById,
  setDefaultAddress,
  getDefaultAddress 
} from '@/api/address'

// 获取地址列表
const fetchAddresses = async () => {
  const res = await getAddressList()
}

// 新增地址
const createAddress = async () => {
  const res = await addAddress({
    consignee: '张三',
    phone: '13800138000',
    detail: '北京市朝阳区xxx',
    label: '公司',
    isDefault: 0
  })
}

// 设置默认地址
const setDefault = async () => {
  const res = await setDefaultAddress({ id: 1 })
}

// 获取默认地址
const getDefault = async () => {
  const res = await getDefaultAddress()
}
```

---

### 9. 购物车 (cart.js)

```javascript
import { 
  addToCart,
  getCartList,
  subCart,
  cleanCart 
} from '@/api/cart'

// 添加商品到购物车
const addCart = async () => {
  const res = await addToCart({
    dishId: 1, // 或 setmealId
    dishFlavor: '微辣',
    number: 1
  })
}

// 获取购物车列表
const fetchCart = async () => {
  const res = await getCartList()
}

// 减少购物车商品
const subCartItem = async () => {
  const res = await subCart({
    dishId: 1
  })
}

// 清空购物车
const clearCart = async () => {
  const res = await cleanCart()
}
```

---

### 10. 文件上传下载 (common.js)

```javascript
import { uploadFile, getImageUrl } from '@/api/common'

// 文件上传
const handleUpload = async (file) => {
  const res = await uploadFile(file)
  if (res.code === 1) {
    const fileName = res.data // 返回的文件名
    console.log('上传成功', fileName)
  }
}

// 获取图片URL
const imageUrl = getImageUrl('xxx.jpg')
// 返回：/api/common/download?name=xxx.jpg
```

**在Element Plus上传组件中使用：**

```vue
<template>
  <el-upload
    action="/api/common/upload"
    :on-success="handleSuccess"
    :before-upload="beforeUpload"
  >
    <el-button type="primary">点击上传</el-button>
  </el-upload>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { getImageUrl } from '@/api/common'

const handleSuccess = (response) => {
  if (response.code === 1) {
    const imageUrl = getImageUrl(response.data)
    ElMessage.success('上传成功')
  }
}

const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2
  
  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
  }
  return isImage && isLt2M
}
</script>
```

---

## 响应数据格式

后端统一返回格式：

```javascript
{
  code: 1,        // 1-成功，0-失败
  data: {},       // 返回数据
  msg: "操作成功"  // 提示信息
}
```

### 错误处理

```javascript
import { getDishPage } from '@/api/dish'
import { ElMessage } from 'element-plus'

const fetchData = async () => {
  try {
    const res = await getDishPage({ page: 1, pageSize: 10 })
    if (res.code === 1) {
      console.log('成功', res.data)
    } else {
      ElMessage.error(res.msg || '操作失败')
    }
  } catch (error) {
    console.error('请求失败', error)
    // request.js 已经全局处理了错误提示
  }
}
```

---

## 完整示例

### 菜品管理页面

```vue
<template>
  <div>
    <el-button @click="handleAdd">新增菜品</el-button>
    <el-table :data="tableData" v-loading="loading">
      <el-table-column prop="name" label="菜品名称" />
      <el-table-column prop="price" label="价格" />
      <el-table-column label="操作">
        <template #default="{ row }">
          <el-button @click="handleEdit(row)">编辑</el-button>
          <el-button @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      v-model:current-page="page"
      v-model:page-size="pageSize"
      :total="total"
      @current-change="fetchData"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getDishPage, deleteDish } from '@/api/dish'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const fetchData = async () => {
  loading.value = true
  try {
    const res = await getDishPage({
      page: page.value,
      pageSize: pageSize.value
    })
    if (res.code === 1) {
      tableData.value = res.data.records
      total.value = res.data.total
    }
  } finally {
    loading.value = false
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确认删除?', '提示', { type: 'warning' })
    const res = await deleteDish([row.id])
    if (res.code === 1) {
      ElMessage.success('删除成功')
      fetchData()
    }
  } catch (e) {
    // 用户取消
  }
}

const handleAdd = () => {
  // 打开新增对话框
}

const handleEdit = (row) => {
  // 打开编辑对话框
}

onMounted(() => {
  fetchData()
})
</script>
```

---

## 注意事项

1. **所有金额单位为分**，显示时需要除以100
2. **所有分页查询的page从1开始**
3. **文件上传需要使用FormData格式**
4. **删除接口大多支持批量删除，传入ID数组**
5. **状态值说明**：
   - 员工状态：0-禁用，1-启用
   - 菜品/套餐状态：0-停售，1-在售
   - 分类类型：1-菜品分类，2-套餐分类

---

## 代理配置

前端已配置Vite代理，所有 `/api` 请求会自动转发到后端：

```javascript
// vite.config.js
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
      rewrite: (path) => path.replace(/^\/api/, '')
    }
  }
}
```

因此，前端请求 `/api/dish/page` 会自动转发到 `http://localhost:8080/dish/page`

---

## 常见问题

### Q1: 如何处理未登录跳转？
A: `request.js` 已配置响应拦截器，当收到 `NOTLOGIN` 消息时会自动跳转到登录页。

### Q2: 如何添加请求头（如Token）？
A: 在 `request.js` 的请求拦截器中添加：

```javascript
service.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`
  }
  return config
})
```

### Q3: 后端接口返回的code不一致怎么办？
A: 根据实际后端返回调整 `request.js` 中的响应拦截器逻辑。

---

**更新时间：** 2024-11-22  
**维护者：** 开发团队

