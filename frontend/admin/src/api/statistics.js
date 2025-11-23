import request from './request'

/**
 * 统计分析API（管理员功能）
 */

// 获取平台概览数据
export function getPlatformOverview(params) {
  return request({
    url: '/statistics/overview',
    method: 'get',
    params
  })
}

// 获取订单统计数据
export function getOrderStatistics(params) {
  return request({
    url: '/statistics/order',
    method: 'get',
    params
  })
}

// 获取营收统计数据
export function getRevenueStatistics(params) {
  return request({
    url: '/statistics/revenue',
    method: 'get',
    params
  })
}

// 获取用户统计数据
export function getUserStatistics(params) {
  return request({
    url: '/statistics/user',
    method: 'get',
    params
  })
}

// 获取各食堂营收对比
export function getCanteenRevenue(params) {
  return request({
    url: '/statistics/canteen-revenue',
    method: 'get',
    params
  })
}

// 获取热门菜品排行
export function getPopularDishes(params) {
  return request({
    url: '/statistics/popular-dishes',
    method: 'get',
    params
  })
}

// 获取高峰期流量分析
export function getPeakTraffic(params) {
  return request({
    url: '/statistics/peak-traffic',
    method: 'get',
    params
  })
}

// 导出统计报表
export function exportStatistics(params) {
  return request({
    url: '/statistics/export',
    method: 'get',
    params,
    responseType: 'blob'
  })
}

