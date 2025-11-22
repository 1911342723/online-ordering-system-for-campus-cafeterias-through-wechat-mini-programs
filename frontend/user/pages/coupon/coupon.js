// pages/coupon/coupon.js
const request = require('../../utils/request')
const { showError, formatTime } = require('../../utils/util')

Page({
  data: {
    currentTab: 0,
    couponList: [],
    // 模拟数据
    mockCoupons: [
      {
        id: 1,
        name: '新人专享券',
        amount: 10,
        minAmount: 30,
        description: '全场通用',
        expireTime: '2025-12-31',
        status: 'unused'
      },
      {
        id: 2,
        name: '满减优惠券',
        amount: 20,
        minAmount: 50,
        description: '指定商家可用',
        expireTime: '2025-11-30',
        status: 'used'
      }
    ]
  },

  onLoad() {
    this.loadCoupons()
  },

  /**
   * 切换Tab
   */
  switchTab(e) {
    const index = e.currentTarget.dataset.index
    this.setData({ currentTab: index })
    this.loadCoupons()
  },

  /**
   * 加载优惠券列表
   */
  async loadCoupons() {
    try {
      const { formatTime } = require('../../utils/util')
      
      const result = await request({
        url: '/coupon/my',
        method: 'GET',
        data: { status: this.data.currentTab === 0 ? null : this.data.currentTab - 1 }
      })
      
      if (result && Array.isArray(result)) {
        const coupons = result.map(item => ({
          id: item.id,
          name: item.couponName,
          amount: parseFloat(item.amount).toFixed(0),
          minAmount: parseFloat(item.minAmount).toFixed(0),
          description: item.description || '全场通用',
          expireTime: formatTime(item.expireTime).split(' ')[0],
          status: item.status === 0 ? 'unused' : item.status === 1 ? 'used' : 'expired'
        }))
        
        this.setData({ couponList: coupons })
      } else {
        this.setData({ couponList: [] })
      }
      
    } catch (error) {
      console.error('加载优惠券失败:', error)
      // 失败时使用模拟数据
      this.setData({ couponList: this.data.mockCoupons })
    }
  },

  /**
   * 去领券
   */
  goToCanteenList() {
    wx.switchTab({
      url: '/pages/index/index'
    })
  }
})

