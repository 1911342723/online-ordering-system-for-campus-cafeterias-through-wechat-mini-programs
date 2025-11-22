// pages/login/login.js
const request = require('../../utils/request')

Page({
  data: {
    showRetry: false,  // 是否显示重试提示
    isDev: true        // 开发模式标识
  },

  /**
   * 微信手机号授权登录
   */
  getPhoneNumber(e) {
    if (e.detail.code) {
      console.log('Phone Code:', e.detail.code)
      this.setData({ showRetry: false })
      this.doLogin()
    } else if (e.detail.errMsg) {
      console.log('授权失败:', e.detail.errMsg)
      // 用户拒绝授权
      this.setData({ showRetry: true })
      wx.showModal({
        title: '需要授权',
        content: '为了更好地为您服务，需要获取您的手机号用于登录。如果您拒绝授权，可以使用测试登录功能。',
        confirmText: '我知道了',
        showCancel: false
      })
    }
  },

  /**
   * 执行登录请求
   */
  doLogin(phone) {
    wx.showLoading({ title: '登录中...' })
    
    // 生成测试手机号（实际项目中应该通过微信接口解密获取真实手机号）
    const mockPhone = phone || '138' + Math.floor(Math.random() * 100000000).toString().padStart(8, '0')
    
    request({
      url: '/user/login',
      method: 'POST',
      data: {
        phone: mockPhone
      }
    }).then(result => {
      wx.hideLoading()
      
      // 保存用户信息和Token
      const { user, token } = result
      wx.setStorageSync('userInfo', user)
      wx.setStorageSync('token', token)  // 保存JWT Token
      wx.setStorageSync('phone', mockPhone)
      
      console.log('登录成功，Token:', token)
      
      wx.showToast({
        title: '登录成功',
        icon: 'success',
        duration: 1500
      })
      setTimeout(() => {
        wx.switchTab({ url: '/pages/index/index' })
      }, 1500)
    }).catch(err => {
      wx.hideLoading()
      console.error('登录失败:', err)
      wx.showToast({
        title: '登录失败，请重试',
        icon: 'none'
      })
    })
  },

  /**
   * 测试登录（开发使用）
   */
  testLogin() {
    wx.showModal({
      title: '测试登录',
      content: '这是开发测试功能，将使用随机手机号登录',
      confirmText: '确定',
      cancelText: '取消',
      success: (res) => {
        if (res.confirm) {
          this.doLogin()
        }
      }
    })
  },

  /**
   * 重新授权
   */
  retryAuth() {
    this.setData({ showRetry: false })
    wx.showToast({
      title: '请点击下方按钮授权',
      icon: 'none'
    })
  }
})
