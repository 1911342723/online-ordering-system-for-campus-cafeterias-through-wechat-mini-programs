-- ============================================
-- 笔记评价类型字段更新 & 商家好评/差评计数字段
-- 用于实现商家红黑榜功能
-- 执行时间: 2025-11-29
-- ============================================

-- 1. 给 note 表添加 rating_type 和 order_id 字段
ALTER TABLE `note` 
ADD COLUMN `order_id` BIGINT DEFAULT NULL COMMENT '关联订单ID（防止恶意刷分）' AFTER `dish_id`,
ADD COLUMN `rating_type` VARCHAR(20) DEFAULT NULL COMMENT '评价类型: positive=好评推荐, negative=吐槽避雷' AFTER `is_featured`;

-- 2. 给 merchant 表添加好评/差评计数字段
ALTER TABLE `merchant`
ADD COLUMN `positive_count` INT DEFAULT 0 COMMENT '好评数（用于红榜统计）' AFTER `total_reviews`,
ADD COLUMN `negative_count` INT DEFAULT 0 COMMENT '差评数（用于黑榜统计）' AFTER `positive_count`;

-- 3. 创建索引优化查询
CREATE INDEX `idx_note_rating_type` ON `note` (`rating_type`);
CREATE INDEX `idx_note_merchant_id` ON `note` (`merchant_id`);
CREATE INDEX `idx_merchant_positive` ON `merchant` (`positive_count` DESC);
CREATE INDEX `idx_merchant_negative` ON `merchant` (`negative_count` DESC);

-- 4. 更新现有笔记数据，随机分配评价类型（仅用于测试）
UPDATE `note` SET `rating_type` = 'positive' WHERE `id` IN (1, 2, 4);
UPDATE `note` SET `rating_type` = 'negative' WHERE `id` = 3;

-- 5. 根据笔记更新商家的好评/差评计数
-- 统计每个商家的好评数
UPDATE `merchant` m 
SET m.`positive_count` = (
    SELECT COUNT(*) FROM `note` n 
    WHERE n.`merchant_id` = m.`id` AND n.`rating_type` = 'positive' AND n.`status` = 1
);

-- 统计每个商家的差评数
UPDATE `merchant` m 
SET m.`negative_count` = (
    SELECT COUNT(*) FROM `note` n 
    WHERE n.`merchant_id` = m.`id` AND n.`rating_type` = 'negative' AND n.`status` = 1
);

-- 6. 创建视图：商家红榜（好评数最多）
CREATE OR REPLACE VIEW `v_merchant_red_list` AS
SELECT 
    m.`id`,
    m.`name`,
    m.`image`,
    m.`description`,
    m.`rating`,
    m.`sales_count`,
    m.`positive_count`,
    m.`negative_count`,
    (m.`positive_count` - m.`negative_count`) AS `score`,
    ROUND(m.`positive_count` * 100.0 / NULLIF(m.`positive_count` + m.`negative_count`, 0), 1) AS `positive_rate`
FROM `merchant` m
WHERE m.`status` = 1 AND (m.`positive_count` + m.`negative_count`) > 0
ORDER BY m.`positive_count` DESC, `score` DESC
LIMIT 20;

-- 7. 创建视图：商家黑榜（差评数最多）
CREATE OR REPLACE VIEW `v_merchant_black_list` AS
SELECT 
    m.`id`,
    m.`name`,
    m.`image`,
    m.`description`,
    m.`rating`,
    m.`sales_count`,
    m.`positive_count`,
    m.`negative_count`,
    (m.`positive_count` - m.`negative_count`) AS `score`,
    ROUND(m.`negative_count` * 100.0 / NULLIF(m.`positive_count` + m.`negative_count`, 0), 1) AS `negative_rate`
FROM `merchant` m
WHERE m.`status` = 1 AND m.`negative_count` > 0
ORDER BY m.`negative_count` DESC, `negative_rate` DESC
LIMIT 20;

-- 完成
SELECT '笔记评价类型和商家红黑榜字段更新完成！' AS message;

