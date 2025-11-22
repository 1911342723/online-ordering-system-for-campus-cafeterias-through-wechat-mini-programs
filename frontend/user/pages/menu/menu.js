// pages/menu/menu.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { formatPrice, getImageUrl, showLoading, hideLoading, showError, showSuccess } = require('../../utils/util')

Page({
  data: {
    canteenId: '',
    canteenName: '',
    categories: [],
    activeCategory: 0,
    toView: '',
    cart: {}, // { dishId: { dish, count } }
    cartCount: 0,
    cartTotal: 0,
    defaultDishImg: DEFAULT_IMAGES.dish,
    icons: {
      cart: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSIjRkZGRkZGIiBzdHJva2U9Im5vbmUiPjxjaXJjbGUgY3g9IjkiIGN5PSIyMSIgcj0iMSIvPjxjaXJjbGUgY3g9IjIwIiBjeT0iMjEiIHI9IjEiLz48cGF0aCBkPSJNMSAxaDRsMi42OCAxMy4zOWEyIDIgMCAwIDAgMiAxLjYxaDkuNzJhMiAyIDAgMCAwIDItMS42MUwyMyA2SDYiLz48L3N2Zz4=',
      cartEmpty: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiM5OTk5OTkiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48Y2lyY2xlIGN4PSI5IiBjeT0iMjEiIHI9IjEiLz48Y2lyY2xlIGN4PSIyMCIgY3k9IjIxIiByPSIxIi8+PHBhdGggZD0iTTEgMWg0bDIuNjggMTMuMzlhMiAyIDAgMCAwIDIgMS42MWg5LjcyYTIgMiAwIDAgMCAyLTEuNjFMMjMgNkg2Ii8+PC9zdmc+'
    }
  },

  onLoad(options) {
    if (options.canteenId) {
      const canteenId = options.canteenId
      const categoryId = options.categoryId || null
      
      this.setData({ 
        canteenId: canteenId,
        canteenName: options.name || '食堂'
      })
      
      this.loadMenuData(categoryId)
    }
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
              price: formatPrice(dish.price), // 将分转换为元
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
      
      this.setData({ 
        categories: categoriesWithDishes,
        activeCategory: activeIndex,
        toView: `category-${activeIndex}`
      })
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
   * 加载菜品列表 - 根据餐厅ID和分类ID查询
   */
  async loadDishes(categoryId) {
    try {
      const result = await request({
        url: '/dish/list',
        method: 'GET',
        data: {
          canteenId: this.data.canteenId, // 添加餐厅ID参数
          categoryId: categoryId,
          status: 1 // 1-在售
        }
      })
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
      canteenName: this.data.canteenName,
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
  }
})

