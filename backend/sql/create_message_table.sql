-- ============================================
-- 消息表创建脚本
-- 执行时间: 2025-11-29
-- ============================================

-- 创建消息表
CREATE TABLE IF NOT EXISTS `message` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `user_id` BIGINT NOT NULL COMMENT '接收用户ID',
  `from_user_id` BIGINT DEFAULT NULL COMMENT '发送用户ID（系统消息为空）',
  `type` VARCHAR(20) NOT NULL COMMENT '消息类型：like=点赞, comment=评论, collect=收藏, system=系统',
  `content` VARCHAR(500) DEFAULT NULL COMMENT '消息内容',
  `note_id` BIGINT DEFAULT NULL COMMENT '关联笔记ID',
  `is_read` TINYINT DEFAULT 0 COMMENT '是否已读 0:未读 1:已读',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_from_user_id` (`from_user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- 插入一些测试数据
INSERT INTO `message` (`user_id`, `from_user_id`, `type`, `content`, `note_id`, `is_read`) VALUES
(1, 2, 'like', '赞了你的笔记', 1, 0),
(1, 3, 'comment', '评论了你的笔记：太棒了！', 1, 0),
(1, NULL, 'system', '欢迎来到校园美食平台！', NULL, 0);

SELECT '消息表创建完成！' AS message;

