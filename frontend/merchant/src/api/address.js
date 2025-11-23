import request from './request'

/**
 * 地址管理API
 */

// 获取地址列表
export function getAddressList() {
  return request({
    url: '/addressBook/list',
    method: 'get'
  })
}

// 新增地址
export function addAddress(data) {
  return request({
    url: '/addressBook',
    method: 'post',
    data
  })
}

// 修改地址
export function updateAddress(data) {
  return request({
    url: '/addressBook',
    method: 'put',
    data
  })
}

// 删除地址
export function deleteAddress(id) {
  return request({
    url: '/addressBook',
    method: 'delete',
    params: { ids: id }
  })
}

// 根据ID获取地址详情
export function getAddressById(id) {
  return request({
    url: `/addressBook/${id}`,
    method: 'get'
  })
}

// 设置默认地址
export function setDefaultAddress(data) {
  return request({
    url: '/addressBook/default',
    method: 'put',
    data
  })
}

// 获取默认地址
export function getDefaultAddress() {
  return request({
    url: '/addressBook/default',
    method: 'get'
  })
}

