const app = getApp()

const request = (options) => {
  return new Promise((resolve, reject) => {
    const token = wx.getStorageSync('token')
    const baseUrl = 'http://localhost:8080' // 本地后端地址
    
    let url = options.url
    if (!url.startsWith('http')) {
      url = `${baseUrl}${url}`
    }

    wx.request({
      url: url,
      method: options.method || 'GET',
      data: options.data || {},
      header: {
        'content-type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : '', // JWT Token
        'Cookie': wx.getStorageSync('cookie') || ''
      },
      success(res) {
        if (res.statusCode === 200) {
          // Save cookie if present
          if (res.cookies && res.cookies.length > 0) {
             // Simple cookie handling
             const cookie = res.cookies.join(';')
             wx.setStorageSync('cookie', cookie)
          }
          
          const { code, msg, data } = res.data
          if (code === 1) {
            resolve(data)
          } else if (msg === 'NOTLOGIN') {
            // 静默处理未登录错误，不弹框提示
            // 某些接口（如公告、推荐）不需要登录也能访问
            console.log('未登录访问:', options.url)
            reject(res.data)
          } else {
            // 其他错误：如果不是静默模式才显示提示
            if (!options.silent) {
              wx.showToast({
                title: msg || '请求失败',
                icon: 'none'
              })
            }
            reject(res.data)
          }
        } else {
          wx.showToast({
            title: '网络错误 ' + res.statusCode,
            icon: 'none'
          })
          reject(res)
        }
      },
      fail(err) {
        wx.showToast({
          title: '网络请求失败',
          icon: 'none'
        })
        reject(err)
      }
    })
  })
}

module.exports = request
