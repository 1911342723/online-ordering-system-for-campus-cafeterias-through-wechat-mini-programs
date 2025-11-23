import request from './request'

/**
 * 菜品管理API
 */

// 分页查询菜品
export function getDishPage(params) {
  return request({
    url: '/dish/page',
    method: 'get',
    params
  })
}

// 新增菜品
export function addDish(data) {
  return request({
    url: '/dish',
    method: 'post',
    data
  })
}

// 修改菜品
export function updateDish(data) {
  return request({
    url: '/dish',
    method: 'put',
    data
  })
}

// 删除菜品
export function deleteDish(ids) {
  return request({
    url: '/dish',
    method: 'delete',
    params: { ids }
  })
}

// 根据ID获取菜品详情
export function getDishById(id) {
  return request({
    url: `/dish/${id}`,
    method: 'get'
  })
}

// 获取菜品列表（不分页）
export function getDishList(params) {
  return request({
    url: '/dish/list',
    method: 'get',
    params
  })
}

// 修改菜品状态
export function changeDishStatus(status, ids) {
  return request({
    url: `/dish/status/${status}`,
    method: 'post',
    params: { ids }
  })
}

