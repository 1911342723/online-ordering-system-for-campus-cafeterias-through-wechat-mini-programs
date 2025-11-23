// pages/user/user.js
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showError, showSuccess, navigateToLogin, getImageUrl } = require('../../utils/util')

// SVG Icons - Updated for premium look
const ICONS = {
  address: "/assets/icons/address.svg",
  feedback: "/assets/icons/feedback.svg",
  service: "/assets/icons/service.svg",
  settings: "/assets/icons/settings.svg",
  admin: "/assets/icons/admin.svg"
}


Page({
  data: {
    isLoggedIn: false,
    userInfo: {},
    defaultAvatar: DEFAULT_IMAGES.avatar,
    stats: {
      balance: 0,
      coupon: 0,
      points: 0
    },
    menuItems: [
      {
        icon: ICONS.address,
        title: '我的地址',
        action: 'goToAddress'
      },
      {
        icon: ICONS.feedback,
        title: '意见反馈',
        action: 'goToFeedback'
      },
      {
        icon: ICONS.service,
        title: '联系客服',
        action: 'contactService'
      },
      {
        icon: ICONS.settings,
        title: '设置',
        action: 'goToSettings'
      },
      {
        icon: ICONS.admin,
        title: '商家/管理员入口',
        action: 'goToAdmin'
      }
    ]
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
          nickName: userInfo.name || `用户${phone ? phone.substr(-4) : '****'}`,
          phone: phone,
          avatarUrl: getImageUrl(userInfo.avatar, DEFAULT_IMAGES.avatar)
        }
      })
      
      // 加载用户统计数据（可选）
      this.loadUserStats()
    } else {
      this.setData({
        isLoggedIn: false,
        userInfo: {}
      })
    }
  },

  /**
   * 加载用户统计数据 - 从后端获取
   */
  async loadUserStats() {
    try {
      const request = require('../../utils/request')
      
      // 先尝试获取用户基本信息
      const userInfo = await request({
        url: '/user/info',
        method: 'GET'
      })
      
      if (userInfo) {
        // 更新用户信息和基础统计
        this.setData({
          stats: {
            balance: (userInfo.balance || 0).toFixed(2),
            coupon: userInfo.couponCount || 0
          },
          userInfo: {
            ...this.data.userInfo,
            ...userInfo
          }
        })
        
        // 更新本地存储
        wx.setStorageSync('userInfo', userInfo)
      }
    } catch (error) {
      console.error('加载用户统计数据失败:', error)
      
      // 使用本地缓存的数据作为降级
      const cachedUserInfo = wx.getStorageSync('userInfo')
      if (cachedUserInfo) {
        this.setData({
          stats: {
            balance: (cachedUserInfo.balance || 0).toFixed(2),
            coupon: cachedUserInfo.couponCount || 0
          }
        })
      } else {
        // 如果没有缓存且请求失败，显示默认值
        this.setData({
          stats: {
            balance: '0.00',
            coupon: 0
          }
        })
      }
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
              balance: 0,
              coupon: 0
            }
          })
          showSuccess('已退出登录')
        }
      }
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
   * 商家/管理员入口
   */
  goToAdmin() {
    wx.showModal({
      title: '提示',
      content: '请使用电脑浏览器访问管理后台\n\n地址：http://localhost:3000',
      confirmText: '我知道了',
      showCancel: false
    })
  },

  /**
   * 统一菜单项点击处理
   */
  handleMenuClick(e) {
    const { action } = e.currentTarget.dataset
    if (this[action]) {
      this[action]()
    }
  },

  /**
   * 点击统计项
   */
  handleStatClick(e) {
    const { type } = e.currentTarget.dataset
    if (!this.data.isLoggedIn) {
      this.login()
      return
    }
    
    const routes = {
      balance: '/pages/recharge/recharge',
      coupon: '/pages/coupon/coupon'
    }
    
    if (routes[type]) {
      wx.navigateTo({
        url: routes[type]
      })
    }
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
