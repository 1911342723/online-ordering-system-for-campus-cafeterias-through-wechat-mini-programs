// pages/user/messages.js
const request = require('../../utils/request')
const { showLoading, hideLoading, showError, showSuccess } = require('../../utils/util')

Page({
  data: {
    activeTab: 'all',
    messages: [],
    page: 1,
    pageSize: 20,
    hasMore: true,
    loading: false,
    refreshing: false,
    
    totalUnread: 0,
    likeUnread: 0,
    commentUnread: 0,
    systemUnread: 0
  },

  onLoad() {
    this.loadMessages()
    this.loadUnreadCounts()
  },

  onShow() {
    this.loadUnreadCounts()
  },

  /**
   * 切换Tab
   */
  switchTab(e) {
    const tab = e.currentTarget.dataset.tab
    if (tab === this.data.activeTab) return
    
    this.setData({
      activeTab: tab,
      messages: [],
      page: 1,
      hasMore: true
    })
    this.loadMessages()
  },

  /**
   * 加载消息列表
   */
  async loadMessages() {
    if (this.data.loading) return
    
    this.setData({ loading: true })
    
    try {
      const type = this.data.activeTab === 'all' ? '' : this.data.activeTab
      
      const res = await request({
        url: '/message/list',
        method: 'GET',
        data: {
          page: this.data.page,
          pageSize: this.data.pageSize,
          type: type
        }
      })
      
      const messages = (res.records || res || []).map(msg => ({
        ...msg,
        createTimeStr: this.formatTime(msg.createTime)
      }))
      
      this.setData({
        messages: this.data.page === 1 ? messages : [...this.data.messages, ...messages],
        hasMore: messages.length >= this.data.pageSize,
        loading: false,
        refreshing: false
      })
      
    } catch (error) {
      console.error('加载消息失败:', error)
      this.setData({ loading: false, refreshing: false })
      
      // 使用模拟数据
      this.loadMockMessages()
    }
  },

  /**
   * 加载模拟数据
   */
  loadMockMessages() {
    const mockMessages = [
      {
        id: 1,
        type: 'like',
        fromUserName: '美食达人',
        content: '赞了你的帖子',
        noteTitle: '一食堂的红烧肉绝绝子！',
        createTimeStr: '刚刚',
        isRead: false
      },
      {
        id: 2,
        type: 'comment',
        fromUserName: '干饭人',
        content: '看着就很有食欲！明天去吃！',
        noteTitle: '一食堂的红烧肉绝绝子！',
        createTimeStr: '5分钟前',
        isRead: false
      },
      {
        id: 3,
        type: 'collect',
        fromUserName: '奶茶星人',
        content: '收藏了你的帖子',
        noteTitle: '发现一家超好喝的奶茶店！',
        createTimeStr: '1小时前',
        isRead: true
      },
      {
        id: 4,
        type: 'system',
        fromUserName: '',
        content: '恭喜你升级为 Lv.2 美食学徒！继续加油哦~',
        noteTitle: '',
        createTimeStr: '昨天',
        isRead: true
      }
    ]
    
    this.setData({
      messages: mockMessages,
      hasMore: false,
      totalUnread: 2,
      likeUnread: 1,
      commentUnread: 1,
      systemUnread: 0
    })
  },

  /**
   * 加载未读数量
   */
  async loadUnreadCounts() {
    try {
      const res = await request({
        url: '/message/unread/detail',
        method: 'GET'
      })
      
      if (res) {
        this.setData({
          totalUnread: res.total || 0,
          likeUnread: res.like || 0,
          commentUnread: res.comment || 0,
          systemUnread: res.system || 0
        })
      }
    } catch (error) {
      console.error('加载未读数量失败:', error)
    }
  },

  /**
   * 格式化时间
   */
  formatTime(timeStr) {
    if (!timeStr) return ''
    const date = new Date(timeStr)
    const now = new Date()
    const diff = now - date
    
    if (diff < 60000) {
      return '刚刚'
    } else if (diff < 3600000) {
      return Math.floor(diff / 60000) + '分钟前'
    } else if (diff < 86400000) {
      return Math.floor(diff / 3600000) + '小时前'
    } else if (diff < 172800000) {
      return '昨天'
    } else {
      const month = date.getMonth() + 1
      const day = date.getDate()
      return `${month}-${day}`
    }
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
    this.loadMessages()
    this.loadUnreadCounts()
  },

  /**
   * 加载更多
   */
  loadMore() {
    if (this.data.loading || !this.data.hasMore) return
    this.setData({ page: this.data.page + 1 })
    this.loadMessages()
  },

  /**
   * 跳转到详情
   */
  async goToDetail(e) {
    const message = e.currentTarget.dataset.message
    
    // 标记为已读
    if (!message.isRead) {
      try {
        await request({
          url: `/message/read/${message.id}`,
          method: 'POST'
        })
        
        // 更新本地状态
        const messages = this.data.messages.map(m => 
          m.id === message.id ? { ...m, isRead: true } : m
        )
        this.setData({ messages })
        this.loadUnreadCounts()
      } catch (error) {
        console.error('标记已读失败:', error)
      }
    }
    
    // 如果有关联帖子，跳转到帖子详情
    if (message.noteId) {
      wx.navigateTo({
        url: `/pages/community/detail?id=${message.noteId}`
      })
    }
  },

  /**
   * 全部已读
   */
  async markAllRead() {
    try {
      showLoading('处理中...')
      
      await request({
        url: '/message/read/all',
        method: 'POST'
      })
      
      // 更新本地状态
      const messages = this.data.messages.map(m => ({ ...m, isRead: true }))
      this.setData({
        messages,
        totalUnread: 0,
        likeUnread: 0,
        commentUnread: 0,
        systemUnread: 0
      })
      
      hideLoading()
      showSuccess('已全部标记为已读')
      
    } catch (error) {
      hideLoading()
      console.error('标记已读失败:', error)
      showError('操作失败')
    }
  }
})

