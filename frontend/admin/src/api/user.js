import request from './request'

/**
 * 用户管理API（C端用户）
 */

// 用户登录
export function userLogin(data) {
  return request({
    url: '/user/login',
    method: 'post',
    data
  })
}

// 发送验证码
export function sendCode(data) {
  return request({
    url: '/user/sendMsg',
    method: 'post',
    data
  })
}

// 用户登出
export function userLogout() {
  return request({
    url: '/user/logout',
    method: 'post'
  })
}

