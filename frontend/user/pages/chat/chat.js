// pages/chat/chat.js
const app = getApp()
const { request } = require('../../utils/request')

Page({
  data: {
    merchantId: null,
    merchantName: '',
    messages: [],
    inputMessage: '',
    scrollToView: '',
    sending: false
  },

  onLoad(options) {
    if (options.merchantId) {
      this.setData({
        merchantId: options.merchantId,
        merchantName: options.merchantName || '商家'
      })
      this.loadMessages()
      
      // 定时刷新消息
      this.refreshInterval = setInterval(() => {
        this.loadMessages(true)
      }, 3000)
    }
  },

  onUnload() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }
  },

  // 加载消息列表
  async loadMessages(silent = false) {
    try {
      const res = await request({
        url: '/message/list',
        method: 'GET',
        data: {
          merchantId: this.data.merchantId,
          userId: app.globalData.userInfo?.id
        }
      })
      
      if (res.code === 1) {
        this.setData({
          messages: res.data || [],
          scrollToView: `msg-${(res.data || []).length - 1}`
        })
      }
    } catch (error) {
      if (!silent) {
        console.error('加载消息失败:', error)
      }
    }
  },

  // 输入框变化
  onInputChange(e) {
    this.setData({
      inputMessage: e.detail.value
    })
  },

  // 发送消息
  async sendMessage() {
    const message = this.data.inputMessage.trim()
    
    if (!message) {
      wx.showToast({
        title: '请输入消息内容',
        icon: 'none'
      })
      return
    }
    
    this.setData({ sending: true })
    
    try {
      const res = await request({
        url: '/message/send',
        method: 'POST',
        data: {
          merchantId: this.data.merchantId,
          userId: app.globalData.userInfo?.id,
          content: message,
          fromMerchant: false,
          userName: app.globalData.userInfo?.name || '用户'
        }
      })
      
      if (res.code === 1) {
        this.setData({
          inputMessage: ''
        })
        await this.loadMessages()
      }
    } catch (error) {
      console.error('发送消息失败:', error)
      wx.showToast({
        title: '发送失败',
        icon: 'none'
      })
    } finally {
      this.setData({ sending: false })
    }
  },

  // 格式化时间
  formatTime(time) {
    if (!time) return ''
    const date = new Date(time)
    const now = new Date()
    const diff = now - date
    
    if (diff < 60000) return '刚刚'
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
    
    return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
  }
})

