-- ====================================================================
-- 智慧食堂餐饮系统 完整初始化 SQL 脚本
-- 包含了所有基础表、修复表、扩展表结构的创建语句及部分测试数据
-- ====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 地址管理表 (address_book)
-- ----------------------------
DROP TABLE IF EXISTS `address_book`;
CREATE TABLE `address_book`  (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `consignee` varchar(50) NOT NULL COMMENT '收货人',
  `sex` varchar(2) COMMENT '性别 0 女 1 男',
  `phone` varchar(11) NOT NULL COMMENT '手机号',
  `province_code` varchar(12) COMMENT '省级区划编号',
  `province_name` varchar(32) COMMENT '省级名称',
  `city_code` varchar(12) COMMENT '市级区划编号',
  `city_name` varchar(32) COMMENT '市级名称',
  `district_code` varchar(12) COMMENT '区级区划编号',
  `district_name` varchar(32) COMMENT '区级名称',
  `detail` varchar(200) COMMENT '详细地址',
  `label` varchar(100) COMMENT '标签',
  `is_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT '默认 0 否 1是',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '地址管理';

-- ----------------------------
-- 2. AI聊天历史表 (ai_chat_history)
-- ----------------------------
DROP TABLE IF EXISTS `ai_chat_history`;
CREATE TABLE `ai_chat_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role` varchar(20) NOT NULL COMMENT '角色：user用户/ai助手',
  `content` text NOT NULL COMMENT '消息内容',
  `dishes` text COMMENT '推荐菜品JSON（如果有）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_create_time`(`create_time`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = 'AI聊天历史表';

-- ----------------------------
-- 3. 系统/活动公告表 (announcement)
-- ----------------------------
DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) NOT NULL COMMENT '公告标题',
  `content` text NOT NULL COMMENT '公告内容',
  `type` int NOT NULL DEFAULT 1 COMMENT '公告类型：1-系统公告，2-活动公告，3-紧急通知',
  `priority` int NOT NULL DEFAULT 0 COMMENT '优先级：0-普通，1-重要，2-紧急',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-已下架，1-已发布',
  `start_time` datetime COMMENT '开始时间',
  `end_time` datetime COMMENT '结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint COMMENT '创建人',
  `update_user` bigint COMMENT '更新人',
  PRIMARY KEY (`id`),
  INDEX `idx_status`(`status`),
  INDEX `idx_priority`(`priority`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '公告表';

-- ----------------------------
-- 4. 食堂表 (canteen)
-- ----------------------------
DROP TABLE IF EXISTS `canteen`;
CREATE TABLE `canteen`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '食堂名称',
  `description` varchar(500) COMMENT '食堂描述',
  `image` varchar(200) COMMENT '食堂图片',
  `address` varchar(200) COMMENT '食堂地址',
  `phone` varchar(20) COMMENT '联系电话',
  `business_hours` varchar(100) COMMENT '营业时间',
  `rating` decimal(3, 2) DEFAULT 5.00 COMMENT '评分',
  `distance` int DEFAULT 0 COMMENT '距离',
  `status` int DEFAULT 1 COMMENT '状态 0:停业 1:营业',
  `sort` int DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint COMMENT '创建人',
  `update_user` bigint COMMENT '更新人',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '食堂表';

INSERT INTO `canteen` VALUES (1, '第一食堂', '历史最悠久，风味最齐全', 'https://example.com/canteen1.jpg', '校园一区中心', '010-12345678', '06:00-22:00', 4.80, 0, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1);

-- ----------------------------
-- 5. 食堂配置表 (canteen_config)
-- ----------------------------
DROP TABLE IF EXISTS `canteen_config`;
CREATE TABLE `canteen_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `canteen_id` bigint NOT NULL COMMENT '食堂ID',
  `is_teacher_only` int DEFAULT 0 COMMENT '是否仅限教师 0:否 1:是',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '食堂配置表';

-- ----------------------------
-- 6. 分类表 (category)
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` bigint NOT NULL COMMENT '主键',
  `type` int COMMENT '类型 1 菜品分类 2 套餐分类',
  `name` varchar(64) NOT NULL COMMENT '分类名称',
  `sort` int NOT NULL DEFAULT 0 COMMENT '顺序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_category_name` (`name`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '菜品及套餐分类';

-- ----------------------------
-- 7. 优惠券表 (coupon)
-- ----------------------------
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '优惠券名称',
  `type` int NOT NULL DEFAULT 1 COMMENT '类型：1-满减券，2-折扣券，3-无门槛券',
  `amount` decimal(10,2) NOT NULL COMMENT '优惠金额或折扣（折扣券：85代表8.5折）',
  `min_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '最低消费门槛（0表示无门槛）',
  `merchant_id` bigint COMMENT '所属商家ID（空表示平台通用券）',
  `total_count` int NOT NULL DEFAULT 0 COMMENT '发行总数量（-1表示不限制）',
  `remain_count` int NOT NULL DEFAULT 0 COMMENT '剩余数量',
  `start_time` datetime NOT NULL COMMENT '生效时间',
  `end_time` datetime NOT NULL COMMENT '过期时间',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-下架，1-正常',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint COMMENT '创建人',
  `update_user` bigint COMMENT '更新人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- ----------------------------
-- 8. 菜品表 (dish)
-- ----------------------------
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(64) NOT NULL COMMENT '菜品名称',
  `category_id` bigint NOT NULL COMMENT '菜品分类id',
  `merchant_id` bigint COMMENT '商家ID（窗口）',
  `price` decimal(10, 2) DEFAULT NULL COMMENT '菜品价格',
  `code` varchar(64) NOT NULL COMMENT '商品码',
  `image` varchar(200) NOT NULL COMMENT '图片',
  `description` varchar(400) DEFAULT NULL COMMENT '描述信息',
  `stock` int DEFAULT NULL COMMENT '库存数量',
  `status` int NOT NULL DEFAULT 1 COMMENT '0 停售 1 起售',
  `sort` int NOT NULL DEFAULT 0 COMMENT '顺序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_dish_name` (`name`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '菜品管理';

-- ----------------------------
-- 9. 菜品口味关系表 (dish_flavor)
-- ----------------------------
DROP TABLE IF EXISTS `dish_flavor`;
CREATE TABLE `dish_flavor`  (
  `id` bigint NOT NULL COMMENT '主键',
  `dish_id` bigint NOT NULL COMMENT '菜品',
  `name` varchar(64) NOT NULL COMMENT '口味名称',
  `value` varchar(500) DEFAULT NULL COMMENT '口味数据list',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '菜品口味关系表';

-- ----------------------------
-- 10. 员工信息表 (employee)
-- ----------------------------
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(32) NOT NULL COMMENT '姓名',
  `username` varchar(32) NOT NULL COMMENT '用户名',
  `password` varchar(64) NOT NULL COMMENT '密码',
  `phone` varchar(11) NOT NULL COMMENT '手机号',
  `sex` varchar(2) NOT NULL COMMENT '性别',
  `id_number` varchar(18) NOT NULL COMMENT '身份证号',
  `type` int DEFAULT 2 COMMENT '员工类型 1:管理员 2:商家管理员 3:普通员工',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态 0:禁用，1:正常',
  `merchant_id` bigint DEFAULT NULL COMMENT '关联的商家ID',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '员工信息';

INSERT INTO `employee` (`id`, `name`, `username`, `password`, `phone`, `sex`, `id_number`, `type`, `status`, `create_time`, `update_time`, `create_user`, `update_user`) VALUES (1, '管理员', 'admin', 'e10adc3949ba59abbe56e057f20f883e', '13812312312', '1', '110101199001010001', 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1);

-- ----------------------------
-- 11. 商家入驻反馈表 (feedback)
-- ----------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '意见反馈id',
  `user_id` bigint NOT NULL COMMENT '用户ID（关联user表）',
  `user_name` varchar(50) NOT NULL COMMENT '用户姓名',
  `user_phone` varchar(20) NOT NULL COMMENT '联系电话',
  `text` text NOT NULL COMMENT '反馈内容',
  `reply` text COMMENT '管理员回复内容',
  `status` int NOT NULL DEFAULT 0 COMMENT '处理状态 0:未处理，1:已处理',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '商家入驻和意见反馈表';

-- ----------------------------
-- 12. 美食分类表 (food_category) - 首页分类
-- ----------------------------
DROP TABLE IF EXISTS `food_category`;
CREATE TABLE `food_category` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `code` VARCHAR(50) NOT NULL COMMENT '分类标识（如：bbq, noodle, rice）',
    `name` VARCHAR(100) NOT NULL COMMENT '分类名称（如：烧烤、面食、盖饭）',
    `icon` VARCHAR(50) DEFAULT NULL COMMENT '分类图标（emoji或图片URL）',
    `bg_color` VARCHAR(20) DEFAULT '#FEF3C7' COMMENT '背景颜色（十六进制）',
    `keyword` VARCHAR(100) DEFAULT NULL COMMENT '搜索关键词',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `status` INT DEFAULT 1 COMMENT '状态 0:禁用 1:启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='美食分类表';

INSERT IGNORE INTO `food_category` (`code`, `name`, `icon`, `bg_color`, `keyword`, `sort`, `status`) VALUES
('bbq', '烧烤', '🍢', '#FEF3C7', '烧烤', 1, 1),
('night', '夜宵', '🌙', '#E0E7FF', '夜宵', 2, 1),
('noodle', '面食', '🍜', '#FCE7F3', '面', 3, 1),
('rice', '盖饭', '🍚', '#D1FAE5', '饭', 4, 1),
('hotpot', '火锅', '🍲', '#FEE2E2', '火锅', 5, 1),
('snack', '小吃', '🥟', '#FEF9C3', '小吃', 6, 1),
('drink', '饮品', '🧋', '#CFFAFE', '饮品', 7, 1),
('dessert', '甜品', '🍰', '#FCE7F3', '甜品', 8, 1);

-- ----------------------------
-- 13. 商家表 (merchant)
-- ----------------------------
DROP TABLE IF EXISTS `merchant`;
CREATE TABLE `merchant`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `canteen_id` bigint NOT NULL COMMENT '所属食堂ID',
  `name` varchar(100) NOT NULL COMMENT '商家名称',
  `window_number` varchar(20) DEFAULT NULL COMMENT '窗口号',
  `contact` varchar(50) DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `description` varchar(500) DEFAULT NULL COMMENT '商家简介',
  `image` varchar(200) DEFAULT NULL COMMENT '商家图片',
  `employee_id` bigint DEFAULT NULL COMMENT '关联员工ID（登录账号）',
  `application_id` bigint DEFAULT NULL COMMENT '关联的申请ID',
  `avg_price` decimal(10, 2) DEFAULT NULL COMMENT '人均消费',
  `rating` decimal(3, 2) DEFAULT 5.00 COMMENT '评分(0-5)',
  `sales_count` int DEFAULT 0 COMMENT '月销量',
  `total_reviews` int DEFAULT 0 COMMENT '总评价数',
  `positive_count` int DEFAULT 0 COMMENT '好评数',
  `negative_count` int DEFAULT 0 COMMENT '差评数',
  `wechat_group_qrcode` varchar(500) DEFAULT NULL COMMENT '微信社群二维码图片URL',
  `tags` varchar(255) DEFAULT NULL COMMENT '商家标签（逗号分隔）',
  `promo` varchar(100) DEFAULT NULL COMMENT '优惠信息',
  `delivery_time` int DEFAULT 20 COMMENT '配送时间（分钟）',
  `delivery_fee` int DEFAULT 0 COMMENT '配送费（分）',
  `min_order_amount` int DEFAULT 0 COMMENT '起送价（分）',
  `open_time` time DEFAULT '07:00:00' COMMENT '营业开始时间',
  `close_time` time DEFAULT '22:00:00' COMMENT '营业结束时间',
  `is_new` int DEFAULT 0 COMMENT '是否为新店 0:否 1:是',
  `food_category_id` bigint DEFAULT NULL COMMENT '美食分类ID',
  `sort` int DEFAULT 0 COMMENT '排序',
  `status` int DEFAULT 1 COMMENT '状态 0:停业 1:营业 2:待审核',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_canteen_id`(`canteen_id`),
  INDEX `idx_employee_id`(`employee_id`),
  INDEX `idx_status`(`status`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '商家表（窗口）';

-- ----------------------------
-- 14. 商家公告表 (merchant_announcement)
-- ----------------------------
DROP TABLE IF EXISTS `merchant_announcement`;
CREATE TABLE `merchant_announcement`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `title` varchar(100) NOT NULL COMMENT '公告标题',
  `content` text NOT NULL COMMENT '公告内容',
  `type` int NOT NULL DEFAULT 1 COMMENT '类型：1-日常通知，2-活动促销，3-放假通知，4-营业异常',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-隐藏，1-显示',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `start_time` datetime COMMENT '生效起始时间',
  `end_time` datetime COMMENT '生效结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  INDEX `idx_merchant_id`(`merchant_id`),
  INDEX `idx_status`(`status`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '商家公告表';

-- ----------------------------
-- 15. 商家入驻申请表 (merchant_application)
-- ----------------------------
DROP TABLE IF EXISTS `merchant_application`;
CREATE TABLE `merchant_application`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '申请用户ID',
  `merchant_name` varchar(100) NOT NULL COMMENT '店铺名称',
  `contact_name` varchar(50) NOT NULL COMMENT '联系人姓名',
  `contact_phone` varchar(20) NOT NULL COMMENT '联系电话',
  `id_card_front` varchar(200) NOT NULL COMMENT '身份证正面图URL',
  `id_card_back` varchar(200) NOT NULL COMMENT '身份证反面图URL',
  `business_license` varchar(200) NOT NULL COMMENT '营业执照URL',
  `food_safety_cert` varchar(200) COMMENT '食品安全许可证URL',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态：0-待审核 1-已通过 2-已驳回',
  `reject_reason` varchar(500) COMMENT '驳回原因',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_status`(`status`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '商家入驻申请表';

-- ----------------------------
-- 16. 商家配置表 (merchant_settings)
-- ----------------------------
DROP TABLE IF EXISTS `merchant_settings`;
CREATE TABLE `merchant_settings`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `auto_accept_order` int DEFAULT 0 COMMENT '自动接单 0:关闭 1:开启',
  `min_order_amount` decimal(10, 2) DEFAULT 0 COMMENT '起送价（元）',
  `packing_fee_per_item` decimal(10, 2) DEFAULT 0 COMMENT '单件包装费（元）',
  `delivery_fee` decimal(10, 2) DEFAULT 0 COMMENT '配送费（元）',
  `delivery_range` int DEFAULT 3000 COMMENT '配送范围（米）',
  `notice` varchar(500) COMMENT '商家公告',
  `business_status` int DEFAULT 1 COMMENT '营业状态 0:休息中 1:营业中',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_merchant_id` (`merchant_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '商家设置表';

-- ----------------------------
-- 17. 消息表 (message)
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `user_id` BIGINT NOT NULL COMMENT '接收用户ID',
  `from_user_id` BIGINT DEFAULT NULL COMMENT '发送用户ID（系统消息为空）',
  `type` VARCHAR(20) NOT NULL COMMENT '消息类型：like=点赞, comment=评论, collect=收藏, system=系统',
  `content` VARCHAR(500) DEFAULT NULL COMMENT '消息内容',
  `note_id` BIGINT DEFAULT NULL COMMENT '关联笔记ID',
  `is_read` TINYINT DEFAULT 0 COMMENT '是否已读 0:未读 1:已读',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_from_user_id` (`from_user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- ----------------------------
-- 18. 社区笔记表 (note)
-- ----------------------------
DROP TABLE IF EXISTS `note`;
CREATE TABLE `note` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '发布用户ID',
    `title` VARCHAR(200) NOT NULL COMMENT '笔记标题',
    `content` TEXT COMMENT '笔记内容',
    `images` TEXT COMMENT '图片列表（逗号分隔）',
    `cover_image` VARCHAR(500) COMMENT '封面图',
    `tags` VARCHAR(255) COMMENT '标签（逗号分隔）',
    `merchant_id` BIGINT DEFAULT NULL COMMENT '关联商家ID',
    `dish_id` BIGINT DEFAULT NULL COMMENT '关联菜品ID',
    `order_id` BIGINT DEFAULT NULL COMMENT '关联订单ID（防止恶意刷分）',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `collect_count` INT DEFAULT 0 COMMENT '收藏数',
    `comment_count` INT DEFAULT 0 COMMENT '评论数',
    `share_count` INT DEFAULT 0 COMMENT '转发数',
    `view_count` INT DEFAULT 0 COMMENT '浏览数',
    `status` INT DEFAULT 1 COMMENT '状态 0:草稿 1:已发布 2:已删除 3:审核中',
    `is_top` INT DEFAULT 0 COMMENT '是否置顶 0:否 1:是',
    `is_featured` INT DEFAULT 0 COMMENT '是否精华 0:否 1:是',
    `rating_type` VARCHAR(20) DEFAULT NULL COMMENT '评价类型: positive=好评推荐, negative=吐槽避雷',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区笔记表';

-- ----------------------------
-- 19. 笔记评论表 (note_comment)
-- ----------------------------
DROP TABLE IF EXISTS `note_comment`;
CREATE TABLE `note_comment` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `note_id` BIGINT NOT NULL COMMENT '笔记ID',
    `user_id` BIGINT NOT NULL COMMENT '评论用户ID',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父评论ID（0表示一级评论）',
    `reply_user_id` BIGINT DEFAULT NULL COMMENT '被回复用户ID',
    `content` TEXT NOT NULL COMMENT '评论内容',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `status` INT DEFAULT 1 COMMENT '状态 0:已删除 1:正常',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_note_id` (`note_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='笔记评论表';

-- ----------------------------
-- 20. 笔记点赞表 (note_like)
-- ----------------------------
DROP TABLE IF EXISTS `note_like`;
CREATE TABLE `note_like` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `note_id` BIGINT NOT NULL COMMENT '笔记ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_note_user` (`note_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='笔记点赞表';

-- ----------------------------
-- 21. 笔记收藏表 (note_collect)
-- ----------------------------
DROP TABLE IF EXISTS `note_collect`;
CREATE TABLE `note_collect` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `note_id` BIGINT NOT NULL COMMENT '笔记ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_note_user` (`note_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='笔记收藏表';

-- ----------------------------
-- 22. 订单表 (orders)
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint NOT NULL COMMENT '主键',
  `number` varchar(50) COMMENT '订单号',
  `status` int NOT NULL DEFAULT 1 COMMENT '订单状态 1待付款，2待派送，3已派送，4已完成，5已取消',
  `user_id` bigint NOT NULL COMMENT '下单用户',
  `address_book_id` bigint NOT NULL COMMENT '地址id',
  `order_time` datetime NOT NULL COMMENT '下单时间',
  `checkout_time` datetime DEFAULT NULL COMMENT '结账时间',
  `pay_method` int NOT NULL DEFAULT 1 COMMENT '支付方式 1微信,2支付宝',
  `amount` decimal(10, 2) NOT NULL COMMENT '实收金额',
  `remark` varchar(100) DEFAULT NULL COMMENT '备注',
  `phone` varchar(255) DEFAULT NULL COMMENT '联系电话',
  `address` varchar(255) DEFAULT NULL COMMENT '详细地址',
  `user_name` varchar(255) DEFAULT NULL COMMENT '用户姓名',
  `consignee` varchar(255) DEFAULT NULL COMMENT '收货人',
  `merchant_id` bigint DEFAULT NULL COMMENT '所属商家ID',
  `estimated_delivery_time` datetime DEFAULT NULL COMMENT '预计送达时间',
  `delivery_status` int DEFAULT 0 COMMENT '配送状态 0待分配 1骑士已接单 2配送中 3已送达',
  `canteen_id` bigint DEFAULT NULL COMMENT '所属食堂ID',
  `coupon_id` bigint DEFAULT NULL COMMENT '使用的优惠券ID',
  `discount_amount` decimal(10, 2) DEFAULT 0.00 COMMENT '优惠金额',
  PRIMARY KEY (`id`),
  INDEX `idx_merchant_id`(`merchant_id`),
  INDEX `idx_canteen_id`(`canteen_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '订单表';

-- ----------------------------
-- 23. 订单明细表 (order_detail)
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) COMMENT '名字',
  `image` varchar(100) COMMENT '图片',
  `order_id` bigint NOT NULL COMMENT '订单id',
  `dish_id` bigint COMMENT '菜品id',
  `setmeal_id` bigint COMMENT '套餐id',
  `dish_flavor` varchar(50) COMMENT '口味',
  `number` int NOT NULL DEFAULT 1 COMMENT '数量',
  `amount` decimal(10, 2) NOT NULL COMMENT '单价',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '订单明细表';

-- ----------------------------
-- 24. 订单评价表 (order_review)
-- ----------------------------
DROP TABLE IF EXISTS `order_review`;
CREATE TABLE `order_review`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '评价用户ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `rating` int NOT NULL DEFAULT 5 COMMENT '评分（1-5）',
  `content` varchar(500) COMMENT '评价内容',
  `images` varchar(500) COMMENT '评价图片',
  `reply` varchar(500) COMMENT '商家回复',
  `reply_time` datetime COMMENT '回复时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_order_id` (`order_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '订单评价表';

-- ----------------------------
-- 25. 套餐表 (setmeal)
-- ----------------------------
DROP TABLE IF EXISTS `setmeal`;
CREATE TABLE `setmeal`  (
  `id` bigint NOT NULL COMMENT '主键',
  `category_id` bigint NOT NULL COMMENT '菜系id',
  `name` varchar(64) NOT NULL COMMENT '套餐名称',
  `price` decimal(10, 2) NOT NULL COMMENT '套餐价格',
  `status` int DEFAULT NULL COMMENT '状态 0:停用 1:启用',
  `code` varchar(32) DEFAULT NULL COMMENT '编码',
  `description` varchar(512) DEFAULT NULL COMMENT '描述信息',
  `image` varchar(255) DEFAULT NULL COMMENT '图片',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_setmeal_name` (`name`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '套餐';

-- ----------------------------
-- 26. 套餐菜品关系表 (setmeal_dish)
-- ----------------------------
DROP TABLE IF EXISTS `setmeal_dish`;
CREATE TABLE `setmeal_dish`  (
  `id` bigint NOT NULL COMMENT '主键',
  `setmeal_id` varchar(32) NOT NULL COMMENT '套餐id',
  `dish_id` varchar(32) NOT NULL COMMENT '菜品id',
  `name` varchar(32) DEFAULT NULL COMMENT '菜品名称 （冗余字段）',
  `price` decimal(10, 2) DEFAULT NULL COMMENT '菜品单价（冗余字段）',
  `copies` int NOT NULL COMMENT '菜品份数',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '套餐菜品关系';

-- ----------------------------
-- 27. 购物车表 (shopping_cart)
-- ----------------------------
DROP TABLE IF EXISTS `shopping_cart`;
CREATE TABLE `shopping_cart`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) COMMENT '名称',
  `image` varchar(100) COMMENT '图片',
  `user_id` bigint NOT NULL COMMENT '主键',
  `dish_id` bigint COMMENT '菜品id',
  `setmeal_id` bigint COMMENT '套餐id',
  `dish_flavor` varchar(50) COMMENT '口味',
  `number` int NOT NULL DEFAULT 1 COMMENT '数量',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '购物车';

-- ----------------------------
-- 28. 系统配置表 (system_config)
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(100) NOT NULL COMMENT '配置键（例如：app.name）',
  `config_value` text NOT NULL COMMENT '配置值',
  `config_type` varchar(20) DEFAULT 'string' COMMENT '数据类型：string, boolean, integer, json 等',
  `group_name` varchar(50) DEFAULT 'basic' COMMENT '配置分组',
  `description` varchar(255) DEFAULT NULL COMMENT '配置描述',
  `status` int DEFAULT 1 COMMENT '状态 0:禁用 1:启用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全局系统配置表';

-- ----------------------------
-- 29. 用户表 (user)
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) COMMENT '姓名',
  `phone` varchar(100) NOT NULL COMMENT '手机号',
  `user_type` tinyint DEFAULT 1 COMMENT '用户类型 1:学生 2:教师 3:普通用户',
  `id_card` varchar(18) COMMENT '身份证号',
  `real_name` varchar(50) COMMENT '真实姓名',
  `teacher_verified` tinyint DEFAULT 0 COMMENT '教师认证状态 0:未认证 1:待审核 2:已认证 3:已拒绝',
  `sex` varchar(2) COMMENT '性别',
  `id_number` varchar(18) COMMENT '身份证号',
  `avatar` varchar(500) COMMENT '头像',
  `status` int DEFAULT 1 COMMENT '状态 0:禁用，1:正常',
  `balance` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '账户余额（元）',
  `coupon_count` int NOT NULL DEFAULT 0 COMMENT '优惠券数量',
  `signature` varchar(100) COMMENT '个性签名',
  `exp` int DEFAULT 0 COMMENT '经验值',
  `post_count` int DEFAULT 0 COMMENT '发帖数量',
  `collect_count` int DEFAULT 0 COMMENT '收藏数量',
  `like_count` int DEFAULT 0 COMMENT '获赞数量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint,
  `update_user` bigint,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '用户信息';

-- ----------------------------
-- 30. 用户浏览历史表 (user_browse_history)
-- ----------------------------
DROP TABLE IF EXISTS `user_browse_history`;
CREATE TABLE `user_browse_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品ID',
  `canteen_id` bigint DEFAULT NULL COMMENT '餐厅ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `browse_time` datetime NOT NULL COMMENT '浏览时间',
  `stay_duration` int DEFAULT 0 COMMENT '停留时长（秒）',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_dish_id`(`dish_id`),
  INDEX `idx_browse_time`(`browse_time`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '用户浏览历史表';

-- ----------------------------
-- 31. 用户优惠券关系表 (user_coupon)
-- ----------------------------
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `coupon_id` bigint NOT NULL COMMENT '优惠券ID',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态：0-未使用，1-已使用，2-已过期',
  `used_time` datetime DEFAULT NULL COMMENT '使用时间',
  `order_id` bigint DEFAULT NULL COMMENT '订单ID',
  `expire_time` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_coupon_id`(`coupon_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '用户优惠券表';

-- ----------------------------
-- 32. 用户收藏菜品表 (user_favorite_dish)
-- ----------------------------
DROP TABLE IF EXISTS `user_favorite_dish`;
CREATE TABLE `user_favorite_dish`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `dish_id` bigint NOT NULL COMMENT '菜品ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_dish`(`user_id`, `dish_id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_dish_id`(`dish_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '用户收藏菜品表';

-- ----------------------------
-- 33. 用户收藏商家表 (user_favorite_merchant)
-- ----------------------------
DROP TABLE IF EXISTS `user_favorite_merchant`;
CREATE TABLE `user_favorite_merchant`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_merchant`(`user_id`, `merchant_id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_merchant_id`(`merchant_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '用户收藏商家表';

-- ----------------------------
-- 34. 用户反馈表 (user_feedback)
-- ----------------------------
DROP TABLE IF EXISTS `user_feedback`;
CREATE TABLE `user_feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `type` tinyint NOT NULL COMMENT '反馈类型 1:功能建议 2:投诉 3:其他',
  `merchant_id` bigint DEFAULT NULL COMMENT '关联商家ID（可选）',
  `content` varchar(1000) NOT NULL COMMENT '反馈内容',
  `images` varchar(1000) DEFAULT NULL COMMENT '反馈图片（逗号分隔）',
  `contact` varchar(100) DEFAULT NULL COMMENT '联系方式',
  `status` tinyint DEFAULT 1 COMMENT '处理状态 1:待处理 2:处理中 3:已完成',
  `reply` varchar(1000) DEFAULT NULL COMMENT '回复内容',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`),
  INDEX `idx_merchant_id`(`merchant_id`),
  INDEX `idx_status`(`status`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '用户反馈表';

-- ----------------------------
-- 35. 用户饮食偏好表 (user_preference)
-- ----------------------------
DROP TABLE IF EXISTS `user_preference`;
CREATE TABLE `user_preference`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品ID',
  `preference_score` decimal(10,2) DEFAULT 0.00 COMMENT '喜好分数',
  `order_count` int DEFAULT 0 COMMENT '订单次数',
  `last_order_time` datetime DEFAULT NULL COMMENT '最后订单时间',
  `preference_type` varchar(50) COMMENT '偏好类型：taste/category/price',
  `preference_value` varchar(200) COMMENT '偏好值',
  `confidence` decimal(5, 2) DEFAULT 0.00 COMMENT '置信度（0-100）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id`(`user_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COMMENT = '用户饮食偏好表';

SET FOREIGN_KEY_CHECKS = 1;
