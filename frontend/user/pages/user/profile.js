// pages/user/profile.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showLoading, hideLoading, showError, showSuccess, getImageUrl } = require('../../utils/util')

Page({
  data: {
    userInfo: {},
    defaultAvatar: DEFAULT_IMAGES.avatar,
    genderText: '未设置',
    phoneDisplay: '****',
    userLevel: {
      level: 1,
      title: '美食小白',
      icon: '🌱',
      currentExp: 0,
      nextExp: 100
    },
    
    // Modal states
    showNicknameModal: false,
    showSignatureModal: false,
    tempNickname: '',
    tempSignature: ''
  },

  onLoad() {
    this.loadUserInfo()
  },

  /**
   * 加载用户信息
   */
  loadUserInfo() {
    const userInfo = wx.getStorageSync('userInfo')
    const phone = wx.getStorageSync('phone')
    
    if (userInfo) {
      const genderMap = { 0: '未设置', 1: '男', 2: '女' }
      
      this.setData({
        userInfo: {
          ...userInfo,
          nickName: userInfo.name || userInfo.nickName || `学生-${phone || '****'}`,
          avatarUrl: getImageUrl(userInfo.avatar, DEFAULT_IMAGES.avatar),
          signature: userInfo.signature || ''
        },
        genderText: genderMap[userInfo.sex] || '未设置',
        phoneDisplay: phone ? phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '****',
        tempNickname: userInfo.name || userInfo.nickName || '',
        tempSignature: userInfo.signature || ''
      })
      
      // 计算等级
      this.calculateLevel(userInfo.exp || 0)
    }
  },

  /**
   * 计算用户等级
   */
  calculateLevel(exp) {
    const LEVEL_CONFIG = [
      { level: 1, title: '美食小白', icon: '🌱', minExp: 0, maxExp: 100 },
      { level: 2, title: '美食学徒', icon: '🌿', minExp: 100, maxExp: 300 },
      { level: 3, title: '美食达人', icon: '🌳', minExp: 300, maxExp: 600 },
      { level: 4, title: '美食专家', icon: '⭐', minExp: 600, maxExp: 1000 },
      { level: 5, title: '美食大师', icon: '🏆', minExp: 1000, maxExp: 2000 },
      { level: 6, title: '美食之神', icon: '👑', minExp: 2000, maxExp: 999999 }
    ]
    
    let currentLevel = LEVEL_CONFIG[0]
    for (let i = LEVEL_CONFIG.length - 1; i >= 0; i--) {
      if (exp >= LEVEL_CONFIG[i].minExp) {
        currentLevel = LEVEL_CONFIG[i]
        break
      }
    }
    
    this.setData({
      userLevel: {
        level: currentLevel.level,
        title: currentLevel.title,
        icon: currentLevel.icon,
        currentExp: exp,
        nextExp: currentLevel.maxExp
      }
    })
  },

  /**
   * 更换头像
   */
  changeAvatar() {
    wx.chooseMedia({
      count: 1,
      mediaType: ['image'],
      sourceType: ['album', 'camera'],
      success: async (res) => {
        const tempFilePath = res.tempFiles[0].tempFilePath
        
        try {
          showLoading('上传中...')
          
          // 上传头像
          const uploadRes = await this.uploadAvatar(tempFilePath)
          
          if (uploadRes) {
            // 更新用户头像
            await request({
              url: '/user/update',
              method: 'PUT',
              data: { avatar: uploadRes }
            })
            
            // 更新本地数据
            const userInfo = wx.getStorageSync('userInfo')
            userInfo.avatar = uploadRes
            wx.setStorageSync('userInfo', userInfo)
            
            this.setData({
              'userInfo.avatarUrl': getImageUrl(uploadRes, DEFAULT_IMAGES.avatar)
            })
            
            hideLoading()
            showSuccess('头像更新成功')
          }
        } catch (error) {
          hideLoading()
          console.error('更换头像失败:', error)
          showError('更换头像失败')
        }
      }
    })
  },

  /**
   * 上传头像
   */
  uploadAvatar(filePath) {
    return new Promise((resolve, reject) => {
      const token = wx.getStorageSync('token')
      
      wx.uploadFile({
        url: `${getApp().globalData.baseUrl}/common/upload`,
        filePath: filePath,
        name: 'file',
        header: {
          'Authorization': token ? `Bearer ${token}` : ''
        },
        success: (res) => {
          try {
            const data = JSON.parse(res.data)
            if (data.code === 1 && data.data) {
              resolve(data.data)
            } else {
              reject(new Error(data.msg || '上传失败'))
            }
          } catch (e) {
            reject(e)
          }
        },
        fail: reject
      })
    })
  },

  /**
   * 编辑昵称
   */
  editNickname() {
    this.setData({
      showNicknameModal: true,
      tempNickname: this.data.userInfo.nickName || ''
    })
  },

  /**
   * 关闭昵称弹窗
   */
  closeNicknameModal() {
    this.setData({ showNicknameModal: false })
  },

  /**
   * 昵称输入
   */
  onNicknameInput(e) {
    this.setData({ tempNickname: e.detail.value })
  },

  /**
   * 保存昵称
   */
  async saveNickname() {
    const nickname = this.data.tempNickname.trim()
    
    if (!nickname) {
      showError('请输入昵称')
      return
    }
    
    if (nickname.length < 2) {
      showError('昵称至少2个字符')
      return
    }
    
    try {
      showLoading('保存中...')
      
      const updatedUser = await request({
        url: '/user/update',
        method: 'PUT',
        data: { name: nickname }
      })
      
      // 使用服务器返回的最新数据更新本地存储
      if (updatedUser) {
        wx.setStorageSync('userInfo', updatedUser)
      } else {
        // 如果服务器没返回，手动更新本地数据
        const userInfo = wx.getStorageSync('userInfo')
        userInfo.name = nickname
        wx.setStorageSync('userInfo', userInfo)
      }
      
      this.setData({
        'userInfo.nickName': nickname,
        showNicknameModal: false
      })
      
      hideLoading()
      showSuccess('昵称修改成功')
    } catch (error) {
      hideLoading()
      console.error('修改昵称失败:', error)
      showError('修改失败')
    }
  },

  /**
   * 编辑个性签名
   */
  editSignature() {
    this.setData({
      showSignatureModal: true,
      tempSignature: this.data.userInfo.signature || ''
    })
  },

  /**
   * 关闭签名弹窗
   */
  closeSignatureModal() {
    this.setData({ showSignatureModal: false })
  },

  /**
   * 签名输入
   */
  onSignatureInput(e) {
    this.setData({ tempSignature: e.detail.value })
  },

  /**
   * 保存签名
   */
  async saveSignature() {
    const signature = this.data.tempSignature.trim()
    
    try {
      showLoading('保存中...')
      
      const updatedUser = await request({
        url: '/user/update',
        method: 'PUT',
        data: { signature: signature }
      })
      
      // 使用服务器返回的最新数据更新本地存储
      if (updatedUser) {
        wx.setStorageSync('userInfo', updatedUser)
      } else {
        // 如果服务器没返回，手动更新本地数据
        const userInfo = wx.getStorageSync('userInfo')
        userInfo.signature = signature
        wx.setStorageSync('userInfo', userInfo)
      }
      
      this.setData({
        'userInfo.signature': signature,
        showSignatureModal: false
      })
      
      hideLoading()
      showSuccess('签名修改成功')
    } catch (error) {
      hideLoading()
      console.error('修改签名失败:', error)
      showError('修改失败')
    }
  },

  /**
   * 选择性别
   */
  selectGender() {
    wx.showActionSheet({
      itemList: ['男', '女', '保密'],
      success: async (res) => {
        const genderMap = { 0: 1, 1: 2, 2: 0 }
        const genderTextMap = { 0: '男', 1: '女', 2: '保密' }
        const sex = genderMap[res.tapIndex]
        
        try {
          showLoading('保存中...')
          
          await request({
            url: '/user/update',
            method: 'PUT',
            data: { sex: sex }
          })
          
          // 更新本地数据
          const userInfo = wx.getStorageSync('userInfo')
          userInfo.sex = sex
          wx.setStorageSync('userInfo', userInfo)
          
          this.setData({
            genderText: genderTextMap[res.tapIndex]
          })
          
          hideLoading()
          showSuccess('性别修改成功')
        } catch (error) {
          hideLoading()
          console.error('修改性别失败:', error)
          showError('修改失败')
        }
      }
    })
  },

  /**
   * 阻止滚动穿透
   */
  preventMove() {
    return false
  }
})

