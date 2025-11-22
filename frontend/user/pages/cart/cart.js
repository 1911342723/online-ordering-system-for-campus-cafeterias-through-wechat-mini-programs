// pages/cart/cart.js
const request = require('../../utils/request')
const { DEFAULT_IMAGES } = require('../../utils/config')
const { getImageUrl, showError, showSuccess, showLoading, hideLoading, checkLogin, navigateToLogin, formatPrice } = require('../../utils/util')

// 空购物车图标
const EMPTY_CART_ICON = "data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200' viewBox='0 0 200 200'%3E%3Cg fill='%23CCCCCC'%3E%3Ccircle cx='70' cy='180' r='10'/%3E%3Ccircle cx='150' cy='180' r='10'/%3E%3Cpath d='M10 20h30l20 100h100l20-60H60'/%3E%3C/g%3E%3C/svg%3E"

Page({
  data: {
    cartItems: [],
    allChecked: false,
    checkedCount: 0,
    totalAmount: '0.00',
    emptyCartIcon: EMPTY_CART_ICON
  },

  onShow() {
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
    
    this.loadCartData()
  },

  /**
   * 加载购物车数据
   */
  async loadCartData() {
    try {
      showLoading('加载中...')
      
      const cartList = await request({
        url: '/shoppingCart/list',
        method: 'GET'
      })
      
      // 处理购物车数据
      const processedCart = (cartList || []).map(item => ({
        ...item,
        checked: true, // 默认选中
        image: getImageUrl(item.image, DEFAULT_IMAGES.dish),
        price: formatPrice(item.amount)
      }))
      
      this.setData({ 
        cartItems: processedCart,
        allChecked: processedCart.length > 0
      })
      
      this.calculateTotal()
      hideLoading()
      
    } catch (error) {
      hideLoading()
      console.error('加载购物车失败:', error)
      showError('加载购物车失败')
    }
  },

  /**
   * 切换单个商品选中状态
   */
  toggleCheck(e) {
    const { id } = e.currentTarget.dataset
    const cartItems = this.data.cartItems.map(item => {
      if (item.id === id) {
        item.checked = !item.checked
      }
      return item
    })
    
    const allChecked = cartItems.every(item => item.checked)
    this.setData({ cartItems, allChecked })
    this.calculateTotal()
  },

  /**
   * 全选/取消全选
   */
  toggleSelectAll() {
    const allChecked = !this.data.allChecked
    const cartItems = this.data.cartItems.map(item => {
      item.checked = allChecked
      return item
    })
    
    this.setData({ cartItems, allChecked })
    this.calculateTotal()
  },

  /**
   * 更新商品数量
   */
  async updateQuantity(e) {
    const { id, action } = e.currentTarget.dataset
    const cartItems = this.data.cartItems
    const item = cartItems.find(i => i.id === id)
    
    if (!item) return
    
    try {
      if (action === 'minus') {
        if (item.number <= 1) {
          // 删除商品
          const confirm = await wx.showModal({
            title: '提示',
            content: '确定要删除该商品吗？'
          })
          
          if (!confirm.confirm) return
          
          await request({
            url: '/shoppingCart/sub',
            method: 'POST',
            data: { dishId: item.dishId || item.setmealId }
          })
          
          // 从列表中移除
          this.setData({
            cartItems: cartItems.filter(i => i.id !== id)
          })
        } else {
          // 减少数量
          await request({
            url: '/shoppingCart/sub',
            method: 'POST',
            data: { dishId: item.dishId || item.setmealId }
          })
          
          item.number--
          this.setData({ cartItems })
        }
      } else {
        // 增加数量
        await request({
          url: '/shoppingCart/add',
          method: 'POST',
          data: {
            dishId: item.dishId,
            setmealId: item.setmealId,
            name: item.name,
            image: item.image,
            amount: item.amount
          }
        })
        
        item.number++
        this.setData({ cartItems })
      }
      
      this.calculateTotal()
      
    } catch (error) {
      console.error('更新数量失败:', error)
      showError('操作失败')
    }
  },

  /**
   * 计算总价
   */
  calculateTotal() {
    const { cartItems } = this.data
    const checkedItems = cartItems.filter(item => item.checked)
    
    let totalAmount = 0
    checkedItems.forEach(item => {
      const price = parseFloat(item.price)
      totalAmount += price * item.number
    })
    
    this.setData({
      checkedCount: checkedItems.length,
      totalAmount: totalAmount.toFixed(2)
    })
  },

  /**
   * 去结算
   */
  goToCheckout() {
    const checkedItems = this.data.cartItems.filter(item => item.checked)
    
    if (checkedItems.length === 0) {
      showError('请选择要结算的商品')
      return
    }
    
    // 保存订单数据到本地
    const orderItems = checkedItems.map(item => ({
      dishId: item.dishId,
      setmealId: item.setmealId,
      name: item.name,
      price: item.price,
      number: item.number,
      image: item.image
    }))
    
    wx.setStorageSync('orderData', {
      items: orderItems,
      total: this.data.totalAmount,
      canteenId: 1, // 可以从第一个商品获取
      canteenName: '食堂'
    })
    
    // 跳转到下单页面
    wx.navigateTo({
      url: '/pages/order/checkout'
    })
  },

  /**
   * 去逛逛
   */
  goShopping() {
    wx.switchTab({
      url: '/pages/index/index'
    })
  }
})

