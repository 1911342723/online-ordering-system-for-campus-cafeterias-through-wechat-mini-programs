// pages/user/user.js
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showError, showSuccess, navigateToLogin } = require('../../utils/util')

// SVG Icons - Updated for premium look
const ICONS = {
  address: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23FF5000'%3E%3Cpath d='M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z'/%3E%3C/svg%3E",
  feedback: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%231890FF'%3E%3Cpath d='M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H6l-2 2V4h16v12z'/%3E%3C/svg%3E",
  service: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%2352C41A'%3E%3Cpath d='M21 12.22C21 6.73 16.74 3 12 3c-4.69 0-9 3.65-9 9.28C2.4 12.62 2 13.26 2 14v2c0 1.1.9 2 2 2h1v-6.1c0-3.87 3.13-7 7-7s7 3.13 7 7V19h-8v2h8c1.1 0 2-.9 2-2v-1.22c.59-.31 1-.92 1-1.64v-2.3c0-.7-.41-1.31-1-1.62z'/%3E%3C/svg%3E",
  settings: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23595959'%3E%3Cpath d='M19.43 12.98c.04-.32.07-.64.07-.98s-.03-.66-.07-.98l2.11-1.65c.19-.15.24-.42.12-.64l-2-3.46c-.12-.22-.39-.3-.61-.22l-2.49 1c-.52-.4-1.08-.73-1.69-.98l-.38-2.65C14.46 2.18 14.25 2 14 2h-4c-.25 0-.46.18-.49.42l-.38 2.65c-.61.25-1.17.59-1.69.98l-2.49-1c-.23-.09-.49 0-.61.22l-2 3.46c-.13.22-.07.49.12.64l2.11 1.65c-.04.32-.07.65-.07.98s.03.66.07.98l-2.11 1.65c-.19.15-.24.42-.12.64l2 3.46c.12.22.39.3.61.22l2.49-1c.52.4 1.08.73 1.69.98l.38 2.65c.03.24.24.42.49.42h4c.25 0 .46-.18.49-.42l.38-2.65c.61-.25 1.17-.59 1.69-.98l2.49 1c.23.09.49 0 .61-.22l2-3.46c.12-.22.07-.49-.12-.64l-2.11-1.65zM12 15.5c-1.93 0-3.5-1.57-3.5-3.5s1.57-3.5 3.5-3.5 3.5 1.57 3.5 3.5-1.57 3.5-3.5 3.5z'/%3E%3C/svg%3E",
  admin: "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23999999'%3E%3Cpath d='M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z'/%3E%3C/svg%3E"
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
          avatarUrl: userInfo.avatar || DEFAULT_IMAGES.avatar
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
