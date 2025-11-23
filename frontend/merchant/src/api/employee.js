import request from './request'

/**
 * 员工管理API
 */

// 分页查询员工
export function getEmployeePage(params) {
  return request({
    url: '/employee/page',
    method: 'get',
    params
  })
}

// 新增员工
export function addEmployee(data) {
  return request({
    url: '/employee',
    method: 'post',
    data
  })
}

// 修改员工信息
export function updateEmployee(data) {
  return request({
    url: '/employee',
    method: 'put',
    data
  })
}

// 根据ID获取员工详情
export function getEmployeeById(id) {
  return request({
    url: `/employee/${id}`,
    method: 'get'
  })
}

// 修改员工状态
export function changeEmployeeStatus(data) {
  return request({
    url: '/employee',
    method: 'put',
    data
  })
}

