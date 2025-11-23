// 商家公告管理 API

// 分页查询公告列表
function getAnnouncementPage(params) {
  return $axios({
    url: '/merchantAnnouncement/page',
    method: 'get',
    params
  })
}

// 根据ID查询公告
function getAnnouncementById(id) {
  return $axios({
    url: `/merchantAnnouncement/${id}`,
    method: 'get'
  })
}

// 新增公告
function addAnnouncement(params) {
  return $axios({
    url: '/merchantAnnouncement',
    method: 'post',
    data: { ...params }
  })
}

// 更新公告
function updateAnnouncement(params) {
  return $axios({
    url: '/merchantAnnouncement',
    method: 'put',
    data: { ...params }
  })
}

// 删除公告
function deleteAnnouncement(id) {
  return $axios({
    url: `/merchantAnnouncement/${id}`,
    method: 'delete'
  })
}

// 更新公告状态
function updateAnnouncementStatus(id, status) {
  return $axios({
    url: `/merchantAnnouncement/status/${id}`,
    method: 'put',
    params: { status }
  })
}

// 根据员工ID获取商家信息
function getMerchantByEmployeeId(employeeId) {
  return $axios({
    url: `/merchant/byEmployee/${employeeId}`,
    method: 'get'
  })
}

