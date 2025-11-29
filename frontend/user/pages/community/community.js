// pages/community/community.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showLoading, hideLoading, showError, checkLogin, navigateToLogin } = require('../../utils/util')

Page({
  data: {
    activeTab: 'discover',
    
    // 关注列表
    followList: [],
    followLeftCol: [],
    followRightCol: [],
    
    // 发现列表
    discoverList: [],
    discoverLeftCol: [],
    discoverRightCol: [],
    
    // 附近列表
    nearbyList: [],
    nearbyLeftCol: [],
    nearbyRightCol: [],
    
    // 热门话题
    hotTopics: [
      { id: 1, name: '今日美食' },
      { id: 2, name: '食堂探店' },
      { id: 3, name: '减脂餐' },
      { id: 4, name: '深夜放毒' }
    ],
    
    // 位置
    location: '南京工业大学',
    
    // 分页
    page: 1,
    pageSize: 10,
    hasMore: true,
    loading: false,
    refreshing: false,
    
    defaultAvatar: DEFAULT_IMAGES.avatar
  },

  onLoad() {
    this.loadData()
  },

  onShow() {
    // 每次显示时刷新当前 tab 数据
    this.loadData()
  },

  /**
   * 切换 Tab
   */
  switchTab(e) {
    const tab = e.currentTarget.dataset.tab
    if (tab === this.data.activeTab) return
    
    this.setData({
      activeTab: tab,
      page: 1,
      hasMore: true
    })
    
    this.loadData()
  },

  /**
   * 切换到发现
   */
  switchToDiscover() {
    this.setData({ activeTab: 'discover' })
    this.loadData()
  },

  /**
   * 加载数据
   */
  async loadData() {
    const { activeTab } = this.data
    
    this.setData({ loading: true })
    
    try {
      let notes = []
      
      // 根据 tab 加载不同数据
      switch (activeTab) {
        case 'follow':
          notes = await this.loadFollowNotes()
          break
        case 'discover':
          notes = await this.loadDiscoverNotes()
          break
        case 'nearby':
          notes = await this.loadNearbyNotes()
          break
      }
      
      // 分配到两列（瀑布流）
      const { leftCol, rightCol } = this.distributeToColumns(notes)
      
      // 根据 tab 设置数据
      switch (activeTab) {
        case 'follow':
          this.setData({
            followList: notes,
            followLeftCol: leftCol,
            followRightCol: rightCol
          })
          break
        case 'discover':
          this.setData({
            discoverList: notes,
            discoverLeftCol: leftCol,
            discoverRightCol: rightCol
          })
          break
        case 'nearby':
          this.setData({
            nearbyList: notes,
            nearbyLeftCol: leftCol,
            nearbyRightCol: rightCol
          })
          break
      }
      
    } catch (error) {
      console.error('加载数据失败:', error)
      // 加载模拟数据
      this.loadMockData()
    } finally {
      this.setData({ 
        loading: false,
        refreshing: false
      })
    }
  },

  /**
   * 加载关注的笔记
   */
  async loadFollowNotes() {
    if (!checkLogin()) {
      return []
    }
    
    try {
      const res = await request({
        url: '/note/list',
        method: 'GET',
        data: {
          page: this.data.page,
          pageSize: this.data.pageSize,
          type: 'follow'
        }
      })
      
      return this.processNotes(res.records || res || [])
    } catch (error) {
      console.error('加载关注笔记失败:', error)
      return []
    }
  },

  /**
   * 加载发现的笔记
   */
  async loadDiscoverNotes() {
    try {
      const res = await request({
        url: '/note/list',
        method: 'GET',
        data: {
          page: this.data.page,
          pageSize: this.data.pageSize
        }
      })
      
      const notes = res.records || res || []
      this.setData({ hasMore: notes.length >= this.data.pageSize })
      
      return this.processNotes(notes)
    } catch (error) {
      console.error('加载发现笔记失败:', error)
      throw error
    }
  },

  /**
   * 加载附近的笔记
   */
  async loadNearbyNotes() {
    try {
      const res = await request({
        url: '/note/list',
        method: 'GET',
        data: {
          page: this.data.page,
          pageSize: this.data.pageSize,
          type: 'nearby'
        }
      })
      
      const notes = this.processNotes(res.records || res || [])
      
      // 添加随机距离
      notes.forEach(note => {
        note.distance = `${Math.floor(Math.random() * 900 + 100)}m`
      })
      
      return notes
    } catch (error) {
      console.error('加载附近笔记失败:', error)
      throw error
    }
  },

  /**
   * 处理笔记数据
   */
  processNotes(notes) {
    return notes.map(note => ({
      ...note,
      coverImage: note.coverImage || (note.images ? note.images.split(',')[0] : null),
      userAvatar: note.userAvatar || DEFAULT_IMAGES.avatar,
      userName: note.userName || '匿名用户',
      likeCount: note.likeCount || 0,
      isLiked: note.isLiked || false,
      isFeatured: note.isFeatured === 1
    }))
  },

  /**
   * 分配到两列
   */
  distributeToColumns(items) {
    const leftCol = []
    const rightCol = []
    
    items.forEach((item, index) => {
      if (index % 2 === 0) {
        leftCol.push(item)
      } else {
        rightCol.push(item)
      }
    })
    
    return { leftCol, rightCol }
  },

  /**
   * 加载模拟数据
   */
  loadMockData() {
    const mockData = [
      { 
        id: 1, 
        title: '一食堂的红烧肉绝绝子！真的太好吃了😭', 
        userName: '吃货小明', 
        likeCount: 234, 
        isLiked: true, 
        isFeatured: true,
        coverImage: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80', 
        userAvatar: DEFAULT_IMAGES.avatar 
      },
      { 
        id: 2, 
        title: '清爽解腻！夏日必备清爽柠檬水🍋', 
        userName: 'RunningMan', 
        likeCount: 125, 
        isLiked: false, 
        isFeatured: false,
        coverImage: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=300&q=80', 
        userAvatar: DEFAULT_IMAGES.avatar 
      },
      { 
        id: 3, 
        title: '二食堂新开的奶茶店排队好长啊...不过味道真的值得！', 
        userName: '奶茶星人', 
        likeCount: 456, 
        isLiked: true, 
        isFeatured: true,
        coverImage: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=300&q=80', 
        userAvatar: DEFAULT_IMAGES.avatar 
      },
      { 
        id: 4, 
        title: '考试周加油！吃顿好的犒劳自己💪', 
        userName: '学霸君', 
        likeCount: 889, 
        isLiked: false, 
        isFeatured: false,
        coverImage: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=300&q=80', 
        userAvatar: DEFAULT_IMAGES.avatar 
      },
      { 
        id: 5, 
        title: '有没有人一起拼单这个？满30减10很划算！', 
        userName: '省钱小能手', 
        likeCount: 56, 
        isLiked: false, 
        isFeatured: false,
        coverImage: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&q=80', 
        userAvatar: DEFAULT_IMAGES.avatar 
      },
      { 
        id: 6, 
        title: '这家的麻辣烫是我吃过最正宗的！', 
        userName: '辣妹子', 
        likeCount: 342, 
        isLiked: true, 
        isFeatured: true,
        coverImage: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300&q=80', 
        userAvatar: DEFAULT_IMAGES.avatar 
      }
    ]

    // 添加距离信息（附近 tab 用）
    const nearbyData = mockData.map(item => ({
      ...item,
      distance: `${Math.floor(Math.random() * 900 + 100)}m`
    }))

    const { leftCol, rightCol } = this.distributeToColumns(mockData)
    const { leftCol: nearbyLeft, rightCol: nearbyRight } = this.distributeToColumns(nearbyData)

    this.setData({
      discoverList: mockData,
      discoverLeftCol: leftCol,
      discoverRightCol: rightCol,
      nearbyList: nearbyData,
      nearbyLeftCol: nearbyLeft,
      nearbyRightCol: nearbyRight,
      hasMore: false
    })
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
    this.loadData()
  },

  /**
   * 加载更多
   */
  loadMore() {
    if (this.data.loading || !this.data.hasMore) return
    
    this.setData({ page: this.data.page + 1 })
    this.loadData()
  },

  /**
   * 点击笔记卡片
   */
  onCardClick(e) {
    const note = e.currentTarget.dataset.note
    wx.navigateTo({
      url: `/pages/community/detail?id=${note.id}`
    })
  },

  /**
   * 点赞
   */
  async onLike(e) {
    const note = e.currentTarget.dataset.note
    
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再点赞',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }
    
    // 乐观更新
    const { activeTab } = this.data
    const listKey = `${activeTab}List`
    const leftColKey = `${activeTab}LeftCol`
    const rightColKey = `${activeTab}RightCol`
    
    const list = [...this.data[listKey]]
    const item = list.find(n => n.id === note.id)
    
    if (item) {
      item.isLiked = !item.isLiked
      item.likeCount = item.isLiked ? item.likeCount + 1 : Math.max(0, item.likeCount - 1)
      
      const { leftCol, rightCol } = this.distributeToColumns(list)
      
      this.setData({
        [listKey]: list,
        [leftColKey]: leftCol,
        [rightColKey]: rightCol
      })
    }
    
    try {
      await request({
        url: `/note/like/${note.id}`,
        method: 'POST'
      })
    } catch (error) {
      console.error('点赞失败:', error)
      // 回滚
      if (item) {
        item.isLiked = !item.isLiked
        item.likeCount = item.isLiked ? item.likeCount + 1 : Math.max(0, item.likeCount - 1)
        
        const { leftCol, rightCol } = this.distributeToColumns(list)
        
        this.setData({
          [listKey]: list,
          [leftColKey]: leftCol,
          [rightColKey]: rightCol
        })
      }
    }
  },

  /**
   * 点击话题
   */
  onTopicClick(e) {
    const topic = e.currentTarget.dataset.topic
    wx.navigateTo({
      url: `/pages/search/search?keyword=${encodeURIComponent('#' + topic.name)}`
    })
  },

  /**
   * 切换位置
   */
  changeLocation() {
    wx.showActionSheet({
      itemList: ['南京工业大学', '江浦校区', '丁家桥校区'],
      success: (res) => {
        const locations = ['南京工业大学', '江浦校区', '丁家桥校区']
        this.setData({ location: locations[res.tapIndex] })
        
        // 重新加载附近数据
        if (this.data.activeTab === 'nearby') {
          this.loadData()
        }
      }
    })
  },

  /**
   * 跳转搜索
   */
  goToSearch() {
    wx.navigateTo({
      url: '/pages/search/search'
    })
  },

  /**
   * 发布笔记
   */
  onPublish() {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再发布',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }
    
    wx.navigateTo({
      url: '/pages/community/publish'
    })
  }
})
