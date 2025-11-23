// pages/order/detail.js
const request = require('../../utils/request')
const { getOrderStatusText } = require('../../utils/config')
const { showError, showSuccess, showLoading, hideLoading, formatTime, formatPrice } = require('../../utils/util')

Page({
  data: {
    orderId: null,
    orderInfo: {},
    dishList: [],
    dishAmount: '0.00',
    statusText: '',
    statusDesc: ''
  },

  onLoad(options) {
    const { id } = options
    
    if (!id) {
      showError('订单信息错误')
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
      return
    }

    this.setData({ orderId: id })
    this.loadOrderDetail()
  },

  /**
   * 加载订单详情
   */
  async loadOrderDetail() {
    try {
      showLoading('加载中...')
      
      const result = await request({
        url: `/order/${this.data.orderId}`,
        method: 'GET'
      })
      
      hideLoading()
      
      if (result) {
        // 格式化订单信息
        const orderInfo = {
          ...result,
          orderTime: formatTime(result.orderTime),
          amount: formatPrice(result.amount),
          deliveryFee: formatPrice(result.deliveryFee || 0)
        }
        
        // 计算菜品金额
        const dishAmount = result.deliveryFee 
          ? (parseFloat(result.amount) - parseFloat(result.deliveryFee)).toFixed(2)
          : result.amount
        
        // 设置状态文本和描述
        const statusInfo = this.getStatusInfo(result.status, result.deliveryType)
        
        this.setData({
          orderInfo,
          dishAmount: formatPrice(dishAmount),
          statusText: getOrderStatusText(result.status, result.deliveryType),
          statusDesc: statusInfo.desc
        })
        
        // 加载订单明细
        this.loadOrderDetails()
      }
    } catch (error) {
      hideLoading()
      console.error('加载订单详情失败:', error)
      showError('加载失败')
    }
  },

  /**
   * 加载订单明细（商品列表）
   */
  async loadOrderDetails() {
    try {
      // 如果后端已经返回了订单详情
      const orderDetails = this.data.orderInfo.orderDetails
      if (orderDetails && orderDetails.length > 0) {
        const dishList = orderDetails.map(item => ({
          ...item,
          amount: formatPrice(item.amount)
        }))
        this.setData({ dishList })
      }
    } catch (error) {
      console.error('加载订单明细失败:', error)
    }
  },

  /**
   * 获取状态信息
   */
  getStatusInfo(status, deliveryType) {
    // 自取订单状态描述
    const pickupStatusMap = {
      1: { desc: '订单已提交，请尽快完成支付' },
      2: { desc: '等待商家接单' },
      3: { desc: '商家正在准备您的订单' },
      4: { desc: '您的订单已准备好，请前往取餐' },
      5: { desc: '感谢您的光临，期待再次为您服务' },
      6: { desc: '订单已取消' }
    }
    
    // 外送订单状态描述
    const deliveryStatusMap = {
      1: { desc: '订单已提交，请尽快完成支付' },
      2: { desc: '等待商家接单' },
      3: { desc: '商家正在准备您的订单' },
      4: { desc: '您的订单正在配送中，请注意查收' },
      5: { desc: '感谢您的光临，期待再次为您服务' },
      6: { desc: '订单已取消' }
    }
    
    const statusMap = deliveryType === 2 ? deliveryStatusMap : pickupStatusMap
    return statusMap[status] || { desc: '' }
  },

  /**
   * 去支付
   */
  goPay() {
    wx.navigateTo({
      url: `/pages/payment/payment?orderId=${this.data.orderId}`
    })
  },

  /**
   * 去评价
   */
  goReview() {
    wx.navigateTo({
      url: `/pages/review/add?orderId=${this.data.orderId}&merchantId=${this.data.orderInfo.merchantId}`
    })
  },

  /**
   * 取消订单
   */
  async cancelOrder() {
    const result = await wx.showModal({
      title: '确认取消',
      content: '确定要取消该订单吗?'
    })

    if (!result.confirm) return

    try {
      showLoading('取消中...')
      
      await request({
        url: `/order/cancel/${this.data.orderId}`,
        method: 'PUT'
      })

      hideLoading()
      showSuccess('订单已取消')
      
      setTimeout(() => {
        this.loadOrderDetail()
      }, 1500)
    } catch (error) {
      hideLoading()
      console.error('取消订单失败:', error)
      showError(error.msg || '取消失败')
    }
  },

  /**
   * 申请退款
   */
  async applyRefund() {
    const result = await wx.showModal({
      title: '申请退款',
      content: '确定要申请退款吗?',
      editable: true,
      placeholderText: '请输入退款原因'
    })

    if (!result.confirm) return

    try {
      showLoading('申请中...')
      
      await request({
        url: `/order/refund/${this.data.orderId}`,
        method: 'POST',
        data: {
          reason: result.content || '无理由退款'
        }
      })

      hideLoading()
      showSuccess('退款申请已提交')
      
      setTimeout(() => {
        this.loadOrderDetail()
      }, 1500)
    } catch (error) {
      hideLoading()
      console.error('申请退款失败:', error)
      showError(error.msg || '申请失败')
    }
  }
})

