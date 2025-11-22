// pages/order/order.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES, getOrderStatusText } = require('../../utils/config')
const { formatPrice, formatTime, getImageUrl, showLoading, hideLoading, showError, checkLogin, navigateToLogin } = require('../../utils/util')

Page({
  data: {
    currentTab: 0,
    orders: [],
    defaultOrderImg: DEFAULT_IMAGES.order,
    statusFilter: '' // 状态过滤：'', 3(制作中), 4(待取餐), 5(已完成)
  },

  onShow() {
    if (!checkLogin()) {
      navigateToLogin()
      return
    }
    this.loadOrders()
  },

  /**
   * 切换标签页
   */
  switchTab(e) {
    const index = parseInt(e.currentTarget.dataset.index)
    let statusFilter = 0
    
    switch(index) {
      case 0: statusFilter = 0; break       // 全部（0表示不筛选）
      case 1: statusFilter = 1; break       // 待付款
      case 2: statusFilter = 2; break       // 待派送
      case 3: statusFilter = 3; break       // 已派送
      case 4: statusFilter = 4; break       // 已完成
    }
    
    console.log('切换Tab:', index, '筛选状态:', statusFilter)
    
    this.setData({
      currentTab: index,
      statusFilter: statusFilter
    })
    this.loadOrders()
  },

  /**
   * 加载订单列表 - 对接后端API
   */
  async loadOrders() {
    showLoading('加载中...')
    try {
      const requestData = {
        page: 1,
        pageSize: 20
      }
      
      // 如果有状态筛选，添加status参数（只有当statusFilter > 0时才传，空字符串不传）
      if (this.data.statusFilter && this.data.statusFilter > 0) {
        requestData.status = this.data.statusFilter
        console.log('筛选状态:', this.data.statusFilter)
      } else {
        console.log('查询所有订单')
      }
      
      const result = await request({
        url: '/order/userPage',
        method: 'GET',
        data: requestData
      })
      
      hideLoading()
      
      if (result && result.records) {
        const orders = result.records.map(order => {
          // 获取第一个菜品信息
          const firstDish = order.orderDetails && order.orderDetails.length > 0 
            ? order.orderDetails[0] 
            : null
          
          const deliveryType = order.deliveryType || 1
          const statusText = getOrderStatusText(order.status, deliveryType)
          
          console.log(`订单${order.id}: 状态${order.status}, 配送方式${deliveryType}, 状态文本: ${statusText}`)
          
          return {
            id: order.id || order.number,
            shopName: order.canteenName || '第一食堂',
            status: order.status,
            deliveryType: deliveryType,
            statusText: statusText,
            firstDishName: firstDish ? firstDish.name : '订单商品',
            count: order.sumNum || 1,
            amount: formatPrice(order.amount),
            orderTime: formatTime(order.orderTime),
            image: firstDish ? getImageUrl(firstDish.image, DEFAULT_IMAGES.order) : DEFAULT_IMAGES.order
          }
        })
        
        this.setData({ orders })
      } else {
        this.setData({ orders: [] })
      }
    } catch (error) {
      hideLoading()
      console.error('加载订单失败:', error)
      // 使用模拟数据作为降级方案
      this.loadMockOrders()
    }
  },

  /**
   * 加载模拟订单（降级方案）
   */
  loadMockOrders() {
    const mockOrders = [
      {
        id: '1234567890',
        shopName: '第一食堂',
        status: 5,
        statusText: '已完成',
        firstDishName: '宫保鸡丁',
        count: 2,
        amount: '28.00',
        orderTime: formatTime(new Date(Date.now() - 3600000)),
        image: DEFAULT_IMAGES.order
      },
      {
        id: '1234567891',
        shopName: '第二食堂',
        status: 3,
        statusText: '制作中',
        firstDishName: '牛肉面',
        count: 1,
        amount: '15.00',
        orderTime: formatTime(new Date()),
        image: DEFAULT_IMAGES.order
      },
      {
        id: '1234567892',
        shopName: '教工食堂',
        status: 4,
        statusText: '待取餐',
        firstDishName: '红烧肉套餐',
        count: 3,
        amount: '45.00',
        orderTime: formatTime(new Date(Date.now() - 1800000)),
        image: DEFAULT_IMAGES.order
      }
    ]
    
    // 过滤
    let filteredOrders = mockOrders
    if (this.data.statusFilter) {
      filteredOrders = mockOrders.filter(o => o.status === this.data.statusFilter)
    }
    
    this.setData({ orders: filteredOrders })
    showError('网络异常，使用模拟数据')
  },

  /**
   * 再来一单
   */
  reorder(e) {
    const orderId = e.currentTarget.dataset.id
    wx.showModal({
      title: '提示',
      content: '确定要再来一单吗？',
      success: (res) => {
        if (res.confirm) {
          // 这里应该调用后端接口获取订单详情，然后跳转到菜单页或直接下单
          showError('再来一单功能开发中...')
        }
      }
    })
  },

  /**
   * 去支付
   */
  goPay(e) {
    const orderId = e.currentTarget.dataset.id
    // 跳转到支付页面
    wx.navigateTo({
      url: `/pages/payment/payment?orderId=${orderId}`
    })
  },

  /**
   * 查看订单详情
   */
  viewOrderDetail(e) {
    const orderId = e.currentTarget.dataset.id
    wx.navigateTo({ 
      url: `/pages/order/detail?id=${orderId}` 
    })
  }
})

