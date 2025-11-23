import request from './request'

/**
 * 商家管理API（管理员功能）
 */

// 分页查询商家
export function getMerchantPage(params) {
  return request({
    url: '/merchant/page',
    method: 'get',
    params
  })
}

// 根据ID获取商家详情
export function getMerchantById(id) {
  return request({
    url: `/merchant/${id}`,
    method: 'get'
  })
}

// 新增商家（审核通过）
export function addMerchant(data) {
  return request({
    url: '/merchant',
    method: 'post',
    data
  })
}

// 修改商家信息
export function updateMerchant(data) {
  return request({
    url: '/merchant',
    method: 'put',
    data
  })
}

// 冻结/解冻商家账号
export function changeMerchantStatus(data) {
  return request({
    url: '/merchant/status',
    method: 'put',
    data
  })
}

// 审核商家入驻申请
export function approveMerchant(data) {
  return request({
    url: '/merchant/approve',
    method: 'post',
    data
  })
}

// 获取待审核商家列表
export function getPendingMerchants() {
  return request({
    url: '/merchant/pending',
    method: 'get'
  })
}

// 删除商家（管理员）
export function deleteMerchant(id) {
  return request({
    url: `/merchant/${id}`,
    method: 'delete'
  })
}

// 根据员工ID获取商家信息
export function getMerchantByEmployeeId(employeeId) {
  return request({
    url: `/merchant/byEmployee/${employeeId}`,
    method: 'get'
  })
}

/**
 * 商家入驻申请API
 */

// 提交商家入驻申请
export function submitMerchantApplication(data) {
  return request({
    url: '/merchantApplication',
    method: 'post',
    data
  })
}

// 分页查询商家入驻申请（管理员）
export function getMerchantApplicationPage(params) {
  return request({
    url: '/merchantApplication/page',
    method: 'get',
    params
  })
}

// 获取申请详情
export function getMerchantApplicationById(id) {
  return request({
    url: `/merchantApplication/${id}`,
    method: 'get'
  })
}

// 审核商家申请（管理员）
export function auditMerchantApplication(data) {
  return request({
    url: '/merchantApplication/audit',
    method: 'post',
    data
  })
}

// 获取待审核数量
export function getPendingCount() {
  return request({
    url: '/merchantApplication/pendingCount',
    method: 'get'
  })
}
