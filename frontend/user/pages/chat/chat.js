const request = require('../../utils/request')

Page({
  data: {
    merchantId: null,
    merchantName: '',
    currentUserId: null,
    messages: [],
    inputMessage: '',
    scrollToView: '',
    sending: false,
    isIpx: false,
    isFirstLoad: true
  },

  async onLoad(options) {
    const systemInfo = wx.getSystemInfoSync()
    this.setData({
      isIpx: systemInfo.safeArea && systemInfo.safeArea.bottom < systemInfo.screenHeight
    })

    if (options.merchantId) {
      this.setData({
        merchantId: String(options.merchantId),
        merchantName: decodeURIComponent(options.merchantName || '联系商家')
      })

      wx.setNavigationBarTitle({
        title: this.data.merchantName
      })

      await this.ensureCurrentUserId()

      await this.loadMessages()
      this.setData({ isFirstLoad: false })
      
      if (this.data.messages.length === 0 && options.orderNumber) {
        const content = `您好，我想咨询订单 ${decodeURIComponent(options.orderNumber)} 的相关问题。`
        this.sendQuickMessage(content)
      }
      
      this.startPolling()
    }
  },

  onShow() {
    if (!this.data.isFirstLoad) {
      this.loadMessages(true)
      this.startPolling()
    }
  },

  onHide() {
    this.stopPolling()
  },

  onUnload() {
    this.stopPolling()
  },

  startPolling() {
    this.stopPolling()
    this.refreshInterval = setInterval(() => {
      this.loadMessages(true)
    }, 3000)
  },

  stopPolling() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
      this.refreshInterval = null
    }
  },

  safeDate(time) {
    if (!time) return new Date()
    if (Array.isArray(time)) {
      const [y, m, d, h = 0, mm = 0, s = 0] = time
      return new Date(y, (m || 1) - 1, d || 1, h, mm, s)
    }
    if (typeof time === 'string' && time.includes(' ') && !time.includes('T')) {
      return new Date(time.replace(' ', 'T'))
    }
    return new Date(time)
  },

  processMessagesTime(messages) {
    let lastTime = 0
    return messages.map((msg) => {
      const msgTime = this.safeDate(msg.createTime).getTime()
      let showTime = false
      if (msgTime - lastTime > 5 * 60 * 1000) {
        showTime = true
        lastTime = msgTime
      }
      return {
        ...msg,
        showTime,
        displayTime: this.formatTime(msg.createTime)
      }
    })
  },

  async loadMessages(silent = false) {
    try {
      const userId = await this.ensureCurrentUserId()
      if (!userId) return

      const res = await request({
        url: '/message/im/thread',
        method: 'GET',
        data: {
          merchantId: this.data.merchantId
        },
        silent: true
      })

      const rawMessages = Array.isArray(res) ? res : []
      console.log("[im] loaded messages size:", rawMessages.length);
      
      let latestList = rawMessages.map((msg, index) => {
        return {
          ...msg,
          id: String(msg.id || `msg_${Date.now()}_${index}`),
          fromMerchant: msg.fromMerchant === true || msg.fromMerchant === 'true',
          sending: false
        }
      })

      const sendingMessages = this.data.messages.filter(m => m.sending);
      // latestList = [...latestList, ...sendingMessages]; // You can append sending ones if you need them persisted through reloads

      const processedMessages = this.processMessagesTime(latestList)
      
      const needScroll = this.data.messages.length !== processedMessages.length || (processedMessages.length > 0 && this.data.messages.length > 0 && processedMessages[processedMessages.length - 1].id !== this.data.messages[this.data.messages.length - 1].id);

      this.setData({
        messages: processedMessages
      }, () => {
        if (needScroll) {
          this.scrollToBottom()
        }
      })

      this.markChatRead()
    } catch (error) {
      if (!silent) {
        console.error('加载消息失败:', error)
      }
    }
  },

  async markChatRead() {
    try {
      const userId = await this.ensureCurrentUserId()
      if (!userId) return

      await request({
        url: '/message/im/read',
        method: 'PUT',
        data: {
          merchantId: this.data.merchantId,
          userId
        },
        silent: true
      })
    } catch (e) {}
  },

  onInputChange(e) {
    this.setData({
      inputMessage: e.detail.value
    })
  },

  async sendMessage() {
    const content = this.data.inputMessage.trim()
    if (!content || this.data.sending) return
    
    this.setData({ inputMessage: '' }) // 先清空，给用户秒发的干脆感
    await this.sendQuickMessage(content)
  },

  async sendQuickMessage(content) {
    const userId = await this.ensureCurrentUserId()
    
    // 乐观更新（Optimistic Update）
    const optMsg = {
      id: `local_${Date.now()}`,
      content: content,
      createTime: new Date().toISOString(),
      fromMerchant: false,
      sending: true
    }
    
    const newMessages = [...this.data.messages, optMsg]
    this.setData({
      messages: this.processMessagesTime(newMessages)
    }, () => {
      this.scrollToBottom()
    })

    try {
      const res = await request({
        url: '/message/im/send',
        method: 'POST',
        data: {
          merchantId: this.data.merchantId,
          userId,
          content,
          fromMerchant: false
        },
        silent: true
      })
      console.log("[im] send success!", res);
      // 发送成功，立即拉取实际消息
      setTimeout(() => {
        this.loadMessages(true)
      }, 300)
    } catch (error) {
      console.error('发送消息失败:', error)
      const errorMsg = (error && error.msg) ? error.msg : '发消息失败'
      wx.showToast({ 
        title: errorMsg, 
        icon: 'none',
        duration: 3000
      })
      // 发送失败则将假消息撤回
      this.setData({
        messages: this.data.messages.filter(m => m.id !== optMsg.id)
      })
    }
  },

  scrollToBottom() {
    const len = this.data.messages.length
    if (len > 0) {
      this.setData({
        scrollToView: `msg-${len - 1}`
      })
    }
  },

  async ensureCurrentUserId() {
    if (this.data.currentUserId) return this.data.currentUserId

    const localUser = wx.getStorageSync('userInfo') || {}
    const localId = localUser.id || localUser.userId
    if (localId) {
      this.setData({ currentUserId: localId })
      return localId
    }
    
    try {
      const user = await request({ url: '/user/info', method: 'GET', silent: true })
      const userId = (user && (user.id || user.userId)) || null
      if (userId) {
        wx.setStorageSync('userInfo', user)
        this.setData({ currentUserId: userId })
        return userId
      }
    } catch (e) {}

    return null
  },

  formatTime(timeStr) {
    if (!timeStr) return ''
    const date = this.safeDate(timeStr)
    const now = new Date()
    const diff = now - date

    // 今天
    if (date.toDateString() === now.toDateString()) {
      return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
    }
    
    // 今年
    if (date.getFullYear() === now.getFullYear()) {
      return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
    }

    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`
  }
})
