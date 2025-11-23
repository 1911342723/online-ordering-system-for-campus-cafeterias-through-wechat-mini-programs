// pages/index/index.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { getImageUrl, showLoading, hideLoading, showError, checkLogin, navigateToLogin, formatPrice } = require('../../utils/util')

// SVG Icons
const ICONS = {
  location: "/assets/icons/location.png",
  scan: "/assets/icons/scan.png",
  search: "/assets/icons/search.png",
  star: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23FFC833'%3E%3Cpath d='M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z'/%3E%3C/svg%3E",
  ai: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='64' height='64' viewBox='0 0 64 64'%3E%3Cdefs%3E%3ClinearGradient id='grad' x1='0%25' y1='0%25' x2='100%25' y2='100%25'%3E%3Cstop offset='0%25' style='stop-color:%236366F1;stop-opacity:1' /%3E%3Cstop offset='100%25' style='stop-color:%23A855F7;stop-opacity:1' /%3E%3C/linearGradient%3E%3C/defs%3E%3Ccircle cx='32' cy='32' r='28' fill='url(%23grad)' opacity='0.1'/%3E%3Cpath fill='url(%23grad)' d='M42,24c0,1.1-0.9,2-2,2h-4v4c0,1.1-0.9,2-2,2s-2-0.9-2-2v-4h-4c-1.1,0-2-0.9-2-2s0.9-2,2-2h4v-4c0-1.1,0.9-2,2-2s2,0.9,2,2v4h4C41.1,22,42,22.9,42,24z M46.5,39h-2.2c-0.4,0-0.7-0.2-0.9-0.5L41,34.8c-0.2-0.3-0.2-0.7,0-1l2.4-3.7c0.2-0.3,0.5-0.5,0.9-0.5h2.2c0.8,0,1.3,0.9,0.9,1.6l-2.4,3.7l2.4,3.7C47.8,39.1,47.3,39,46.5,39z M22,42c0,2.2-1.8,4-4,4s-4-1.8-4-4s1.8-4,4-4S22,39.8,22,42z'/%3E%3Cpath fill='white' d='M32,14l4,9l9,4l-9,4l-4,9l-4-9l-9-4l9-4L32,14z'/%3E%3C/svg%3E",
  announcement: "/assets/icons/announcement.png"
}

Page({
  data: {
    banners: [],
    canteens: [],
    announcements: [],
    todayRecommendations: [],
    coupons: [],
    showCouponDialog: false,
    defaultBanner: DEFAULT_IMAGES.banner,
    defaultCanteen: DEFAULT_IMAGES.canteen,
    currentHour: new Date().getHours(),
    icons: ICONS
  },

  onLoad() {
    this.checkLoginStatus()
    this.loadBanners()
    this.loadCanteens()
    this.loadAnnouncements()
    this.loadTodayRecommendations()
    this.loadCoupons() // 加载优惠券用于显示入口
  },

  onShow() {
    // 每次显示页面时刷新数据
    this.loadCanteens()
    this.loadAnnouncements()
    this.checkCouponDialog()
  },

  /**
   * 检查登录状态
   */
  checkLoginStatus() {
    if (!checkLogin()) {
      // 静默检查，不强制弹窗，只有在点击功能时才弹窗
    }
  },

  /**
   * 加载轮播图
   */
  loadBanners() {
    // 使用默认轮播图（实际项目可以从后端获取）
    const defaultBanners = [
      { id: 1, url: DEFAULT_IMAGES.banner, title: '欢迎使用智慧食堂' },
      { id: 2, url: DEFAULT_IMAGES.banner, title: '今日特价' },
      { id: 3, url: DEFAULT_IMAGES.banner, title: '新品推荐' }
    ]
    this.setData({ banners: defaultBanners })
  },

  /**
   * 加载食堂列表 - 对接真实后端API
   */
  async loadCanteens() {
    try {
      showLoading('加载中...')
      
      const canteens = await request({
        url: '/canteen/list',
        method: 'GET'
      })
      
      // 判断营业时间
      const currentHour = this.data.currentHour
      const isLunchTime = currentHour >= 11 && currentHour < 14
      const isDinnerTime = currentHour >= 17 && currentHour < 20
      const isBusinessHours = currentHour >= 7 && currentHour < 21
      
      // 处理餐厅数据
      const processedCanteens = canteens.map(canteen => ({
        ...canteen,
        image: getImageUrl(canteen.image, DEFAULT_IMAGES.canteen),
        isOpen: canteen.status === 1 && isBusinessHours,
        tags: this.parseBusinessHours(canteen.businessHours),
        distance: canteen.distance ? `${canteen.distance}m` : '100m',
        sales: 0 // 可以从订单统计获取
      }))
      
      this.setData({ canteens: processedCanteens })
      hideLoading()
    } catch (error) {
      hideLoading()
      console.error('加载餐厅列表失败:', error)
      // 使用模拟数据作为降级
      this.loadMockCanteens()
    }
  },

  /**
   * 解析营业时间为标签
   */
  parseBusinessHours(businessHours) {
    if (!businessHours) return ['全天营业']
    // 简单处理，可以根据实际情况扩展
    return ['营业中', businessHours]
  },

  /**
   * 加载模拟餐厅数据（降级方案）
   */
  loadMockCanteens() {
    const currentHour = this.data.currentHour
    const isLunchTime = currentHour >= 11 && currentHour < 14
    const isDinnerTime = currentHour >= 17 && currentHour < 20
    const isOpen = isLunchTime || isDinnerTime

    const mockCanteens = [
      {
        id: 1,
        name: '第一食堂',
        image: DEFAULT_IMAGES.canteen,
        tags: ['川菜', '面食', '经济实惠'],
        isOpen: isOpen,
        rating: 4.5,
        distance: '100m',
        sales: 2300
      },
      {
        id: 2,
        name: '第二食堂',
        image: DEFAULT_IMAGES.canteen,
        tags: ['自选餐', '清真', '环境好'],
        isOpen: isOpen,
        rating: 4.8,
        distance: '200m',
        sales: 1800
      },
      {
        id: 3,
        name: '第三食堂',
        image: DEFAULT_IMAGES.canteen,
        tags: ['美食广场', '小吃', '环境好'],
        isOpen: isOpen,
        rating: 4.6,
        distance: '300m',
        sales: 1200
      }
    ]
    
    this.setData({ canteens: mockCanteens })
  },

  /**
   * 跳转到商家列表页
   */
  /**
   * 跳转到食堂列表页
   */
  goToCanteenList() {
    wx.navigateTo({
      url: '/pages/canteen-list/canteen-list'
    })
  },

  goToMenu(e) {
    const { id, name, isopen } = e.currentTarget.dataset
    
    if (!isopen) {
      showError('该食堂暂未营业')
      return
    }
    
    wx.navigateTo({
      url: `/pages/merchant/list?canteenId=${id}&canteenName=${name}`
    })
  },

  /**
   * 扫码点餐
   */
  onScanCode() {
    wx.scanCode({
      success: (res) => {
        console.log('扫码结果:', res)
        // 解析二维码内容，跳转到对应菜单页
        // 假设二维码格式: canteen:1
        const result = res.result
        if (result.startsWith('canteen:')) {
          const canteenId = result.split(':')[1]
          wx.navigateTo({
            url: `/pages/menu/menu?canteenId=${canteenId}`
          })
        } else {
          showError('无效的二维码')
        }
      },
      fail: () => {
        showError('扫码失败')
      }
    })
  },

  /**
   * 跳转到AI聊天
   */
  goToAI() {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后使用AI推荐功能',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }
    
    wx.navigateTo({
      url: '/pages/ai/chat'
    })
  },

  /**
   * 搜索功能
   */
  onSearch() {
    wx.navigateTo({
      url: '/pages/search/search'
    })
  },

  /**
   * 加载公告
   */
  async loadAnnouncements() {
    try {
      const announcements = await request({
        url: '/announcement/active',
        method: 'GET'
      })

      const typeMap = {
        1: '系统公告',
        2: '活动公告',
        3: '紧急通知'
      }

      const processedAnnouncements = announcements.map(item => ({
        ...item,
        typeText: typeMap[item.type] || '公告'
      }))

      this.setData({ announcements: processedAnnouncements })
    } catch (error) {
      console.error('加载公告失败:', error)
      // 使用默认公告
      this.setData({
        announcements: [{
          id: 1,
          title: '欢迎使用智慧餐饮系统',
          type: 1,
          typeText: '系统公告',
          content: '尊敬的用户，欢迎使用我们的智慧餐饮系统！'
        }]
      })
    }
  },

  /**
   * 显示公告详情
   */
  showAnnouncementDetail(e) {
    const announcement = e.currentTarget.dataset.announcement
    wx.showModal({
      title: announcement.title,
      content: announcement.content,
      showCancel: false,
      confirmText: '知道了'
    })
  },

  /**
   * 加载今日推荐
   */
  async loadTodayRecommendations() {
    try {
      const recommendations = await request({
        url: '/recommendation/today',
        method: 'GET',
        data: { limit: 6 }
      })

      console.log('今日推荐数据:', recommendations)

      if (!recommendations || recommendations.length === 0) {
        console.warn('今日推荐返回空数据，使用默认推荐')
        this.loadMockRecommendations()
        return
      }

      const processedRecommendations = recommendations.map(dish => ({
        ...dish,
        image: getImageUrl(dish.image, DEFAULT_IMAGES.dish),
        price: formatPrice(dish.price),
        categoryName: dish.categoryName || '美食'
      }))

      console.log('处理后的推荐数据:', processedRecommendations)
      this.setData({ todayRecommendations: processedRecommendations })
    } catch (error) {
      console.error('加载今日推荐失败:', error)
      // 加载失败时显示模拟数据
      this.loadMockRecommendations()
    }
  },

  /**
   * 加载真实菜品作为推荐（降级方案）
   * 从数据库中获取真实菜品数据
   */
  async loadMockRecommendations() {
    try {
      showLoading('加载推荐...')
      
      // 尝试从菜品列表接口获取真实数据
      // 后端 /dish/list 接口接受 Dish 对象作为查询参数
      const dishes = await request({
        url: '/dish/list',
        method: 'GET',
        data: {
          status: 1  // 只获取在售菜品
        }
      })

      hideLoading()

      if (dishes && dishes.length > 0) {
        console.log('从菜品列表获取到真实数据，共', dishes.length, '个菜品')
        
        // 随机打乱数组并取前6个
        const shuffled = [...dishes].sort(() => 0.5 - Math.random())
        const selectedDishes = shuffled.slice(0, 6)
        
        const processedRecommendations = selectedDishes.map(dish => ({
          ...dish,
          id: dish.id,
          name: dish.name,
          image: getImageUrl(dish.image, DEFAULT_IMAGES.dish),
          price: formatPrice(dish.price),
          categoryName: dish.categoryName || '美食'
        }))
        
        console.log('处理后的真实推荐数据:', processedRecommendations)
        this.setData({ todayRecommendations: processedRecommendations })
      } else {
        console.warn('菜品列表为空')
        // 如果没有菜品数据，显示空
        this.setData({ todayRecommendations: [] })
      }
    } catch (error) {
      hideLoading()
      console.error('加载真实菜品推荐失败:', error)
      // 最终降级：不显示推荐
      this.setData({ todayRecommendations: [] })
    }
  },

  /**
   * 刷新推荐
   */
  refreshRecommendations() {
    this.loadTodayRecommendations()
    wx.showToast({
      title: '已刷新',
      icon: 'success',
      duration: 1000
    })
  },

  /**
   * 查看菜品详情
   */
  goToDishDetail(e) {
    const dish = e.currentTarget.dataset.dish
    console.log('点击菜品跳转:', dish)
    
    // 优先使用 merchantId 直接跳转到商家页并定位菜品
    if (dish.merchantId) {
      wx.navigateTo({
        url: `/pages/menu/menu?merchantId=${dish.merchantId}&dishId=${dish.id}`
      })
    } else {
      // 如果没有merchantId，通过dishId让菜单页自动查询并跳转
      wx.navigateTo({
        url: `/pages/menu/menu?dishId=${dish.id}`
      })
    }
  },

  /**
   * 添加到购物车
   */
  async addToCart(e) {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再添加商品',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }

    const dish = e.currentTarget.dataset.dish
    
    try {
      await request({
        url: '/shoppingCart/add',
        method: 'POST',
        data: {
          dishId: dish.id,
          name: dish.name,
          image: dish.image,
          amount: parseFloat(dish.price) * 100 // 转换为分
        }
      })

      wx.showToast({
        title: '已添加到购物车',
        icon: 'success',
        duration: 1500
      })
    } catch (error) {
      showError('添加失败，请重试')
      console.error('添加到购物车失败:', error)
    }
  },

  /**
   * 加载优惠券（平台券）
   */
  async loadCoupons() {
    try {
      const coupons = await request({
        url: '/coupon/available',
        method: 'GET',
        data: {
          type: 1 // 只查询平台券
        }
      })

      console.log('首页加载平台券:', coupons)

      if (coupons && coupons.length > 0) {
        // 格式化优惠券数据
        const formattedCoupons = coupons.slice(0, 3).map(coupon => ({
          ...coupon,
          amount: Math.floor(parseFloat(coupon.amount) / 100), // 转为整数
          minAmount: Math.floor(parseFloat(coupon.minAmount) / 100) // 转为整数
        }))
        
        this.setData({ coupons: formattedCoupons })
      } else {
        // 即使没有优惠券，也显示入口（可以引导用户查看）
        this.setData({ coupons: [] })
      }
    } catch (error) {
      console.error('加载优惠券失败:', error)
      // 加载失败也设置为空数组，保持入口可见
      this.setData({ coupons: [] })
    }
  },

  /**
   * 检查是否显示优惠券弹窗
   */
  async checkCouponDialog() {
    // 先加载优惠券
    await this.loadCoupons()
    
    // 检查今天是否已显示过
    const today = new Date().toDateString()
    const lastShow = wx.getStorageSync('coupon_dialog_date')
    
    if (lastShow !== today && this.data.coupons.length > 0 && checkLogin()) {
      this.setData({ showCouponDialog: true })
      wx.setStorageSync('coupon_dialog_date', today)
    }
  },

  /**
   * 关闭优惠券弹窗
   */
  closeCouponDialog() {
    this.setData({ showCouponDialog: false })
  },

  /**
   * 去领券中心
   */
  goToCouponCenter() {
    if (!checkLogin()) {
      navigateToLogin()
      return
    }
    
    // 如果弹窗打开，先关闭
    if (this.data.showCouponDialog) {
      this.closeCouponDialog()
    }
    
    wx.navigateTo({
      url: '/pages/coupon-center/coupon-center'
    })
  },

  /**
   * 点击优惠券活动
   */
  onCouponClick() {
    if (!checkLogin()) {
      navigateToLogin()
      return
    }
    wx.navigateTo({
      url: '/pages/coupon-center/coupon-center'
    })
  }
})
