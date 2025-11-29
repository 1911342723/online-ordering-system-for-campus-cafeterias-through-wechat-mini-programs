-- ============================================
-- 社区笔记相关表
-- 执行时间: 2025-11-29
-- ============================================

-- 1. 创建笔记表
DROP TABLE IF EXISTS `note`;
CREATE TABLE `note` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '发布用户ID',
    `title` VARCHAR(200) NOT NULL COMMENT '笔记标题',
    `content` TEXT COMMENT '笔记内容',
    `images` TEXT COMMENT '图片列表（逗号分隔）',
    `cover_image` VARCHAR(500) COMMENT '封面图',
    `tags` VARCHAR(255) COMMENT '标签（逗号分隔）',
    `merchant_id` BIGINT DEFAULT NULL COMMENT '关联商家ID',
    `dish_id` BIGINT DEFAULT NULL COMMENT '关联菜品ID',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `collect_count` INT DEFAULT 0 COMMENT '收藏数',
    `comment_count` INT DEFAULT 0 COMMENT '评论数',
    `share_count` INT DEFAULT 0 COMMENT '转发数',
    `view_count` INT DEFAULT 0 COMMENT '浏览数',
    `status` INT DEFAULT 1 COMMENT '状态 0:草稿 1:已发布 2:已删除 3:审核中',
    `is_top` INT DEFAULT 0 COMMENT '是否置顶 0:否 1:是',
    `is_featured` INT DEFAULT 0 COMMENT '是否精华 0:否 1:是',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='社区笔记表';

-- 2. 创建笔记评论表
DROP TABLE IF EXISTS `note_comment`;
CREATE TABLE `note_comment` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `note_id` BIGINT NOT NULL COMMENT '笔记ID',
    `user_id` BIGINT NOT NULL COMMENT '评论用户ID',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父评论ID（0表示一级评论）',
    `reply_user_id` BIGINT DEFAULT NULL COMMENT '被回复用户ID',
    `content` TEXT NOT NULL COMMENT '评论内容',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `status` INT DEFAULT 1 COMMENT '状态 0:已删除 1:正常',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_note_id` (`note_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记评论表';

-- 3. 创建笔记点赞表
DROP TABLE IF EXISTS `note_like`;
CREATE TABLE `note_like` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `note_id` BIGINT NOT NULL COMMENT '笔记ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_note_user` (`note_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记点赞表';

-- 4. 创建笔记收藏表
DROP TABLE IF EXISTS `note_collect`;
CREATE TABLE `note_collect` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `note_id` BIGINT NOT NULL COMMENT '笔记ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_note_user` (`note_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记收藏表';

-- 5. 插入示例笔记数据
INSERT INTO `note` (`user_id`, `title`, `content`, `images`, `cover_image`, `tags`, `like_count`, `collect_count`, `comment_count`, `share_count`, `view_count`, `status`, `is_top`, `is_featured`) VALUES
(1, '一食堂的红烧肉绝绝子！真的太好吃了😭', '今天中午去一食堂吃饭，排队的人超级多！但是为了这口红烧肉一切都值得！\n\n肥而不腻，入口即化，酱汁浓郁，拌饭简直是一绝！\n\n强烈推荐大家去尝试一下！', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80', '红烧肉,一食堂,美食打卡', 234, 56, 2, 12, 1520, 1, 1, 1),
(2, '发现一家超好喝的奶茶店！', '就在二食堂旁边，叫茶颜悦色，他们家的幽兰拿铁真的绝了！\n\n奶香浓郁，茶味清香，甜度刚刚好，喝完一杯还想再来一杯！', 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=600&q=80', 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=600&q=80', '奶茶,茶颜悦色,饮品推荐', 189, 42, 5, 8, 980, 1, 0, 1),
(3, '川味面馆的担担面太香了！', '作为一个四川人，对担担面有着特殊的情怀。今天终于在学校找到了正宗的味道！\n\n麻辣鲜香，花生碎和芝麻酱的搭配恰到好处，面条劲道有嚼劲。', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80', '担担面,川菜,面食', 156, 38, 3, 5, 756, 1, 0, 0),
(1, '轻食沙拉减脂餐分享', '最近在减脂，发现学校的轻食沙拉真的很不错！\n\n蔬菜新鲜，鸡胸肉嫩滑，酱汁是油醋汁，热量很低但是味道很好！\n\n推荐给同样在减脂的小伙伴们～', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80', '轻食,减脂餐,健康饮食', 98, 67, 8, 15, 523, 1, 0, 0);

-- 6. 插入示例评论数据
INSERT INTO `note_comment` (`note_id`, `user_id`, `parent_id`, `reply_user_id`, `content`, `like_count`, `status`) VALUES
(1, 2, 0, NULL, '看着就很有食欲！明天去吃！', 5, 1),
(1, 3, 0, NULL, '多少钱一份呀？', 2, 1),
(1, 1, 2, 3, '12块钱一份，超值！', 1, 1),
(2, 1, 0, NULL, '他们家的声声乌龙也很好喝！', 3, 1),
(2, 4, 0, NULL, '排队太久了😭', 1, 1);

-- 完成
SELECT '笔记相关表创建完成！' AS message;

