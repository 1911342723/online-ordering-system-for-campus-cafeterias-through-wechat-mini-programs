// pages/review/add.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    orderId: '',
    merchantId: '',
    rating: 5,
    tasteRating: 5,    // 口味评分
    serviceRating: 5,  // 服务评分
    speedRating: 5,    // 速度评分
    content: '',
    ratingText: {
      1: '非常差',
      2: '差',
      3: '一般',
      4: '好',
      5: '非常好'
    }
  },

  onLoad(options) {
    if (options.orderId) {
      this.setData({
        orderId: options.orderId,
        merchantId: options.merchantId || ''
      })
    }
  },

  setRating(e) {
    const value = parseInt(e.currentTarget.dataset.value)
    const type = e.currentTarget.dataset.type || 'rating'
    this.setData({ [type]: value })
  },

  onInput(e) {
    this.setData({ content: e.detail.value })
  },

  async submitReview() {
    if (!this.data.rating) {
      showError('请选择评分')
      return
    }

    try {
      showLoading('提交中...')
      
      await request({
        url: '/review',
        method: 'POST',
        data: {
          orderId: this.data.orderId,
          merchantId: this.data.merchantId,
          rating: this.data.rating,
          tasteRating: this.data.tasteRating,
          serviceRating: this.data.serviceRating,
          speedRating: this.data.speedRating,
          content: this.data.content
        }
      })

      hideLoading()
      showSuccess('评价成功')
      
      // 延迟返回，让用户看到成功提示
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
      
    } catch (error) {
      hideLoading()
      console.error('评价失败:', error)
      showError(error.msg || '评价失败，请重试')
    }
  }
})
