# 🍔 Online Catering System | 校园智慧餐饮系统

一个功能完善的校园智慧餐饮管理系统，支持在线点餐、AI智能推荐、优惠券管理、配送服务等功能。

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-8+-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.4+-green.svg)](https://spring.io/projects/spring-boot)
[![WeChat MiniProgram](https://img.shields.io/badge/WeChat-MiniProgram-brightgreen.svg)](https://developers.weixin.qq.com/miniprogram/dev/framework/)

---

## ✨ 主要功能

### 🎨 前端功能（小程序 + 管理后台）

#### 📱 微信小程序（用户端）
- **首页**：轮播图、系统公告、今日推荐、AI智能推荐入口、食堂列表
- **菜品浏览**：分类筛选、菜品详情、口味选择
- **购物车**：批量管理、结算
- **订单管理**：下单、支付、查看订单状态（待付款/制作中/配送中/已完成）
- **AI智能推荐**：基于用户历史订单和浏览行为的个性化推荐
- **优惠券系统**：领取优惠券、使用优惠券
- **地址管理**：多地址管理、默认地址设置
- **个人中心**：钱包余额、充值、意见反馈、设置

#### 💼 管理后台（Vue3 + Element Plus）
- **员工管理**：员工账号管理、权限控制
- **分类管理**：菜品分类、套餐分类
- **菜品管理**：菜品的增删改查、口味配置、上下架
- **套餐管理**：套餐组合、价格设置
- **订单管理**：订单查看、状态更新、配送管理
- **数据统计**：销售数据、营业额统计

### 🔧 后端功能

- **用户系统**：手机号登录、JWT认证、Session管理
- **菜品系统**：菜品CRUD、分类管理、口味管理
- **订单系统**：订单创建、状态流转、配送方式选择
- **支付系统**：钱包支付、余额管理
- **优惠券系统**：优惠券发放、核销
- **推荐算法**：
  - 基于协同过滤的个性化推荐
  - 基于内容的推荐（分类偏好）
  - 热度推荐（销量、评分）
  - 时间衰减算法
- **AI推荐**：集成豆包AI，智能对话推荐菜品
- **公告系统**：系统公告发布、优先级管理

---

## 🛠️ 技术栈

### 后端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Java | 8+ | 开发语言 |
| Spring Boot | 2.4.5 | 后端框架 |
| MyBatis Plus | 3.4.2 | ORM框架 |
| MySQL | 5.7+ | 数据库 |
| Druid | 1.1.23 | 数据库连接池 |
| Lombok | 1.18.20 | 简化Java代码 |
| FastJSON | 1.2.76 | JSON解析 |
| JWT | - | 用户认证 |

### 前端技术

#### 小程序端
- **框架**：微信小程序原生框架
- **语言**：JavaScript
- **样式**：WXSS（CSS扩展）
- **UI设计**：Premium Vibrant 配色方案

#### 管理后台
- **框架**：Vue 3
- **UI组件库**：Element Plus
- **构建工具**：Vite
- **HTTP客户端**：Axios

---

## 📦 项目结构

```
Online-Catering-System/
├── backend/                    # 后端项目
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/java_project/reggie/
│   │       │       ├── common/        # 公共类（返回结果、异常处理等）
│   │       │       ├── config/        # 配置类（AI、JWT等）
│   │       │       ├── controller/    # 控制器层
│   │       │       ├── dto/           # 数据传输对象
│   │       │       ├── entity/        # 实体类
│   │       │       ├── filter/        # 过滤器（登录、JWT认证）
│   │       │       ├── mapper/        # MyBatis映射器
│   │       │       ├── service/       # 业务逻辑层
│   │       │       └── utils/         # 工具类
│   │       └── resources/
│   │           ├── application.yml    # 配置文件
│   │           ├── food_img/          # 菜品图片
│   │           └── front/             # 静态资源
│   ├── db.sql                         # 初始数据库脚本
│   ├── 一键更新数据库.sql             # 数据库更新脚本
│   ├── 修复推荐功能数据库.sql         # 推荐功能修复脚本
│   └── pom.xml                        # Maven配置
│
├── frontend/
│   ├── admin/                         # 管理后台（Vue3）
│   │   ├── src/
│   │   │   ├── api/                   # API接口
│   │   │   ├── components/            # 组件
│   │   │   ├── router/                # 路由
│   │   │   ├── styles/                # 样式
│   │   │   └── views/                 # 页面
│   │   ├── package.json
│   │   └── vite.config.js
│   │
│   └── user/                          # 用户端小程序
│       ├── pages/                     # 页面
│       │   ├── index/                 # 首页
│       │   ├── menu/                  # 菜单页
│       │   ├── cart/                  # 购物车
│       │   ├── order/                 # 订单
│       │   ├── ai/                    # AI推荐
│       │   └── user/                  # 个人中心
│       ├── utils/                     # 工具函数
│       ├── app.js
│       ├── app.json
│       └── app.wxss
│
├── .gitignore                         # Git忽略文件
└── README.md                          # 项目说明文档
```

---

## 🚀 快速开始

### 环境要求

- **JDK**：1.8 或更高
- **Maven**：3.6+
- **MySQL**：5.7 或更高
- **Node.js**：14+ (管理后台需要)
- **微信开发者工具**：最新版

### 1️⃣ 数据库配置

#### 创建数据库
```sql
CREATE DATABASE reggie DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 执行初始化脚本
```bash
# 1. 执行基础数据库脚本
mysql -u root -p reggie < backend/db.sql

# 2. 执行更新脚本（添加新功能表）
mysql -u root -p reggie < backend/一键更新数据库.sql

# 3. 修复推荐功能（可选，如果需要AI推荐功能）
mysql -u root -p reggie < backend/修复推荐功能数据库.sql
```

### 2️⃣ 后端配置与启动

#### 修改配置文件
编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/reggie?serverTimezone=Asia/Shanghai&useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&useSSL=false&allowPublicKeyRetrieval=true
    username: root       # 修改为你的MySQL用户名
    password: 123456     # 修改为你的MySQL密码

server:
  port: 8080             # 后端端口
```

#### 启动后端
```bash
cd backend
mvn clean install
mvn spring-boot:run

# 或使用启动脚本（Windows）
启动后端.bat
```

后端启动成功后访问：`http://localhost:8080`

### 3️⃣ 管理后台启动

```bash
cd frontend/admin
npm install
npm run dev

# 或使用启动脚本（Windows）
cd ../..
启动前端.bat
```

管理后台访问：`http://localhost:3000`

**默认管理员账号**：
- 用户名：`admin`
- 密码：`123456`

### 4️⃣ 微信小程序配置

1. 打开微信开发者工具
2. 导入项目，选择 `frontend/user` 目录
3. 填写 AppID（测试可选择"不使用AppID"）
4. 修改 `frontend/user/utils/config.js` 中的后端地址：
   ```javascript
   const API_BASE_URL = 'http://localhost:8080'
   ```
5. 点击"编译"即可预览

---

## 📖 功能详解

### 🤖 AI智能推荐

本系统集成了两种推荐方式：

#### 1. 基于算法的推荐（`/recommendation/today`）
- **协同过滤**：根据用户历史订单推荐相似菜品
- **内容推荐**：基于用户喜好的分类推荐
- **热度推荐**：结合菜品销量和评分
- **时间衰减**：近期订单权重更高

#### 2. AI对话推荐（集成豆包AI）
- 用户可以通过聊天方式描述需求
- AI根据用户偏好、时间、预算等推荐菜品
- 支持多轮对话，精准理解用户意图

### 💳 优惠券系统

- **发放机制**：新人券、活动券、满减券
- **使用规则**：满额使用、有效期限制
- **核销流程**：订单结算时自动计算优惠

### 📦 订单配送

支持两种配送方式：
- **到店自取**：无配送费，到店取餐
- **商家配送**：支付配送费，送餐到指定地址

---

## 🎨 UI设计亮点

### Premium Vibrant 设计主题

- **主色调**：Volcano Orange (`#FF5000`) - 活力、食欲
- **辅助色**：深灰 (`#1A1A1A`) - 高级感
- **背景色**：Cool Grey (`#F5F7FA`) - 现代、清爽
- **点缀色**：Gold (`#FFC833`) - 评分、VIP

### 视觉特点

- ✅ 圆角卡片设计，柔和美观
- ✅ 渐变按钮，视觉吸引力强
- ✅ 微妙阴影，层次分明
- ✅ 高质量图片占位符（Unsplash）
- ✅ 流畅的交互动画

---

## 🔐 安全特性

- **JWT认证**：无状态的用户身份验证
- **过滤器拦截**：登录检查、权限控制
- **SQL注入防护**：MyBatis参数化查询
- **密码加密**：MD5哈希存储
- **HTTPS支持**：生产环境加密传输

---

## 📱 系统截图

（可在此添加系统截图）

---

## 📄 开发文档

更多详细文档请查看：

- [数据库升级指南.md](数据库升级指南.md)
- [前后端联调完成情况.md](前后端联调完成情况.md)
- [订单和支付系统完整指南.md](订单和支付系统完整指南.md)
- [API使用文档.md](frontend/admin/API使用文档.md)

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 提交代码流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 📝 更新日志

### v2.0.0 (2025-11-22)
- ✨ 全新 Premium Vibrant UI设计
- ✨ AI智能推荐功能
- ✨ 优惠券系统
- ✨ 配送方式选择
- ✨ 真实数据的"今日推荐"板块
- 🐛 修复登录拦截问题
- 🐛 修复推荐功能数据库问题
- 📱 小程序UI全面优化

### v1.0.0 (2021-07-23)
- 🎉 项目初始化
- ✨ 基础点餐功能
- ✨ 订单管理
- ✨ 菜品管理

---

## 📞 联系方式

如有问题，请提交 Issue 或通过以下方式联系：

- **GitHub Issues**: [提交问题](../../issues)
- **Email**: your-email@example.com

---

## 📜 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

---

## 🙏 致谢

感谢以下开源项目和服务：

- [Spring Boot](https://spring.io/projects/spring-boot)
- [MyBatis Plus](https://baomidou.com/)
- [Element Plus](https://element-plus.org/)
- [Unsplash](https://unsplash.com/) - 高质量图片
- [豆包AI](https://www.volcengine.com/product/doubao) - AI推荐服务

---

<p align="center">
  Made with ❤️ by Your Team
</p>

