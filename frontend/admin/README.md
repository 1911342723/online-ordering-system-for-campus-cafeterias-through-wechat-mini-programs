# 智慧食堂管理端 (Admin)

基于 Vue 3 + Vite + Element Plus 开发的智慧食堂后台管理系统，主要用于管理员对平台、食堂、商户和用户的综合管理。

## 技术栈

- **核心框架**：Vue 3.3 (Composition API)
- **构建工具**：Vite 4.4
- **UI 组件库**：Element Plus 2.4
- **路由管理**：Vue Router 4.2
- **HTTP 客户端**：Axios 1.6
- **图表可视化**：ECharts 5.4
- **CSS 预处理**：Sass 1.69

## 功能模块

- **登录/鉴权**：账号密码登录，JWT Token 认证
- **数据概览 (Dashboard)**：平台关键指标展示 (用户数、订单数、营业额等)
- **员工管理**：平台管理员账号的增删改查
- **用户管理**：管理C端注册用户，查看用户信息及状态
- **食堂管理**：管理学校食堂信息 (名称、位置、简介等)
- **商家管理**：商家入驻审核、信息维护、状态管理
- **公告管理**：发布和维护系统公告

## 项目结构

```
frontend/admin/src/
├── api/              # API 接口定义 (按模块分类)
├── layout/           # 页面布局组件 (侧边栏、顶栏)
├── router/           # 路由配置
├── styles/           # 全局样式 (Sass)
├── views/            # 页面视图组件
│   ├── dashboard/    # 数据概览
│   ├── member/       # 员工管理
│   ├── user/         # 用户管理
│   ├── canteen/      # 食堂管理
│   ├── merchant/     # 商家管理
│   └── announcement/ # 公告管理
├── App.vue           # 根组件
└── main.js           # 入口文件
```

## 接口代理配置

开发环境通过 `vite.config.js` 配置了反向代理，以解决跨域问题：

```javascript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080', // 后端服务地址
      changeOrigin: true,
      rewrite: (path) => path.replace(/^\/api/, '')
    }
  }
}
```
