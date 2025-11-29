// pages/radar/radar.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showError, getImageUrl } = require('../../utils/util')

// 食物类型对应的emoji图标
const FOOD_EMOJIS = ['🍱', '🥤', '🍜', '🍔', '🍕', '🍣', '🥗', '🍰', '🍲', '🌮']

Page({
  data: {
    locationStatus: '点击定位',
    showPopup: false,
    selectedStall: {},
    merchants: [],
    displayMerchants: [], // 雷达上显示的商家（最多6个）
    defaultImg: DEFAULT_IMAGES.merchant || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    
    // 用户位置
    userLocation: null
  },

  onLoad() {
    this.loadMerchants()
    this.checkLocation()
  },

  onShow() {
    // 刷新数据
    if (this.data.userLocation) {
      this.loadMerchants()
    }
  },

  /**
   * 检查定位权限
   */
  checkLocation() {
    wx.getSetting({
      success: (res) => {
        if (res.authSetting['scope.userLocation']) {
          this.getLocation()
        }
      }
    })
  },

  /**
   * 获取定位
   */
  onGetLocation() {
    this.getLocation()
  },

  /**
   * 获取位置
   */
  getLocation() {
    this.setData({ locationStatus: '定位中...' })
    
    wx.getLocation({
      type: 'gcj02', // 使用国测局坐标
      success: (res) => {
        console.log('定位成功:', res)
        
        this.setData({ 
          locationStatus: '已定位',
          userLocation: {
            latitude: res.latitude,
            longitude: res.longitude
          }
        })
        
        // 定位成功后重新加载商家并计算距离
        this.loadMerchants()
      },
      fail: (err) => {
        console.error('定位失败:', err)
        this.setData({ locationStatus: '定位失败' })
        wx.showToast({ title: '需要定位权限', icon: 'none' })
      }
    })
  },

  /**
   * 加载商家数据
   */
  async loadMerchants() {
    try {
      const res = await request({
        url: '/merchant/list',
        method: 'GET',
        data: {
          page: 1,
          pageSize: 20,
          status: 1
        }
      })
      
      let merchants = res.records || res || []
      
      // 处理商家数据
      merchants = merchants.map((merchant, index) => {
        const processed = {
          ...merchant,
          image: getImageUrl(merchant.image, DEFAULT_IMAGES.merchant),
          iconEmoji: FOOD_EMOJIS[index % FOOD_EMOJIS.length],
          tagList: merchant.tags ? merchant.tags.split(',').slice(0, 3) : []
        }
        
        // 计算距离
        if (this.data.userLocation && merchant.latitude && merchant.longitude) {
          const distance = this.calculateDistance(
            this.data.userLocation.latitude,
            this.data.userLocation.longitude,
            merchant.latitude,
            merchant.longitude
          )
          processed.distance = distance
          processed.distanceText = this.formatDistance(distance)
        } else if (this.data.userLocation) {
          // 如果商家没有坐标，生成模拟距离（100-2000米）
          const mockDistance = Math.floor(Math.random() * 1900 + 100)
          processed.distance = mockDistance
          processed.distanceText = this.formatDistance(mockDistance)
        }
        
        return processed
      })
      
      // 按距离排序
      if (this.data.userLocation) {
        merchants.sort((a, b) => (a.distance || 9999) - (b.distance || 9999))
      }
      
      // 取前6个显示在雷达上
      const displayMerchants = merchants.slice(0, 6).map((merchant, index) => ({
        ...merchant,
        positionStyle: this.getRadarPosition(index, merchants.length)
      }))
      
      this.setData({
        merchants,
        displayMerchants
      })
      
    } catch (error) {
      console.error('加载商家失败:', error)
      // 使用模拟数据
      this.loadMockData()
    }
  },

  /**
   * 加载模拟数据
   */
  loadMockData() {
    const mockMerchants = [
      { 
        id: 1, 
        name: '胖叔便当', 
        rating: 4.8, 
        tags: '实惠,量大,家常',
        description: '坚持手作，还原家里的味道。招牌红烧肉每天限量供应！',
        image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
        salesCount: 1200,
        positiveCount: 89,
        avgPrice: 15
      },
      { 
        id: 2, 
        name: '清爽柠檬', 
        rating: 4.9, 
        tags: '解暑,鲜果,饮品',
        description: '选用当季新鲜柠檬，现点现捣，绝对不加一滴浓缩汁。',
        image: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400&q=80',
        salesCount: 800,
        positiveCount: 156,
        avgPrice: 12
      },
      { 
        id: 3, 
        name: '深夜拉面', 
        rating: 4.7, 
        tags: '暖胃,夜宵,日式',
        description: '熬制12小时的豚骨汤底，温暖每一个晚归的灵魂。',
        image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
        salesCount: 650,
        positiveCount: 72,
        avgPrice: 28
      },
      {
        id: 4,
        name: '黄焖鸡米饭',
        rating: 4.6,
        tags: '下饭,实惠,快餐',
        description: '正宗济南黄焖鸡，鸡肉嫩滑，汤汁浓郁。',
        image: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&q=80',
        salesCount: 920,
        positiveCount: 68,
        avgPrice: 18
      },
      {
        id: 5,
        name: '麻辣香锅',
        rating: 4.8,
        tags: '麻辣,重口,聚餐',
        description: '自选食材，现炒现做，麻辣鲜香。',
        image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80',
        salesCount: 560,
        positiveCount: 95,
        avgPrice: 35
      }
    ]
    
    const merchants = mockMerchants.map((merchant, index) => {
      const mockDistance = Math.floor(Math.random() * 1900 + 100)
      return {
        ...merchant,
        iconEmoji: FOOD_EMOJIS[index % FOOD_EMOJIS.length],
        tagList: merchant.tags ? merchant.tags.split(',') : [],
        distance: mockDistance,
        distanceText: this.formatDistance(mockDistance)
      }
    })
    
    // 按距离排序
    merchants.sort((a, b) => a.distance - b.distance)
    
    const displayMerchants = merchants.slice(0, 6).map((merchant, index) => ({
      ...merchant,
      positionStyle: this.getRadarPosition(index, merchants.length)
    }))
    
    this.setData({
      merchants,
      displayMerchants
    })
  },

  /**
   * 计算两点之间的距离（米）
   * 使用 Haversine 公式
   */
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371000 // 地球半径（米）
    const dLat = this.deg2rad(lat2 - lat1)
    const dLon = this.deg2rad(lon2 - lon1)
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2)
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    const distance = R * c
    
    return Math.round(distance)
  },

  /**
   * 角度转弧度
   */
  deg2rad(deg) {
    return deg * (Math.PI / 180)
  },

  /**
   * 格式化距离显示
   */
  formatDistance(meters) {
    if (meters < 1000) {
      return `${meters}m`
    } else {
      return `${(meters / 1000).toFixed(1)}km`
    }
  },

  /**
   * 获取雷达上的位置样式
   */
  getRadarPosition(index, total) {
    // 在雷达圆周上均匀分布
    const positions = [
      { top: '15%', left: '20%' },
      { top: '25%', right: '15%' },
      { top: '55%', left: '8%' },
      { bottom: '25%', right: '20%' },
      { bottom: '15%', left: '35%' },
      { top: '45%', right: '5%' }
    ]
    
    const pos = positions[index % positions.length]
    let style = ''
    
    if (pos.top) style += `top: ${pos.top};`
    if (pos.bottom) style += `bottom: ${pos.bottom};`
    if (pos.left) style += `left: ${pos.left};`
    if (pos.right) style += `right: ${pos.right};`
    
    return style
  },

  /**
   * 点击商家
   */
  onStallClick(e) {
    const item = e.currentTarget.dataset.item
    
    if (!item) return
    
    this.setData({
      selectedStall: item,
      showPopup: true
    })
    // 不再震动
  },

  /**
   * 关闭弹窗
   */
  closePopup() {
    this.setData({ showPopup: false })
  },

  /**
   * 阻止事件冒泡
   */
  stopProp() {},

  /**
   * 跳转到商家菜单
   */
  goToMerchant(e) {
    const id = e.currentTarget.dataset.id
    this.closePopup()
    
    wx.navigateTo({
      url: `/pages/menu/menu?merchantId=${id}&merchantName=${encodeURIComponent(this.data.selectedStall.name)}`
    })
  }
})
