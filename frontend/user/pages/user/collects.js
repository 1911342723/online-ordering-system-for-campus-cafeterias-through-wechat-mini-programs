// pages/user/collects.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showLoading, hideLoading, showError, showSuccess } = require('../../utils/util')

Page({
  data: {
    collects: [],
    page: 1,
    pageSize: 10,
    hasMore: true,
    loading: false,
    refreshing: false,
    defaultAvatar: DEFAULT_IMAGES.avatar
  },

  onLoad() {
    this.loadCollects()
  },

  onShow() {
    this.loadCollects()
  },

  /**
   * 加载收藏列表
   */
  async loadCollects() {
    if (this.data.loading) return
    
    this.setData({ loading: true })
    
    try {
      const res = await request({
        url: '/note/my/collects',
        method: 'GET',
        data: {
          page: this.data.page,
          pageSize: this.data.pageSize
        }
      })
      
      const collects = (res.records || res || []).map(item => ({
        ...item,
        collectTimeStr: this.formatTime(item.collectTime || item.createTime)
      }))
      
      this.setData({
        collects: this.data.page === 1 ? collects : [...this.data.collects, ...collects],
        hasMore: collects.length >= this.data.pageSize,
        loading: false,
        refreshing: false
      })
      
    } catch (error) {
      console.error('加载收藏失败:', error)
      this.setData({ loading: false, refreshing: false })
      
      // 使用模拟数据
      this.loadMockCollects()
    }
  },

  /**
   * 加载模拟数据
   */
  loadMockCollects() {
    const mockCollects = [
      {
        id: 1,
        noteId: 1,
        title: '一食堂的红烧肉绝绝子！',
        coverImage: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80',
        userName: '美食达人',
        userAvatar: DEFAULT_IMAGES.avatar,
        collectTimeStr: '11-28'
      },
      {
        id: 2,
        noteId: 2,
        title: '发现一家超好喝的奶茶店！',
        coverImage: 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=300&q=80',
        userName: '奶茶星人',
        userAvatar: DEFAULT_IMAGES.avatar,
        collectTimeStr: '11-25'
      }
    ]
    
    this.setData({
      collects: mockCollects,
      hasMore: false
    })
  },

  /**
   * 格式化时间
   */
  formatTime(timeStr) {
    if (!timeStr) return ''
    const date = new Date(timeStr)
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${month}-${day}`
  },

  /**
   * 下拉刷新
   */
  onRefresh() {
    this.setData({
      page: 1,
      hasMore: true,
      refreshing: true
    })
    this.loadCollects()
  },

  /**
   * 加载更多
   */
  loadMore() {
    if (this.data.loading || !this.data.hasMore) return
    this.setData({ page: this.data.page + 1 })
    this.loadCollects()
  },

  /**
   * 跳转到详情
   */
  goToDetail(e) {
    const id = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/community/detail?id=${id}`
    })
  },

  /**
   * 取消收藏
   */
  async uncollect(e) {
    const id = e.currentTarget.dataset.id
    
    try {
      await request({
        url: `/note/collect/${id}`,
        method: 'POST'
      })
      
      // 从列表中移除
      const collects = this.data.collects.filter(c => (c.noteId || c.id) !== id)
      this.setData({ collects })
      
      showSuccess('已取消收藏')
      
    } catch (error) {
      console.error('取消收藏失败:', error)
      showError('操作失败')
    }
  },

  /**
   * 去发现
   */
  goDiscover() {
    wx.switchTab({
      url: '/pages/community/community'
    })
  }
})

