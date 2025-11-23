import request from './request'

/**
 * 套餐管理API
 */

// 分页查询套餐
export function getSetmealPage(params) {
  return request({
    url: '/setmeal/page',
    method: 'get',
    params
  })
}

// 新增套餐
export function addSetmeal(data) {
  return request({
    url: '/setmeal',
    method: 'post',
    data
  })
}

// 修改套餐
export function updateSetmeal(data) {
  return request({
    url: '/setmeal',
    method: 'put',
    data
  })
}

// 删除套餐
export function deleteSetmeal(ids) {
  return request({
    url: '/setmeal',
    method: 'delete',
    params: { ids }
  })
}

// 根据ID获取套餐详情
export function getSetmealById(id) {
  return request({
    url: `/setmeal/${id}`,
    method: 'get'
  })
}

// 修改套餐状态
export function changeSetmealStatus(status, ids) {
  return request({
    url: `/setmeal/status/${status}`,
    method: 'post',
    params: { ids }
  })
}

// 获取套餐列表（不分页）
export function getSetmealList(params) {
  return request({
    url: '/setmeal/list',
    method: 'get',
    params
  })
}

