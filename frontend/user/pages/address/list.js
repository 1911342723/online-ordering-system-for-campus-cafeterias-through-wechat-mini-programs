// pages/address/list.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    addressList: [],
    fromPage: '' // 来源页面：checkout-选择地址，空-管理地址
  },

  onLoad(options) {
    this.setData({
      fromPage: options.from || ''
    })
    this.loadAddressList()
  },

  onShow() {
    // 从编辑页面返回时刷新列表
    this.loadAddressList()
  },

  /**
   * 加载地址列表
   */
  async loadAddressList() {
    try {
      showLoading('加载中...')
      
      const res = await request({
        url: '/addressBook/list',
        method: 'GET'
      })
      
      hideLoading()
      
      // request已经返回data，不需要再取res.data
      if (res) {
        console.log('地址列表:', res)
        this.setData({
          addressList: Array.isArray(res) ? res : []
        })
      }
    } catch (error) {
      hideLoading()
      console.error('加载地址列表失败:', error)
      showError(error.msg || '加载失败')
    }
  },

  /**
   * 点击地址项
   */
  handleAddressClick(e) {
    const { address } = e.currentTarget.dataset
    
    // 如果是从结算页面来的，选择地址后返回
    if (this.data.fromPage === 'checkout') {
      const eventChannel = this.getOpenerEventChannel()
      if (eventChannel) {
        eventChannel.emit('selectAddress', address)
      }
      wx.navigateBack()
    }
  },

  /**
   * 添加新地址
   */
  addAddress() {
    wx.navigateTo({
      url: '/pages/address/edit?from=' + this.data.fromPage
    })
  },

  /**
   * 编辑地址
   */
  editAddress(e) {
    const { address } = e.currentTarget.dataset
    wx.navigateTo({
      url: `/pages/address/edit?id=${address.id}&from=${this.data.fromPage}`
    })
  },

  /**
   * 设为默认地址
   */
  async setDefault(e) {
    const { id } = e.currentTarget.dataset
    
    try {
      showLoading('设置中...')
      
      await request({
        url: '/addressBook/default',
        method: 'PUT',
        data: { id }
      })
      
      hideLoading()
      showSuccess('设置成功')
      
      // 刷新列表
      this.loadAddressList()
      
    } catch (error) {
      hideLoading()
      console.error('设置默认地址失败:', error)
      showError(error.msg || '设置失败')
    }
  },

  /**
   * 删除地址
   */
  deleteAddress(e) {
    const { id } = e.currentTarget.dataset
    
    wx.showModal({
      title: '提示',
      content: '确定要删除这个地址吗？',
      success: async (res) => {
        if (res.confirm) {
          try {
            showLoading('删除中...')
            
            await request({
              url: `/addressBook/${id}`,
              method: 'DELETE'
            })
            
            hideLoading()
            showSuccess('删除成功')
            
            // 刷新列表
            this.loadAddressList()
            
          } catch (error) {
            hideLoading()
            console.error('删除地址失败:', error)
            showError(error.msg || '删除失败')
          }
        }
      }
    })
  },

  /**
   * 阻止事件冒泡
   */
  stopPropagation() {
    // 空函数，用于阻止事件冒泡
  }
})

