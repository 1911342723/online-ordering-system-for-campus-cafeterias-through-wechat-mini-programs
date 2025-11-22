-- 简化后的数据库更新（只保留优惠券功能）
USE reggie;

-- 1. 添加配送字段到orders表（如果还没执行）
ALTER TABLE `orders` 
ADD COLUMN `delivery_type` int(11) DEFAULT 1 COMMENT '配送方式 1:到店自取 2:商家外送' AFTER `consignee`,
ADD COLUMN `delivery_fee` decimal(10,2) DEFAULT 0.00 COMMENT '配送费' AFTER `delivery_type`,
ADD COLUMN `canteen_id` bigint(20) DEFAULT NULL COMMENT '食堂ID' AFTER `delivery_fee`,
ADD COLUMN `canteen_name` varchar(100) DEFAULT NULL COMMENT '食堂名称' AFTER `canteen_id`;

ALTER TABLE `orders` 
MODIFY COLUMN `address_book_id` bigint(20) DEFAULT NULL COMMENT '地址id';

-- 2. 创建意见反馈表
CREATE TABLE IF NOT EXISTS `feedback` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `type` varchar(20) NOT NULL COMMENT '反馈类型：bug/suggest/service/food/delivery/other',
  `content` text NOT NULL COMMENT '反馈内容',
  `images` varchar(500) DEFAULT NULL COMMENT '图片URL（多张用逗号分隔）',
  `contact` varchar(50) DEFAULT NULL COMMENT '联系方式',
  `status` int(11) DEFAULT 0 COMMENT '状态：0-待处理，1-处理中，2-已处理',
  `reply` text DEFAULT NULL COMMENT '回复内容',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='意见反馈表';

-- 3. 创建优惠券表
CREATE TABLE IF NOT EXISTS `coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '优惠券名称',
  `amount` decimal(10,2) NOT NULL COMMENT '优惠金额',
  `min_amount` decimal(10,2) NOT NULL COMMENT '最低消费金额',
  `type` varchar(20) NOT NULL COMMENT '类型：normal-普通券，newbie-新人券',
  `description` varchar(200) DEFAULT NULL COMMENT '描述',
  `total_count` int(11) NOT NULL COMMENT '总数量',
  `remain_count` int(11) NOT NULL COMMENT '剩余数量',
  `valid_days` int(11) NOT NULL COMMENT '有效天数',
  `status` int(11) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 4. 创建用户优惠券表
CREATE TABLE IF NOT EXISTS `user_coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `coupon_id` bigint(20) NOT NULL COMMENT '优惠券ID',
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '状态：0-未使用，1-已使用，2-已过期',
  `used_time` datetime DEFAULT NULL COMMENT '使用时间',
  `order_id` bigint(20) DEFAULT NULL COMMENT '使用的订单ID',
  `expire_time` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL COMMENT '获得时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 5. 插入初始优惠券数据
INSERT INTO `coupon` (`name`, `amount`, `min_amount`, `type`, `description`, `total_count`, `remain_count`, `valid_days`, `status`, `create_time`, `update_time`) VALUES
('新人专享券', 10.00, 30.00, 'newbie', '新用户首单专享', 1000, 1000, 30, 1, NOW(), NOW()),
('满减优惠券20-5', 5.00, 20.00, 'normal', '全场通用', 500, 500, 15, 1, NOW(), NOW()),
('满减优惠券50-10', 10.00, 50.00, 'normal', '全场通用', 500, 500, 15, 1, NOW(), NOW()),
('满减优惠券100-20', 20.00, 100.00, 'normal', '全场通用', 500, 500, 15, 1, NOW(), NOW());

