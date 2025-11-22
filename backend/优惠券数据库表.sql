-- 优惠券表
CREATE TABLE IF NOT EXISTS `coupon` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '优惠券名称',
  `type` int NOT NULL COMMENT '类型：1-满减券，2-折扣券，3-通用券',
  `condition_amount` decimal(10,2) DEFAULT NULL COMMENT '满足金额条件（元）',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '优惠金额（元）',
  `discount_rate` decimal(3,2) DEFAULT NULL COMMENT '折扣率（0.1-1.0）',
  `total_count` int NOT NULL COMMENT '发放总数量',
  `remain_count` int NOT NULL COMMENT '剩余数量',
  `valid_days` int NOT NULL COMMENT '有效天数',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态：0-已下架，1-上架中',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 用户优惠券表
CREATE TABLE IF NOT EXISTS `user_coupon` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `coupon_id` bigint NOT NULL COMMENT '优惠券ID',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态：0-未使用，1-已使用，2-已过期',
  `used_time` datetime DEFAULT NULL COMMENT '使用时间',
  `expire_time` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL COMMENT '领取时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_coupon_id` (`coupon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 插入一些测试优惠券数据
INSERT INTO `coupon` (`id`, `name`, `type`, `condition_amount`, `discount_amount`, `discount_rate`, `total_count`, `remain_count`, `valid_days`, `status`, `create_time`, `update_time`) 
VALUES 
(1, '满50减10元', 1, 50.00, 10.00, NULL, 1000, 1000, 30, 1, NOW(), NOW()),
(2, '全场8折券', 2, NULL, NULL, 0.80, 500, 500, 15, 1, NOW(), NOW()),
(3, '新人券5元', 1, 0.00, 5.00, NULL, 10000, 10000, 7, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

