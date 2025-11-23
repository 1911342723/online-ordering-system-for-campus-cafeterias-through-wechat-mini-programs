// pages/order/checkout.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    deliveryType: 1, // 1:自取 2:外送
    selectedAddress: null,
    orderItems: [],
    dishAmount: '0.00',
    totalAmount: '0.00',
    remark: '',
    canteenId: null,
    canteenName: '',
    selectedCoupon: null, // 选中的优惠券
    availableCoupons: [], // 可用优惠券列表
    couponDiscount: 0, // 优惠券优惠金额
    deliveryFee: 0 // 配送费
  },

  onLoad(options) {
    // 从本地存储获取订单数据
    const orderData = wx.getStorageSync('orderData')
    if (!orderData || !orderData.items || orderData.items.length === 0) {
      showError('购物车为空')
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
      return
    }

    this.setData({
      orderItems: orderData.items,
      dishAmount: orderData.total,
      totalAmount: orderData.total,
      canteenId: orderData.canteenId || 1,
      canteenName: orderData.canteenName || '食堂'
    })
    
    // 加载可用优惠券
    this.loadAvailableCoupons()
  },

  /**
   * 加载可用优惠券
   */
  async loadAvailableCoupons() {
    try {
      const res = await request({
        url: '/coupon/my',
        method: 'GET',
        data: { status: 0 } // 0-未使用
      })
      
      if (res && res.length > 0) {
        // 过滤满足订单金额的优惠券
        const dishAmountValue = parseFloat(this.data.dishAmount) * 100 // 转换为分
        const availableCoupons = res.filter(coupon => {
          return dishAmountValue >= coupon.minAmount
        })
        
        this.setData({ availableCoupons })
      }
    } catch (error) {
      console.error('加载优惠券失败:', error)
    }
  },

  /**
   * 选择配送方式
   */
  selectDeliveryType(e) {
    const type = parseInt(e.currentTarget.dataset.type) // 转换为数字
    const deliveryFee = type === 2 ? 3.00 : 0

    // 如果选择外送但没有地址，需要选择地址
    if (type === 2 && !this.data.selectedAddress) {
      wx.showModal({
        title: '提示',
        content: '外送需要选择收货地址',
        showCancel: false
      })
    }

    this.setData({
      deliveryType: type,
      deliveryFee: deliveryFee
    }, () => {
      this.calculateTotal()
    })
  },

  /**
   * 选择优惠券
   */
  selectCoupon() {
    if (this.data.availableCoupons.length === 0) {
      showError('暂无可用优惠券')
      return
    }

    const availableCoupons = this.data.availableCoupons
    const itemList = availableCoupons.map(c => {
      const amount = parseInt(c.amount / 100)
      const minAmount = parseInt(c.minAmount / 100)
      return `${c.couponName} - 满${minAmount}减${amount}`
    })
    itemList.push('不使用优惠券')

    wx.showActionSheet({
      itemList: itemList,
      success: (res) => {
        const index = res.tapIndex
        if (index === availableCoupons.length) {
          // 不使用优惠券
          this.setData({
            selectedCoupon: null,
            couponDiscount: 0
          }, () => {
            this.calculateTotal()
          })
        } else {
          // 选择优惠券
          const coupon = availableCoupons[index]
          this.setData({
            selectedCoupon: coupon,
            couponDiscount: parseFloat(coupon.amount / 100)
          }, () => {
            this.calculateTotal()
          })
        }
      }
    })
  },

  /**
   * 计算总价
   */
  calculateTotal() {
    const dishAmount = parseFloat(this.data.dishAmount)
    const deliveryFee = this.data.deliveryFee
    const couponDiscount = this.data.couponDiscount
    
    const total = Math.max(dishAmount + deliveryFee - couponDiscount, 0)
    
    this.setData({
      totalAmount: total.toFixed(2)
    })
  },

  /**
   * 选择收货地址
   */
  selectAddress() {
    wx.navigateTo({
      url: '/pages/address/list?from=checkout',
      events: {
        // 监听地址选择事件
        selectAddress: (address) => {
          this.setData({ selectedAddress: address })
        }
      }
    })
  },

  /**
   * 备注输入
   */
  onRemarkInput(e) {
    this.setData({ remark: e.detail.value })
  },

  /**
   * 提交订单
   */
  async submitOrder() {
    const { deliveryType, selectedAddress, orderItems, totalAmount, remark, canteenId, canteenName, selectedCoupon } = this.data

    // 验证
    if (deliveryType === 2 && !selectedAddress) {
      showError('请选择收货地址')
      return
    }

    if (!orderItems || orderItems.length === 0) {
      showError('购物车为空')
      return
    }

    try {
      showLoading('提交中...')

      // 构建订单数据
      const orderData = {
        deliveryType: deliveryType,
        addressBookId: deliveryType === 2 ? selectedAddress.id : null,
        payMethod: 1, // 1:微信支付 2:支付宝
        remark: remark,
        canteenId: canteenId,
        canteenName: canteenName,
        userCouponId: selectedCoupon ? selectedCoupon.id : null // 用户优惠券ID
      }

      const res = await request({
        url: '/order/submit',
        method: 'POST',
        data: orderData
      })

      hideLoading()
      
      if (res) {
        showSuccess('下单成功！')
        
        // 清除本地订单数据
        wx.removeStorageSync('orderData')
        
        // 跳转到订单列表
        setTimeout(() => {
          wx.switchTab({
            url: '/pages/order/order'
          })
        }, 1500)
      }

    } catch (error) {
      hideLoading()
      console.error('提交订单失败:', error)
      showError(error.msg || '下单失败，请重试')
    }
  }
})

