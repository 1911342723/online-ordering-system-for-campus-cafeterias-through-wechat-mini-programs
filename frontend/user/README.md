# 智慧食堂微信小程序 (User)

基于微信小程序原生框架开发的 C 端用户应用，为师生提供便捷的校园餐饮服务。

## 技术栈

- **框架**：微信小程序原生框架 (MINA)
- **语言**：JavaScript (ES6+)
- **样式**：WXSS (支持 CSS 大部分特性)
- **结构**：WXML
- **配置**：JSON

## 功能模块

- **首页**：
  - 校园食堂列表展示
  - 系统公告轮播
  - 今日推荐菜品
  - AI 智能推荐入口
- **点餐**：
  - 商家菜单浏览 (支持分类锚点定位)
  - 菜品详情与口味选择
  - 购物车管理 (加购、减购、清空)
- **订单**：
  - 创建订单与支付 (模拟支付/钱包支付)
  - 订单状态实时跟踪
  - 历史订单查询
- **AI 推荐**：
  - 基于用户偏好的智能推荐
  - 对话式点餐助手
- **个人中心**：
  - 用户信息管理
  - 钱包充值与余额查询
  - 地址管理
  - 优惠券查看

## 项目结构

```
frontend/user/
├── app.js             # 全局逻辑与生命周期
├── app.json           # 全局配置 (页面路由、窗口表现、TabBar)
├── app.wxss           # 全局样式
├── project.config.json # 开发者工具配置
├── assets/            # 静态资源
│   └── icons/         # 图标文件 (PNG/SVG)
├── pages/             # 页面目录
│   ├── index/         # 首页
│   ├── menu/          # 商家菜单页
│   ├── cart/          # 购物车页
│   ├── order/         # 订单相关页
│   ├── ai/            # AI 推荐页
│   ├── user/          # 个人中心页
│   ├── address/       # 地址管理页
│   └── ...
└── utils/             # 工具类
    ├── config.js      # 配置文件 (后端 API 地址)
    ├── request.js     # 网络请求封装
    └── util.js        # 通用工具函数
```

## 配置说明

### 后端接口地址

在 `utils/config.js` 中配置后端 API 地址：

```javascript
const API_BASE_URL = 'http://localhost:8080'; // 开发环境
// const API_BASE_URL = 'https://your-prod-domain.com'; // 生产环境
```

### 图标资源

由于微信小程序 TabBar 仅支持本地图片路径，相关图标资源存放于 `assets/icons/` 目录下。
