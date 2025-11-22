-- 公告表
CREATE TABLE IF NOT EXISTS `announcement` (
  `id` bigint NOT NULL COMMENT '主键',
  `title` varchar(100) NOT NULL COMMENT '公告标题',
  `content` text NOT NULL COMMENT '公告内容',
  `type` int NOT NULL DEFAULT '1' COMMENT '公告类型：1-系统公告，2-活动公告，3-紧急通知',
  `priority` int NOT NULL DEFAULT '0' COMMENT '优先级：0-普通，1-重要，2-紧急',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态：0-已下架，1-已发布',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告表';

-- 用户浏览历史表（用于推荐算法）
CREATE TABLE IF NOT EXISTS `user_browse_history` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品ID',
  `canteen_id` bigint DEFAULT NULL COMMENT '餐厅ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `browse_time` datetime NOT NULL COMMENT '浏览时间',
  `stay_duration` int DEFAULT '0' COMMENT '停留时长（秒）',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_dish_id` (`dish_id`),
  KEY `idx_browse_time` (`browse_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户浏览历史表';

-- 用户喜好表（用于推荐算法）
CREATE TABLE IF NOT EXISTS `user_preference` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品ID',
  `preference_score` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '喜好分数（0-100）',
  `order_count` int DEFAULT '0' COMMENT '订单次数',
  `last_order_time` datetime DEFAULT NULL COMMENT '最后订单时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_dish` (`user_id`, `dish_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_preference_score` (`preference_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户喜好表';

-- 插入示例公告数据
INSERT INTO `announcement` (`id`, `title`, `content`, `type`, `priority`, `status`, `start_time`, `end_time`, `create_time`, `update_time`) 
VALUES 
(1, '欢迎使用智慧餐饮系统', '尊敬的用户，欢迎使用我们的智慧餐饮系统！您可以在线点餐、查看菜品、使用优惠券等功能。祝您用餐愉快！', 1, 0, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), NOW(), NOW()),
(2, '新用户福利来袭', '新注册用户可领取5元优惠券，满50元即可使用！机不可失，快来领取吧！', 2, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NOW(), NOW()),
(3, '周末特惠活动', '本周末全场8折优惠！更有多款特色菜品限时供应，敬请期待！', 2, 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), NOW(), NOW())
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`);

