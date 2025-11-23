// pages/order/order.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES, getOrderStatusText } = require('../../utils/config')
const { formatPrice, formatTime, getImageUrl, showLoading, hideLoading, showError, checkLogin, navigateToLogin } = require('../../utils/util')

Page({
  data: {
    currentTab: 0,
    orders: [],
    defaultOrderImg: DEFAULT_IMAGES.order,
    statusFilter: '', // 状态过滤：'', 3(制作中), 4(待取餐), 5(已完成)
    page: 1,
    pageSize: 10,
    hasMore: true,
    isLoading: false
  },

  // 定时刷新定时器
  refreshTimer: null,

  onShow() {
    if (!checkLogin()) {
      navigateToLogin()
      return
    }
    // 刷新第一页
    this.resetAndLoad()
    // 启动定时刷新（每10秒刷新一次）
    this.startAutoRefresh()
  },

  onHide() {
    // 页面隐藏时停止定时刷新
    this.stopAutoRefresh()
  },

  onUnload() {
    // 页面卸载时停止定时刷新
    this.stopAutoRefresh()
  },

  /**
   * 启动自动刷新
   */
  startAutoRefresh() {
    this.stopAutoRefresh() // 先清除之前的定时器
    this.refreshTimer = setInterval(() => {
      // 静默刷新（不显示加载提示）
      this.silentRefresh()
    }, 10000) // 每10秒刷新一次
  },

  /**
   * 停止自动刷新
   */
  stopAutoRefresh() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
      this.refreshTimer = null
    }
  },

  /**
   * 静默刷新（不显示loading）
   */
  async silentRefresh() {
    if (this.data.isLoading) return
    
    try {
      const requestData = {
        page: 1,
        pageSize: this.data.page * this.data.pageSize // 加载当前已显示的所有数据
      }
      
      if (this.data.statusFilter && this.data.statusFilter > 0) {
        requestData.status = this.data.statusFilter
      }
      
      const result = await request({
        url: '/order/userPage',
        method: 'GET',
        data: requestData
      })

      if (result && result.records) {
        // 【关键修复】使用与 loadOrders 完全相同的格式化逻辑
        const formattedOrders = result.records.map(order => {
          // 获取第一个菜品信息
          const firstDish = order.orderDetails && order.orderDetails.length > 0 
            ? order.orderDetails[0] 
            : null
          
          const deliveryType = order.deliveryType || 1
          const statusText = getOrderStatusText(order.status, deliveryType)
          
          // 格式化菜品名称显示
          let dishNameText = '订单商品'
          if (firstDish) {
            if (order.orderDetails.length > 1) {
              dishNameText = `${firstDish.name} 等${order.orderDetails.length}件商品`
            } else {
              dishNameText = firstDish.name
            }
          }
          
          return {
            id: order.id || order.number,
            shopName: order.canteenName || '第一食堂',
            status: order.status,
            deliveryType: deliveryType,
            statusText: statusText,
            firstDishName: dishNameText,
            count: order.sumNum || 1,
            amount: formatPrice(order.amount),
            orderTime: formatTime(order.orderTime),
            image: firstDish ? getImageUrl(firstDish.image, DEFAULT_IMAGES.order) : DEFAULT_IMAGES.order
          }
        })

        this.setData({
          orders: formattedOrders
        })
      }
    } catch (error) {
      console.error('静默刷新失败:', error)
      // 静默失败，不提示用户
    }
  },

  // 下拉刷新
  onPullDownRefresh() {
    this.resetAndLoad()
  },

  // 上拉加载更多
  onReachBottom() {
    if (this.data.hasMore && !this.data.isLoading) {
      this.loadOrders()
    }
  },

  /**
   * 重置并加载第一页
   */
  async resetAndLoad() {
    this.setData({
      page: 1,
      orders: [],
      hasMore: true
    })
    await this.loadOrders()
    wx.stopPullDownRefresh()
  },

  /**
   * 切换标签页
   */
  switchTab(e) {
    const index = parseInt(e.currentTarget.dataset.index)
    let statusFilter = 0
    
    if (this.data.currentTab === index) return

    switch(index) {
      case 0: statusFilter = 0; break       // 全部（0表示不筛选）
      case 1: statusFilter = 1; break       // 待付款
      case 2: statusFilter = 2; break       // 待派送(制作中)
      case 3: statusFilter = 3; break       // 已派送(配送中)
      case 4: statusFilter = 4; break       // 已完成
    }
    
    this.setData({
      currentTab: index,
      statusFilter: statusFilter
    })
    this.resetAndLoad()
  },

  /**
   * 加载订单列表 - 对接后端API
   */
  async loadOrders() {
    if (this.data.isLoading || !this.data.hasMore) return

    this.setData({ isLoading: true })
    showLoading('加载中...')
    
    try {
      const requestData = {
        page: this.data.page,
        pageSize: this.data.pageSize
      }
      
      if (this.data.statusFilter && this.data.statusFilter > 0) {
        requestData.status = this.data.statusFilter
      }
      
      const result = await request({
        url: '/order/userPage',
        method: 'GET',
        data: requestData
      })
      
      hideLoading()
      
      if (result && result.records && result.records.length > 0) {
        const newOrders = result.records.map(order => {
          // 获取第一个菜品信息
          const firstDish = order.orderDetails && order.orderDetails.length > 0 
            ? order.orderDetails[0] 
            : null
          
          const deliveryType = order.deliveryType || 1
          const statusText = getOrderStatusText(order.status, deliveryType)
          
          // 格式化菜品名称显示
          let dishNameText = '订单商品'
          if (firstDish) {
            if (order.orderDetails.length > 1) {
              dishNameText = `${firstDish.name} 等${order.orderDetails.length}件商品`
            } else {
              dishNameText = firstDish.name
            }
          }
          
          return {
            id: order.id || order.number,
            shopName: order.canteenName || '第一食堂',
            status: order.status,
            deliveryType: deliveryType,
            statusText: statusText,
            firstDishName: dishNameText,
            count: order.sumNum || 1,
            amount: formatPrice(order.amount),
            orderTime: formatTime(order.orderTime),
            image: firstDish ? getImageUrl(firstDish.image, DEFAULT_IMAGES.order) : DEFAULT_IMAGES.order
          }
        })
        
        this.setData({
          orders: [...this.data.orders, ...newOrders],
          page: this.data.page + 1,
          isLoading: false,
          hasMore: newOrders.length === this.data.pageSize
        })
      } else {
        this.setData({
          isLoading: false,
          hasMore: false
        })
      }
    } catch (error) {
      hideLoading()
      console.error('加载订单失败:', error)
      this.setData({ isLoading: false })
      // 仅在第一页失败时加载模拟数据
      if (this.data.page === 1) {
        this.loadMockOrders()
      }
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

