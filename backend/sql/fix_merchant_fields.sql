-- ============================================
-- 修复数据库缺失字段（Docker部署自动执行）
-- 执行时间: 2026-03-17
-- 问题描述: 
--   1. merchant表缺少positive_count、negative_count、wechat_group_qrcode等字段
--   2. dish表缺少stock字段
--   3. merchant_announcement表缺少create_user、update_user字段
-- ============================================

-- ====== 修复 merchant 表 ======

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `positive_count` INT DEFAULT 0 COMMENT '好评数' AFTER `total_reviews`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `negative_count` INT DEFAULT 0 COMMENT '差评数' AFTER `positive_count`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `wechat_group_qrcode` VARCHAR(500) DEFAULT NULL COMMENT '微信社群二维码' AFTER `negative_count`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `tags` VARCHAR(255) DEFAULT NULL COMMENT '商家标签' AFTER `wechat_group_qrcode`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `promo` VARCHAR(100) DEFAULT NULL COMMENT '优惠信息' AFTER `tags`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `delivery_time` INT DEFAULT 20 COMMENT '配送时间' AFTER `promo`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `delivery_fee` INT DEFAULT 0 COMMENT '配送费' AFTER `delivery_time`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `min_order_amount` INT DEFAULT 0 COMMENT '起送价' AFTER `delivery_fee`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `open_time` TIME DEFAULT '07:00:00' COMMENT '营业开始时间' AFTER `min_order_amount`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `close_time` TIME DEFAULT '22:00:00' COMMENT '营业结束时间' AFTER `open_time`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `is_new` INT DEFAULT 0 COMMENT '是否新店' AFTER `close_time`;

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `food_category_id` BIGINT DEFAULT NULL COMMENT '美食分类ID' AFTER `is_new`;

-- ====== 修复 dish 表 ======

ALTER TABLE `dish`
ADD COLUMN IF NOT EXISTS `stock` INT DEFAULT NULL COMMENT '库存数量' AFTER `description`;

-- ====== 修复 merchant_announcement 表 ======

ALTER TABLE `merchant_announcement`
ADD COLUMN IF NOT EXISTS `create_user` BIGINT DEFAULT NULL COMMENT '创建人' AFTER `update_time`;

ALTER TABLE `merchant_announcement`
ADD COLUMN IF NOT EXISTS `update_user` BIGINT DEFAULT NULL COMMENT '更新人' AFTER `create_user`;

-- ====== 创建 food_category 表（如不存在）======

CREATE TABLE IF NOT EXISTS `food_category` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `code` VARCHAR(50) NOT NULL COMMENT '分类标识',
    `name` VARCHAR(100) NOT NULL COMMENT '分类名称',
    `icon` VARCHAR(50) DEFAULT NULL COMMENT '分类图标',
    `bg_color` VARCHAR(20) DEFAULT '#FEF3C7' COMMENT '背景颜色',
    `keyword` VARCHAR(100) DEFAULT NULL COMMENT '搜索关键词',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `status` INT DEFAULT 1 COMMENT '状态',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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

-- ====== 修复 merchant 表 - 添加 application_id（若不存在） ======

ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `application_id` BIGINT DEFAULT NULL COMMENT '关联的申请ID' AFTER `employee_id`;

SELECT '数据库字段修复完成！' AS message;
