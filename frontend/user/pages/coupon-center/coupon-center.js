// pages/coupon-center/coupon-center.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading, checkLogin, navigateToLogin, formatPrice } = require('../../utils/util')

Page({
  data: {
    coupons: []
  },

  onLoad() {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          } else {
            wx.navigateBack()
          }
        }
      })
      return
    }
    
    this.loadCoupons()
  },

  /**
   * 加载可领取的优惠券（平台券）
   */
  async loadCoupons() {
    try {
      showLoading('加载中...')
      
      const coupons = await request({
        url: '/coupon/available',
        method: 'GET',
        data: {
          type: 1 // 只查询平台券
        }
      })
      
      hideLoading()
      
      console.log('领券中心加载平台券:', coupons)
      
      if (coupons && coupons.length > 0) {
        const formattedCoupons = coupons.map(coupon => ({
          ...coupon,
          amount: Math.floor(parseFloat(coupon.amount) / 100), // 转为整数
          minAmount: Math.floor(parseFloat(coupon.minAmount) / 100), // 转为整数
          received: coupon.received || false // 使用后端返回的领取状态
        }))
        
        this.setData({ coupons: formattedCoupons })
      } else {
        this.setData({ coupons: [] })
      }
    } catch (error) {
      hideLoading()
      console.error('加载优惠券失败:', error)
      showError('加载失败')
    }
  },

  /**
   * 领取优惠券
   */
  async receiveCoupon(e) {
    const { id, index } = e.currentTarget.dataset
    const coupon = this.data.coupons[index]
    
    // 如果已领取，不允许重复领取
    if (coupon.received) {
      showError('您已经领取过该优惠券了')
      return
    }
    
    try {
      showLoading('领取中...')
      
      await request({
        url: `/coupon/receive/${id}`,
        method: 'POST'
      })
      
      hideLoading()
      showSuccess('领取成功')
      
      // 更新UI状态
      const coupons = this.data.coupons
      coupons[index].received = true
      coupons[index].remainCount--
      
      this.setData({ coupons })
    } catch (error) {
      hideLoading()
      console.error('领取优惠券失败:', error)
      
      if (error.msg) {
        showError(error.msg)
      } else {
        showError('领取失败，请重试')
      }
    }
  },

  /**
   * 查看我的优惠券
   */
  goToMyCoupons() {
    wx.navigateTo({
      url: '/pages/coupon/coupon'
    })
  }
})

