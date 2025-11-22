-- 快速执行SQL - 直接复制到MySQL执行
USE reggie;

-- 添加user表字段
ALTER TABLE `user` ADD COLUMN `balance` DECIMAL(10,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `user` ADD COLUMN `coupon_count` INT NOT NULL DEFAULT 0;
ALTER TABLE `user` ADD COLUMN `points` INT NOT NULL DEFAULT 0;
ALTER TABLE `user` ADD COLUMN `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `user` ADD COLUMN `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
ALTER TABLE `user` ADD COLUMN `create_user` BIGINT DEFAULT NULL;
ALTER TABLE `user` ADD COLUMN `update_user` BIGINT DEFAULT NULL;

-- 创建餐厅表
CREATE TABLE `canteen` (
  `id` BIGINT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(500) DEFAULT NULL,
  `image` VARCHAR(200) DEFAULT NULL,
  `address` VARCHAR(200) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `business_hours` VARCHAR(100) DEFAULT NULL,
  `rating` DECIMAL(3,1) DEFAULT 4.5,
  `distance` INT DEFAULT 0,
  `status` INT NOT NULL DEFAULT 1,
  `sort` INT NOT NULL DEFAULT 0,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_user` BIGINT DEFAULT NULL,
  `update_user` BIGINT DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 添加dish表字段
ALTER TABLE `dish` ADD COLUMN `canteen_id` BIGINT DEFAULT NULL;

-- 添加orders表字段
ALTER TABLE `orders` ADD COLUMN `delivery_type` INT NOT NULL DEFAULT 1;
ALTER TABLE `orders` ADD COLUMN `delivery_fee` DECIMAL(10,2) DEFAULT 0.00;
ALTER TABLE `orders` ADD COLUMN `canteen_id` BIGINT DEFAULT NULL;
ALTER TABLE `orders` ADD COLUMN `canteen_name` VARCHAR(100) DEFAULT NULL;

-- 创建AI聊天历史表
CREATE TABLE `ai_chat_history` (
  `id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `content` TEXT NOT NULL,
  `dishes` TEXT DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入餐厅数据
INSERT INTO `canteen` VALUES 
(1, '第一食堂', '提供多种中式菜品，价格实惠', 'canteen1.jpg', '校园东区', '0371-12345678', '07:00-21:00', 4.6, 100, 1, 1, NOW(), NOW(), NULL, NULL),
(2, '第二食堂', '清真餐厅，环境优雅', 'canteen2.jpg', '校园西区', '0371-12345679', '07:00-21:00', 4.5, 200, 1, 2, NOW(), NOW(), NULL, NULL),
(3, '第三食堂', '特色小吃，品种丰富', 'canteen3.jpg', '校园南区', '0371-12345680', '07:00-21:00', 4.7, 150, 1, 3, NOW(), NOW(), NULL, NULL);

-- 将菜品分配到第一食堂
UPDATE `dish` SET `canteen_id` = 1 WHERE `canteen_id` IS NULL;

SELECT '✅ 数据库更新完成！' AS message;

