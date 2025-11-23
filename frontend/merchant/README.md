# 智慧食堂管理端

基于 Vue 3 + Vite + Element Plus 开发的智慧食堂管理系统。

## 快速开始

### 安装依赖

```bash
npm install
```

### 开发环境

```bash
npm run dev
```

访问 http://localhost:3000

### 生产打包

```bash
npm run build
```

### 预览生产构建

```bash
npm run preview
```

## 技术栈

- **框架：** Vue 3.3
- **构建工具：** Vite 4.4
- **UI 组件：** Element Plus 2.4
- **路由：** Vue Router 4.2
- **HTTP 客户端：** Axios 1.6
- **图表：** ECharts 5.4
- **样式：** Sass 1.69

## 功能模块

- ✅ 登录/登出
- ✅ 数据概览（Dashboard）
- ✅ 订单管理
- ✅ 菜品管理
- ✅ 分类管理
- ✅ 员工管理

## 默认账号

- 超级管理员：admin / 123456
- 食堂经理：manager / 123456
- 员工测试：staff / 123456

## 项目结构

```
src/
├── api/              # API 接口
├── layout/           # 布局组件
├── router/           # 路由配置
├── styles/           # 全局样式
├── views/            # 页面组件
├── App.vue           # 根组件
└── main.js           # 入口文件
```

## 开发规范

- 使用 Composition API
- 使用 `<script setup>` 语法
- 组件命名使用 PascalCase
- API 按模块分文件管理

## 配置说明

### API 代理

开发环境通过 Vite 代理转发到后端服务（默认 http://localhost:8080）

配置文件：`vite.config.js`

```javascript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
      rewrite: (path) => path.replace(/^\/api/, '')
    }
  }
}
```

## 浏览器支持

- Chrome（推荐）
- Firefox
- Safari
- Edge

## License

MIT
