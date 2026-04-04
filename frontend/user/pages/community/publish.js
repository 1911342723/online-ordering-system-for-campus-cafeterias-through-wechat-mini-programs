// pages/community/publish.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { showLoading, hideLoading, showError, showSuccess, checkLogin, navigateToLogin } = require('../../utils/util')

Page({
  data: {
    images: [],
    title: '',
    content: '',
    tags: [],
    recommendTags: ['美食打卡', '食堂探店', '减脂餐', '深夜放毒', '宿舍美食', '奶茶推荐', '校园生活', '今日份快乐'],
    
    // 关联订单（必选）
    linkedOrder: null,
    showOrderModal: false,
    orderList: [],
    orderPage: 1,
    orderLoading: false,
    orderHasMore: true,
    defaultMerchantImg: DEFAULT_IMAGES.merchant || 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&q=80',
    
    // 评价类型（必选）：positive=好评, negative=吐槽
    ratingType: '',
    
    showTagModal: false,
    newTag: '',
    
    canPublish: false
  },

  onLoad(options) {
    // 检查登录状态
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再发布',
        showCancel: false,
        success: () => {
          navigateToLogin()
        }
      })
    }
  },

  /**
   * 选择图片
   */
  chooseImage() {
    const remaining = 9 - this.data.images.length
    
    wx.chooseMedia({
      count: remaining,
      mediaType: ['image'],
      sourceType: ['album', 'camera'],
      success: (res) => {
        const newImages = res.tempFiles.map(file => file.tempFilePath)
        this.setData({
          images: [...this.data.images, ...newImages]
        })
        this.checkCanPublish()
      }
    })
  },

  /**
   * 删除图片
   */
  deleteImage(e) {
    const index = e.currentTarget.dataset.index
    const images = [...this.data.images]
    images.splice(index, 1)
    this.setData({ images })
    this.checkCanPublish()
  },

  /**
   * 标题输入
   */
  onTitleInput(e) {
    this.setData({ title: e.detail.value })
    this.checkCanPublish()
  },

  /**
   * 内容输入
   */
  onContentInput(e) {
    this.setData({ content: e.detail.value })
    this.checkCanPublish()
  },

  /**
   * 显示标签输入弹窗
   */
  showTagInput() {
    this.setData({ showTagModal: true, newTag: '' })
  },

  /**
   * 隐藏标签输入弹窗
   */
  hideTagInput() {
    this.setData({ showTagModal: false, newTag: '' })
  },

  /**
   * 标签输入
   */
  onTagInput(e) {
    this.setData({ newTag: e.detail.value })
  },

  /**
   * 确认添加标签
   */
  confirmAddTag() {
    const { newTag, tags } = this.data
    
    if (!newTag.trim()) {
      showError('请输入标签名称')
      return
    }
    
    if (tags.includes(newTag.trim())) {
      showError('标签已存在')
      return
    }
    
    if (tags.length >= 5) {
      showError('最多添加5个标签')
      return
    }
    
    this.setData({
      tags: [...tags, newTag.trim()],
      showTagModal: false,
      newTag: ''
    })
  },

  /**
   * 添加推荐标签
   */
  addRecommendTag(e) {
    const tag = e.currentTarget.dataset.tag
    const { tags } = this.data
    
    if (tags.includes(tag)) {
      this.setData({ tags: tags.filter(t => t !== tag) })
    } else {
      if (tags.length >= 5) {
        showError('最多添加5个标签')
        return
      }
      this.setData({ tags: [...tags, tag] })
    }
  },

  /**
   * 删除标签
   */
  deleteTag(e) {
    const index = e.currentTarget.dataset.index
    const tags = [...this.data.tags]
    tags.splice(index, 1)
    this.setData({ tags })
  },

  /**
   * 选择评价类型
   */
  selectRatingType(e) {
    const type = e.currentTarget.dataset.type
    this.setData({ ratingType: type })
    this.checkCanPublish()
  },

  /**
   * 打开订单选择弹窗
   */
  selectOrder() {
    this.setData({ showOrderModal: true })
    if (this.data.orderList.length === 0) {
      this.loadOrders()
    }
  },

  /**
   * 关闭订单选择弹窗
   */
  hideOrderModal() {
    this.setData({ showOrderModal: false })
  },

  /**
   * 加载已完成订单列表
   */
  async loadOrders(isLoadMore = false) {
    if (this.data.orderLoading) return
    if (isLoadMore && !this.data.orderHasMore) return
    
    this.setData({ orderLoading: true })
    
    try {
      const res = await request({
        url: '/order/userPage',
        method: 'GET',
        data: {
          page: isLoadMore ? this.data.orderPage + 1 : 1,
          pageSize: 20,
          status: 5
        }
      })
      
      const orders = (res.records || res || []).map(order => ({
        ...order,
        orderTimeStr: this.formatTime(order.orderTime || order.createTime),
        dishNames: order.orderDetails ? order.orderDetails.map(d => d.name).join('、') : (order.dishNames || ''),
        amount: (order.amount / 100).toFixed(2)
      }))
      
      if (isLoadMore) {
        this.setData({
          orderList: [...this.data.orderList, ...orders],
          orderPage: this.data.orderPage + 1,
          orderHasMore: orders.length >= 20,
          orderLoading: false
        })
      } else {
        this.setData({
          orderList: orders,
          orderPage: 1,
          orderHasMore: orders.length >= 20,
          orderLoading: false
        })
      }
    } catch (error) {
      console.error('加载订单列表失败:', error)
      this.setData({ orderLoading: false })
      this.loadMockOrders()
    }
  },

  /**
   * 加载模拟订单数据
   */
  loadMockOrders() {
    const mockOrders = [
      { id: 1, merchantName: '一食堂红烧肉窗口', merchantImage: '', orderNo: '202411280001', dishNames: '红烧肉饭、紫菜蛋花汤', amount: '18.00', orderTimeStr: '11-28' },
      { id: 2, merchantName: '二食堂奶茶店', merchantImage: '', orderNo: '202411270002', dishNames: '幽兰拿铁、芋泥波波', amount: '28.00', orderTimeStr: '11-27' },
      { id: 3, merchantName: '三食堂麻辣烫', merchantImage: '', orderNo: '202411260003', dishNames: '麻辣烫大份', amount: '22.00', orderTimeStr: '11-26' }
    ]
    
    this.setData({
      orderList: mockOrders,
      orderHasMore: false
    })
  },

  /**
   * 格式化时间
   */
  formatTime(timeStr) {
    if (!timeStr) return ''
    const date = new Date(timeStr)
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${month}-${day}`
  },

  /**
   * 加载更多订单
   */
  loadMoreOrders() {
    this.loadOrders(true)
  },

  /**
   * 选择订单
   */
  onSelectOrder(e) {
    const order = e.currentTarget.dataset.order
    this.setData({
      linkedOrder: order,
      showOrderModal: false
    })
    this.checkCanPublish()
  },

  /**
   * 检查是否可以发布
   */
  checkCanPublish() {
    const { images, title, content, linkedOrder, ratingType } = this.data
    const canPublish = images.length > 0 && 
                       title.trim().length > 0 && 
                       content.trim().length > 0 &&
                       linkedOrder !== null &&
                       ratingType !== ''
    this.setData({ canPublish })
  },

  /**
   * 保存草稿
   */
  saveDraft() {
    const { images, title, content, tags, linkedOrder, ratingType } = this.data
    
    const draft = {
      images, title, content, tags, linkedOrder, ratingType,
      savedAt: Date.now()
    }
    
    wx.setStorageSync('noteDraft', draft)
    showSuccess('草稿已保存')
  },

  /**
   * 发布笔记
   */
  async publish() {
    const { images, title, content, linkedOrder, ratingType } = this.data
    
    if (images.length === 0) {
      showError('请至少添加一张图片')
      return
    }
    
    if (!title.trim()) {
      showError('请输入标题')
      return
    }
    
    if (!content.trim()) {
      showError('请输入内容')
      return
    }
    
    if (!linkedOrder) {
      showError('请选择关联订单')
      return
    }
    
    if (!ratingType) {
      showError('请选择评价类型')
      return
    }
    
    if (!checkLogin()) {
      wx.showModal({
        title: '提示',
        content: '请先登录后再发布',
        success: (res) => {
          if (res.confirm) navigateToLogin()
        }
      })
      return
    }
    
    try {
      showLoading('发布中...')
      
      const { tags } = this.data
      
      // 上传图片
      const uploadedImages = []
      for (const image of images) {
        if (image.startsWith('http')) {
          uploadedImages.push(image)
        } else {
          const uploadRes = await this.uploadImage(image)
          if (uploadRes) uploadedImages.push(uploadRes)
        }
      }
      
      // 创建笔记（关联订单）
      const noteData = {
        title: title.trim(),
        content: content.trim(),
        images: uploadedImages.join(','),
        coverImage: uploadedImages[0] || '',
        tags: tags.join(','),
        orderId: linkedOrder.id,
        merchantId: linkedOrder.merchantId,
        ratingType: ratingType,
        status: 1
      }
      
      await request({
        url: '/note',
        method: 'POST',
        data: noteData
      })
      
      hideLoading()
      wx.removeStorageSync('noteDraft')
      showSuccess('发布成功')
      
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
      
    } catch (error) {
      hideLoading()
      console.error('发布失败:', error)
      showError('发布失败，请重试')
    }
  },

  /**
   * 上传图片
   */
  uploadImage(filePath) {
    return new Promise((resolve) => {
      const token = wx.getStorageSync('token')
      
      wx.uploadFile({
        url: `${getApp().globalData.baseUrl}/common/upload`,
        filePath: filePath,
        name: 'file',
        header: { 'Authorization': token ? `Bearer ${token}` : '' },
        success: (res) => {
          try {
            const data = JSON.parse(res.data)
            if (data.code === 1 && data.data) {
              resolve(data.data)
            } else {
              resolve(filePath)
            }
          } catch (e) {
            resolve(filePath)
          }
        },
        fail: () => resolve(filePath)
      })
    })
  },

  preventMove() { return false },

  onShow() {
    const draft = wx.getStorageSync('noteDraft')
    if (draft && !this.data.title && !this.data.content) {
      wx.showModal({
        title: '提示',
        content: '检测到未发布的草稿，是否恢复？',
        success: (res) => {
          if (res.confirm) {
            this.setData({
              images: draft.images || [],
              title: draft.title || '',
              content: draft.content || '',
              tags: draft.tags || [],
              linkedOrder: draft.linkedOrder,
              ratingType: draft.ratingType || ''
            })
            this.checkCanPublish()
          } else {
            wx.removeStorageSync('noteDraft')
          }
        }
      })
    }
  }
})
