import request from './request'

/**
 * 购物车API
 */

// 添加商品到购物车
export function addToCart(data) {
  return request({
    url: '/shoppingCart/add',
    method: 'post',
    data
  })
}

// 获取购物车列表
export function getCartList() {
  return request({
    url: '/shoppingCart/list',
    method: 'get'
  })
}

// 减少购物车商品
export function subCart(data) {
  return request({
    url: '/shoppingCart/sub',
    method: 'post',
    data
  })
}

// 清空购物车
export function cleanCart() {
  return request({
    url: '/shoppingCart/clean',
    method: 'delete'
  })
}

