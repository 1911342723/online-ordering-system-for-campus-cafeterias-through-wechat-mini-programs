/**
 * 通用工具函数
 */

/**
 * 格式化价格 - 后端返回的是分，需要转换为元
 * @param {number} price - 价格（分）
 * @returns {string} 格式化后的价格
 */
function formatPrice(price) {
  if (!price && price !== 0) return '0.00'
  // 后端返回的是分（BigDecimal），需要除以100转换为元
  return (parseFloat(price) / 100).toFixed(2)
}

/**
 * 格式化时间 - 兼容iOS
 * @param {string|Date} time - 时间
 * @returns {string} 格式化后的时间
 */
function formatTime(time) {
  if (!time) return ''
  
  // iOS兼容处理：将 "2025-11-22 18:43:02" 转为 "2025-11-22T18:43:02"
  let dateString = time
  if (typeof time === 'string' && time.includes(' ') && !time.includes('T')) {
    dateString = time.replace(' ', 'T')
  }
  
  const date = new Date(dateString)
  
  // 检查日期是否有效
  if (isNaN(date.getTime())) {
    console.error('Invalid date:', time)
    return time
  }
  
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hour = String(date.getHours()).padStart(2, '0')
  const minute = String(date.getMinutes()).padStart(2, '0')
  
  return `${year}-${month}-${day} ${hour}:${minute}`
}

/**
 * 格式化日期
 * @param {string|Date} time - 时间
 * @returns {string} 格式化后的日期
 */
function formatDate(time) {
  if (!time) return ''
  
  const date = new Date(time)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  
  return `${year}-${month}-${day}`
}

/**
 * 防抖函数
 * @param {Function} func - 要执行的函数
 * @param {number} wait - 等待时间
 * @returns {Function}
 */
function debounce(func, wait = 500) {
  let timeout
  return function() {
    const context = this
    const args = arguments
    clearTimeout(timeout)
    timeout = setTimeout(() => {
      func.apply(context, args)
    }, wait)
  }
}

/**
 * 节流函数
 * @param {Function} func - 要执行的函数
 * @param {number} wait - 等待时间
 * @returns {Function}
 */
function throttle(func, wait = 500) {
  let previous = 0
  return function() {
    const now = Date.now()
    const context = this
    const args = arguments
    if (now - previous > wait) {
      func.apply(context, args)
      previous = now
    }
  }
}

/**
 * 获取图片URL（处理默认图）
 * @param {string} name - 图片名称
 * @param {string} defaultImg - 默认图片
 * @returns {string} 图片URL
 */
function getImageUrl(name, defaultImg = '') {
  if (!name) return defaultImg
  if (name.startsWith('http')) return name
  const { DOWNLOAD_URL_PREFIX } = require('./config')
  return `${DOWNLOAD_URL_PREFIX}${name}`
}

/**
 * 显示加载提示
 * @param {string} title - 提示文字
 */
function showLoading(title = '加载中...') {
  wx.showLoading({
    title,
    mask: true
  })
}

/**
 * 隐藏加载提示
 */
function hideLoading() {
  wx.hideLoading()
}

/**
 * 显示成功提示
 * @param {string} title - 提示文字
 */
function showSuccess(title) {
  wx.showToast({
    title,
    icon: 'success',
    duration: 2000
  })
}

/**
 * 显示错误提示
 * @param {string} title - 提示文字
 */
function showError(title) {
  wx.showToast({
    title,
    icon: 'none',
    duration: 2000
  })
}

/**
 * 显示确认对话框
 * @param {string} content - 内容
 * @param {string} title - 标题
 * @returns {Promise}
 */
function showConfirm(content, title = '提示') {
  return new Promise((resolve, reject) => {
    wx.showModal({
      title,
      content,
      success: (res) => {
        if (res.confirm) {
          resolve(true)
        } else {
          reject(false)
        }
      },
      fail: reject
    })
  })
}

/**
 * 检查登录状态
 * @returns {boolean}
 */
function checkLogin() {
  const token = wx.getStorageSync('token')
  const userInfo = wx.getStorageSync('userInfo')
  return !!(token && userInfo)
}

/**
 * 跳转到登录页
 */
function navigateToLogin() {
  wx.navigateTo({
    url: '/pages/login/login'
  })
}

module.exports = {
  formatPrice,
  formatTime,
  formatDate,
  debounce,
  throttle,
  getImageUrl,
  showLoading,
  hideLoading,
  showSuccess,
  showError,
  showConfirm,
  checkLogin,
  navigateToLogin
}

