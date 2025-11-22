import axios from 'axios'
import { ElMessage } from 'element-plus'

const service = axios.create({
  baseURL: '/api', // Vite proxy will handle this
  timeout: 10000
})

// Request Interceptor
service.interceptors.request.use(
  config => {
    const userInfo = localStorage.getItem('userInfo')
    // if (userInfo) {
    //   config.headers['Authorization'] = ...
    // }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// Response Interceptor
service.interceptors.response.use(
  response => {
    const res = response.data
    // Assuming backend returns code 0 or 1. 
    // Backend: code 1 is success, 0 is error
    if (res.code === 0 && res.msg === 'NOTLOGIN') {
      localStorage.removeItem('userInfo')
      window.location.href = '/login'
      return Promise.reject(new Error('Not Login'))
    }
    return res
  },
  error => {
    console.log('err' + error)
    let { message } = error;
    if (message == "Network Error") {
      message = "后端接口连接异常";
    }
    else if (message.includes("timeout")) {
      message = "系统接口请求超时";
    }
    else if (message.includes("Request failed with status code")) {
      message = "系统接口" + message.substr(message.length - 3) + "异常";
    }
    ElMessage({
      message: message,
      type: 'error',
      duration: 5 * 1000
    })
    return Promise.reject(error)
  }
)

export default service

