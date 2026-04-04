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
      // 优先读取后端实时余额，避免使用过期缓存
      const res = await request({
        url: '/payment/balance',
        method: 'GET',
        silent: true
      })

      if (res && res.balance !== undefined) {
        this.updateBalancePayMethodDesc(res.balance)
        return
      }

      // 接口异常时再兜底使用全局缓存
      const userInfo = app.globalData.userInfo
      if (userInfo && userInfo.balance !== undefined) {
        this.updateBalancePayMethodDesc(userInfo.balance)
      }
    } catch (error) {
      console.error('加载余额失败:', error)
    }
  },

  /**
   * 更新余额支付文案
   */
  updateBalancePayMethodDesc(balanceRaw) {
    const numericBalance = Number(balanceRaw)
    const balance = Number.isFinite(numericBalance) ? numericBalance.toFixed(2) : '0.00'
    const payMethods = this.data.payMethods.map((method) => {
      if (method.id === 3) {
        return {
          ...method,
          desc: `当前余额：¥${balance}`
        }
      }
      return method
    })

    this.setData({ payMethods })
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
      
      await request({
        url: '/payment/pay',
        method: 'POST',
        data: {
          orderId: this.data.orderId,
          payMethod: payMethod
        }
      })
      
      hideLoading()

      showSuccess('支付成功！')
      
      // 跳转到订单列表页，避免重复支付
      setTimeout(() => {
        wx.switchTab({
          url: '/pages/order/order'
        })
      }, 1500)
    } catch (error) {
      hideLoading()
      console.error('支付失败:', error)
      const msg = error && error.msg ? error.msg : '支付失败'
      if (msg.includes('余额不足')) {
        showError(`余额不足，当前需支付¥${this.data.orderAmount}`)
      } else {
        showError(msg)
      }
    }
  }
})

