// pages/feedback/feedback.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    feedbackTypes: [
      { value: 'bug', label: '功能异常' },
      { value: 'suggest', label: '功能建议' },
      { value: 'service', label: '服务问题' },
      { value: 'food', label: '菜品问题' },
      { value: 'delivery', label: '配送问题' },
      { value: 'other', label: '其他' }
    ],
    selectedType: 'suggest',
    content: '',
    images: [],
    contact: ''
  },

  onLoad() {
    // 加载用户手机号作为默认联系方式
    const phone = wx.getStorageSync('phone')
    if (phone) {
      this.setData({ contact: phone })
    }
  },

  /**
   * 选择反馈类型
   */
  selectType(e) {
    const { value } = e.currentTarget.dataset
    this.setData({ selectedType: value })
  },

  /**
   * 输入反馈内容
   */
  onContentInput(e) {
    this.setData({ content: e.detail.value })
  },

  /**
   * 输入联系方式
   */
  onContactInput(e) {
    this.setData({ contact: e.detail.value })
  },

  /**
   * 选择图片
   */
  chooseImage() {
    const remaining = 3 - this.data.images.length
    
    wx.chooseImage({
      count: remaining,
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: (res) => {
        const newImages = [...this.data.images, ...res.tempFilePaths]
        this.setData({ images: newImages })
      }
    })
  },

  /**
   * 删除图片
   */
  deleteImage(e) {
    const { index } = e.currentTarget.dataset
    const images = this.data.images.filter((_, i) => i !== index)
    this.setData({ images })
  },

  /**
   * 提交反馈
   */
  async submitFeedback() {
    const { selectedType, content, images, contact } = this.data

    // 验证
    if (!content || content.trim().length === 0) {
      showError('请输入问题描述')
      return
    }

    if (content.length < 10) {
      showError('问题描述至少10个字')
      return
    }

    try {
      showLoading('提交中...')

      // TODO: 如果有图片，先上传图片
      let imageUrls = []
      if (images.length > 0) {
        // 这里可以调用图片上传接口
        // imageUrls = await this.uploadImages(images)
        console.log('图片上传功能待实现')
      }

      // 提交反馈
      await request({
        url: '/feedback/submit',
        method: 'POST',
        data: {
          type: selectedType,
          content: content.trim(),
          images: imageUrls.join(','),
          contact: contact
        }
      })

      hideLoading()
      showSuccess('提交成功，感谢您的反馈！')

      // 延迟返回
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)

    } catch (error) {
      hideLoading()
      console.error('提交反馈失败:', error)
      showError(error.msg || '提交失败，请重试')
    }
  }
})

