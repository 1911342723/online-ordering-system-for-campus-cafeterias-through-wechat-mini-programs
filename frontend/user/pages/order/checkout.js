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
    canteenName: ''
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
  },

  /**
   * 选择配送方式
   */
  selectDeliveryType(e) {
    const type = parseInt(e.currentTarget.dataset.type) // 转换为数字
    let totalAmount = this.data.dishAmount

    // 如果选择外送，添加配送费
    if (type === 2) {
      totalAmount = (parseFloat(this.data.dishAmount) + 3.00).toFixed(2)
      
      // 如果选择外送但没有地址，需要选择地址
      if (!this.data.selectedAddress) {
        wx.showModal({
          title: '提示',
          content: '外送需要选择收货地址',
          showCancel: false
        })
      }
    } else {
      // 自取时不加配送费
      totalAmount = this.data.dishAmount
    }

    this.setData({
      deliveryType: type,
      totalAmount: totalAmount
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
    const { deliveryType, selectedAddress, orderItems, totalAmount, remark, canteenId, canteenName } = this.data

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
        canteenName: canteenName
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

