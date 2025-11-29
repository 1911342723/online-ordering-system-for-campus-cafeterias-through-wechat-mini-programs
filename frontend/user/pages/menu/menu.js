// pages/menu/menu.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { formatPrice, getImageUrl, showLoading, hideLoading, showError, showSuccess } = require('../../utils/util')

Page({
  data: {
    merchantId: '',
    merchantName: '',
    merchantInfo: null, // 商家详细信息
    announcements: [], // 商家公告
    merchantCoupons: [], // 商家优惠券
    categories: [],
    activeCategory: 0,
    toView: '',
    cart: {}, // { dishId: { dish, count } }
    cartCount: 0,
    cartTotal: 0,
    defaultDishImg: DEFAULT_IMAGES.dish,
    showQrcodeModal: false,
    defaultQrcode: 'https://via.placeholder.com/300x300?text=QR+Code',
    icons: {
      cart: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSIjRkZGRkZGIiBzdHJva2U9Im5vbmUiPjxjaXJjbGUgY3g9IjkiIGN5PSIyMSIgcj0iMSIvPjxjaXJjbGUgY3g9IjIwIiBjeT0iMjEiIHI9IjEiLz48cGF0aCBkPSJNMSAxaDRsMi42OCAxMy4zOWEyIDIgMCAwIDAgMiAxLjYxaDkuNzJhMiAyIDAgMCAwIDItMS42MUwyMyA2SDYiLz48L3N2Zz4=',
      cartEmpty: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM5OTk5OTkiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48Y2lyY2xlIGN4PSI5IiBjeT0iMjEiIHI9IjEiLz48Y2lyY2xlIGN4PSIyMCIgY3k9IjIxIiByPSIxIi8+PHBhdGggZD0iTTEgMWg0bDIuNjggMTMuMzlhMiAyIDAgMCAwIDIgMS42MWg5LjcyYTIgMiAwIDAgMCAyLTEuNjFMMjMgNkg2Ii8+PC9zdmc+'
    }
  },

  onLoad(options) {
    console.log('菜单页参数:', options)
    
    if (options.merchantId) {
      const merchantId = options.merchantId
      const categoryId = options.categoryId || null
      const dishId = options.dishId || null
      
      this.setData({ 
        merchantId: merchantId,
        merchantName: decodeURIComponent(options.merchantName || '商家'),
        targetDishId: dishId // 保存目标菜品ID，用于自动定位
      })
      
      this.loadMerchantInfo() // 加载商家信息
      this.loadMerchantAnnouncements() // 加载商家公告
      this.loadMerchantCoupons() // 加载商家优惠券
      this.loadMenuData(categoryId)
    } else if (options.dishId) {
      // 如果只有dishId，先获取菜品信息，再获取商家ID
      this.loadDishAndMerchant(options.dishId)
    } else {
      showError('参数错误')
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
    }
  },

  /**
   * 根据菜品ID加载菜品和商家信息
   */
  async loadDishAndMerchant(dishId) {
    try {
      showLoading('加载中...')
      
      // 获取菜品详情
      const dishDetail = await request({
        url: `/dish/${dishId}`,
        method: 'GET'
      })
      
      if (dishDetail && dishDetail.merchantId) {
        this.setData({
          merchantId: dishDetail.merchantId,
          targetDishId: dishId
        })
        
        this.loadMerchantInfo()
        this.loadMerchantAnnouncements()
        this.loadMerchantCoupons()
        this.loadMenuData(dishDetail.categoryId)
      } else {
        hideLoading()
        showError('无法找到菜品所属商家')
        setTimeout(() => {
          wx.navigateBack()
        }, 1500)
      }
    } catch (error) {
      hideLoading()
      console.error('加载菜品信息失败:', error)
      showError('加载失败')
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
    }
  },

  /**
   * 加载商家信息
   */
  async loadMerchantInfo() {
    try {
      const merchantInfo = await request({
        url: `/merchant/${this.data.merchantId}`,
        method: 'GET'
      })
      
      console.log('商家信息:', merchantInfo)
      
      this.setData({
        merchantInfo: {
          ...merchantInfo,
          image: getImageUrl(merchantInfo.image, DEFAULT_IMAGES.merchant)
        },
        merchantName: merchantInfo.name || this.data.merchantName
      })
    } catch (error) {
      console.error('加载商家信息失败:', error)
    }
  },

  /**
   * 加载商家公告
   */
  async loadMerchantAnnouncements() {
    try {
      const announcements = await request({
        url: '/merchantAnnouncement/active',
        method: 'GET',
        data: { merchantId: this.data.merchantId }
      })
      
      console.log('商家公告:', announcements)
      
      const typeMap = {
        1: '通知',
        2: '优惠',
        3: '活动'
      }
      
      const processedAnnouncements = announcements.map(item => ({
        ...item,
        typeText: typeMap[item.type] || '公告'
      }))
      
      this.setData({ announcements: processedAnnouncements })
    } catch (error) {
      console.error('加载商家公告失败:', error)
      this.setData({ announcements: [] })
    }
  },

  /**
   * 加载商家优惠券
   */
  async loadMerchantCoupons() {
    try {
      const coupons = await request({
        url: '/coupon/available',
        method: 'GET',
        data: {
          type: 2, // 商家券
          merchantId: this.data.merchantId
        }
      })
      
      console.log('商家优惠券:', coupons)
      
      if (coupons && coupons.length > 0) {
        const formattedCoupons = coupons.map(coupon => ({
          ...coupon,
          amount: Math.floor(parseFloat(coupon.amount) / 100),
          minAmount: Math.floor(parseFloat(coupon.minAmount) / 100),
          received: coupon.received || false
        }))
        
        this.setData({ merchantCoupons: formattedCoupons })
      }
    } catch (error) {
      console.error('加载商家优惠券失败:', error)
      this.setData({ merchantCoupons: [] })
    }
  },

  /**
   * 显示商家详情
   */
  showShopDetail() {
    const info = this.data.merchantInfo
    if (!info) return
    
    wx.showModal({
      title: this.data.merchantName,
      content: `营业时间：${info.openingHours || '全天'}\n地址：${info.address || '暂无'}\n电话：${info.phone || '暂无'}\n\n${info.description || ''}`,
      showCancel: false
    })
  },

  /**
   * 显示公告详情
   */
  showAnnouncementDetail(e) {
    const announcement = e.currentTarget.dataset.announcement
    wx.showModal({
      title: announcement.title,
      content: announcement.content,
      showCancel: false,
      confirmText: '知道了'
    })
  },

  /**
   * 加载菜单数据 - 对接后端API
   */
  async loadMenuData(highlightCategoryId = null) {
    showLoading('加载中...')
    try {
      // 1. 获取分类列表
      const categories = await this.loadCategories()
      
      // 2. 为每个分类加载菜品
      const categoriesWithDishes = await Promise.all(
        categories.map(async (category) => {
          const dishes = await this.loadDishes(category.id)
          return {
            ...category,
            dishes: dishes.map(dish => ({
              ...dish,
              price: formatPrice(dish.price), // 后端返回的是分，formatPrice会处理
              image: getImageUrl(dish.image, DEFAULT_IMAGES.dish),
              cartCount: 0
            }))
          }
        })
      )
      
      // 如果指定了分类ID，自动切换到该分类
      let activeIndex = 0
      if (highlightCategoryId) {
        const index = categoriesWithDishes.findIndex(c => c.id == highlightCategoryId)
        if (index !== -1) {
          activeIndex = index
          console.log('自动切换到分类:', categoriesWithDishes[index].name)
        }
      }
      
      // 如果指定了目标菜品ID，自动定位到该菜品所在分类
      const targetDishId = this.data.targetDishId
      let targetViewId = `cat-${activeIndex}`
      
      if (targetDishId && !highlightCategoryId) {
        // 查找目标菜品所在的分类
        for (let i = 0; i < categoriesWithDishes.length; i++) {
          const category = categoriesWithDishes[i]
          const dishIndex = category.dishes.findIndex(d => d.id == targetDishId)
          if (dishIndex !== -1) {
            activeIndex = i
            console.log('找到目标菜品，所在分类:', category.name, '菜品索引:', dishIndex)
            
            // 高亮该菜品（添加一个标记，用于样式显示）
            category.dishes[dishIndex].isHighlighted = true
            
            // 设置滚动到该菜品
            targetViewId = `dish-${i}-${dishIndex}`
            console.log('准备滚动到:', targetViewId)
            
            // 2秒后取消高亮效果
            setTimeout(() => {
              const categories = this.data.categories
              if (categories[i] && categories[i].dishes[dishIndex]) {
                categories[i].dishes[dishIndex].isHighlighted = false
                this.setData({ categories })
              }
            }, 2000)
            break
          }
        }
      }
      
      this.setData({ 
        categories: categoriesWithDishes,
        activeCategory: activeIndex,
        toView: targetViewId
      })
      
      // 如果需要滚动到菜品，再次设置toView确保滚动生效
      if (targetDishId && targetViewId.startsWith('dish-')) {
        setTimeout(() => {
          this.setData({ toView: targetViewId })
          console.log('延迟滚动到:', targetViewId)
        }, 300)
      }
      hideLoading()
    } catch (error) {
      hideLoading()
      console.error('加载菜单失败:', error)
      // 使用模拟数据作为降级方案
      this.loadMockData()
    }
  },

  /**
   * 加载分类列表
   */
  async loadCategories() {
    try {
      const result = await request({
        url: '/category/list',
        method: 'GET',
        data: { type: 1 } // 1-菜品分类
      })
      return result || []
    } catch (error) {
      console.error('加载分类失败:', error)
      return []
    }
  },

  /**
   * 加载菜品列表 - 根据商家ID和分类ID查询
   */
  async loadDishes(categoryId) {
    try {
      const result = await request({
        url: '/dish/list',
        method: 'GET',
        data: {
          merchantId: this.data.merchantId, // 根据商家ID查询菜品
          categoryId: categoryId,
          status: 1 // 1-在售
        }
      })
      console.log('加载菜品:', result)
      return result || []
    } catch (error) {
      console.error('加载菜品失败:', error)
      return []
    }
  },

  /**
   * 加载模拟数据（降级方案）
   */
  loadMockData() {
    const mockCategories = [
      {
        id: 1,
        name: '热销',
        dishes: [
          { id: 101, name: '招牌红烧肉', price: '25.00', description: '肥而不腻，色泽红亮', image: DEFAULT_IMAGES.dish, sales: 100, cartCount: 0 },
          { id: 102, name: '清炒时蔬', price: '12.00', description: '新鲜当季蔬菜', image: DEFAULT_IMAGES.dish, sales: 80, cartCount: 0 },
          { id: 103, name: '宫保鸡丁', price: '28.00', description: '经典川菜', image: DEFAULT_IMAGES.dish, sales: 95, cartCount: 0 }
        ]
      },
      {
        id: 2,
        name: '主食',
        dishes: [
          { id: 201, name: '米饭', price: '2.00', description: '五常大米', image: DEFAULT_IMAGES.dish, sales: 500, cartCount: 0 },
          { id: 202, name: '馒头', price: '1.00', description: '手工大馒头', image: DEFAULT_IMAGES.dish, sales: 200, cartCount: 0 },
          { id: 203, name: '炒饭', price: '15.00', description: '扬州炒饭', image: DEFAULT_IMAGES.dish, sales: 150, cartCount: 0 }
        ]
      },
      {
        id: 3,
        name: '汤类',
        dishes: [
          { id: 301, name: '紫菜蛋花汤', price: '6.00', description: '清淡可口', image: DEFAULT_IMAGES.dish, sales: 120, cartCount: 0 },
          { id: 302, name: '玉米排骨汤', price: '18.00', description: '营养丰富', image: DEFAULT_IMAGES.dish, sales: 88, cartCount: 0 }
        ]
      }
    ]
    this.setData({ categories: mockCategories })
    showError('网络异常，使用模拟数据')
  },


  /**
   * 切换分类
   */
  switchCategory(e) {
    const index = e.currentTarget.dataset.index
    this.setData({
      activeCategory: index,
      toView: `cat-${index}`
    })
  },

  /**
   * 更新购物车
   */
  async updateCart(e) {
    const { dish, action } = e.currentTarget.dataset
    const categories = this.data.categories
    const cart = this.data.cart
    let cartTotal = this.data.cartTotal
    let cartCount = this.data.cartCount

    try {
      // 找到并更新菜品
      for (let cat of categories) {
        for (let d of cat.dishes) {
          if (d.id === dish.id) {
            if (action === 'add') {
              // 调用后端API加入购物车
              await request({
                url: '/shoppingCart/add',
                method: 'POST',
                data: {
                  dishId: d.id,
                  name: d.name,
                  image: d.image,
                  amount: parseFloat(d.price) * 100 // 转换为分
                }
              })
              
              d.cartCount = (d.cartCount || 0) + 1
              cartTotal = (parseFloat(cartTotal) + parseFloat(d.price)).toFixed(2)
              cartCount++
              
              // 更新购物车对象
              if (cart[d.id]) {
                cart[d.id].count++
              } else {
                cart[d.id] = {
                  dish: d,
                  count: 1
                }
              }
            } else {
              if (d.cartCount > 0) {
                // 调用后端API减少购物车
                await request({
                  url: '/shoppingCart/sub',
                  method: 'POST',
                  data: {
                    dishId: d.id
                  }
                })
                
                d.cartCount--
                cartTotal = (parseFloat(cartTotal) - parseFloat(d.price)).toFixed(2)
                cartCount--
                
                // 更新购物车对象
                if (cart[d.id]) {
                  cart[d.id].count--
                  if (cart[d.id].count <= 0) {
                    delete cart[d.id]
                  }
                }
              }
            }
            break
          }
        }
      }

      this.setData({
        categories,
        cart,
        cartTotal,
        cartCount
      })
      
    } catch (error) {
      console.error('更新购物车失败:', error)
      showError('操作失败')
    }
  },

  /**
   * 显示购物车详情
   */
  showCartDetail() {
    if (this.data.cartCount === 0) return
    
    const cart = this.data.cart
    const cartItems = Object.values(cart).map(item => ({
      name: item.dish.name,
      price: item.dish.price,
      count: item.count
    }))
    
    console.log('购物车详情:', cartItems)
    // 这里可以弹出一个购物车详情弹窗
    showSuccess('购物车功能开发中...')
  },

  /**
   * 去结算
   */
  async goToPay() {
    if (this.data.cartCount === 0) {
      showError('请先选择菜品')
      return
    }
    
    // 构建订单数据
    const cart = this.data.cart
    const orderItems = Object.values(cart).map(item => ({
      dishId: item.dish.id,
      name: item.dish.name,
      price: item.dish.price,
      number: item.count,
      image: item.dish.image
    }))
    
    // 保存订单数据到本地
    wx.setStorageSync('orderData', {
      merchantId: this.data.merchantId,
      merchantName: this.data.merchantName,
      items: orderItems,
      total: this.data.cartTotal
    })
    
    // 跳转到下单页面
    wx.navigateTo({
      url: '/pages/order/checkout'
    })
  },

  /**
   * 显示菜品详情
   */
  showDetail(e) {
    const { dish } = e.currentTarget.dataset
    wx.showModal({
      title: dish.name,
      content: `价格：¥${dish.price}\n描述：${dish.description || '暂无描述'}\n月售：${dish.sales || 0}`,
      showCancel: false
    })
  },

  /**
   * 领取商家优惠券
   */
  async receiveMerchantCoupon(e) {
    const { id, index } = e.currentTarget.dataset
    const coupon = this.data.merchantCoupons[index]
    
    if (coupon.received) {
      showError('您已经领取过该优惠券了')
      return
    }
    
    try {
      const request = require('../../utils/request')
      showLoading('领取中...')
      
      await request({
        url: `/coupon/receive/${id}`,
        method: 'POST'
      })
      
      hideLoading()
      showSuccess('领取成功')
      
      // 更新UI
      const merchantCoupons = this.data.merchantCoupons
      merchantCoupons[index].received = true
      merchantCoupons[index].remainCount--
      
      this.setData({ merchantCoupons })
    } catch (error) {
      hideLoading()
      console.error('领取商家优惠券失败:', error)
      showError(error.msg || '领取失败')
    }
  },

  /**
   * 联系商家 - 显示微信社群二维码
   */
  contactMerchant() {
    const { merchantInfo } = this.data
    
    if (!merchantInfo || !merchantInfo.wechatGroupQrcode) {
      wx.showModal({
        title: '提示',
        content: '该商家暂未设置微信社群，请稍后再试',
        showCancel: false
      })
      return
    }
    
    this.setData({ showQrcodeModal: true })
  },

  /**
   * 隐藏二维码弹窗
   */
  hideQrcodeModal() {
    this.setData({ showQrcodeModal: false })
  },

  /**
   * 保存二维码到相册
   */
  saveQrcode() {
    const { merchantInfo } = this.data
    
    if (!merchantInfo || !merchantInfo.wechatGroupQrcode) {
      showError('二维码不存在')
      return
    }
    
    wx.showLoading({ title: '保存中...' })
    
    // 下载图片
    wx.downloadFile({
      url: merchantInfo.wechatGroupQrcode,
      success: (res) => {
        if (res.statusCode === 200) {
          // 保存到相册
          wx.saveImageToPhotosAlbum({
            filePath: res.tempFilePath,
            success: () => {
              wx.hideLoading()
              showSuccess('已保存到相册')
            },
            fail: (err) => {
              wx.hideLoading()
              if (err.errMsg.includes('auth deny')) {
                wx.showModal({
                  title: '提示',
                  content: '需要您授权保存图片到相册',
                  success: (res) => {
                    if (res.confirm) {
                      wx.openSetting()
                    }
                  }
                })
              } else {
                showError('保存失败')
              }
            }
          })
        } else {
          wx.hideLoading()
          showError('下载失败')
        }
      },
      fail: () => {
        wx.hideLoading()
        showError('下载失败')
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

