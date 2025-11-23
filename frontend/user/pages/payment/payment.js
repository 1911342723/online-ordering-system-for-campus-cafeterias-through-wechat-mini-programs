// pages/payment/payment.js
const app = getApp()
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    orderId: null,
    orderAmount: '0.00',
    payMethod: 3, // 默认余额支付：1-微信 2-支付宝 3-余额
    payMethods: [
      { id: 3, name: '余额支付', icon: '/assets/icons/icons8-钱包-100.png', desc: '当前余额：¥0.00' },
      { id: 1, name: '微信支付', icon: '/assets/icons/icons8-微信-100.png', desc: '' },
      { id: 2, name: '支付宝', icon: '/assets/icons/icons8-支付宝-96.png', desc: '' }
    ]
  },

  onLoad(options) {
    const { orderId } = options
    
    if (!orderId) {
      showError('订单信息错误')
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
      return
    }

    this.setData({ orderId })
    this.loadOrderInfo()
    this.loadUserBalance()
  },

  /**
   * 加载用户余额
   */
  async loadUserBalance() {
    try {
      const userInfo = app.globalData.userInfo
      if (userInfo && userInfo.balance !== undefined) {
        const balance = (userInfo.balance / 100).toFixed(2)
        const payMethods = this.data.payMethods
        payMethods[2].desc = `当前余额：¥${balance}`
        this.setData({ payMethods })
      }
    } catch (error) {
      console.error('加载余额失败:', error)
    }
  },

  /**
   * 选择支付方式
   */
  selectPayMethod(e) {
    const { method } = e.currentTarget.dataset
    this.setData({ payMethod: method })
  },

  /**
   * 加载订单信息
   */
  async loadOrderInfo() {
    try {
      const result = await request({
        url: `/order/${this.data.orderId}`,
        method: 'GET'
      })
      
      if (result) {
        this.setData({
          orderAmount: (result.amount / 100).toFixed(2)
        })
      }
    } catch (error) {
      console.error('加载订单信息失败:', error)
    }
  },

  /**
   * 确认支付
   */
  async confirmPay() {
    const { payMethod } = this.data
    
    try {
      showLoading('支付中...')
      
      const result = await request({
        url: '/payment/pay',
        method: 'POST',
        data: {
          orderId: this.data.orderId,
          payMethod: payMethod
        }
      })
      
      hideLoading()
      
      if (result.code === 1) {
        showSuccess('支付成功！')
        
        // 跳转到订单列表页，避免重复支付
        setTimeout(() => {
          wx.switchTab({
            url: '/pages/order/order'
          })
        }, 1500)
      } else {
        showError(result.msg || '支付失败')
      }
    } catch (error) {
      hideLoading()
      console.error('支付失败:', error)
      showError('支付失败')
    }
  }
})

