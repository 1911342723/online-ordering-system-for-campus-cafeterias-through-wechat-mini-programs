// pages/favorite/favorite.js
const app = getApp()
const { request } = require('../../utils/request')

Page({
  data: {
    activeTab: 0,
    merchants: [],
    dishes: [],
    loading: false
  },

  onLoad() {
    this.loadData()
  },

  onShow() {
    if (this.data.merchants.length > 0 || this.data.dishes.length > 0) {
      this.loadData()
    }
  },

  // 切换标签
  onTabChange(e) {
    this.setData({
      activeTab: e.detail.index
    })
  },

  // 加载数据
  async loadData() {
    this.setData({ loading: true })
    try {
      if (this.data.activeTab === 0) {
        await this.loadMerchants()
      } else {
        await this.loadDishes()
      }
    } finally {
      this.setData({ loading: false })
    }
  },

  // 加载收藏商家
  async loadMerchants() {
    try {
      const res = await request({
        url: '/favorite/merchant/my',
        method: 'GET'
      })
      
      if (res.code === 1) {
        this.setData({
          merchants: res.data || []
        })
      }
    } catch (error) {
      console.error('加载收藏商家失败:', error)
    }
  },

  // 加载收藏菜品
  async loadDishes() {
    try {
      const res = await request({
        url: '/favorite/dish/my',
        method: 'GET'
      })
      
      if (res.code === 1) {
        this.setData({
          dishes: res.data || []
        })
      }
    } catch (error) {
      console.error('加载收藏菜品失败:', error)
    }
  },

  // 取消收藏商家
  async cancelFavoriteMerchant(e) {
    const { merchantId } = e.currentTarget.dataset
    
    wx.showModal({
      title: '提示',
      content: '确定要取消收藏吗？',
      success: async (res) => {
        if (res.confirm) {
          try {
            const result = await request({
              url: `/favorite/merchant/${merchantId}`,
              method: 'POST'
            })
            
            if (result.code === 1) {
              wx.showToast({
                title: '已取消收藏',
                icon: 'success'
              })
              this.loadMerchants()
            }
          } catch (error) {
            console.error('取消收藏失败:', error)
          }
        }
      }
    })
  },

  // 取消收藏菜品
  async cancelFavoriteDish(e) {
    const { dishId } = e.currentTarget.dataset
    
    wx.showModal({
      title: '提示',
      content: '确定要取消收藏吗？',
      success: async (res) => {
        if (res.confirm) {
          try {
            const result = await request({
              url: `/favorite/dish/${dishId}`,
              method: 'POST'
            })
            
            if (result.code === 1) {
              wx.showToast({
                title: '已取消收藏',
                icon: 'success'
              })
              this.loadDishes()
            }
          } catch (error) {
            console.error('取消收藏失败:', error)
          }
        }
      }
    })
  },

  // 跳转到商家详情
  goToMerchant(e) {
    const { merchantId } = e.currentTarget.dataset
    wx.navigateTo({
      url: `/pages/merchant/merchant?id=${merchantId}`
    })
  },

  // 添加到购物车
  async addToCart(e) {
    const { dishId } = e.currentTarget.dataset
    
    try {
      const result = await request({
        url: '/shoppingCart/add',
        method: 'POST',
        data: {
          dishId: dishId,
          number: 1
        }
      })
      
      if (result.code === 1) {
        wx.showToast({
          title: '已加入购物车',
          icon: 'success'
        })
      }
    } catch (error) {
      console.error('加入购物车失败:', error)
    }
  }
})
