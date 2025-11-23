# 智慧食堂后端服务 (Backend)

基于 Spring Boot 开发的智慧食堂后端系统，提供 RESTful API 接口，支撑管理端、商家端和小程序端的业务运行。

## 技术栈

- **开发语言**：Java 8+
- **核心框架**：Spring Boot 2.4.5
- **持久层框架**：MyBatis Plus 3.4.2
- **数据库**：MySQL 5.7+
- **数据库连接池**：Druid 1.1.23
- **工具库**：Lombok, FastJSON, Apache Commons
- **身份认证**：JWT (JSON Web Token)
- **API 文档**：Swagger / Knife4j (可选集成)

## 核心功能

- **用户认证**：支持 C 端用户手机号登录/注册，B 端员工/商家账号密码登录。
- **权限拦截**：基于 Filter 的登录状态检查和权限控制。
- **业务模块**：
  - **员工/用户管理**：账号的增删改查与状态控制。
  - **菜品/套餐管理**：完整的餐饮商品管理逻辑。
  - **订单处理**：订单创建、支付、状态流转、取消等全生命周期管理。
  - **购物车**：基于数据库的购物车实现。
  - **推荐算法**：实现协同过滤、内容推荐等算法逻辑。
- **公共服务**：
  - **文件上传**：支持图片上传与下载。
  - **消息推送**：WebSocket 消息推送 (用于商家接单)。

## 项目结构

```
backend/src/main/java/com/java_project/reggie/
├── common/        # 公共组件 (全局异常处理、统一返回结果 R、自定义异常)
├── config/        # 配置类 (WebMvc 配置、MyBatis Plus 配置等)
├── controller/    # 控制器层 (处理 HTTP 请求)
├── dto/           # 数据传输对象 (用于层间数据传输)
├── entity/        # 实体类 (对应数据库表)
├── filter/        # 过滤器 (登录校验 LoginCheckFilter)
├── mapper/        # 数据访问层 (MyBatis Mapper 接口)
├── service/       # 业务逻辑层接口
│   └── impl/      # 业务逻辑层实现
└── utils/         # 工具类 (SMS 工具、JWT 工具等)
```

## 数据库配置

配置文件位于 `src/main/resources/application.yml`。

主要配置项：
- `spring.datasource`：数据库连接信息 (URL, Username, Password)
- `server.port`：服务端口 (默认 8080)
- `reggie.path`：图片上传存储路径

## 运行环境

- JDK 1.8+
- Maven 3.6+
- MySQL 5.7+
