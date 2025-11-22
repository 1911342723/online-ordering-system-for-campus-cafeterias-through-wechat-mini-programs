import request from './request'

/**
 * 订单管理API
 */

// 分页查询订单（管理端）
export function getOrderPage(params) {
  return request({
    url: '/order/page',
    method: 'get',
    params
  })
}

// 分页查询订单（用户端）
export function getUserOrderPage(params) {
  return request({
    url: '/order/userPage',
    method: 'get',
    params
  })
}

// 提交订单
export function submitOrder(data) {
  return request({
    url: '/order/submit',
    method: 'post',
    data
  })
}

// 获取订单详情
export function getOrderDetail(id) {
  return request({
    url: `/order/${id}`,
    method: 'get'
  })
}

// 修改订单状态
export function updateOrderStatus(data) {
  return request({
    url: '/order',
    method: 'put',
    data
  })
}

