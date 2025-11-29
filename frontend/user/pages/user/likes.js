// pages/user/likes.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')

Page({
  data: {
    likes: [],
    totalLikes: 0,
    page: 1,
    pageSize: 20,
    hasMore: true,
    loading: false,
    refreshing: false,
    defaultAvatar: DEFAULT_IMAGES.avatar
  },

  onLoad() {
    this.loadLikes()
  },

  async loadLikes() {
    if (this.data.loading) return
    this.setData({ loading: true })
    
    try {
      const res = await request({
        url: '/note/my/likes',
        method: 'GET',
        data: {
          page: this.data.page,
          pageSize: this.data.pageSize
        }
      })
      
      const likes = (res.records || res || []).map(item => ({
        ...item,
        createTimeStr: this.formatTime(item.createTime)
      }))
      
      this.setData({
        likes: this.data.page === 1 ? likes : [...this.data.likes, ...likes],
        totalLikes: res.total || likes.length,
        hasMore: likes.length >= this.data.pageSize,
        loading: false,
        refreshing: false
      })
    } catch (error) {
      console.error('加载获赞失败:', error)
      this.setData({ loading: false, refreshing: false })
      this.loadMockLikes()
    }
  },

  loadMockLikes() {
    const mockLikes = [
      {
        id: 1,
        fromUserName: '美食达人',
        fromUserAvatar: DEFAULT_IMAGES.avatar,
        noteId: 1,
        noteTitle: '一食堂的红烧肉绝绝子！',
        createTimeStr: '刚刚'
      },
      {
        id: 2,
        fromUserName: '干饭人',
        fromUserAvatar: DEFAULT_IMAGES.avatar,
        noteId: 1,
        noteTitle: '一食堂的红烧肉绝绝子！',
        createTimeStr: '5分钟前'
      }
    ]
    
    this.setData({
      likes: mockLikes,
      totalLikes: 28,
      hasMore: false
    })
  },

  formatTime(timeStr) {
    if (!timeStr) return ''
    const date = new Date(timeStr)
    const now = new Date()
    const diff = now - date
    
    if (diff < 60000) return '刚刚'
    if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
    if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
    
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${month}-${day}`
  },

  onRefresh() {
    this.setData({ page: 1, hasMore: true, refreshing: true })
    this.loadLikes()
  },

  loadMore() {
    if (this.data.loading || !this.data.hasMore) return
    this.setData({ page: this.data.page + 1 })
    this.loadLikes()
  },

  goToDetail(e) {
    const id = e.currentTarget.dataset.id
    if (id) {
      wx.navigateTo({ url: `/pages/community/detail?id=${id}` })
    }
  }
})

