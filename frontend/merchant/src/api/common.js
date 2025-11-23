import request from './request'

/**
 * 通用API - 文件上传下载
 */

// 文件上传
export function uploadFile(file) {
  const formData = new FormData()
  formData.append('file', file)
  
  return request({
    url: '/common/upload',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 文件下载URL
export function getDownloadUrl(name) {
  return `/api/common/download?name=${name}`
}

// 获取图片预览URL
export function getImageUrl(name) {
  return name ? getDownloadUrl(name) : ''
}

