// pages/payment/payment.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    orderId: null,
    orderInfo: {
      number: '',
      amount: '0.00'
    },
    paymentMethod: 'balance', // 默认选择余额支付
    userBalance: '0.00',
    insufficientBalance: false,
    selectedCoupon: null,
    finalAmount: '0.00'
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
    
    // 加载订单信息和用户余额
    this.loadOrderInfo()
    this.loadUserBalance()
  },

  /**
   * 加载订单信息
   */
  async loadOrderInfo() {
    try {
      const res = await request({
        url: `/order/${this.data.orderId}`,
        method: 'GET'
      })
      
      // request已经返回data，不需要再取res.data
      if (res) {
        const amount = parseFloat(res.amount || 0).toFixed(2)
        console.log('订单金额:', amount)
        
        this.setData({
          orderInfo: {
            number: res.number || '',
            amount: amount
          },
          finalAmount: amount
        })
        this.checkBalance()
      }
    } catch (error) {
      console.error('加载订单信息失败:', error)
      showError('加载订单信息失败')
    }
  },

  /**
   * 加载用户余额
   */
  async loadUserBalance() {
    try {
      const res = await request({
        url: '/payment/balance',
        method: 'GET'
      })
      
      // request已经返回data，不需要再取res.data
      if (res && res.balance !== undefined) {
        console.log('获取到用户余额:', res.balance)
        this.setData({
          userBalance: parseFloat(res.balance).toFixed(2)
        })
        this.checkBalance()
      }
    } catch (error) {
      console.error('加载用户余额失败:', error)
      showError('获取余额失败')
    }
  },

  /**
   * 检查余额是否充足
   */
  checkBalance() {
    const balance = parseFloat(this.data.userBalance || 0)
    const amount = parseFloat(this.data.orderInfo.amount || 0)
    
    console.log('余额检查 - 用户余额:', balance, '订单金额:', amount, '余额不足:', balance < amount)
    
    this.setData({
      insufficientBalance: balance < amount
    })
  },

  /**
   * 选择支付方式
   */
  selectPayment(e) {
    const { method } = e.currentTarget.dataset
    this.setData({ paymentMethod: method })
  },

  /**
   * 选择优惠券
   */
  selectCoupon() {
    wx.navigateTo({
      url: '/pages/coupon/select?orderId=' + this.data.orderId,
      events: {
        selectCoupon: (coupon) => {
          this.setData({ 
            selectedCoupon: coupon,
            finalAmount: (parseFloat(this.data.orderInfo.amount) - parseFloat(coupon.amount)).toFixed(2)
          })
          this.checkBalance()
        }
      }
    })
  },

  /**
   * 去充值
   */
  goRecharge() {
    wx.navigateTo({
      url: '/pages/recharge/recharge'
    })
  },

  /**
   * 提交支付
   */
  async submitPayment() {
    const { paymentMethod, orderId, orderInfo } = this.data

    // 如果是余额支付，检查余额
    if (paymentMethod === 'balance') {
      if (this.data.insufficientBalance) {
        wx.showModal({
          title: '余额不足',
          content: '您的余额不足，是否前往充值？',
          confirmText: '去充值',
          success: (res) => {
            if (res.confirm) {
              this.goRecharge()
            }
          }
        })
        return
      }

      // 使用余额支付
      await this.payByBalance()
    } else {
      // 使用第三方支付
      await this.payByMock()
    }
  },

  /**
   * 余额支付
   */
  async payByBalance() {
    try {
      showLoading('支付中...')
      
      const res = await request({
        url: '/payment/balance',
        method: 'POST',
        data: {
          orderId: this.data.orderId
        }
      })
      
      hideLoading()
      
      // request已经返回data，不需要再取res.data
      if (res && res.success) {
        showSuccess('支付成功！')
        
        // 延迟跳转到订单列表
        setTimeout(() => {
          wx.switchTab({
            url: '/pages/order/order'
          })
        }, 1500)
      } else {
        showError(res.message || '支付失败')
      }
    } catch (error) {
      hideLoading()
      console.error('支付失败:', error)
      showError(error.msg || '支付失败，请重试')
    }
  },

  /**
   * 模拟第三方支付
   */
  async payByMock() {
    const payTypeName = this.data.paymentMethod === 'wechat' ? '微信' : '支付宝'
    
    wx.showModal({
      title: '模拟支付',
      content: `确定使用${payTypeName}支付 ¥${this.data.orderInfo.amount} 吗？`,
      success: async (res) => {
        if (res.confirm) {
          try {
            showLoading('支付中...')
            
            const result = await request({
              url: '/payment/mock',
              method: 'POST',
              data: {
                orderId: this.data.orderId,
                payType: this.data.paymentMethod
              }
            })
            
            hideLoading()
            
            // request已经返回data，不需要再取result.data
            if (result && result.success) {
              showSuccess('支付成功！')
              
              // 延迟跳转到订单列表
              setTimeout(() => {
                wx.switchTab({
                  url: '/pages/order/order'
                })
              }, 1500)
            } else {
              showError(result.message || '支付失败')
            }
          } catch (error) {
            hideLoading()
            console.error('支付失败:', error)
            showError(error.msg || '支付失败，请重试')
          }
        }
      }
    })
  }
})

