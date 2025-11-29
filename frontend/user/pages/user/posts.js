// pages/user/posts.js
const request = require('../../utils/request')
const { showLoading, hideLoading, showError, showSuccess } = require('../../utils/util')

Page({
  data: {
    activeTab: 'published',
    posts: [],
    publishedCount: 0,
    draftCount: 0,
    page: 1,
    pageSize: 10,
    hasMore: true,
    loading: false,
    refreshing: false
  },

  onLoad() {
    this.loadPosts()
  },

  onShow() {
    // 每次显示时刷新
    this.loadPosts()
  },

  /**
   * 切换Tab
   */
  switchTab(e) {
    const tab = e.currentTarget.dataset.tab
    if (tab === this.data.activeTab) return
    
    this.setData({
      activeTab: tab,
      posts: [],
      page: 1,
      hasMore: true
    })
    this.loadPosts()
  },

  /**
   * 加载帖子列表
   */
  async loadPosts() {
    if (this.data.loading) return
    
    this.setData({ loading: true })
    
    try {
      const status = this.data.activeTab === 'published' ? 1 : 0
      
      const res = await request({
        url: '/note/my',
        method: 'GET',
        data: {
          page: this.data.page,
          pageSize: this.data.pageSize,
          status: status
        }
      })
      
      const posts = (res.records || res || []).map(post => ({
        ...post,
        createTimeStr: this.formatTime(post.createTime)
      }))
      
      this.setData({
        posts: this.data.page === 1 ? posts : [...this.data.posts, ...posts],
        hasMore: posts.length >= this.data.pageSize,
        loading: false,
        refreshing: false,
        publishedCount: res.publishedCount || this.data.publishedCount,
        draftCount: res.draftCount || this.data.draftCount
      })
      
    } catch (error) {
      console.error('加载帖子失败:', error)
      this.setData({ loading: false, refreshing: false })
      
      // 使用模拟数据
      this.loadMockPosts()
    }
  },

  /**
   * 加载模拟数据
   */
  loadMockPosts() {
    const mockPosts = [
      {
        id: 1,
        title: '一食堂的红烧肉绝绝子！',
        content: '今天中午去一食堂吃饭，排队的人超级多！但是为了这口红烧肉一切都值得！',
        coverImage: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80',
        createTimeStr: '11-28',
        viewCount: 156,
        likeCount: 23,
        commentCount: 5
      },
      {
        id: 2,
        title: '发现一家超好喝的奶茶店！',
        content: '就在二食堂旁边，叫茶颜悦色，他们家的幽兰拿铁真的绝了！',
        coverImage: 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=300&q=80',
        createTimeStr: '11-25',
        viewCount: 89,
        likeCount: 12,
        commentCount: 3
      }
    ]
    
    this.setData({
      posts: mockPosts,
      publishedCount: 2,
      draftCount: 0,
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
    this.loadPosts()
  },

  /**
   * 加载更多
   */
  loadMore() {
    if (this.data.loading || !this.data.hasMore) return
    this.setData({ page: this.data.page + 1 })
    this.loadPosts()
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
   * 编辑帖子
   */
  editPost(e) {
    const post = e.currentTarget.dataset.post
    wx.navigateTo({
      url: `/pages/community/publish?id=${post.id}&edit=1`
    })
  },

  /**
   * 删除帖子
   */
  deletePost(e) {
    const id = e.currentTarget.dataset.id
    
    wx.showModal({
      title: '确认删除',
      content: '删除后无法恢复，确定要删除吗？',
      confirmColor: '#ef4444',
      success: async (res) => {
        if (res.confirm) {
          try {
            showLoading('删除中...')
            
            await request({
              url: `/note/${id}`,
              method: 'DELETE'
            })
            
            hideLoading()
            showSuccess('删除成功')
            
            // 从列表中移除
            const posts = this.data.posts.filter(p => p.id !== id)
            this.setData({
              posts,
              publishedCount: this.data.activeTab === 'published' ? this.data.publishedCount - 1 : this.data.publishedCount,
              draftCount: this.data.activeTab === 'draft' ? this.data.draftCount - 1 : this.data.draftCount
            })
            
          } catch (error) {
            hideLoading()
            console.error('删除失败:', error)
            showError('删除失败')
          }
        }
      }
    })
  },

  /**
   * 去发布
   */
  goPublish() {
    wx.navigateTo({
      url: '/pages/community/publish'
    })
  }
})

