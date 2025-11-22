-- =============================================
-- 一键更新数据库脚本
-- 解决所有表结构问题
-- =============================================

USE reggie;

-- 1. 更新user表 - 添加缺失字段
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `balance` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '账户余额（元）';
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `coupon_count` INT NOT NULL DEFAULT 0 COMMENT '优惠券数量';
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `points` INT NOT NULL DEFAULT 0 COMMENT '积分';
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间';
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `create_user` BIGINT DEFAULT NULL COMMENT '创建人';
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS `update_user` BIGINT DEFAULT NULL COMMENT '修改人';

-- 2. 创建餐厅表
CREATE TABLE IF NOT EXISTS `canteen` (
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

-- 3. 修改dish表 - 添加餐厅关联
ALTER TABLE `dish` ADD COLUMN IF NOT EXISTS `canteen_id` BIGINT DEFAULT NULL COMMENT '所属餐厅ID';

-- 4. 修改orders表 - 添加配送方式和外送费
ALTER TABLE `orders` ADD COLUMN IF NOT EXISTS `delivery_type` INT NOT NULL DEFAULT 1 COMMENT '配送方式 1:自取 2:外送';
ALTER TABLE `orders` ADD COLUMN IF NOT EXISTS `delivery_fee` DECIMAL(10,2) DEFAULT 0.00 COMMENT '配送费';
ALTER TABLE `orders` ADD COLUMN IF NOT EXISTS `canteen_id` BIGINT DEFAULT NULL COMMENT '餐厅ID';
ALTER TABLE `orders` ADD COLUMN IF NOT EXISTS `canteen_name` VARCHAR(100) DEFAULT NULL COMMENT '餐厅名称';

-- 5. 创建AI聊天历史表
CREATE TABLE IF NOT EXISTS `ai_chat_history` (
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

-- 6. 插入测试餐厅数据
INSERT IGNORE INTO `canteen` VALUES 
(1, '第一食堂', '提供多种中式菜品，价格实惠', 'canteen1.jpg', '校园东区', '0371-12345678', '07:00-21:00', 4.6, 100, 1, 1, NOW(), NOW(), NULL, NULL),
(2, '第二食堂', '清真餐厅，环境优雅', 'canteen2.jpg', '校园西区', '0371-12345679', '07:00-21:00', 4.5, 200, 1, 2, NOW(), NOW(), NULL, NULL),
(3, '第三食堂', '特色小吃，品种丰富', 'canteen3.jpg', '校园南区', '0371-12345680', '07:00-21:00', 4.7, 150, 1, 3, NOW(), NOW(), NULL, NULL);

-- 7. 将现有菜品分配到餐厅（所有菜品分配给第一食堂）
UPDATE `dish` SET `canteen_id` = 1 WHERE `canteen_id` IS NULL;

-- 8. 验证更新
SELECT '数据库更新完成！' AS message;
SELECT COUNT(*) AS user_count FROM user;
SELECT COUNT(*) AS canteen_count FROM canteen;
SELECT COUNT(*) AS dish_count FROM dish WHERE canteen_id IS NOT NULL;

