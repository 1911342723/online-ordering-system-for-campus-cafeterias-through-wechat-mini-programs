// pages/review/add.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    orderId: '',
    merchantId: '',
    rating: 5,
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
    const value = e.currentTarget.dataset.value
    this.setData({ rating: value })
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
