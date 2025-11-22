// pages/recharge/recharge.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    balance: '0.00',
    selectedAmount: 10, // 默认选择10元
    customAmount: '',
    paymentMethod: 'wechat', // 默认微信支付
    displayAmount: '10.00'
  },

  onLoad(options) {
    this.loadUserBalance()
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
          balance: parseFloat(res.balance).toFixed(2)
        })
      }
    } catch (error) {
      console.error('加载用户余额失败:', error)
    }
  },

  /**
   * 选择充值金额
   */
  selectAmount(e) {
    const amount = parseInt(e.currentTarget.dataset.amount)
    this.setData({
      selectedAmount: amount,
      customAmount: '',
      displayAmount: amount.toFixed(2)
    })
  },

  /**
   * 自定义金额输入
   */
  onCustomAmountInput(e) {
    const value = e.detail.value
    this.setData({
      customAmount: value,
      selectedAmount: null
    })
  },

  /**
   * 自定义金额输入完成
   */
  onCustomAmountConfirm(e) {
    const value = parseFloat(e.detail.value)
    if (value && value > 0) {
      this.setData({
        displayAmount: value.toFixed(2)
      })
    }
  },

  /**
   * 选择支付方式
   */
  selectPayment(e) {
    const { method } = e.currentTarget.dataset
    this.setData({ paymentMethod: method })
  },

  /**
   * 提交充值
   */
  async submitRecharge() {
    let amount = this.data.selectedAmount
    
    // 如果是自定义金额
    if (!amount && this.data.customAmount) {
      amount = parseFloat(this.data.customAmount)
    }

    // 验证金额
    if (!amount || amount <= 0) {
      showError('请选择或输入充值金额')
      return
    }

    if (amount > 10000) {
      showError('单次充值金额不能超过10000元')
      return
    }

    const payTypeName = this.data.paymentMethod === 'wechat' ? '微信' : '支付宝'
    
    wx.showModal({
      title: '确认充值',
      content: `确定使用${payTypeName}充值 ¥${amount.toFixed(2)} 吗？`,
      success: async (res) => {
        if (res.confirm) {
          try {
            showLoading('充值中...')
            
            const result = await request({
              url: '/payment/recharge',
              method: 'POST',
              data: {
                amount: amount,
                payType: this.data.paymentMethod
              }
            })
            
            hideLoading()
            
            // request已经返回data，不需要再取result.data
            if (result && result.success) {
              showSuccess('充值成功！')
              
              // 更新余额显示
              this.setData({
                balance: result.balance
              })
              
              // 延迟返回上一页或个人中心
              setTimeout(() => {
                wx.navigateBack()
              }, 1500)
            } else {
              showError(result.message || '充值失败')
            }
          } catch (error) {
            hideLoading()
            console.error('充值失败:', error)
            showError(error.msg || '充值失败，请重试')
          }
        }
      }
    })
  }
})

