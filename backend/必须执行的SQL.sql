-- ==========================================
-- 【必须执行】否则系统无法正常运行
-- 请逐条执行，忽略"字段已存在"的错误
-- ==========================================

USE reggie;

-- ========== 第1步：修复user表 ==========
ALTER TABLE `user` ADD COLUMN `balance` DECIMAL(10,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `user` ADD COLUMN `coupon_count` INT NOT NULL DEFAULT 0;
ALTER TABLE `user` ADD COLUMN `points` INT NOT NULL DEFAULT 0;
ALTER TABLE `user` ADD COLUMN `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE `user` ADD COLUMN `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
ALTER TABLE `user` ADD COLUMN `create_user` BIGINT DEFAULT NULL;
ALTER TABLE `user` ADD COLUMN `update_user` BIGINT DEFAULT NULL;

-- ========== 第2步：创建餐厅表（重要！） ==========
DROP TABLE IF EXISTS `canteen`;
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

-- ========== 第3步：插入餐厅数据（必须！） ==========
INSERT INTO `canteen` VALUES 
(1, '第一食堂', '提供多种中式菜品，价格实惠', 'canteen1.jpg', '校园东区', '0371-12345678', '07:00-21:00', 4.6, 100, 1, 1, NOW(), NOW(), NULL, NULL),
(2, '第二食堂', '清真餐厅，环境优雅', 'canteen2.jpg', '校园西区', '0371-12345679', '07:00-21:00', 4.5, 200, 1, 2, NOW(), NOW(), NULL, NULL),
(3, '第三食堂', '特色小吃，品种丰富', 'canteen3.jpg', '校园南区', '0371-12345680', '07:00-21:00', 4.7, 150, 1, 3, NOW(), NOW(), NULL, NULL);

-- ========== 第4步：修复dish表 ==========
ALTER TABLE `dish` ADD COLUMN `canteen_id` BIGINT DEFAULT NULL;
UPDATE `dish` SET `canteen_id` = 1 WHERE `canteen_id` IS NULL OR `canteen_id` = 0;

-- ========== 第5步：修复orders表 ==========
ALTER TABLE `orders` ADD COLUMN `delivery_type` INT NOT NULL DEFAULT 1;
ALTER TABLE `orders` ADD COLUMN `delivery_fee` DECIMAL(10,2) DEFAULT 0.00;
ALTER TABLE `orders` ADD COLUMN `canteen_id` BIGINT DEFAULT NULL;
ALTER TABLE `orders` ADD COLUMN `canteen_name` VARCHAR(100) DEFAULT NULL;

-- ========== 第6步：创建AI聊天历史表 ==========
DROP TABLE IF EXISTS `ai_chat_history`;
CREATE TABLE `ai_chat_history` (
  `id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `content` TEXT NOT NULL,
  `dishes` TEXT DEFAULT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== 验证结果 ==========
SELECT 'canteen表记录数' AS 项目, COUNT(*) AS 数量 FROM canteen
UNION ALL
SELECT 'dish表已分配餐厅', COUNT(*) FROM dish WHERE canteen_id IS NOT NULL
UNION ALL
SELECT 'user表字段数', COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema='reggie' AND table_name='user';

SELECT '✅ 执行完成！现在重启后端！' AS 提示;

