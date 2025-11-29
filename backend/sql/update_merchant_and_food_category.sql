-- ============================================
-- 更新商家表结构和创建美食分类表
-- 执行时间: 2025-11-29
-- ============================================

-- 1. 创建美食分类表
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

-- 2. 插入默认美食分类数据
INSERT INTO `food_category` (`code`, `name`, `icon`, `bg_color`, `keyword`, `sort`, `status`) VALUES
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

-- 3. 更新商家表，添加新字段
-- 先检查字段是否存在，如果不存在则添加
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `tags` VARCHAR(255) DEFAULT NULL COMMENT '商家标签（逗号分隔）' AFTER `total_reviews`,
ADD COLUMN IF NOT EXISTS `promo` VARCHAR(100) DEFAULT NULL COMMENT '优惠信息' AFTER `tags`,
ADD COLUMN IF NOT EXISTS `delivery_time` INT DEFAULT 20 COMMENT '配送时间（分钟）' AFTER `promo`,
ADD COLUMN IF NOT EXISTS `delivery_fee` INT DEFAULT 0 COMMENT '配送费（分）' AFTER `delivery_time`,
ADD COLUMN IF NOT EXISTS `min_order_amount` INT DEFAULT 0 COMMENT '起送价（分）' AFTER `delivery_fee`,
ADD COLUMN IF NOT EXISTS `open_time` TIME DEFAULT '07:00:00' COMMENT '营业开始时间' AFTER `min_order_amount`,
ADD COLUMN IF NOT EXISTS `close_time` TIME DEFAULT '22:00:00' COMMENT '营业结束时间' AFTER `open_time`,
ADD COLUMN IF NOT EXISTS `is_new` INT DEFAULT 0 COMMENT '是否为新店 0:否 1:是' AFTER `close_time`,
ADD COLUMN IF NOT EXISTS `food_category_id` BIGINT DEFAULT NULL COMMENT '美食分类ID' AFTER `is_new`;

-- 4. 添加外键约束（可选，根据实际情况决定是否添加）
-- ALTER TABLE `merchant` ADD CONSTRAINT `fk_merchant_food_category` 
-- FOREIGN KEY (`food_category_id`) REFERENCES `food_category`(`id`) ON DELETE SET NULL;

-- 5. 更新现有商家数据，设置一些默认标签和分类
-- 为已有商家随机分配分类和标签（仅作示例）
UPDATE `merchant` SET 
    `tags` = CASE 
        WHEN `name` LIKE '%烧烤%' THEN '烧烤,夜宵,人气爆棚'
        WHEN `name` LIKE '%面%' THEN '面食,川菜,经济实惠'
        WHEN `name` LIKE '%饭%' THEN '盖饭,快餐,分量足'
        WHEN `name` LIKE '%奶茶%' OR `name` LIKE '%茶%' THEN '奶茶,饮品,网红店'
        WHEN `name` LIKE '%火锅%' THEN '火锅,麻辣,好评如潮'
        WHEN `name` LIKE '%沙拉%' OR `name` LIKE '%轻食%' THEN '轻食,健康,低卡'
        ELSE '美食,好评'
    END,
    `promo` = CASE 
        WHEN RAND() > 0.7 THEN '满30减10'
        WHEN RAND() > 0.5 THEN '新客立减5元'
        WHEN RAND() > 0.3 THEN '第二杯半价'
        ELSE NULL
    END,
    `delivery_time` = FLOOR(15 + RAND() * 15),
    `is_new` = CASE WHEN RAND() > 0.8 THEN 1 ELSE 0 END
WHERE `tags` IS NULL;

-- 6. 插入一些示例商家数据（如果表为空）
INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '老王烧烤', '正宗炭火烧烤，夜宵首选', NULL, 4.9, 2300, '烧烤,夜宵,人气爆棚', '满30减10', 20, 0, 
    (SELECT id FROM food_category WHERE code = 'bbq'), 1, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '老王烧烤');

INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '川味面馆', '地道川味，麻辣鲜香', NULL, 4.8, 1800, '面食,川菜,经济实惠', NULL, 15, 0,
    (SELECT id FROM food_category WHERE code = 'noodle'), 1, 2
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '川味面馆');

INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '一品香盖饭', '分量十足，经济实惠', NULL, 4.7, 1500, '盖饭,快餐,分量足', '新客立减5元', 18, 1,
    (SELECT id FROM food_category WHERE code = 'rice'), 1, 3
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '一品香盖饭');

INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '茶颜悦色', '新式茶饮，颜值与口感并存', NULL, 4.9, 3200, '奶茶,饮品,网红店', '第二杯半价', 10, 0,
    (SELECT id FROM food_category WHERE code = 'drink'), 1, 4
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '茶颜悦色');

INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '麻辣小火锅', '一人食火锅，麻辣过瘾', NULL, 4.6, 980, '火锅,麻辣,好评如潮', NULL, 25, 0,
    (SELECT id FROM food_category WHERE code = 'hotpot'), 1, 5
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '麻辣小火锅');

INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '轻食沙拉', '健康轻食，低卡美味', NULL, 4.5, 650, '轻食,健康,低卡', '满25减3', 12, 1,
    (SELECT id FROM food_category WHERE code = 'healthy'), 1, 6
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '轻食沙拉');

INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '日式拉面屋', '正宗日式拉面，浓郁骨汤', NULL, 4.8, 1200, '日料,拉面,正宗', NULL, 20, 0,
    (SELECT id FROM food_category WHERE code = 'japanese'), 1, 7
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '日式拉面屋');

INSERT INTO `merchant` (`canteen_id`, `name`, `description`, `image`, `rating`, `sales_count`, `tags`, `promo`, `delivery_time`, `is_new`, `food_category_id`, `status`, `sort`)
SELECT 1, '韩式炸鸡', '韩式炸鸡配啤酒，完美搭配', NULL, 4.7, 890, '韩餐,炸鸡,啤酒', '满50减15', 22, 0,
    (SELECT id FROM food_category WHERE code = 'korean'), 1, 8
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE name = '韩式炸鸡');

-- 完成
SELECT '数据库更新完成！' AS message;

