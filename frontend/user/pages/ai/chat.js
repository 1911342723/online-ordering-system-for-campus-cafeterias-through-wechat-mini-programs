// pages/ai/chat.js
const request = require('../../utils/request')
const { showError, checkLogin, navigateToLogin, getImageUrl } = require('../../utils/util')
const { DEFAULT_IMAGES } = require('../../utils/config')

// AI Avatar - Gradient Diamond Star (透明背景的渐变菱形星星)
const GEMINI_STAR_URL = 'data:image/svg+xml;charset=utf-8,%3Csvg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 80 80"%3E%3Cdefs%3E%3ClinearGradient id="grad1" x1="0%25" y1="0%25" x2="100%25" y2="100%25"%3E%3Cstop offset="0%25" style="stop-color:%234285F4;stop-opacity:1" /%3E%3Cstop offset="50%25" style="stop-color:%2334A853;stop-opacity:1" /%3E%3Cstop offset="100%25" style="stop-color:%23FBBC04;stop-opacity:1" /%3E%3C/linearGradient%3E%3ClinearGradient id="grad2" x1="100%25" y1="0%25" x2="0%25" y2="100%25"%3E%3Cstop offset="0%25" style="stop-color:%23EA4335;stop-opacity:1" /%3E%3Cstop offset="100%25" style="stop-color:%234285F4;stop-opacity:1" /%3E%3C/linearGradient%3E%3C/defs%3E%3Cg transform="translate(40,40)"%3E%3Cpath d="M 0,-32 L 8,-8 L 32,0 L 8,8 L 0,32 L -8,8 L -32,0 L -8,-8 Z" fill="url(%23grad1)" opacity="0.9"/%3E%3Cpath d="M 0,-24 L 6,-6 L 24,0 L 6,6 L 0,24 L -6,6 L -24,0 L -6,-6 Z" fill="url(%23grad2)" opacity="0.7"/%3E%3C/g%3E%3C/svg%3E'

Page({
  data: {
    messages: [],
    inputValue: '',
    toView: 'scroll-bottom',
    isAIThinking: false,
    geminiStarUrl: GEMINI_STAR_URL
  },

  async onLoad() {
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后使用AI推荐功能',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          } else {
            wx.navigateBack()
          }
        }
      })
      return
    }
    
    // 加载历史聊天记录
    await this.loadChatHistory()
    
    // 如果没有历史记录，显示初始问候语
    if (this.data.messages.length === 0) {
      this.simulateStream('你好！我是智慧食堂AI助手，我可以根据您的口味偏好推荐美食！')
    }
  },
  
  /**
   * 加载聊天历史
   */
  async loadChatHistory() {
    try {
      const history = await request({
        url: '/ai/history',
        method: 'GET'
      })
      
      if (!history || history.length === 0) {
        console.log('没有历史聊天记录')
        return
      }
      
      console.log('加载了', history.length, '条历史记录')
      
      // 转换历史记录格式
      const messages = history.map(item => {
        let dishes = []
        
        // 解析菜品JSON
        if (item.dishes) {
          try {
            dishes = JSON.parse(item.dishes)
            // 处理菜品图片和价格
            dishes = dishes.map(dish => ({
              ...dish,
              image: getImageUrl(dish.image, DEFAULT_IMAGES.dish),
              price: typeof dish.price === 'number' ? dish.price.toFixed(2) : dish.price
            }))
          } catch (e) {
            console.error('解析菜品JSON失败:', e)
          }
        }
        
        return {
          id: item.id,
          role: item.role,
          content: item.content,
          dishes: dishes
        }
      })
      
      this.setData({ 
        messages,
        toView: 'scroll-bottom'
      })
      
    } catch (error) {
      console.error('加载聊天历史失败:', error)
      // 失败不影响继续聊天
    }
  },

  onInput(e) {
    this.setData({ inputValue: e.detail.value })
  },

  async sendMessage() {
    const content = this.data.inputValue
    if (!content.trim()) {
      showError('请输入消息')
      return
    }

    // 添加用户消息
    this.addMessage('user', content)
    
    this.setData({
      inputValue: '',
      isAIThinking: true
    })

    try {
      const res = await request({
        url: '/ai/chat',
        method: 'POST',
        data: { message: content }
      })
      
      this.setData({ isAIThinking: false })
      
      let aiContent = ''
      let dishes = []

      if (typeof res === 'string') {
        aiContent = res
      } else if (typeof res === 'object') {
        aiContent = res.answer || '抱歉，我暂时无法理解您的需求'
        dishes = res.dishes || []
        
        // 处理菜品图片并格式化价格
        dishes = dishes.map(dish => ({
          ...dish,
          image: getImageUrl(dish.image, DEFAULT_IMAGES.dish),
          price: typeof dish.price === 'number' ? dish.price.toFixed(2) : dish.price
        }))
      }

      // 过滤推荐菜品：只展示AI回复中提到的菜品
      if (dishes.length > 0 && aiContent) {
        // 使用菜名进行匹配
        dishes = dishes.filter(dish => aiContent.includes(dish.name))
      }
      
      // 模拟流式输出
      this.simulateStream(aiContent, dishes)
      
    } catch (error) {
      console.error('AI回复失败:', error)
      this.setData({ isAIThinking: false })
      
      // 使用本地推荐作为降级
      const mockResponse = this.getLocalRecommendation(content)
      this.simulateStream(mockResponse)
    }
  },

  /**
   * 模拟流式输出
   */
  simulateStream(content, dishes = []) {
    const messages = this.data.messages
    const msgId = Date.now()
    const index = messages.length
    
    // 先添加一个空消息
    messages.push({
      id: msgId,
      role: 'ai',
      content: '',
      dishes: []
    })
    
    this.setData({ messages, toView: 'scroll-bottom' })
    
    let i = 0
    const len = content.length
    const speed = 30 // 打字速度 ms
    
    const interval = setInterval(() => {
      if (i >= len) {
        clearInterval(interval)
        
        // 文本输出完毕后，显示推荐菜品
        if (dishes.length > 0) {
          const key = `messages[${index}].dishes`
          this.setData({ 
            [key]: dishes
          })
          
          // 延迟滚动确保菜品渲染完成
          setTimeout(() => {
            this.setData({ toView: 'scroll-bottom' })
          }, 100)
        }
        return
      }
      
      // 逐字更新
      const char = content[i]
      const key = `messages[${index}].content`
      const currentContent = this.data.messages[index].content
      
      this.setData({ 
        [key]: currentContent + char
      })
      
      // 每隔几个字滚动一次
      if (i % 5 === 0 || i === len - 1) {
         this.setData({ toView: 'scroll-bottom' })
      }
      
      i++
    }, speed)
  },

  /**
   * 本地推荐（降级方案）
   */
  getLocalRecommendation(userInput) {
    const input = userInput.toLowerCase()
    
    if (input.includes('辣') || input.includes('川菜')) {
      return '🌶️ 推荐：宫保鸡丁、麻婆豆腐、水煮鱼片'
    }
    if (input.includes('清淡') || input.includes('素')) {
      return '🥗 推荐：清炒时蔬、番茄蛋汤、蒸蛋'
    }
    if (input.includes('营养') || input.includes('套餐')) {
      return '🍱 推荐营养套餐：红烧肉+时蔬+米饭+汤'
    }
    
    return '请告诉我您的口味偏好，我会为您推荐合适的菜品~ 😊'
  },

  /**
   * 添加消息
   */
  addMessage(role, content, dishes = []) {
    const messages = this.data.messages
    messages.push({
      id: Date.now(),
      role,
      content,
      dishes
    })
    this.setData({ messages })
    
    setTimeout(() => {
      this.setData({ toView: 'scroll-bottom' })
    }, 100)
  },

  /**
   * 快捷问题
   */
  quickQuestion(e) {
    const { question } = e.currentTarget.dataset
    this.setData({ inputValue: question })
    this.sendMessage()
  },
  
  /**
   * 添加到购物车
   */
  async addToCart(e) {
    const dish = e.currentTarget.dataset.dish
    
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录',
        success: (res) => {
          if (res.confirm) {
            navigateToLogin()
          }
        }
      })
      return
    }
    
    try {
      // 处理图片URL - 只保存文件名，不包含完整URL
      let imageName = dish.image
      if (imageName && imageName.includes('name=')) {
        // 从URL中提取文件名: http://localhost:8080/common/download?name=xxx.jpg
        imageName = imageName.split('name=')[1]
      }
      
      // 构建购物车数据
      const cartData = {
        dishId: dish.id,
        name: dish.name,
        image: imageName,
        amount: dish.price  // 后端接收的是BigDecimal，会自动转换
      }
      
      console.log('加入购物车:', cartData)
      
      const res = await request({
        url: '/shoppingCart/add',
        method: 'POST',
        data: cartData
      })
      
      if (res) {
        wx.showToast({
          title: '已加入购物车 ✓',
          icon: 'success',
          duration: 1500
        })
      }
      
    } catch (error) {
      console.error('加入购物车失败:', error)
      showError(error.msg || '加入购物车失败')
    }
  },
  
  /**
   * 跳转到菜品所在餐厅菜单页
   */
  goToDish(e) {
    const dish = e.currentTarget.dataset.dish
    console.log('跳转到菜品:', dish)
    
    // 跳转到菜单页面，传递餐厅ID和菜品分类ID
    const canteenId = dish.canteenId || 1
    const categoryId = dish.categoryId || ''
    
    // 如果有分类ID，传递过去方便自动切换到对应分类
    let url = `/pages/menu/menu?canteenId=${canteenId}`
    if (categoryId) {
      url += `&categoryId=${categoryId}`
    }
    
    wx.navigateTo({
      url: url
    })
  }
})
