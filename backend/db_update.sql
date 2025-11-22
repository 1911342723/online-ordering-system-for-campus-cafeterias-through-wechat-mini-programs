-- =============================================
-- 数据库升级脚本 - 添加餐厅功能和用户余额系统
-- =============================================

USE reggie;

-- =============================================
-- 1. 创建餐厅表
-- =============================================
DROP TABLE IF EXISTS `canteen`;
CREATE TABLE `canteen` (
  `id` BIGINT NOT NULL COMMENT '主键',
  `name` VARCHAR(100) NOT NULL COMMENT '餐厅名称',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '餐厅描述',
  `image` VARCHAR(200) DEFAULT NULL COMMENT '餐厅图片',
  `address` VARCHAR(200) DEFAULT NULL COMMENT '餐厅地址',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  `business_hours` VARCHAR(100) DEFAULT NULL COMMENT '营业时间',
  `rating` DECIMAL(3,1) DEFAULT 4.5 COMMENT '评分',
  `distance` INT DEFAULT 0 COMMENT '距离（米）',
  `status` INT NOT NULL DEFAULT 1 COMMENT '状态 0:停业 1:营业',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` BIGINT DEFAULT NULL COMMENT '创建人',
  `update_user` BIGINT DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='餐厅信息表';

-- =============================================
-- 2. 修改菜品表 - 添加餐厅关联
-- =============================================
ALTER TABLE `dish` ADD COLUMN `canteen_id` BIGINT DEFAULT NULL COMMENT '所属餐厅ID' AFTER `category_id`;
ALTER TABLE `dish` ADD KEY `idx_canteen_id` (`canteen_id`);

-- =============================================
-- 3. 修改用户表 - 添加余额、优惠券、积分
-- =============================================
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `balance` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '账户余额（元）' AFTER `status`;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `coupon_count` INT NOT NULL DEFAULT 0 COMMENT '优惠券数量' AFTER `balance`;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `points` INT NOT NULL DEFAULT 0 COMMENT '积分' AFTER `coupon_count`;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `points`;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `create_time`;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `create_user` BIGINT DEFAULT NULL COMMENT '创建人' AFTER `update_time`;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `update_user` BIGINT DEFAULT NULL COMMENT '修改人' AFTER `create_user`;

-- =============================================
-- 4. 插入测试餐厅数据
-- =============================================
INSERT INTO `canteen` VALUES 
(1, '第一食堂', '提供各类美味佳肴，湘菜、川菜应有尽有', 
 'https://img0.baidu.com/it/u=2983909840,3644391536&fm=253&fmt=auto&app=138&f=JPEG', 
 '本部校区东侧', '010-12345678', '07:00-20:00', 4.5, 100, 1, 1, NOW(), NOW(), 1, 1),

(2, '第二食堂', '以粤菜为主，提供精致美食和营养套餐', 
 'https://img2.baidu.com/it/u=3695384729,2506865151&fm=253&fmt=auto&app=138&f=JPEG', 
 '本部校区南侧', '010-12345679', '07:00-20:00', 4.8, 200, 1, 2, NOW(), NOW(), 1, 1),

(3, '第三食堂', '美食广场，汇集各地特色小吃', 
 'https://img1.baidu.com/it/u=3636313896,2358180361&fm=253&fmt=auto&app=138&f=JPEG', 
 '本部校区北侧', '010-12345680', '07:00-21:00', 4.6, 300, 1, 3, NOW(), NOW(), 1, 1);

-- =============================================
-- 5. 更新菜品数据 - 分配到各个餐厅
-- =============================================
-- 第一食堂：湘菜（ID: 1397844263642378242）
UPDATE `dish` SET `canteen_id` = 1 WHERE `category_id` = 1397844263642378242;

-- 第二食堂：粤菜（ID: 1397844391040167938）
UPDATE `dish` SET `canteen_id` = 2 WHERE `category_id` = 1397844391040167938;

-- 第三食堂：川菜（ID: 1397844303408574465）和其他
UPDATE `dish` SET `canteen_id` = 3 WHERE `category_id` = 1397844303408574465;

-- 饮品和主食分配到第一食堂
UPDATE `dish` SET `canteen_id` = 1 WHERE `category_id` IN (1413341197421846529, 1413384954989060097) AND `canteen_id` IS NULL;

-- 其他未分配的菜品默认分配到第一食堂
UPDATE `dish` SET `canteen_id` = 1 WHERE `canteen_id` IS NULL;

-- =============================================
-- 6. 插入测试用户数据（用于测试订单）
-- =============================================
INSERT INTO `user` (`id`, `name`, `phone`, `sex`, `id_number`, `avatar`, `status`, `balance`, `coupon_count`, `points`) VALUES 
(1417012167126876162, '张三', '13800138000', '1', '110101199001010001', NULL, 1, 98.50, 3, 1280),
(1417012167126876163, '李四', '13800138001', '1', '110101199001010002', NULL, 1, 150.00, 5, 800),
(1417012167126876164, '王五', '13800138002', '0', '110101199001010003', NULL, 1, 200.00, 2, 500),
(1417012167126876165, '赵六', '13800138003', '1', '110101199001010004', NULL, 1, 50.00, 1, 200)
ON DUPLICATE KEY UPDATE 
  `balance` = VALUES(`balance`),
  `coupon_count` = VALUES(`coupon_count`),
  `points` = VALUES(`points`);

-- =============================================
-- 7. 插入测试地址数据
-- =============================================
INSERT INTO `address_book` VALUES 
('1417414526093082626', '1417012167126876162', '张三', '1', '13800138000', NULL, NULL, NULL, NULL, NULL, NULL, '学生宿舍1号楼101', '宿舍', '1', NOW(), NOW(), '1417012167126876162', '1417012167126876162', '0'),
('1417414526093082627', '1417012167126876163', '李四', '1', '13800138001', NULL, NULL, NULL, NULL, NULL, NULL, '学生宿舍2号楼201', '宿舍', '1', NOW(), NOW(), '1417012167126876163', '1417012167126876163', '0'),
('1417414526093082628', '1417012167126876164', '王五', '0', '13800138002', NULL, NULL, NULL, NULL, NULL, NULL, '学生宿舍3号楼301', '宿舍', '1', NOW(), NOW(), '1417012167126876164', '1417012167126876164', '0'),
('1417414526093082629', '1417012167126876165', '赵六', '1', '13800138003', NULL, NULL, NULL, NULL, NULL, NULL, '教师公寓A栋101', '家', '1', NOW(), NOW(), '1417012167126876165', '1417012167126876165', '0')
ON DUPLICATE KEY UPDATE 
  `consignee` = VALUES(`consignee`),
  `phone` = VALUES(`phone`);

-- =============================================
-- 8. 创建优惠券表（可选）
-- =============================================
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon` (
  `id` BIGINT NOT NULL COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `name` VARCHAR(100) NOT NULL COMMENT '优惠券名称',
  `type` INT NOT NULL DEFAULT 1 COMMENT '类型 1:满减 2:折扣 3:代金券',
  `amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '优惠金额/折扣率',
  `min_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '最低消费金额',
  `status` INT NOT NULL DEFAULT 0 COMMENT '状态 0:未使用 1:已使用 2:已过期',
  `expire_time` DATETIME DEFAULT NULL COMMENT '过期时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `use_time` DATETIME DEFAULT NULL COMMENT '使用时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 插入测试优惠券
INSERT INTO `user_coupon` VALUES 
(1, 1417012167126876162, '满30减5元', 1, 5.00, 30.00, 0, DATE_ADD(NOW(), INTERVAL 30 DAY), NOW(), NULL),
(2, 1417012167126876162, '满50减10元', 1, 10.00, 50.00, 0, DATE_ADD(NOW(), INTERVAL 30 DAY), NOW(), NULL),
(3, 1417012167126876162, '9折优惠券', 2, 0.90, 0.00, 0, DATE_ADD(NOW(), INTERVAL 30 DAY), NOW(), NULL),
(4, 1417012167126876163, '满30减5元', 1, 5.00, 30.00, 0, DATE_ADD(NOW(), INTERVAL 30 DAY), NOW(), NULL),
(5, 1417012167126876163, '满50减10元', 1, 10.00, 50.00, 0, DATE_ADD(NOW(), INTERVAL 30 DAY), NOW(), NULL);

-- =============================================
-- 9. 创建积分记录表（可选）
-- =============================================
DROP TABLE IF EXISTS `points_record`;
CREATE TABLE `points_record` (
  `id` BIGINT NOT NULL COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `points` INT NOT NULL COMMENT '积分变化（正数为增加，负数为减少）',
  `type` INT NOT NULL COMMENT '类型 1:消费获得 2:签到 3:兑换 4:过期',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '说明',
  `order_id` BIGINT DEFAULT NULL COMMENT '关联订单ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分记录表';

-- =============================================
-- 10. 创建余额变动记录表（可选）
-- =============================================
DROP TABLE IF EXISTS `balance_record`;
CREATE TABLE `balance_record` (
  `id` BIGINT NOT NULL COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '金额变化（正数为充值，负数为消费）',
  `type` INT NOT NULL COMMENT '类型 1:充值 2:消费 3:退款',
  `balance_before` DECIMAL(10,2) NOT NULL COMMENT '变动前余额',
  `balance_after` DECIMAL(10,2) NOT NULL COMMENT '变动后余额',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '说明',
  `order_id` BIGINT DEFAULT NULL COMMENT '关联订单ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='余额变动记录表';

-- =============================================
-- 11. 创建AI聊天历史表
-- =============================================
DROP TABLE IF EXISTS `ai_chat_history`;
CREATE TABLE `ai_chat_history` (
  `id` BIGINT NOT NULL COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role` VARCHAR(20) NOT NULL COMMENT '角色：user用户/ai助手',
  `content` TEXT NOT NULL COMMENT '消息内容',
  `dishes` TEXT DEFAULT NULL COMMENT '推荐菜品JSON（如果有）',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI聊天历史表';

-- =============================================
-- 完成
-- =============================================
SELECT 'Database update completed successfully!' AS message;

