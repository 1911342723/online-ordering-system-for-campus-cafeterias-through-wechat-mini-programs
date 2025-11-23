import { ElNotification } from 'element-plus'

class OrderWebSocket {
  constructor() {
    this.ws = null
    this.merchantId = null
    this.reconnectTimer = null
    this.heartbeatTimer = null
    this.isManualClose = false
    this.callbacks = {
      onNewOrder: null,
      onConnected: null,
      onDisconnected: null
    }
  }

  connect(merchantId) {
    if (!merchantId) {
      console.error('商家ID不能为空')
      return
    }

    this.merchantId = merchantId
    this.isManualClose = false

    // 获取WebSocket URL
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    const host = import.meta.env.VITE_API_BASE_URL 
      ? import.meta.env.VITE_API_BASE_URL.replace(/^https?:\/\//, '')
      : window.location.host
    const wsUrl = `${protocol}//${host}/ws/order?merchantId=${merchantId}`

    try {
      this.ws = new WebSocket(wsUrl)
      this.setupEventHandlers()
    } catch (error) {
      console.error('WebSocket连接失败:', error)
      this.scheduleReconnect()
    }
  }

  setupEventHandlers() {
    this.ws.onopen = () => {
      console.log('WebSocket连接成功')
      this.startHeartbeat()
      
      if (this.callbacks.onConnected) {
        this.callbacks.onConnected()
      }
    }

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        this.handleMessage(data)
      } catch (error) {
        console.error('解析WebSocket消息失败:', error)
      }
    }

    this.ws.onerror = (error) => {
      console.error('WebSocket错误:', error)
    }

    this.ws.onclose = () => {
      console.log('WebSocket连接关闭')
      this.stopHeartbeat()
      
      if (this.callbacks.onDisconnected) {
        this.callbacks.onDisconnected()
      }

      // 非手动关闭时自动重连
      if (!this.isManualClose) {
        this.scheduleReconnect()
      }
    }
  }

  handleMessage(data) {
    switch (data.type) {
      case 'connected':
        console.log('WebSocket连接确认:', data.message)
        break
      
      case 'new_order':
        console.log('收到新订单通知:', data.data)
        this.showOrderNotification(data.data)
        
        if (this.callbacks.onNewOrder) {
          this.callbacks.onNewOrder(data.data)
        }
        break
      
      default:
        console.log('未知消息类型:', data)
    }
  }

  showOrderNotification(orderData) {
    const amount = (orderData.amount / 100).toFixed(2)
    const orderType = orderData.orderType === 2 ? '[预订单]' : ''
    
    ElNotification({
      title: '新订单通知',
      message: `${orderType}订单号: ${orderData.orderNumber}\n金额: ¥${amount}\n客户: ${orderData.userName}`,
      type: 'success',
      duration: 10000,
      position: 'top-right',
      onClick: () => {
        // 可以跳转到订单详情页
        window.location.href = '/#/order'
      }
    })

    // 播放提示音
    this.playNotificationSound()
  }

  playNotificationSound() {
    try {
      const audio = new Audio('/notification.mp3')
      audio.play().catch(err => {
        console.log('播放提示音失败:', err)
      })
    } catch (error) {
      console.log('提示音加载失败:', error)
    }
  }

  startHeartbeat() {
    this.heartbeatTimer = setInterval(() => {
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.ws.send('ping')
      }
    }, 30000) // 每30秒发送一次心跳
  }

  stopHeartbeat() {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer)
      this.heartbeatTimer = null
    }
  }

  scheduleReconnect() {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer)
    }

    this.reconnectTimer = setTimeout(() => {
      console.log('尝试重新连接WebSocket...')
      this.connect(this.merchantId)
    }, 5000) // 5秒后重连
  }

  disconnect() {
    this.isManualClose = true
    this.stopHeartbeat()
    
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = null
    }

    if (this.ws) {
      this.ws.close()
      this.ws = null
    }
  }

  on(event, callback) {
    if (this.callbacks.hasOwnProperty(`on${event.charAt(0).toUpperCase()}${event.slice(1)}`)) {
      this.callbacks[`on${event.charAt(0).toUpperCase()}${event.slice(1)}`] = callback
    }
  }
}

// 导出单例
export default new OrderWebSocket()

