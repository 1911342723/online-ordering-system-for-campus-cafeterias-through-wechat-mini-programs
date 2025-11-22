// pages/settings/settings.js
const { showError, showSuccess } = require('../../utils/util')

Page({
  data: {
    userInfo: {
      nickName: '',
      phone: '',
      sex: '0',
      avatarUrl: ''
    },
    settings: {
      orderNotify: true,
      promoNotify: true
    },
    cacheSize: '0 KB'
  },

  onLoad() {
    this.loadUserInfo()
    this.loadSettings()
    this.calculateCacheSize()
  },

  /**
   * 加载用户信息
   */
  async loadUserInfo() {
    try {
      const request = require('../../utils/request')
      const { DEFAULT_IMAGES } = require('../../utils/config')
      
      const userInfo = await request({
        url: '/user/info',
        method: 'GET'
      })
      
      if (userInfo) {
        this.setData({
          userInfo: {
            nickName: userInfo.name || '未设置',
            phone: userInfo.phone || '未绑定',
            sex: userInfo.sex || '0',
            avatarUrl: userInfo.avatar || DEFAULT_IMAGES.avatar
          }
        })
      }
    } catch (error) {
      console.error('加载用户信息失败:', error)
      // 使用缓存数据
      const userInfo = wx.getStorageSync('userInfo')
      const phone = wx.getStorageSync('phone')
      const { DEFAULT_IMAGES } = require('../../utils/config')
      
      if (userInfo) {
        this.setData({
          userInfo: {
            nickName: userInfo.name || `用户${phone ? phone.substr(-4) : '****'}`,
            phone: phone || '未绑定',
            sex: userInfo.sex || '0',
            avatarUrl: userInfo.avatar || DEFAULT_IMAGES.avatar
          }
        })
      }
    }
  },

  /**
   * 加载设置
   */
  loadSettings() {
    const settings = wx.getStorageSync('settings')
    if (settings) {
      this.setData({ settings })
    }
  },

  /**
   * 计算缓存大小
   */
  calculateCacheSize() {
    // 简单模拟，实际应该计算真实缓存大小
    this.setData({ cacheSize: '2.3 MB' })
  },

  /**
   * 编辑头像
   */
  editAvatar() {
    wx.chooseImage({
      count: 1,
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: async (res) => {
        try {
          const { showLoading, hideLoading, showSuccess, showError } = require('../../utils/util')
          showLoading('上传中...')
          
          // 上传图片
          const uploadRes = await new Promise((resolve, reject) => {
            wx.uploadFile({
              url: 'http://localhost:8080/common/upload',
              filePath: res.tempFilePaths[0],
              name: 'file',
              header: {
                'Authorization': 'Bearer ' + wx.getStorageSync('token')
              },
              success: resolve,
              fail: reject
            })
          })
          
          const data = JSON.parse(uploadRes.data)
          if (data.code === 1) {
            // 更新头像
            const request = require('../../utils/request')
            await request({
              url: '/user/update',
              method: 'PUT',
              data: {
                avatar: data.data
              }
            })
            
            this.setData({
              'userInfo.avatarUrl': 'http://localhost:8080/common/download?name=' + data.data
            })
            
            hideLoading()
            showSuccess('修改成功')
          } else {
            hideLoading()
            showError('上传失败')
          }
        } catch (error) {
          hideLoading()
          console.error('修改头像失败:', error)
          showError('修改失败')
        }
      }
    })
  },

  /**
   * 编辑昵称
   */
  editNickname() {
    wx.showModal({
      title: '修改昵称',
      editable: true,
      placeholderText: '请输入昵称',
      success: async (res) => {
        if (res.confirm && res.content) {
          try {
            const request = require('../../utils/request')
            
            await request({
              url: '/user/update',
              method: 'PUT',
              data: {
                name: res.content
              }
            })
            
            this.setData({
              'userInfo.nickName': res.content
            })
            
            showSuccess('修改成功')
          } catch (error) {
            console.error('修改昵称失败:', error)
            showError(error.msg || '修改失败')
          }
        }
      }
    })
  },
  
  /**
   * 编辑性别
   */
  editGender() {
    wx.showActionSheet({
      itemList: ['男', '女'],
      success: async (res) => {
        const sex = res.tapIndex === 0 ? '1' : '2'
        
        try {
          const request = require('../../utils/request')
          const { showSuccess, showError } = require('../../utils/util')
          
          await request({
            url: '/user/update',
            method: 'PUT',
            data: {
              sex: sex
            }
          })
          
          this.setData({
            'userInfo.sex': sex
          })
          
          showSuccess('修改成功')
        } catch (error) {
          console.error('修改性别失败:', error)
          showError(error.msg || '修改失败')
        }
      }
    })
  },

  /**
   * 订单通知开关
   */
  onOrderNotifyChange(e) {
    const value = e.detail.value
    this.setData({
      'settings.orderNotify': value
    })
    this.saveSettings()
  },

  /**
   * 优惠活动通知开关
   */
  onPromoNotifyChange(e) {
    const value = e.detail.value
    this.setData({
      'settings.promoNotify': value
    })
    this.saveSettings()
  },

  /**
   * 保存设置
   */
  saveSettings() {
    wx.setStorageSync('settings', this.data.settings)
    showSuccess('设置已保存')
  },

  /**
   * 清除缓存
   */
  clearCache() {
    wx.showModal({
      title: '提示',
      content: '确定要清除缓存吗？',
      success: (res) => {
        if (res.confirm) {
          wx.clearStorage({
            success: () => {
              showSuccess('缓存已清除')
              this.setData({ cacheSize: '0 KB' })
              
              // 延迟跳转到登录页
              setTimeout(() => {
                wx.reLaunch({
                  url: '/pages/login/login'
                })
              }, 1500)
            }
          })
        }
      }
    })
  },

  /**
   * 检查更新
   */
  checkUpdate() {
    wx.showToast({
      title: '已是最新版本',
      icon: 'success'
    })
  },

  /**
   * 关于我们
   */
  showAbout() {
    wx.showModal({
      title: '关于我们',
      content: '校园智慧食堂 v1.0.0\n\n为师生提供便捷的订餐服务\n\n© 2025 All Rights Reserved',
      showCancel: false
    })
  }
})

