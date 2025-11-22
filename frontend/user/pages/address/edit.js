// pages/address/edit.js
const request = require('../../utils/request')
const { showError, showSuccess, showLoading, hideLoading } = require('../../utils/util')

Page({
  data: {
    addressId: null, // 地址ID，编辑时有值
    fromPage: '', // 来源页面
    region: ['', '', ''], // 地区选择
    customLabel: null, // 自定义标签
    formData: {
      consignee: '',
      phone: '',
      sex: '1',
      provinceName: '',
      cityName: '',
      districtName: '',
      provinceCode: '',
      cityCode: '',
      districtCode: '',
      detail: '',
      label: '家',
      isDefault: 0
    }
  },

  onLoad(options) {
    const { id, from } = options
    
    this.setData({
      addressId: id || null,
      fromPage: from || ''
    })

    // 如果是编辑，加载地址详情
    if (id) {
      wx.setNavigationBarTitle({
        title: '编辑地址'
      })
      this.loadAddressDetail(id)
    } else {
      wx.setNavigationBarTitle({
        title: '新增地址'
      })
    }
  },

  /**
   * 加载地址详情
   */
  async loadAddressDetail(id) {
    try {
      showLoading('加载中...')
      
      const res = await request({
        url: `/addressBook/${id}`,
        method: 'GET'
      })
      
      hideLoading()
      
      // request已经返回data，不需要再取res.data
      if (res) {
        // 检查是否是自定义标签
        const customLabel = !['家', '公司', '学校'].includes(res.label) ? res.label : null
        
        this.setData({
          formData: {
            consignee: res.consignee || '',
            phone: res.phone || '',
            sex: res.sex || '1',
            provinceName: res.provinceName || '',
            cityName: res.cityName || '',
            districtName: res.districtName || '',
            provinceCode: res.provinceCode || '',
            cityCode: res.cityCode || '',
            districtCode: res.districtCode || '',
            detail: res.detail || '',
            label: res.label || '家',
            isDefault: res.isDefault || 0
          },
          region: [
            res.provinceName || '',
            res.cityName || '',
            res.districtName || ''
          ],
          customLabel: customLabel
        })
      }
    } catch (error) {
      hideLoading()
      console.error('加载地址详情失败:', error)
      showError(error.msg || '加载失败')
    }
  },

  /**
   * 输入框变化
   */
  onInput(e) {
    const { field } = e.currentTarget.dataset
    const { value } = e.detail
    
    this.setData({
      [`formData.${field}`]: value
    })
  },

  /**
   * 选择性别
   */
  selectGender(e) {
    const { sex } = e.currentTarget.dataset
    this.setData({
      'formData.sex': sex
    })
  },

  /**
   * 地区选择
   */
  onRegionChange(e) {
    const [provinceName, cityName, districtName] = e.detail.value
    
    this.setData({
      region: e.detail.value,
      'formData.provinceName': provinceName,
      'formData.cityName': cityName,
      'formData.districtName': districtName,
      // 注意：微信小程序的 region picker 不提供区划代码
      // 如果后端需要，可以维护一个省市区代码映射表
      'formData.provinceCode': '',
      'formData.cityCode': '',
      'formData.districtCode': ''
    })
  },

  /**
   * 选择标签
   */
  selectLabel(e) {
    const { label } = e.currentTarget.dataset
    
    if (label === '' || label === undefined) {
      // 选择自定义标签
      this.setData({
        customLabel: '',
        'formData.label': ''
      })
    } else {
      // 选择预设标签
      this.setData({
        customLabel: null,
        'formData.label': label
      })
    }
  },

  /**
   * 默认地址开关
   */
  onDefaultChange(e) {
    this.setData({
      'formData.isDefault': e.detail.value ? 1 : 0
    })
  },

  /**
   * 验证表单
   */
  validateForm() {
    const { consignee, phone, provinceName, cityName, districtName, detail } = this.data.formData

    if (!consignee || !consignee.trim()) {
      showError('请输入收货人姓名')
      return false
    }

    if (!phone || !phone.trim()) {
      showError('请输入联系电话')
      return false
    }

    // 验证手机号格式
    const phoneReg = /^1[3-9]\d{9}$/
    if (!phoneReg.test(phone)) {
      showError('请输入正确的手机号码')
      return false
    }

    if (!provinceName || !cityName || !districtName) {
      showError('请选择所在地区')
      return false
    }

    if (!detail || !detail.trim()) {
      showError('请输入详细地址')
      return false
    }

    return true
  },

  /**
   * 保存地址
   */
  async saveAddress() {
    // 验证表单
    if (!this.validateForm()) {
      return
    }

    try {
      showLoading('保存中...')

      const { addressId, formData } = this.data
      
      // 构建请求数据
      const requestData = {
        ...formData,
        consignee: formData.consignee.trim(),
        phone: formData.phone.trim(),
        detail: formData.detail.trim()
      }

      // 如果是编辑，添加ID
      if (addressId) {
        requestData.id = addressId
      }

      // 发送请求
      const url = addressId ? '/addressBook' : '/addressBook'
      const method = addressId ? 'PUT' : 'POST'
      
      await request({
        url,
        method,
        data: requestData
      })

      hideLoading()
      showSuccess(addressId ? '修改成功' : '添加成功')

      // 延迟返回上一页
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)

    } catch (error) {
      hideLoading()
      console.error('保存地址失败:', error)
      showError(error.msg || '保存失败，请重试')
    }
  }
})

