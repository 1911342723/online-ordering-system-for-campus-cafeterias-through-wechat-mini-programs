-- ============================================
-- 修复数据库缺失字段（Docker部署自动执行）
-- 执行时间: 2026-03-17
-- 问题描述: 
--   1. merchant表缺少positive_count、negative_count、wechat_group_qrcode字段
--   2. dish表缺少stock字段
--   3. update_merchant_and_food_category.sql中的字段也需要补充
-- ============================================

-- ====== 修复 merchant 表 ======

-- 添加好评数字段（用于红榜统计）
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `positive_count` INT DEFAULT 0 COMMENT '好评数（用于红榜统计）' AFTER `total_reviews`;

-- 添加差评数字段（用于黑榜统计）
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `negative_count` INT DEFAULT 0 COMMENT '差评数（用于黑榜统计）' AFTER `positive_count`;

-- 添加微信社群二维码字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `wechat_group_qrcode` VARCHAR(500) DEFAULT NULL COMMENT '微信社群二维码图片URL' AFTER `negative_count`;

-- 添加商家标签字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `tags` VARCHAR(255) DEFAULT NULL COMMENT '商家标签（逗号分隔）' AFTER `wechat_group_qrcode`;

-- 添加优惠信息字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `promo` VARCHAR(100) DEFAULT NULL COMMENT '优惠信息' AFTER `tags`;

-- 添加配送时间字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `delivery_time` INT DEFAULT 20 COMMENT '配送时间（分钟）' AFTER `promo`;

-- 添加配送费字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `delivery_fee` INT DEFAULT 0 COMMENT '配送费（分）' AFTER `delivery_time`;

-- 添加起送价字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `min_order_amount` INT DEFAULT 0 COMMENT '起送价（分）' AFTER `delivery_fee`;

-- 添加营业开始时间字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `open_time` TIME DEFAULT '07:00:00' COMMENT '营业开始时间' AFTER `min_order_amount`;

-- 添加营业结束时间字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `close_time` TIME DEFAULT '22:00:00' COMMENT '营业结束时间' AFTER `open_time`;

-- 添加是否新店字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `is_new` INT DEFAULT 0 COMMENT '是否为新店 0:否 1:是' AFTER `close_time`;

-- 添加美食分类ID字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `food_category_id` BIGINT DEFAULT NULL COMMENT '美食分类ID' AFTER `is_new`;

-- ====== 修复 dish 表 ======

-- 添加库存字段
ALTER TABLE `dish`
ADD COLUMN IF NOT EXISTS `stock` INT DEFAULT NULL COMMENT '库存数量' AFTER `description`;

-- ====== 创建 food_category 表（如果不存在）======

CREATE TABLE IF NOT EXISTS `food_category` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `code` VARCHAR(50) NOT NULL COMMENT '分类标识',
    `name` VARCHAR(100) NOT NULL COMMENT '分类名称',
    `icon` VARCHAR(50) DEFAULT NULL COMMENT '分类图标',
    `bg_color` VARCHAR(20) DEFAULT '#FEF3C7' COMMENT '背景颜色',
    `keyword` VARCHAR(100) DEFAULT NULL COMMENT '搜索关键词',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `status` INT DEFAULT 1 COMMENT '状态 0:禁用 1:启用',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='美食分类表';

-- 插入默认美食分类数据（忽略已存在的）
INSERT IGNORE INTO `food_category` (`code`, `name`, `icon`, `bg_color`, `keyword`, `sort`, `status`) VALUES
('bbq', '烧烤', '🍢', '#FEF3C7', '烧烤', 1, 1),
('night', '夜宵', '🌙', '#E0E7FF', '夜宵', 2, 1),
('noodle', '面食', '🍜', '#FCE7F3', '面', 3, 1),
('rice', '盖饭', '🍚', '#D1FAE5', '饭', 4, 1),
('hotpot', '火锅', '🍲', '#FEE2E2', '火锅', 5, 1),
('snack', '小吃', '🥟', '#FEF9C3', '小吃', 6, 1),
('drink', '饮品', '🧋', '#CFFAFE', '饮品', 7, 1),
('dessert', '甜品', '🍰', '#FCE7F3', '甜品', 8, 1),
('western', '西餐', '🍔', '#FFEDD5', '西餐', 9, 1),
('healthy', '轻食', '🥗', '#DCFCE7', '轻食', 10, 1),
('sichuan', '川菜', '🌶️', '#FEE2E2', '川菜', 11, 1),
('cantonese', '粤菜', '🥢', '#FEF3C7', '粤菜', 12, 1),
('japanese', '日料', '🍣', '#FECACA', '日料', 13, 1),
('korean', '韩餐', '🍱', '#E0E7FF', '韩餐', 14, 1),
('breakfast', '早餐', '🥐', '#FEF3C7', '早餐', 15, 1);

-- 完成
SELECT '数据库字段修复完成！' AS message;
