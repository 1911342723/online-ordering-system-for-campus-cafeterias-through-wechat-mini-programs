// pages/merchant/list.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { getImageUrl, showLoading, hideLoading, showError } = require('../../utils/util')

Page({
  data: {
    canteenId: 0,
    canteenName: '',
    merchantList: [],
    loading: true
  },

  onLoad(options) {
    console.log('商家列表页参数:', options)
    
    this.setData({
      canteenId: options.canteenId || 0,
      canteenName: decodeURIComponent(options.canteenName || '商家列表')
    })
    
    if (this.data.canteenId) {
      this.loadMerchantList()
    } else {
      showError('参数错误')
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
    }
  },

  /**
   * 加载商家列表
   */
  async loadMerchantList() {
    try {
      showLoading('加载商家中...')
      this.setData({ loading: true })
      
      const merchants = await request({
        url: '/merchant/list',
        method: 'GET',
        data: { canteenId: this.data.canteenId }
      })
      
      console.log('商家列表数据:', merchants)
      
      if (!merchants || merchants.length === 0) {
        this.setData({
          merchantList: [],
          loading: false
        })
        hideLoading()
        wx.showToast({
          title: '该食堂暂无商家',
          icon: 'none',
          duration: 2000
        })
        return
      }
      
      // 处理商家数据
      const processedMerchants = merchants.map(merchant => ({
        ...merchant,
        image: getImageUrl(merchant.image, DEFAULT_IMAGES.merchant || DEFAULT_IMAGES.canteen),
        avgPriceText: merchant.avgPrice ? `¥${merchant.avgPrice}` : '',
        ratingText: merchant.rating ? merchant.rating.toFixed(1) : '5.0',
        salesText: merchant.salesCount ? `月售${merchant.salesCount}` : '新店',
        statusText: this.getStatusText(merchant.status)
      }))
      
      this.setData({
        merchantList: processedMerchants,
        loading: false
      })
      
      hideLoading()
    } catch (error) {
      console.error('加载商家列表失败:', error)
      this.setData({ loading: false })
      hideLoading()
      showError('加载失败，请重试')
    }
  },

  /**
   * 获取状态文本
   */
  getStatusText(status) {
    const statusMap = {
      0: '休息中',
      1: '营业中',
      2: '筹备中'
    }
    return statusMap[status] || '未知'
  },

  /**
   * 跳转到商家菜单页
   */
  goToMenu(e) {
    const { id, name, status } = e.currentTarget.dataset
    
    if (status !== 1) {
      showError('该商家暂未营业')
      return
    }
    
    wx.navigateTo({
      url: `/pages/menu/menu?merchantId=${id}&merchantName=${name}`
    })
  },

  /**
   * 下拉刷新
   */
  onPullDownRefresh() {
    this.loadMerchantList().then(() => {
      wx.stopPullDownRefresh()
    })
  }
})

