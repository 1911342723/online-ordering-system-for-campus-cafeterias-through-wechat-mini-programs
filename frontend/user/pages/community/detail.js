// pages/community/detail.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showLoading, hideLoading, showError, showSuccess, checkLogin, navigateToLogin } = require('../../utils/util')

Page({
  data: {
    noteId: null,
    note: {
      id: 0,
      title: '',
      content: '',
      imageList: [],
      tagList: [],
      likeCount: 0,
      collectCount: 0,
      commentCount: 0,
      shareCount: 0,
      isLiked: false,
      isCollected: false,
      comments: []
    },
    loading: false,
    defaultAvatar: DEFAULT_IMAGES.avatar,
    isAuthor: false,
    
    // 评论相关
    showCommentModal: false,
    commentText: '',
    replyTo: null // 回复的评论对象
  },

  onLoad(options) {
    if (options.id) {
      this.setData({ noteId: options.id })
      this.loadNoteDetail(options.id)
    } else {
      // 使用模拟数据
      this.loadMockData()
    }
  },

  /**
   * 加载笔记详情
   */
  async loadNoteDetail(id) {
    this.setData({ loading: true })
    
    try {
      showLoading('加载中...')
      
      const note = await request({
        url: `/note/${id}`,
        method: 'GET'
      })
      
      // 处理图片列表
      if (note.images && typeof note.images === 'string') {
        note.imageList = note.images.split(',').filter(img => img)
      } else if (!note.imageList) {
        note.imageList = note.coverImage ? [note.coverImage] : []
      }
      
      // 处理标签列表
      if (note.tags && typeof note.tags === 'string') {
        note.tagList = note.tags.split(',').filter(tag => tag)
      } else if (!note.tagList) {
        note.tagList = []
      }
      
      // 格式化时间
      if (note.createTime) {
        note.createTimeStr = this.formatTime(note.createTime)
      }
      
      // 确保评论是数组
      if (!note.comments) {
        note.comments = []
      }
      
      // 格式化评论时间
      note.comments.forEach(comment => {
        if (comment.createTime) {
          comment.createTimeStr = this.formatTime(comment.createTime)
        }
        // 确保回复是数组
        if (!comment.replies) {
          comment.replies = []
        }
      })
      
      // 同步评论数量
      note.commentCount = note.comments.length
      
      // 检查是否是作者
      const userId = wx.getStorageSync('userId')
      const isAuthor = note.userId && note.userId.toString() === userId
      
      this.setData({ 
        note,
        isAuthor,
        loading: false
      })
      
      hideLoading()
    } catch (error) {
      hideLoading()
      console.error('加载笔记详情失败:', error)
      this.setData({ loading: false })
      
      // 加载失败使用模拟数据
      this.loadMockData()
    }
  },

  /**
   * 加载模拟数据
   */
  loadMockData() {
    const mockNote = {
      id: 1,
      title: '一食堂的红烧肉绝绝子！真的太好吃了😭',
      content: '今天中午去一食堂吃饭，排队的人超级多！但是为了这口红烧肉一切都值得！\n\n肥而不腻，入口即化，酱汁浓郁，拌饭简直是一绝！\n\n强烈推荐大家去尝试一下！',
      coverImage: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      imageList: [
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80'
      ],
      tagList: ['红烧肉', '一食堂', '美食打卡'],
      createTimeStr: '11-25',
      userName: '美食达人',
      userAvatar: DEFAULT_IMAGES.avatar,
      likeCount: 234,
      collectCount: 56,
      commentCount: 2,
      shareCount: 12,
      isLiked: false,
      isCollected: false,
      comments: [
        { 
          id: 1, 
          userName: '干饭人', 
          userAvatar: DEFAULT_IMAGES.avatar, 
          content: '看着就很有食欲！明天去吃！', 
          createTimeStr: '11-25', 
          likeCount: 5,
          isLiked: false,
          replies: []
        },
        { 
          id: 2, 
          userName: '路人甲', 
          userAvatar: DEFAULT_IMAGES.avatar, 
          content: '多少钱一份呀？', 
          createTimeStr: '11-25', 
          likeCount: 2,
          isLiked: false,
          replies: [
            {
              id: 3,
              userName: '美食达人',
              replyUserName: '路人甲',
              content: '12块钱一份，超值！'
            }
          ]
        }
      ]
    }
    
    this.setData({ note: mockNote })
  },

  /**
   * 格式化时间
   */
  formatTime(timeStr) {
    const date = new Date(timeStr)
    const now = new Date()
    const diff = now - date
    
    if (diff < 60000) {
      return '刚刚'
    } else if (diff < 3600000) {
      return Math.floor(diff / 60000) + '分钟前'
    } else if (diff < 86400000) {
      return Math.floor(diff / 3600000) + '小时前'
    } else if (diff < 604800000) {
      return Math.floor(diff / 86400000) + '天前'
    } else {
      const month = date.getMonth() + 1
      const day = date.getDate()
      return `${month}-${day}`
    }
  },

  /**
   * 预览图片
   */
  previewImage(e) {
    const url = e.currentTarget.dataset.url
    wx.previewImage({
      current: url,
      urls: this.data.note.imageList || [url]
    })
  },

  /**
   * 点赞
   */
  async onLike() {
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
    
    const note = this.data.note
    const newIsLiked = !note.isLiked
    const newLikeCount = newIsLiked ? note.likeCount + 1 : note.likeCount - 1
    
    // 乐观更新
    this.setData({
      'note.isLiked': newIsLiked,
      'note.likeCount': newLikeCount
    })
    
    try {
      await request({
        url: `/note/like/${note.id}`,
        method: 'POST'
      })
    } catch (error) {
      // 回滚
      this.setData({
        'note.isLiked': !newIsLiked,
        'note.likeCount': note.likeCount
      })
      showError('操作失败')
    }
  },

  /**
   * 收藏
   */
  async onCollect() {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再收藏',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }
    
    const note = this.data.note
    const newIsCollected = !note.isCollected
    const newCollectCount = newIsCollected ? note.collectCount + 1 : note.collectCount - 1
    
    // 乐观更新
    this.setData({
      'note.isCollected': newIsCollected,
      'note.collectCount': newCollectCount
    })
    
    showSuccess(newIsCollected ? '已收藏' : '已取消收藏')
    
    try {
      await request({
        url: `/note/collect/${note.id}`,
        method: 'POST'
      })
    } catch (error) {
      // 回滚
      this.setData({
        'note.isCollected': !newIsCollected,
        'note.collectCount': note.collectCount
      })
      showError('操作失败')
    }
  },

  /**
   * 转发
   */
  async onShare() {
    const note = this.data.note
    
    // 更新转发数
    this.setData({
      'note.shareCount': note.shareCount + 1
    })
    
    // 调用微信分享
    wx.showShareMenu({
      withShareTicket: true,
      menus: ['shareAppMessage', 'shareTimeline']
    })
    
    try {
      await request({
        url: `/note/share/${note.id}`,
        method: 'POST'
      })
    } catch (error) {
      console.error('更新转发数失败:', error)
    }
  },

  /**
   * 分享给朋友
   */
  onShareAppMessage() {
    const note = this.data.note
    return {
      title: note.title,
      path: `/pages/community/detail?id=${note.id}`,
      imageUrl: note.coverImage || note.imageList[0]
    }
  },

  /**
   * 分享到朋友圈
   */
  onShareTimeline() {
    const note = this.data.note
    return {
      title: note.title,
      query: `id=${note.id}`,
      imageUrl: note.coverImage || note.imageList[0]
    }
  },

  /**
   * 显示评论输入框
   */
  showCommentInput() {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再评论',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }
    
    this.setData({ showCommentModal: true })
  },

  /**
   * 隐藏评论输入框
   */
  hideCommentInput() {
    this.setData({ 
      showCommentModal: false,
      commentText: '',
      replyTo: null
    })
  },

  /**
   * 评论输入
   */
  onCommentInput(e) {
    this.setData({ commentText: e.detail.value })
  },

  /**
   * 回复评论
   */
  onReplyComment(e) {
    const comment = e.currentTarget.dataset.comment
    
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再回复',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }
    
    this.setData({ 
      replyTo: comment,
      showCommentModal: true
    })
  },

  /**
   * 提交评论
   */
  async submitComment() {
    const { commentText, replyTo, note } = this.data
    
    if (!commentText.trim()) {
      showError('请输入评论内容')
      return
    }
    
    try {
      showLoading('发送中...')
      
      const commentData = {
        noteId: note.id,
        content: commentText.trim(),
        parentId: replyTo ? replyTo.id : 0,
        replyUserId: replyTo ? replyTo.userId : null
      }
      
      const newComment = await request({
        url: '/note/comment',
        method: 'POST',
        data: commentData
      })
      
      hideLoading()
      
      // 添加到评论列表
      const comments = [...(note.comments || [])]
      if (replyTo) {
        // 添加到回复列表
        const parentComment = comments.find(c => c.id === replyTo.id)
        if (parentComment) {
          if (!parentComment.replies) {
            parentComment.replies = []
          }
          parentComment.replies.push({
            id: newComment.id,
            userName: newComment.userName || '我',
            replyUserName: replyTo.userName,
            content: commentText.trim()
          })
        }
      } else {
        // 添加到一级评论
        comments.unshift({
          id: newComment.id || Date.now(),
          userName: newComment.userName || '我',
          userAvatar: newComment.userAvatar || DEFAULT_IMAGES.avatar,
          content: commentText.trim(),
          createTimeStr: '刚刚',
          likeCount: 0,
          isLiked: false,
          replies: []
        })
      }
      
      this.setData({
        'note.comments': comments,
        'note.commentCount': (note.commentCount || 0) + 1,
        showCommentModal: false,
        commentText: '',
        replyTo: null
      })
      
      showSuccess('评论成功')
      
    } catch (error) {
      hideLoading()
      console.error('评论失败:', error)
      showError('评论失败，请重试')
    }
  },

  /**
   * 评论点赞
   */
  async onLikeComment(e) {
    const commentId = e.currentTarget.dataset.id
    
    // 找到评论并更新
    const comments = [...this.data.note.comments]
    const comment = comments.find(c => c.id === commentId)
    
    if (comment) {
      comment.isLiked = !comment.isLiked
      comment.likeCount = comment.isLiked ? (comment.likeCount || 0) + 1 : Math.max(0, (comment.likeCount || 0) - 1)
      
      this.setData({ 'note.comments': comments })
      
      try {
        await request({
          url: `/note/comment/like/${commentId}`,
          method: 'POST'
        })
      } catch (error) {
        console.error('评论点赞失败:', error)
      }
    }
  },

  /**
   * 阻止滚动穿透
   */
  preventMove() {
    return false
  }
})
