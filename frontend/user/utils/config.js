/**
 * 配置文件 - 默认图片、API基础URL等
 */

// 默认占位图
const DEFAULT_IMAGES = {
  // 轮播图默认图 - 使用高质量 Unsplash 图片
  banner: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
  
  // 食堂默认图
  canteen: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=500&q=80',
  
  // 商家默认图（窗口）
  merchant: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=500&q=80',
  
  // 菜品默认图
  dish: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80',
  
  // 用户头像默认图
  avatar: 'https://ui-avatars.com/api/?name=User&background=38bdf8&color=fff&rounded=true',
  
  // 空状态图
  empty: 'https://cdn-icons-png.flaticon.com/512/4076/4076432.png',
  
  // 订单默认图
  order: 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=200&q=80'
}

// API 基础URL
const API_BASE_URL = 'http://localhost:8080'

// 文件上传URL
const UPLOAD_URL = `${API_BASE_URL}/common/upload`

// 文件下载URL前缀
const DOWNLOAD_URL_PREFIX = `${API_BASE_URL}/common/download?name=`

// 订单状态映射 - 统一状态定义
const ORDER_STATUS = {
  1: '待付款',
  2: '待接单',
  3: '制作中',
  4: '待取餐',  // 自取订单
  5: '已完成',
  6: '已取消'
}

// 外送订单状态映射
const ORDER_STATUS_DELIVERY = {
  1: '待付款',
  2: '待接单',
  3: '制作中',
  4: '派送中',  // 外送订单
  5: '已完成',
  6: '已取消'
}

/**
 * 根据订单类型获取状态文本
 * @param {number} status - 订单状态
 * @param {number} deliveryType - 配送方式 1:自取 2:外送
 */
function getOrderStatusText(status, deliveryType) {
  // 区分自取和外送
  if (deliveryType === 2) {
    return ORDER_STATUS_DELIVERY[status] || '未知状态'
  }
  return ORDER_STATUS[status] || '未知状态'
}

// 订单状态颜色 - Updated to new palette
const ORDER_STATUS_COLOR = {
  1: '#38bdf8', // Brand Blue
  2: '#0284c7', // Dark Blue
  3: '#fbbf24', // Yellow/Amber
  4: '#34d399', // Green
  5: '#9ca3af', // Grey
  6: '#f87171'  // Red
}

// 菜品分类类型
const CATEGORY_TYPE = {
  1: '菜品分类',
  2: '套餐分类'
}

module.exports = {
  DEFAULT_IMAGES,
  API_BASE_URL,
  UPLOAD_URL,
  DOWNLOAD_URL_PREFIX,
  ORDER_STATUS,
  ORDER_STATUS_DELIVERY,
  ORDER_STATUS_COLOR,
  CATEGORY_TYPE,
  getOrderStatusText
}
