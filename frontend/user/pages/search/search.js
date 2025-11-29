const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { getImageUrl, formatPrice, showLoading, hideLoading, showError, showSuccess, checkLogin, navigateToLogin } = require('../../utils/util')

Page({
  data: {
    keyword: '',
    history: [],
    searchResults: [],
    searching: false,
    page: 1,
    pageSize: 10,
    hasMore: true,
    defaultDishImg: DEFAULT_IMAGES.dish,
    icons: {
      search: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23999999'%3E%3Cpath d='M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z'/%3E%3C/svg%3E",
      delete: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23999999'%3E%3Cpath d='M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z'/%3E%3C/svg%3E",
      clear: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23CCCCCC'%3E%3Cpath d='M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z'/%3E%3C/svg%3E"
    }
  },

  onLoad() {
    this.loadHistory()
  },

  /**
   * 加载搜索历史
   */
  loadHistory() {
    const history = wx.getStorageSync('search_history') || []
    this.setData({ history })
  },

  /**
   * 清空历史
   */
  clearHistory() {
    wx.showModal({
      title: '提示',
      content: '确定清空搜索历史吗？',
      success: (res) => {
        if (res.confirm) {
          wx.removeStorageSync('search_history')
          this.setData({ history: [] })
        }
      }
    })
  },

  /**
   * 输入关键字
   */
  onInput(e) {
    this.setData({
      keyword: e.detail.value
    })
  },

  /**
   * 清空输入
   */
  onClear() {
    this.setData({
      keyword: '',
      searchResults: [],
      searching: false
    })
  },

  /**
   * 点击历史记录
   */
  onHistoryClick(e) {
    const keyword = e.currentTarget.dataset.text
    this.setData({ keyword })
    this.doSearch()
  },

  /**
   * 执行搜索
   */
  async doSearch() {
    const keyword = this.data.keyword.trim()
    if (!keyword) return

    // 保存历史
    let history = this.data.history
    const index = history.indexOf(keyword)
    if (index > -1) {
      history.splice(index, 1)
    }
    history.unshift(keyword)
    history = history.slice(0, 10) // 只保留10条
    wx.setStorageSync('search_history', history)
    this.setData({ history, searching: true, page: 1, searchResults: [], hasMore: true })

    this.loadData()
  },

  /**
   * 加载数据
   */
  async loadData() {
    if (!this.data.hasMore) return

    showLoading('搜索中...')
    try {
      const res = await request({
        url: '/dish/page',
        method: 'GET',
        data: {
          page: this.data.page,
          pagesize: this.data.pageSize,
          name: this.data.keyword
        }
      })

      hideLoading()

      if (res && res.records) {
        const newItems = res.records.map(item => ({
          ...item,
          image: getImageUrl(item.image, DEFAULT_IMAGES.dish),
          price: formatPrice(item.price)
        }))

        this.setData({
          searchResults: [...this.data.searchResults, ...newItems],
          page: this.data.page + 1,
          hasMore: newItems.length === this.data.pageSize
        })
      } else {
        this.setData({ hasMore: false })
      }
    } catch (error) {
      hideLoading()
      console.error('搜索失败:', error)
      showError('搜索失败，请重试')
    }
  },

  /**
   * 加载更多
   */
  onReachBottom() {
    if (this.data.searching && this.data.hasMore) {
      this.loadData()
    }
  },

  /**
   * 添加到购物车
   */
  async addToCart(e) {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录',
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
      showSuccess('已加入购物车')
    } catch (error) {
      console.error('加入购物车失败:', error)
      showError('操作失败')
    }
  },
  
  /**
   * 跳转详情
   */
  goToDetail(e) {
    const dishId = e.currentTarget.dataset.id
    // 搜索页跳转到菜单页并定位可能比较复杂，简单起见可以跳转到菜单页带上参数
    // 或者直接弹窗显示详情
    // 复用 menu.js 的逻辑，跳转到 menu 页
    // 既然是全局搜索，可能跨食堂，这里最好能知道 canteenId
    // 如果 dish 对象里有 canteenId
    const dish = this.data.searchResults.find(d => d.id === dishId)
    if (dish && dish.canteenId) {
        wx.navigateTo({
            url: `/pages/menu/menu?canteenId=${dish.canteenId}&dishId=${dishId}`
        })
    } else {
        // 如果没有 canteenId，可能无法准确定位到菜单
        showError('无法定位商家')
    }
  }
})



