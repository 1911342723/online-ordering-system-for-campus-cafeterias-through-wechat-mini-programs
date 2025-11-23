// pages/canteen-list/canteen-list.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { getImageUrl, showLoading, hideLoading, showError } = require('../../utils/util')

Page({
  data: {
    canteens: [],
    defaultCanteen: DEFAULT_IMAGES.canteen
  },

  onLoad() {
    this.loadCanteens()
  },

  /**
   * 加载食堂列表
   */
  async loadCanteens() {
    try {
      showLoading('加载中...')
      
      const canteens = await request({
        url: '/canteen/list',
        method: 'GET'
      })
      
      // 判断营业时间
      const currentHour = new Date().getHours()
      const isBusinessHours = currentHour >= 7 && currentHour < 21
      
      // 处理餐厅数据
      const processedCanteens = canteens.map(canteen => ({
        ...canteen,
        image: getImageUrl(canteen.image, DEFAULT_IMAGES.canteen),
        isOpen: canteen.status === 1 && isBusinessHours,
        rating: canteen.rating || '4.5',
        distance: canteen.distance || 100
      }))
      
      this.setData({ canteens: processedCanteens })
      hideLoading()
    } catch (error) {
      hideLoading()
      console.error('加载食堂列表失败:', error)
      showError(error.msg || '加载失败')
    }
  },

  /**
   * 跳转到商家列表
   */
  goToMerchantList(e) {
    const { id, name, isopen } = e.currentTarget.dataset
    
    if (!isopen) {
      showError('该食堂暂未营业')
      return
    }
    
    wx.navigateTo({
      url: `/pages/merchant/list?canteenId=${id}&canteenName=${name}`
    })
  }
})

