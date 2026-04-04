import request from './request'

function normalizeOrderIdPayload(data) {
  if (!data || typeof data !== 'object') {
    return data
  }
  const payload = { ...data }
  if (payload.id !== undefined && payload.id !== null) {
    payload.id = String(payload.id)
  }
  if (payload.orderId !== undefined && payload.orderId !== null) {
    payload.orderId = String(payload.orderId)
  }
  return payload
}

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

// 获取订单详情（别名）
export function getOrderById(id) {
  return getOrderDetail(id)
}

// 修改订单状态
export function updateOrderStatus(data) {
  return request({
    url: '/order',
    method: 'put',
    data: normalizeOrderIdPayload(data)
  })
}

