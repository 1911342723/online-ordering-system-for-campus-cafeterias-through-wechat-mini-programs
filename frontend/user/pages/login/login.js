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
   * 快捷学生登录
   */
  async quickStudentLogin() {
    try {
      wx.showLoading({ title: '登录中...' })
      
      // 生成测试学生手机号
      const testPhone = '138' + Math.floor(Math.random() * 100000000).toString().padStart(8, '0')
      
      const result = await request({
        url: '/userAuth/student/quickLogin',
        method: 'POST',
        data: { phone: testPhone }
      })
      
      wx.hideLoading()
      this.handleLoginSuccess(result, '学生')
    } catch (err) {
      wx.hideLoading()
      console.error('学生登录失败:', err)
      wx.showToast({
        title: err.msg || '登录失败',
        icon: 'none',
        duration: 2000
      })
    }
  },

  /**
   * 快捷教师登录
   */
  async quickTeacherLogin() {
    try {
      wx.showLoading({ title: '登录中...' })
      
      // 生成测试教师手机号
      const testPhone = '139' + Math.floor(Math.random() * 100000000).toString().padStart(8, '0')
      
      const result = await request({
        url: '/userAuth/teacher/quickLogin',
        method: 'POST',
        data: { phone: testPhone }
      })
      
      wx.hideLoading()
      this.handleLoginSuccess(result, '教师')
    } catch (err) {
      wx.hideLoading()
      console.error('教师登录失败:', err)
      wx.showToast({
        title: err.msg || '登录失败',
        icon: 'none',
        duration: 2000
      })
    }
  },

  /**
   * 处理登录成功
   */
  handleLoginSuccess(result, userType) {
    const { user, token } = result
    
    // 保存用户信息和Token
    wx.setStorageSync('userInfo', user)
    wx.setStorageSync('token', token)
    wx.setStorageSync('phone', user.phone)
    
    console.log(`${userType}登录成功:`, user)
    
    wx.showToast({
      title: `${userType}登录成功`,
      icon: 'success',
      duration: 1500
    })
    
    setTimeout(() => {
      wx.switchTab({ url: '/pages/index/index' })
    }, 1500)
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
