import request from './request'

/**
 * 分类管理API
 */

// 分页查询分类
export function getCategoryPage(params) {
  return request({
    url: '/category/page',
    method: 'get',
    params
  })
}

// 新增分类
export function addCategory(data) {
  return request({
    url: '/category',
    method: 'post',
    data
  })
}

// 修改分类
export function updateCategory(data) {
  return request({
    url: '/category',
    method: 'put',
    data
  })
}

// 删除分类
export function deleteCategory(id) {
  return request({
    url: '/category',
    method: 'delete',
    params: { id }
  })
}

// 获取所有分类列表（不分页）
export function getCategoryList(params) {
  return request({
    url: '/category/list',
    method: 'get',
    params
  })
}

