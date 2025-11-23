import request from './request'

/**
 * 用户管理API（管理员功能）
 */

// 分页查询用户
export function getUserPage(params) {
  return request({
    url: '/user/page',
    method: 'get',
    params
  })
}

// 根据ID获取用户详情
export function getUserById(id) {
  return request({
    url: `/user/${id}`,
    method: 'get'
  })
}

// 冻结/解冻用户账号
export function changeUserStatus(data) {
  return request({
    url: '/user/status',
    method: 'put',
    data
  })
}

// 查看用户订单记录
export function getUserOrders(userId, params) {
  return request({
    url: `/user/${userId}/orders`,
    method: 'get',
    params
  })
}

// 查看用户消费统计
export function getUserStats(userId) {
  return request({
    url: `/user/${userId}/stats`,
    method: 'get'
  })
}
