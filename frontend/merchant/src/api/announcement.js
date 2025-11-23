import request from './request'

/**
 * 商家公告管理API
 */

// 分页查询公告
export function getAnnouncementPage(params) {
  return request({
    url: '/merchantAnnouncement/page',
    method: 'get',
    params
  })
}

// 获取有效公告列表（用户端）
export function getActiveAnnouncements(merchantId) {
  return request({
    url: '/merchantAnnouncement/active',
    method: 'get',
    params: { merchantId }
  })
}

// 根据ID获取公告详情
export function getAnnouncementById(id) {
  return request({
    url: `/merchantAnnouncement/${id}`,
    method: 'get'
  })
}

// 新增公告
export function addAnnouncement(data) {
  return request({
    url: '/merchantAnnouncement',
    method: 'post',
    data
  })
}

// 修改公告
export function updateAnnouncement(data) {
  return request({
    url: '/merchantAnnouncement',
    method: 'put',
    data
  })
}

// 删除公告
export function deleteAnnouncement(id) {
  return request({
    url: `/merchantAnnouncement/${id}`,
    method: 'delete'
  })
}

// 更新公告状态
export function updateAnnouncementStatus(id, status) {
  return request({
    url: `/merchantAnnouncement/status/${id}`,
    method: 'put',
    params: { status }
  })
}

