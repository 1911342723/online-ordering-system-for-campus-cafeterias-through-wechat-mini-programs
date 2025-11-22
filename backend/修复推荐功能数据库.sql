-- =============================================
-- 修复推荐功能数据库脚本
-- 解决 500 错误：Unknown column 'category_id' in 'field list'
-- =============================================

USE reggie;

-- 1. 检查并创建 user_preference 表（如果不存在）
CREATE TABLE IF NOT EXISTS `user_preference` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品ID',
  `preference_score` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '喜好分数（0-100）',
  `order_count` int DEFAULT '0' COMMENT '订单次数',
  `last_order_time` datetime DEFAULT NULL COMMENT '最后订单时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_dish` (`user_id`, `dish_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_preference_score` (`preference_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户喜好表';

-- 2. 检查并创建 user_browse_history 表（如果不存在）
CREATE TABLE IF NOT EXISTS `user_browse_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品ID',
  `canteen_id` bigint DEFAULT NULL COMMENT '餐厅ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `browse_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
  `stay_duration` int DEFAULT '0' COMMENT '停留时长（秒）',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_dish_id` (`dish_id`),
  KEY `idx_browse_time` (`browse_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户浏览历史表';

-- 3. 添加 category_id 字段到 user_preference 表（如果字段不存在）
-- 注意：MySQL 不支持 IF NOT EXISTS 添加列，需要使用存储过程或忽略错误
SET @query = (SELECT IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'user_preference' 
     AND COLUMN_NAME = 'category_id') = 0,
    'ALTER TABLE `user_preference` ADD COLUMN `category_id` bigint DEFAULT NULL COMMENT ''分类ID'' AFTER `user_id`',
    'SELECT ''Column category_id already exists in user_preference'' AS message'
));

PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. 验证表结构
SELECT '推荐功能数据库修复完成！' AS message;
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_COMMENT 
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME IN ('user_preference', 'user_browse_history')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 5. 验证现有数据
SELECT COUNT(*) AS user_preference_count FROM user_preference;
SELECT COUNT(*) AS user_browse_history_count FROM user_browse_history;

