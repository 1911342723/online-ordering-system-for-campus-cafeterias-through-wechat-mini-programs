import request from './request'

/**
 * 食堂管理API
 */

// 分页查询食堂
export function getCanteenPage(params) {
  return request({
    url: '/canteen/page',
    method: 'get',
    params
  })
}

// 获取食堂列表（不分页）
export function getCanteenList() {
  return request({
    url: '/canteen/list',
    method: 'get'
  })
}

// 根据ID获取食堂详情
export function getCanteenById(id) {
  return request({
    url: `/canteen/${id}`,
    method: 'get'
  })
}

// 新增食堂
export function addCanteen(data) {
  return request({
    url: '/canteen',
    method: 'post',
    data
  })
}

// 修改食堂
export function updateCanteen(data) {
  return request({
    url: '/canteen',
    method: 'put',
    data
  })
}

// 删除食堂
export function deleteCanteen(id) {
  return request({
    url: `/canteen/${id}`,
    method: 'delete'
  })
}

// 修改食堂状态
export function changeCanteenStatus(status, ids) {
  return request({
    url: `/canteen/status/${status}`,
    method: 'post',
    params: { ids }
  })
}

