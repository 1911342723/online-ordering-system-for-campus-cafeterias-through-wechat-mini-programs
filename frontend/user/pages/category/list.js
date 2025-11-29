// pages/category/list.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { getImageUrl, showLoading, hideLoading, showError } = require('../../utils/util')

// 美食分类数据（带背景色）
const FOOD_CATEGORIES = [
  { id: 'bbq', name: '烧烤', icon: '🍢', keyword: '烧烤', bgColor: '#FEF3C7' },
  { id: 'night', name: '夜宵', icon: '🌙', keyword: '夜宵', bgColor: '#E0E7FF' },
  { id: 'noodle', name: '面食', icon: '🍜', keyword: '面', bgColor: '#FCE7F3' },
  { id: 'rice', name: '盖饭', icon: '🍚', keyword: '饭', bgColor: '#D1FAE5' },
  { id: 'hotpot', name: '火锅', icon: '🍲', keyword: '火锅', bgColor: '#FEE2E2' },
  { id: 'snack', name: '小吃', icon: '🥟', keyword: '小吃', bgColor: '#FEF9C3' },
  { id: 'drink', name: '饮品', icon: '🧋', keyword: '饮品', bgColor: '#CFFAFE' },
  { id: 'dessert', name: '甜品', icon: '🍰', keyword: '甜品', bgColor: '#FCE7F3' },
  { id: 'western', name: '西餐', icon: '🍔', keyword: '西餐', bgColor: '#FFEDD5' },
  { id: 'healthy', name: '轻食', icon: '🥗', keyword: '轻食', bgColor: '#DCFCE7' },
  { id: 'sichuan', name: '川菜', icon: '🌶️', keyword: '川菜', bgColor: '#FEE2E2' },
  { id: 'cantonese', name: '粤菜', icon: '🥢', keyword: '粤菜', bgColor: '#FEF3C7' },
  { id: 'japanese', name: '日料', icon: '🍣', keyword: '日料', bgColor: '#FECACA' },
  { id: 'korean', name: '韩餐', icon: '🍱', keyword: '韩餐', bgColor: '#E0E7FF' },
  { id: 'breakfast', name: '早餐', icon: '🥐', keyword: '早餐', bgColor: '#FEF3C7' }
]

const AVAILABLE_TAGS = [
  '优惠活动', '品质商家', '新店开业', '免配送费', 
  '满减优惠', '特色推荐', '好评如潮', '分量超足'
]

Page({
  data: {
    categories: FOOD_CATEGORIES,
    currentCategory: 'all',
    currentCategoryData: { name: '全部分类', icon: '' }, // 当前选中的分类数据
    currentKeyword: '',
    sortBy: 'default',
    shopList: [],
    loading: false,
    hasMore: true,
    page: 1,
    pageSize: 10,
    
    // 分类下拉面板
    showCategoryDropdown: false,
    
    // 筛选相关
    showFilter: false,
    filterStatus: 'all',
    deliveryType: 'all',
    selectedTags: [],
    availableTags: AVAILABLE_TAGS
  },

  onLoad(options) {
    console.log('分类页面参数:', options)
    
    // 处理传入的参数
    if (options.id && options.id !== 'all') {
      const category = FOOD_CATEGORIES.find(c => c.id === options.id)
      this.setData({ 
        currentCategory: options.id,
        currentCategoryData: category || { name: '全部分类', icon: '' }
      })
      
      // 设置导航栏标题
      if (options.name) {
        wx.setNavigationBarTitle({
          title: decodeURIComponent(options.name)
        })
      }
      
      // 设置搜索关键词
      if (options.keyword) {
        this.setData({ currentKeyword: decodeURIComponent(options.keyword) })
      }
    }
    
    // 如果是查看全部门店
    if (options.showAll === 'true' && options.tab === 'shops') {
      wx.setNavigationBarTitle({
        title: '全部门店'
      })
    }
    
    this.loadShopList()
  },

  onShow() {
    // 页面显示时可以刷新数据
  },

  /**
   * 下拉刷新
   */
  onPullDownRefresh() {
    this.setData({ page: 1, hasMore: true, shopList: [] })
    this.loadShopList().then(() => {
      wx.stopPullDownRefresh()
    })
  },

  /**
   * 加载门店列表
   */
  async loadShopList() {
    if (this.data.loading || !this.data.hasMore) return
    
    this.setData({ loading: true })
    
    try {
      // 构建请求参数
      const params = {
        page: this.data.page,
        pageSize: this.data.pageSize
      }
      
      // 添加分类关键词筛选
      if (this.data.currentKeyword) {
        params.keyword = this.data.currentKeyword
      }
      
      // 添加排序
      if (this.data.sortBy !== 'default') {
        params.sortBy = this.data.sortBy
      }
      
      // 添加营业状态筛选
      if (this.data.filterStatus === 'open') {
        params.status = 1
      }
      
      const merchants = await request({
        url: '/merchant/list',
        method: 'GET',
        data: params
      })
      
      // 判断营业时间
      const currentHour = new Date().getHours()
      const isBusinessHours = currentHour >= 7 && currentHour < 22
      
      // 处理商户数据
      let processedMerchants = merchants.map(merchant => ({
        ...merchant,
        image: getImageUrl(merchant.image, DEFAULT_IMAGES.canteen),
        isOpen: merchant.status === 1 && isBusinessHours,
        tags: merchant.tags ? merchant.tags.split(',') : this.generateRandomTags(),
        distance: merchant.distance ? `${merchant.distance}m` : `${Math.floor(Math.random() * 500 + 100)}m`,
        rating: merchant.rating || (Math.random() * 1 + 4).toFixed(1),
        sales: merchant.salesCount || Math.floor(Math.random() * 2000 + 100),
        deliveryTime: Math.floor(Math.random() * 20 + 15),
        promo: Math.random() > 0.5 ? '满20减5' : '',
        isNew: Math.random() > 0.8
      }))
      
      // 应用前端筛选（当后端筛选不完整时）
      processedMerchants = this.applyLocalFilters(processedMerchants)
      
      // 应用排序
      processedMerchants = this.applySorting(processedMerchants)
      
      const newList = this.data.page === 1 
        ? processedMerchants 
        : [...this.data.shopList, ...processedMerchants]
      
      this.setData({
        shopList: newList,
        loading: false,
        hasMore: processedMerchants.length >= this.data.pageSize,
        page: this.data.page + 1
      })
      
    } catch (error) {
      console.error('加载门店列表失败:', error)
      this.setData({ loading: false })
      
      // 加载模拟数据
      this.loadMockData()
    }
  },

  /**
   * 生成随机标签
   */
  generateRandomTags() {
    const allTags = ['美味', '实惠', '好评', '快速', '新鲜', '特色']
    const count = Math.floor(Math.random() * 2) + 1
    return allTags.sort(() => 0.5 - Math.random()).slice(0, count)
  },

  /**
   * 应用本地筛选
   */
  applyLocalFilters(list) {
    let result = [...list]
    
    // 营业状态筛选
    if (this.data.filterStatus === 'open') {
      result = result.filter(item => item.isOpen)
    }
    
    // 标签筛选
    if (this.data.selectedTags.length > 0) {
      result = result.filter(item => {
        return this.data.selectedTags.some(tag => 
          item.tags && item.tags.includes(tag)
        )
      })
    }
    
    return result
  },

  /**
   * 应用排序
   */
  applySorting(list) {
    const sorted = [...list]
    
    switch (this.data.sortBy) {
      case 'sales':
        sorted.sort((a, b) => b.sales - a.sales)
        break
      case 'rating':
        sorted.sort((a, b) => parseFloat(b.rating) - parseFloat(a.rating))
        break
      case 'distance':
        sorted.sort((a, b) => parseInt(a.distance) - parseInt(b.distance))
        break
      default:
        // 综合排序：评分 * 0.4 + 销量权重 * 0.3 + 距离权重 * 0.3
        break
    }
    
    return sorted
  },

  /**
   * 加载模拟数据
   */
  loadMockData() {
    const currentHour = new Date().getHours()
    const isBusinessHours = currentHour >= 7 && currentHour < 22
    
    const mockShops = [
      {
        id: 1,
        name: '老王烧烤',
        image: DEFAULT_IMAGES.canteen,
        tags: ['烧烤', '夜宵', '人气爆棚'],
        isOpen: isBusinessHours,
        rating: '4.9',
        distance: '100m',
        sales: 2300,
        deliveryTime: 20,
        promo: '满30减10',
        isNew: false
      },
      {
        id: 2,
        name: '川味面馆',
        image: DEFAULT_IMAGES.canteen,
        tags: ['面食', '川菜', '经济实惠'],
        isOpen: isBusinessHours,
        rating: '4.8',
        distance: '150m',
        sales: 1800,
        deliveryTime: 15,
        promo: '',
        isNew: false
      },
      {
        id: 3,
        name: '一品香盖饭',
        image: DEFAULT_IMAGES.canteen,
        tags: ['盖饭', '快餐', '分量足'],
        isOpen: isBusinessHours,
        rating: '4.7',
        distance: '200m',
        sales: 1500,
        deliveryTime: 18,
        promo: '新客立减5元',
        isNew: true
      },
      {
        id: 4,
        name: '茶颜悦色',
        image: DEFAULT_IMAGES.canteen,
        tags: ['奶茶', '饮品', '网红店'],
        isOpen: isBusinessHours,
        rating: '4.9',
        distance: '120m',
        sales: 3200,
        deliveryTime: 10,
        promo: '第二杯半价',
        isNew: false
      },
      {
        id: 5,
        name: '麻辣小火锅',
        image: DEFAULT_IMAGES.canteen,
        tags: ['火锅', '麻辣', '好评如潮'],
        isOpen: isBusinessHours,
        rating: '4.6',
        distance: '300m',
        sales: 980,
        deliveryTime: 25,
        promo: '',
        isNew: false
      },
      {
        id: 6,
        name: '轻食沙拉',
        image: DEFAULT_IMAGES.canteen,
        tags: ['轻食', '健康', '低卡'],
        isOpen: isBusinessHours,
        rating: '4.5',
        distance: '250m',
        sales: 650,
        deliveryTime: 12,
        promo: '满25减3',
        isNew: true
      },
      {
        id: 7,
        name: '日式拉面屋',
        image: DEFAULT_IMAGES.canteen,
        tags: ['日料', '拉面', '正宗'],
        isOpen: isBusinessHours,
        rating: '4.8',
        distance: '180m',
        sales: 1200,
        deliveryTime: 20,
        promo: '',
        isNew: false
      },
      {
        id: 8,
        name: '韩式炸鸡',
        image: DEFAULT_IMAGES.canteen,
        tags: ['韩餐', '炸鸡', '啤酒'],
        isOpen: isBusinessHours,
        rating: '4.7',
        distance: '350m',
        sales: 890,
        deliveryTime: 22,
        promo: '满50减15',
        isNew: false
      }
    ]
    
    // 根据当前分类筛选
    let filteredShops = mockShops
    if (this.data.currentKeyword) {
      filteredShops = mockShops.filter(shop => 
        shop.name.includes(this.data.currentKeyword) ||
        shop.tags.some(tag => tag.includes(this.data.currentKeyword))
      )
    }
    
    // 应用筛选和排序
    filteredShops = this.applyLocalFilters(filteredShops)
    filteredShops = this.applySorting(filteredShops)
    
    this.setData({
      shopList: filteredShops,
      loading: false,
      hasMore: false
    })
  },

  /**
   * 切换分类
   */
  /**
   * 切换分类下拉面板显示
   */
  toggleCategoryDropdown() {
    this.setData({ showCategoryDropdown: !this.data.showCategoryDropdown })
  },

  /**
   * 隐藏分类下拉面板
   */
  hideCategoryDropdown() {
    this.setData({ showCategoryDropdown: false })
  },

  /**
   * 选择分类（下拉面板）
   */
  selectCategory(e) {
    const { id, name, icon } = e.currentTarget.dataset
    
    if (id === this.data.currentCategory) {
      this.hideCategoryDropdown()
      return
    }
    
    const category = this.data.categories.find(c => c.id === id)
    
    this.setData({
      currentCategory: id,
      currentCategoryData: { name: name || '全部分类', icon: icon || '' },
      currentKeyword: category ? category.keyword : '',
      showCategoryDropdown: false,
      page: 1,
      hasMore: true,
      shopList: []
    })
    
    // 更新标题
    wx.setNavigationBarTitle({
      title: name || '美食分类'
    })
    
    this.loadShopList()
  },

  /**
   * 切换分类（旧方法保留兼容）
   */
  switchCategory(e) {
    const id = e.currentTarget.dataset.id
    
    if (id === this.data.currentCategory) return
    
    const category = this.data.categories.find(c => c.id === id)
    
    this.setData({
      currentCategory: id,
      currentCategoryData: category || { name: '全部分类', icon: '' },
      currentKeyword: category ? category.keyword : '',
      page: 1,
      hasMore: true,
      shopList: []
    })
    
    // 更新标题
    wx.setNavigationBarTitle({
      title: category ? category.name : '美食分类'
    })
    
    this.loadShopList()
  },

  /**
   * 切换排序
   */
  changeSort(e) {
    const sort = e.currentTarget.dataset.sort
    
    if (sort === this.data.sortBy) return
    
    this.setData({
      sortBy: sort,
      page: 1,
      hasMore: true,
      shopList: []
    })
    
    this.loadShopList()
  },

  /**
   * 显示筛选面板
   */
  showFilterPanel() {
    this.setData({ showFilter: true })
  },

  /**
   * 隐藏筛选面板
   */
  hideFilterPanel() {
    this.setData({ showFilter: false })
  },

  /**
   * 设置营业状态筛选
   */
  setFilterStatus(e) {
    this.setData({ filterStatus: e.currentTarget.dataset.status })
  },

  /**
   * 设置配送方式
   */
  setDeliveryType(e) {
    this.setData({ deliveryType: e.currentTarget.dataset.type })
  },

  /**
   * 切换标签选择
   */
  toggleTag(e) {
    const tag = e.currentTarget.dataset.tag
    const tags = [...this.data.selectedTags]
    
    const index = tags.indexOf(tag)
    if (index > -1) {
      tags.splice(index, 1)
    } else {
      tags.push(tag)
    }
    
    this.setData({ selectedTags: tags })
  },

  /**
   * 重置筛选
   */
  resetFilter() {
    this.setData({
      filterStatus: 'all',
      deliveryType: 'all',
      selectedTags: []
    })
  },

  /**
   * 应用筛选
   */
  applyFilter() {
    this.hideFilterPanel()
    
    this.setData({
      page: 1,
      hasMore: true,
      shopList: []
    })
    
    this.loadShopList()
  },

  /**
   * 加载更多
   */
  loadMore() {
    if (!this.data.loading && this.data.hasMore) {
      this.loadShopList()
    }
  },

  /**
   * 跳转到门店
   */
  goToShop(e) {
    const shop = e.currentTarget.dataset.shop
    
    if (!shop.isOpen) {
      showError('该门店暂未营业')
      return
    }
    
    wx.navigateTo({
      url: `/pages/menu/menu?merchantId=${shop.id}&merchantName=${encodeURIComponent(shop.name)}`
    })
  },

  /**
   * 跳转到搜索
   */
  goToSearch() {
    wx.navigateTo({
      url: '/pages/search/search'
    })
  }
})

