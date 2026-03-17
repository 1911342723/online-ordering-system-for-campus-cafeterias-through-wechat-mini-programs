-- ============================================
-- 修复商家表缺失字段
-- 执行时间: 2026-03-17
-- 问题描述: merchant表缺少positive_count、negative_count、wechat_group_qrcode字段
--          导致MyBatis-Plus查询时生成包含这些列的SQL，引发500错误
-- ============================================

-- 添加好评数字段（用于红榜统计）
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `positive_count` INT DEFAULT 0 COMMENT '好评数（用于红榜统计）' AFTER `total_reviews`;

-- 添加差评数字段（用于黑榜统计）
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `negative_count` INT DEFAULT 0 COMMENT '差评数（用于黑榜统计）' AFTER `positive_count`;

-- 添加微信社群二维码字段
ALTER TABLE `merchant`
ADD COLUMN IF NOT EXISTS `wechat_group_qrcode` VARCHAR(500) DEFAULT NULL COMMENT '微信社群二维码图片URL' AFTER `negative_count`;

-- 完成
SELECT '商家表字段修复完成！' AS message;
