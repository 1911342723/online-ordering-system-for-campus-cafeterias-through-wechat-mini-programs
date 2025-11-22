-- 为orders表添加配送相关字段
-- 执行时间：2025-11-22

USE reggie;

-- 添加配送方式字段
ALTER TABLE `orders` 
ADD COLUMN `delivery_type` int(11) DEFAULT 1 COMMENT '配送方式 1:到店自取 2:商家外送' AFTER `consignee`;

-- 添加配送费字段
ALTER TABLE `orders` 
ADD COLUMN `delivery_fee` decimal(10,2) DEFAULT 0.00 COMMENT '配送费' AFTER `delivery_type`;

-- 添加食堂ID字段
ALTER TABLE `orders` 
ADD COLUMN `canteen_id` bigint(20) DEFAULT NULL COMMENT '食堂ID' AFTER `delivery_fee`;

-- 添加食堂名称字段
ALTER TABLE `orders` 
ADD COLUMN `canteen_name` varchar(100) DEFAULT NULL COMMENT '食堂名称' AFTER `canteen_id`;

-- 修改address_book_id字段为可空（因为自取不需要地址）
ALTER TABLE `orders` 
MODIFY COLUMN `address_book_id` bigint(20) DEFAULT NULL COMMENT '地址id';

-- 查看表结构确认
DESC orders;

