-- ============================================
-- 用户个人信息和等级系统字段更新
-- 执行时间: 2025-11-29
-- ============================================

-- 1. 给 user 表添加新字段
ALTER TABLE `user`
ADD COLUMN `signature` VARCHAR(100) DEFAULT NULL COMMENT '个性签名' AFTER `coupon_count`,
ADD COLUMN `exp` INT DEFAULT 0 COMMENT '经验值' AFTER `signature`,
ADD COLUMN `post_count` INT DEFAULT 0 COMMENT '发帖数量' AFTER `exp`,
ADD COLUMN `collect_count` INT DEFAULT 0 COMMENT '收藏数量' AFTER `post_count`,
ADD COLUMN `like_count` INT DEFAULT 0 COMMENT '获赞数量' AFTER `collect_count`;

-- 2. 创建消息表
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '接收用户ID',
    `from_user_id` BIGINT DEFAULT NULL COMMENT '发送用户ID（系统消息为空）',
    `type` VARCHAR(20) NOT NULL COMMENT '消息类型：like=点赞, comment=评论, collect=收藏, system=系统',
    `content` VARCHAR(500) NOT NULL COMMENT '消息内容',
    `note_id` BIGINT DEFAULT NULL COMMENT '关联笔记ID',
    `is_read` TINYINT DEFAULT 0 COMMENT '是否已读 0:未读 1:已读',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_is_read` (`is_read`),
    KEY `idx_type` (`type`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';

-- 3. 创建索引优化查询
CREATE INDEX `idx_user_exp` ON `user` (`exp` DESC);

-- 4. 更新现有用户的统计数据
-- 更新发帖数
UPDATE `user` u 
SET u.`post_count` = (
    SELECT COUNT(*) FROM `note` n 
    WHERE n.`user_id` = u.`id` AND n.`status` = 1
);

-- 更新获赞数
UPDATE `user` u 
SET u.`like_count` = (
    SELECT COALESCE(SUM(n.`like_count`), 0) FROM `note` n 
    WHERE n.`user_id` = u.`id` AND n.`status` = 1
);

-- 更新收藏数
UPDATE `user` u 
SET u.`collect_count` = (
    SELECT COUNT(*) FROM `note_collect` nc 
    WHERE nc.`user_id` = u.`id`
);

-- 5. 计算初始经验值（基于现有活动）
-- 每发一篇帖子 +20 经验
-- 每获得一个赞 +2 经验
-- 每获得一个收藏 +3 经验
UPDATE `user` u 
SET u.`exp` = (u.`post_count` * 20) + (u.`like_count` * 2);

-- 6. 插入示例消息数据
INSERT INTO `message` (`user_id`, `from_user_id`, `type`, `content`, `note_id`, `is_read`) VALUES
(1, 2, 'like', '赞了你的帖子', 1, 0),
(1, 3, 'comment', '评论了你的帖子：看着就很有食欲！', 1, 0),
(1, NULL, 'system', '欢迎加入校园美食社区！发布帖子可以获得经验哦~', NULL, 1);

-- 完成
SELECT '用户个人信息和等级系统字段更新完成！' AS message;

