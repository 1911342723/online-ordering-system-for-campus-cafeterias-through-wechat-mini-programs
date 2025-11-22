-- 创建意见反馈表
USE reggie;

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

