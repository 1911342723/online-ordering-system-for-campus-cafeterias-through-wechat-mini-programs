// pages/user/user.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showError, showSuccess, navigateToLogin, getImageUrl, checkLogin } = require('../../utils/util')

// 等级配置
const LEVEL_CONFIG = [
  { level: 1, title: '美食小白', icon: '🌱', minExp: 0, maxExp: 100, tips: '再发布1篇帖子即可升级' },
  { level: 2, title: '美食学徒', icon: '🌿', minExp: 100, maxExp: 300, tips: '多发帖、评论可以快速升级哦' },
  { level: 3, title: '美食达人', icon: '🌳', minExp: 300, maxExp: 600, tips: '你已经是美食达人啦！' },
  { level: 4, title: '美食专家', icon: '⭐', minExp: 600, maxExp: 1000, tips: '继续加油，即将成为美食大师！' },
  { level: 5, title: '美食大师', icon: '🏆', minExp: 1000, maxExp: 2000, tips: '恭喜成为美食大师！' },
  { level: 6, title: '美食之神', icon: '👑', minExp: 2000, maxExp: 999999, tips: '你已经是传说中的美食之神！' }
]

Page({
  data: {
    isLoggedIn: false,
    userInfo: {},
    defaultAvatar: DEFAULT_IMAGES.avatar,
    stats: {
      balance: '0.00',
      coupon: 0,
      posts: 0,
      collects: 0,
      likes: 0
    },
    userLevel: {
      level: 1,
      title: '美食小白',
      icon: '🌱',
      currentExp: 0,
      nextExp: 100,
      progress: 0,
      tips: '发布帖子、下单可以获得经验哦'
    },
    unreadCount: 0
  },

  onShow() {
    this.loadUserInfo()
  },

  /**
   * 加载用户信息
   */
  loadUserInfo() {
    const userInfo = wx.getStorageSync('userInfo')
    const token = wx.getStorageSync('token')
    const phone = wx.getStorageSync('phone')
    
    if (userInfo && token) {
      this.setData({
        isLoggedIn: true,
        userInfo: {
          ...userInfo,
          nickName: userInfo.name || userInfo.nickName || `学生-${phone || '****'}`,
          phone: phone,
          avatarUrl: getImageUrl(userInfo.avatar, DEFAULT_IMAGES.avatar),
          signature: userInfo.signature || ''
        }
      })
      
      // 加载用户统计数据
      this.loadUserStats()
      // 加载未读消息数
      this.loadUnreadCount()
    } else {
      this.setData({
        isLoggedIn: false,
        userInfo: {},
        stats: {
          balance: '0.00',
          coupon: 0,
          posts: 0,
          collects: 0,
          likes: 0
        }
      })
    }
  },

  /**
   * 加载用户统计数据
   */
  async loadUserStats() {
    try {
      // 获取用户基本信息
      const userInfo = await request({
        url: '/user/info',
        method: 'GET',
        silent: true  // 静默模式，由本方法自行处理错误
      })
      
      if (userInfo) {
        // 计算等级
        const exp = userInfo.exp || 0
        const levelInfo = this.calculateLevel(exp)
        
        this.setData({
          stats: {
            balance: (userInfo.balance || 0).toFixed(2),
            coupon: userInfo.couponCount || 0,
            posts: userInfo.postCount || 0,
            collects: userInfo.collectCount || 0,
            likes: userInfo.likeCount || 0
          },
          userLevel: levelInfo,
          userInfo: {
            ...this.data.userInfo,
            ...userInfo,
            nickName: userInfo.name || this.data.userInfo.nickName,
            signature: userInfo.signature || ''
          }
        })
        
        // 更新本地存储
        wx.setStorageSync('userInfo', userInfo)
      }
    } catch (error) {
      console.error('加载用户统计数据失败:', error)
      
      // 如果后端返回"用户不存在"，说明token对应的用户已被删除（可能数据库重置），
      // 需要清除本地过期凭证并引导重新登录
      if (error && error.msg === '用户不存在') {
        console.warn('用户不存在，清除过期登录状态')
        wx.removeStorageSync('userInfo')
        wx.removeStorageSync('token')
        wx.removeStorageSync('phone')
        this.setData({
          isLoggedIn: false,
          userInfo: {},
          stats: {
            balance: '0.00',
            coupon: 0,
            posts: 0,
            collects: 0,
            likes: 0
          },
          unreadCount: 0
        })
        wx.showToast({
          title: '登录已过期，请重新登录',
          icon: 'none',
          duration: 2000
        })
        return
      }
      
      // 其他错误使用模拟数据
      this.loadMockStats()
    }
  },

  /**
   * 加载模拟统计数据
   */
  loadMockStats() {
    const mockExp = 150
    const levelInfo = this.calculateLevel(mockExp)
    
    this.setData({
      stats: {
        balance: '0.00',
        coupon: 2,
        posts: 5,
        collects: 12,
        likes: 28
      },
      userLevel: levelInfo
    })
  },

  /**
   * 计算用户等级
   */
  calculateLevel(exp) {
    let currentLevel = LEVEL_CONFIG[0]
    
    for (let i = LEVEL_CONFIG.length - 1; i >= 0; i--) {
      if (exp >= LEVEL_CONFIG[i].minExp) {
        currentLevel = LEVEL_CONFIG[i]
        break
      }
    }
    
    const nextLevel = LEVEL_CONFIG.find(l => l.level === currentLevel.level + 1) || currentLevel
    const expInLevel = exp - currentLevel.minExp
    const expNeeded = currentLevel.maxExp - currentLevel.minExp
    const progress = Math.min(100, Math.round((expInLevel / expNeeded) * 100))
    
    return {
      level: currentLevel.level,
      title: currentLevel.title,
      icon: currentLevel.icon,
      currentExp: exp,
      nextExp: currentLevel.maxExp,
      progress: progress,
      tips: currentLevel.tips
    }
  },

  /**
   * 加载未读消息数
   */
  async loadUnreadCount() {
    try {
      const res = await request({
        url: '/message/unread/count',
        method: 'GET'
      })
      this.setData({ unreadCount: res || 0 })
    } catch (error) {
      console.error('加载未读消息数失败:', error)
      this.setData({ unreadCount: 0 })
    }
  },

  /**
   * 登录
   */
  login() {
    navigateToLogin()
  },

  /**
   * 登出
   */
  logout() {
    wx.showModal({
      title: '提示',
      content: '确定要退出登录吗？',
      success: (res) => {
        if (res.confirm) {
          wx.removeStorageSync('userInfo')
          wx.removeStorageSync('token')
          wx.removeStorageSync('phone')
          this.setData({
            isLoggedIn: false,
            userInfo: {},
            stats: {
              balance: '0.00',
              coupon: 0,
              posts: 0,
              collects: 0,
              likes: 0
            },
            unreadCount: 0
          })
          showSuccess('已退出登录')
        }
      }
    })
  },

  /**
   * 跳转到个人信息设置页面
   */
  goToProfile() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/user/profile'
    })
  },

  /**
   * 跳转到我的帖子
   */
  goToMyPosts() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/user/posts'
    })
  },

  /**
   * 跳转到我的收藏
   */
  goToMyCollects() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/user/collects'
    })
  },

  /**
   * 跳转到获赞页面
   */
  goToMyLikes() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/user/likes'
    })
  },

  /**
   * 跳转到消息中心
   */
  goToMessages() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/user/messages'
    })
  },

  /**
   * 跳转到订单列表
   */
  goToOrders() {
    wx.switchTab({
      url: '/pages/order/order'
    })
  },

  /**
   * 跳转到优惠券
   */
  goToCoupon() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/coupon/coupon'
    })
  },

  /**
   * 跳转到等级详情
   */
  goToLevelDetail() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/user/level'
    })
  },

  /**
   * 我的地址
   */
  goToAddress() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/address/list'
    })
  },

  /**
   * 意见反馈
   */
  goToFeedback() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/feedback/feedback'
    })
  },

  /**
   * 联系客服
   */
  contactService() {
    wx.showModal({
      title: '客服电话',
      content: '服务热线：400-123-4567\n服务时间：9:00-21:00',
      showCancel: false
    })
  },

  /**
   * 设置
   */
  goToSettings() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/settings/settings'
    })
  },

  /**
   * 去充值
   */
  goRecharge() {
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    wx.navigateTo({
      url: '/pages/recharge/recharge'
    })
  }
})
