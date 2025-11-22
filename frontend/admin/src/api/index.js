/**
 * API统一导出文件
 * 方便统一管理和导入所有API
 */

// 登录相关
export * from './login'

// 员工管理
export * from './employee'

// 分类管理
export * from './category'

// 菜品管理
export * from './dish'

// 套餐管理
export * from './setmeal'

// 订单管理
export * from './order'

// 用户管理
export * from './user'

// 地址管理
export * from './address'

// 购物车
export * from './cart'

// 通用接口（文件上传下载）
export * from './common'

// 请求实例
export { default as request } from './request'

