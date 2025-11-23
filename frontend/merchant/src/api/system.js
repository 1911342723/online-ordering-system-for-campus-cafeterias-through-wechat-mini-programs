import request from './request'

/**
 * 系统管理API（管理员功能）
 */

// 获取系统配置
export function getSystemConfig() {
  return request({
    url: '/system/config',
    method: 'get'
  })
}

// 更新系统配置
export function updateSystemConfig(data) {
  return request({
    url: '/system/config',
    method: 'put',
    data
  })
}

// 获取操作日志
export function getOperationLogs(params) {
  return request({
    url: '/system/logs',
    method: 'get',
    params
  })
}

// 导出操作日志
export function exportLogs(params) {
  return request({
    url: '/system/logs/export',
    method: 'get',
    params,
    responseType: 'blob'
  })
}

// 获取系统信息
export function getSystemInfo() {
  return request({
    url: '/system/info',
    method: 'get'
  })
}

