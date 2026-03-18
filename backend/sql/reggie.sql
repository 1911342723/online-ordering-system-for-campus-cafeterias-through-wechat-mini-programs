/*
 Navicat Premium Data Transfer

 Source Server         : 接单
 Source Server Type    : MySQL
 Source Server Version : 80044
 Source Host           : localhost:3306
 Source Schema         : reggie

 Target Server Type    : MySQL
 Target Server Version : 80044
 File Encoding         : 65001

 Date: 23/11/2025 19:04:11
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address_book
-- ----------------------------
DROP TABLE IF EXISTS `address_book`;
CREATE TABLE `address_book`  (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `consignee` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '收货人',
  `sex` tinyint NOT NULL COMMENT '性别 0 女 1 男',
  `phone` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '手机号',
  `province_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省级区划编号',
  `province_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省级名称',
  `city_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '市级区划编号',
  `city_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '市级名称',
  `district_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区级区划编号',
  `district_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区级名称',
  `detail` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '详细地址',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签',
  `is_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT '默认 0 否 1是',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '地址管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of address_book
-- ----------------------------
INSERT INTO `address_book` VALUES (1417414526093082626, 1417012167126876162, '张三', 1, '13800138000', NULL, NULL, NULL, NULL, NULL, NULL, '昌平区金燕龙办公楼', '公司', 1, '2021-07-20 17:22:12', '2021-07-20 17:26:33', 1417012167126876162, 1417012167126876162, 0);
INSERT INTO `address_book` VALUES (1417414526093082627, 1417012167126876163, '李四', 1, '13800138001', NULL, NULL, NULL, NULL, NULL, NULL, '学生宿舍2号楼201', '宿舍', 1, '2025-11-22 17:58:08', '2025-11-22 17:58:08', 1417012167126876163, 1417012167126876163, 0);
INSERT INTO `address_book` VALUES (1417414526093082628, 1417012167126876164, '王五', 0, '13800138002', NULL, NULL, NULL, NULL, NULL, NULL, '学生宿舍3号楼301', '宿舍', 1, '2025-11-22 17:58:08', '2025-11-22 17:58:08', 1417012167126876164, 1417012167126876164, 0);
INSERT INTO `address_book` VALUES (1417414526093082629, 1417012167126876165, '赵六', 1, '13800138003', NULL, NULL, NULL, NULL, NULL, NULL, '教师公寓A栋101', '家', 1, '2025-11-22 17:58:08', '2025-11-22 17:58:08', 1417012167126876165, 1417012167126876165, 0);
INSERT INTO `address_book` VALUES (1417414926166769666, 1417012167126876162, '小李', 1, '13512345678', NULL, NULL, NULL, NULL, NULL, NULL, '测试', '家', 0, '2021-07-20 17:23:47', '2021-07-20 17:23:47', 1417012167126876162, 1417012167126876162, 0);
INSERT INTO `address_book` VALUES (1992189513195323394, 1992175182684745729, '11', 1, '19906454305', '', '北京市', '', '北京市', '', '东城区', '111', '家', 1, '2025-11-22 19:12:48', '2025-11-22 19:12:48', 1992175182684745729, 1992175182684745729, 0);
INSERT INTO `address_book` VALUES (1992517235775901697, 1992198172637925377, 'Yan', 1, '19907475647', '', '北京市', '', '北京市', '', '东城区', '1', '家', 0, '2025-11-23 16:55:03', '2025-11-23 16:55:03', 1992198172637925377, 1992198172637925377, 0);

-- ----------------------------
-- Table structure for ai_chat_history
-- ----------------------------
DROP TABLE IF EXISTS `ai_chat_history`;
CREATE TABLE `ai_chat_history`  (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色：user用户/ai助手',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `dishes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '推荐菜品JSON（如果有）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI聊天历史表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_chat_history
-- ----------------------------

-- ----------------------------
-- Table structure for announcement
-- ----------------------------
DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement`  (
  `id` bigint NOT NULL COMMENT '主键',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告内容',
  `type` int NOT NULL DEFAULT 1 COMMENT '公告类型：1-系统公告，2-活动公告，3-紧急通知',
  `priority` int NOT NULL DEFAULT 0 COMMENT '优先级：0-普通，1-重要，2-紧急',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-已下架，1-已发布',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_priority`(`priority`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of announcement
-- ----------------------------
INSERT INTO `announcement` VALUES (1, '欢迎使用智慧餐饮系统', '尊敬的用户，欢迎使用我们的智慧餐饮系统！您可以在线点餐、查看菜品、使用优惠券等功能。祝您用餐愉快！', 1, 0, 1, '2025-11-22 19:50:16', '2025-12-22 19:50:16', '2025-11-22 19:50:16', '2025-11-22 19:50:16', NULL, NULL);
INSERT INTO `announcement` VALUES (2, '新用户福利来袭', '新注册用户可领取5元优惠券，满50元即可使用！机不可失，快来领取吧！', 2, 1, 1, '2025-11-22 19:50:16', '2025-11-29 19:50:16', '2025-11-22 19:50:16', '2025-11-23 16:32:39', NULL, 1);
INSERT INTO `announcement` VALUES (3, '周末特惠活动', '本周末全场8折优惠！更有多款特色菜品限时供应，敬请期待！', 2, 1, 1, '2025-11-22 19:50:16', '2025-11-25 19:50:16', '2025-11-22 19:50:16', '2025-11-22 19:50:16', NULL, NULL);

-- ----------------------------
-- Table structure for balance_record
-- ----------------------------
DROP TABLE IF EXISTS `balance_record`;
CREATE TABLE `balance_record`  (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额变化（正数为充值，负数为消费）',
  `type` int NOT NULL COMMENT '类型 1:充值 2:消费 3:退款',
  `balance_before` decimal(10, 2) NOT NULL COMMENT '变动前余额',
  `balance_after` decimal(10, 2) NOT NULL COMMENT '变动后余额',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '说明',
  `order_id` bigint NULL DEFAULT NULL COMMENT '关联订单ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '余额变动记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of balance_record
-- ----------------------------

-- ----------------------------
-- Table structure for canteen
-- ----------------------------
DROP TABLE IF EXISTS `canteen`;
CREATE TABLE `canteen`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '餐厅名称',
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '位置',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '餐厅描述',
  `image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '餐厅图片',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '餐厅地址',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `business_hours` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营业时间',
  `rating` decimal(3, 1) NULL DEFAULT 4.5 COMMENT '评分',
  `distance` int NULL DEFAULT 0 COMMENT '距离（米）',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态 0:停业 1:营业',
  `is_teacher_canteen` tinyint(1) NULL DEFAULT 0 COMMENT '是否为教师食堂：0-否，1-是',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_user` bigint NULL DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_sort`(`sort`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '餐厅信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of canteen
-- ----------------------------
INSERT INTO `canteen` VALUES (1, '第一食堂', NULL, '提供多种中式菜品，价格实惠', '0cd45fa7-fdef-4e66-b3bb-7adbadbfe496.jpg', '校园东区', '0371-12345678', '07:00-21:00', 4.6, 100, 1, 0, 1, '2025-11-22 18:22:58', '2025-11-23 17:37:42', NULL, NULL);
INSERT INTO `canteen` VALUES (2, '第二食堂', NULL, '清真餐厅，环境优雅', '29d61365-fb54-4e18-8349-51a872a668ed.jpg', '校园西区', '0371-12345679', '07:00-21:00', 4.5, 200, 1, 0, 2, '2025-11-22 18:22:58', '2025-11-23 17:37:54', NULL, NULL);
INSERT INTO `canteen` VALUES (3, '第三食堂', NULL, '特色小吃，品种丰富', 'ccd9f6cf-da48-4067-9eda-76b05c9247ea.jpg', '校园南区', '0371-12345680', '07:00-21:00', 4.7, 150, 1, 0, 3, '2025-11-22 18:22:58', '2025-11-23 17:38:03', NULL, 1992198172637925377);
INSERT INTO `canteen` VALUES (999, '教师专属食堂', NULL, '专为教职工提供的优质餐饮服务，营养均衡，环境优雅', 'teacher_canteen.jpg', '行政楼一层西侧', '0571-88888888', '07:00-20:00', 5.0, 200, 1, 0, 999, '2025-11-23 18:10:14', '2025-11-23 18:13:37', NULL, NULL);

-- ----------------------------
-- Table structure for canteen_config
-- ----------------------------
DROP TABLE IF EXISTS `canteen_config`;
CREATE TABLE `canteen_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `canteen_id` bigint NOT NULL COMMENT '食堂ID',
  `is_teacher_only` tinyint NULL DEFAULT 0 COMMENT '是否仅限教师 0:否 1:是',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_canteen_id`(`canteen_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '食堂配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of canteen_config
-- ----------------------------
INSERT INTO `canteen_config` VALUES (1, 4, 1, '2025-11-23 17:46:34', '2025-11-23 17:46:34');
INSERT INTO `canteen_config` VALUES (2, 999, 1, '2025-11-23 18:10:14', '2025-11-23 18:13:37');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` bigint NOT NULL COMMENT '主键',
  `type` int NULL DEFAULT NULL COMMENT '类型   1 菜品分类 2 套餐分类',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '分类名称',
  `sort` int NOT NULL DEFAULT 0 COMMENT '顺序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_category_name`(`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '菜品及套餐分类' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (9991, 1, '营养套餐', 1, '2025-11-23 18:16:54', '2025-11-23 18:17:44', 1, 1);
INSERT INTO `category` VALUES (9992, 1, '特色小炒', 2, '2025-11-23 18:16:54', '2025-11-23 18:17:44', 1, 1);
INSERT INTO `category` VALUES (9993, 1, '养生汤品', 3, '2025-11-23 18:16:54', '2025-11-23 18:17:44', 1, 1);
INSERT INTO `category` VALUES (9994, 1, '健康主食', 4, '2025-11-23 18:16:54', '2025-11-23 18:17:44', 1, 1);
INSERT INTO `category` VALUES (1397844263642378242, 1, '湘菜', 1, '2021-05-27 09:16:58', '2021-07-15 20:25:23', 1, 1);
INSERT INTO `category` VALUES (1397844303408574465, 1, '川菜', 2, '2021-05-27 09:17:07', '2021-06-02 14:27:22', 1, 1);
INSERT INTO `category` VALUES (1397844391040167938, 1, '粤菜', 3, '2021-05-27 09:17:28', '2021-07-09 14:37:13', 1, 1);
INSERT INTO `category` VALUES (1413341197421846529, 1, '饮品', 11, '2021-07-09 11:36:15', '2021-07-09 14:39:15', 1, 1);
INSERT INTO `category` VALUES (1413342269393674242, 2, '商务套餐', 5, '2021-07-09 11:40:30', '2021-07-09 14:43:45', 1, 1);
INSERT INTO `category` VALUES (1413384954989060097, 1, '主食', 12, '2021-07-09 14:30:07', '2021-07-09 14:39:19', 1, 1);
INSERT INTO `category` VALUES (1413386191767674881, 2, '儿童套餐', 6, '2021-07-09 14:35:02', '2021-07-09 14:39:05', 1, 1);

-- ----------------------------
-- Table structure for coupon
-- ----------------------------
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '优惠券名称',
  `amount` decimal(10, 2) NOT NULL COMMENT '优惠金额（分）',
  `min_amount` decimal(10, 2) NOT NULL COMMENT '最低消费金额（分）',
  `type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT 'normal' COMMENT '类型：normal-普通券，newbie-新人券，points-积分券',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商家ID（商家券专用）',
  `description` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '描述',
  `total_count` int NOT NULL DEFAULT 0 COMMENT '总数量',
  `remain_count` int NOT NULL DEFAULT 0 COMMENT '剩余数量',
  `valid_days` int NOT NULL DEFAULT 30 COMMENT '有效天数',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_user` bigint NULL DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '优惠券表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of coupon
-- ----------------------------
INSERT INTO `coupon` VALUES (1, '新人专享券', 1000.00, 3000.00, '1', NULL, '新用户专享，满30减10', 1000, 1000, 30, 1, '2025-11-23 18:02:02', '2025-11-23 18:02:02', NULL, NULL);
INSERT INTO `coupon` VALUES (2, '满减优惠券', 500.00, 2000.00, '1', NULL, '全场通用，满20减5', 500, 500, 30, 1, '2025-11-23 18:02:02', '2025-11-23 18:02:02', NULL, NULL);
INSERT INTO `coupon` VALUES (3, '商家专属券', 800.00, 2500.00, '2', 1, '本店专用，满25减8', 200, 200, 15, 1, '2025-11-23 18:02:02', '2025-11-23 18:02:02', NULL, NULL);

-- ----------------------------
-- Table structure for dish
-- ----------------------------
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '菜品名称',
  `category_id` bigint NOT NULL COMMENT '菜品分类id',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '所属商家ID',
  `canteen_id` bigint NULL DEFAULT NULL COMMENT '所属餐厅ID',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '菜品价格',
  `code` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '商品码',
  `image` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '图片',
  `description` varchar(400) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '描述信息',
  `status` int NOT NULL DEFAULT 1 COMMENT '0 停售 1 起售',
  `sort` int NOT NULL DEFAULT 0 COMMENT '顺序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_dish_name`(`name`) USING BTREE,
  INDEX `idx_canteen_id`(`canteen_id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '菜品管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dish
-- ----------------------------
INSERT INTO `dish` VALUES (99901, '营养早餐套餐', 9991, 999, 999, 1500.00, 'D99901', 'breakfast_set.jpg', '牛奶+鸡蛋+全麦面包+水果', 1, 1, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99902, '精品商务套餐A', 9991, 999, 999, 2800.00, 'D99902', 'business_set_a.jpg', '荤素搭配，三菜一汤', 1, 2, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99903, '精品商务套餐B', 9991, 999, 999, 2800.00, 'D99903', 'business_set_b.jpg', '清淡养生，四菜一汤', 1, 3, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99904, '香煎挪威鳕鱼', 9992, 999, 999, 3800.00, 'D99904', 'cod_fish.jpg', '进口深海鳕鱼，低脂高蛋白', 1, 4, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99905, '黑椒牛柳', 9992, 999, 999, 3200.00, 'D99905', 'beef_steak.jpg', '优质牛里脊，口感鲜嫩', 1, 5, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99906, '清炒有机时蔬', 9992, 999, 999, 1500.00, 'D99906', 'organic_veg.jpg', '当季新鲜有机蔬菜', 1, 6, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99907, '养生乌鸡汤', 9993, 999, 999, 1800.00, 'D99907', 'chicken_soup.jpg', '滋补养生，暖心暖胃', 1, 7, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99908, '花胶鱼肚汤', 9993, 999, 999, 2500.00, 'D99908', 'fish_maw_soup.jpg', '美容养颜，胶原蛋白丰富', 1, 8, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99909, '杂粮饭', 9994, 999, 999, 500.00, 'D99909', 'multi_grain_rice.jpg', '五谷杂粮，健康主食', 1, 9, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (99910, '全麦馒头', 9994, 999, 999, 300.00, 'D99910', 'whole_wheat_bun.jpg', '粗纤维，助消化', 1, 10, '2025-11-23 18:17:44', '2025-11-23 18:17:44', 1, 1, 0);
INSERT INTO `dish` VALUES (1397849739276890114, '辣子鸡', 1397844263642378242, 3, 1, 7800.00, '222222222', '014d3a61-754a-42ce-91e6-ccd318cc029b.jpg', '来自鲜嫩美味的小鸡，值得一尝', 1, 0, '2021-05-27 09:38:43', '2021-05-27 09:38:43', 1, 1, 0);
INSERT INTO `dish` VALUES (1397850140982161409, '毛氏红烧肉', 1397844263642378242, 3, 1, 6800.00, '123412341234', '0ca25a1c-fff2-4a51-81e1-b985ac28f5ec.jpg', '毛氏红烧肉毛氏红烧肉，确定不来一份？', 1, 0, '2021-05-27 09:40:19', '2021-05-27 09:40:19', 1, 1, 0);
INSERT INTO `dish` VALUES (1397850392090947585, '组庵鱼翅', 1397844263642378242, 3, 1, 4800.00, '123412341234', '267ce60f-6a2b-4a43-ba29-ac635aa98071.jpg', '组庵鱼翅，看图足以表明好吃程度', 1, 0, '2021-05-27 09:41:19', '2021-05-27 09:41:19', 1, 1, 0);
INSERT INTO `dish` VALUES (1397850851245600769, '霸王别姬', 1397844263642378242, 3, 1, 12800.00, '123412341234', '847efe88-16ed-4e5d-a03c-506ea6013dff.jpg', '还有什么比霸王别姬更美味的呢？', 1, 0, '2021-05-27 09:43:08', '2021-05-27 09:43:08', 1, 1, 0);
INSERT INTO `dish` VALUES (1397851099502260226, '全家福', 1397844263642378242, 3, 1, 11800.00, '23412341234', '880eaab0-46a6-426d-9c0b-b7d0a40ed488.jpg', '别光吃肉啦，来份全家福吧，让你长寿又美味', 1, 0, '2021-05-27 09:44:08', '2021-05-27 09:44:08', 1, 1, 0);
INSERT INTO `dish` VALUES (1397851370462687234, '邵阳猪血丸子', 1397844263642378242, 3, 1, 13800.00, '1246812345678', '9fb8fa2d-4351-4d72-9131-53dd19d6584a.jpg', '看，美味不？来嘛来嘛，这才是最爱吖', 1, 0, '2021-05-27 09:45:12', '2021-05-27 09:45:12', 1, 1, 0);
INSERT INTO `dish` VALUES (1397851668262465537, '口味蛇', 1397844263642378242, 3, 1, 16800.00, '1234567812345678', 'acab7eae-c65d-4b13-a3ef-46ff521341bd.png', '爬行界的扛把子，东兴-口味蛇，让你欲罢不能', 1, 0, '2021-05-27 09:46:23', '2021-05-27 09:46:23', 1, 1, 0);
INSERT INTO `dish` VALUES (1397852391150759938, '辣子鸡丁', 1397844303408574465, 9, 3, 8800.00, '2346812468', 'afc1af5f-d11b-45fd-a8a3-89fc9521bc61.jpg', '辣子鸡丁，辣子鸡丁，永远的魂', 1, 0, '2021-05-27 09:49:16', '2021-05-27 09:49:16', 1, 1, 0);
INSERT INTO `dish` VALUES (1397853183287013378, '麻辣兔头', 1397844303408574465, 9, 3, 19800.00, '123456787654321', 'bfba9462-37ed-4bcf-b5a6-e8130a562053.jpg', '麻辣兔头的详细制作，麻辣鲜香，色泽红润，回味悠长', 1, 0, '2021-05-27 09:52:24', '2021-05-27 09:52:24', 1, 1, 0);
INSERT INTO `dish` VALUES (1397853709101740034, '蒜泥白肉', 1397844303408574465, 9, 3, 9800.00, '1234321234321', 'e41b5ff7-fe52-4814-bee6-f8e861c37d99.jpg', '多么的有食欲啊', 1, 0, '2021-05-27 09:54:30', '2021-05-27 09:54:30', 1, 1, 0);
INSERT INTO `dish` VALUES (1397853890262118402, '鱼香肉丝', 1397844303408574465, 9, 3, 3800.00, '1234212321234', 'cdc9f18d-bfd7-43ac-bd30-452e4d5e084f.jpg', '鱼香肉丝简直就是我们童年回忆的一道经典菜，上学的时候点个鱼香肉丝盖饭坐在宿舍床上看着肥皂剧，绝了！现在完美复刻一下上学的时候感觉', 1, 0, '2021-05-27 09:55:13', '2021-05-27 09:55:13', 1, 1, 0);
INSERT INTO `dish` VALUES (1397854652581064706, '麻辣水煮鱼', 1397844303408574465, 9, 3, 14800.00, '2345312·345321', 'fb9b7404-dbfd-4e0b-82f3-06926090a535.jpg', '鱼片是买的切好的鱼片，放几个虾，增加味道', 1, 0, '2021-05-27 09:58:15', '2021-05-27 09:58:15', 1, 1, 0);
INSERT INTO `dish` VALUES (1397854865672679425, '鱼香炒鸡蛋', 1397844303408574465, 9, 3, 2000.00, '23456431·23456', '014d3a61-754a-42ce-91e6-ccd318cc029b.jpg', '鱼香菜也是川味的特色。里面没有鱼却鱼香味', 1, 0, '2021-05-27 09:59:06', '2021-05-27 09:59:06', 1, 1, 0);
INSERT INTO `dish` VALUES (1397860242057375745, '脆皮烧鹅', 1397844391040167938, 7, 2, 12800.00, '123456786543213456', '267ce60f-6a2b-4a43-ba29-ac635aa98071.jpg', '“广东烤鸭美而香，却胜烧鹅说古冈（今新会），燕瘦环肥各佳妙，君休偏重便宜坊”，可见烧鹅与烧鸭在粤菜之中已早负盛名。作为广州最普遍和最受欢迎的烧烤肉食，以它的“色泽金红，皮脆肉嫩，味香可口”的特色，在省城各大街小巷的烧卤店随处可见。', 1, 0, '2021-05-27 10:20:27', '2021-05-27 10:20:27', 1, 1, 0);
INSERT INTO `dish` VALUES (1397860578738352129, '白切鸡', 1397844391040167938, 7, 2, 6600.00, '12345678654', '0ca25a1c-fff2-4a51-81e1-b985ac28f5ec.jpg', '白切鸡是一道色香味俱全的特色传统名肴，又叫白斩鸡，是粤菜系鸡肴中的一种，始于清代的民间。白切鸡通常选用细骨农家鸡与沙姜、蒜茸等食材，慢火煮浸白切鸡皮爽肉滑，清淡鲜美。著名的泮溪酒家白切鸡，曾获商业部优质产品金鼎奖。湛江白切鸡更是驰名粤港澳。粤菜厨坛中，鸡的菜式有200余款之多，而最为人常食不厌的正是白切鸡，深受食家青睐。', 1, 0, '2021-05-27 10:21:48', '2021-05-27 10:21:48', 1, 1, 0);
INSERT INTO `dish` VALUES (1397860792492666881, '烤乳猪', 1397844391040167938, 7, 2, 38800.00, '213456432123456', 'afc1af5f-d11b-45fd-a8a3-89fc9521bc61.jpg', '广式烧乳猪主料是小乳猪，辅料是蒜，调料是五香粉、芝麻酱、八角粉等，本菜品主要通过将食材放入炭火中烧烤而成。烤乳猪是广州最著名的特色菜，并且是“满汉全席”中的主打菜肴之一。烤乳猪也是许多年来广东人祭祖的祭品之一，是家家都少不了的应节之物，用乳猪祭完先人后，亲戚们再聚餐食用。', 1, 0, '2021-05-27 10:22:39', '2021-05-27 10:22:39', 1, 1, 0);
INSERT INTO `dish` VALUES (1397860963880316929, '脆皮乳鸽', 1397844391040167938, 7, 2, 10800.00, '1234563212345', '847efe88-16ed-4e5d-a03c-506ea6013dff.jpg', '“脆皮乳鸽”是广东菜中的一道传统名菜，属于粤菜系，具有皮脆肉嫩、色泽红亮、鲜香味美的特点，常吃可使身体强健，清肺顺气。随着菜品制作工艺的不断发展，逐渐形成了熟炸法、生炸法和烤制法三种制作方法。无论那种制作方法，都是在鸽子经过一系列的加工，挂脆皮水后再加工而成，正宗的“脆皮乳鸽皮脆肉嫩、色泽红亮、鲜香味美、香气馥郁。这三种方法的制作过程都不算复杂，但想达到理想的效果并不容易。', 1, 0, '2021-05-27 10:23:19', '2021-05-27 10:23:19', 1, 1, 0);
INSERT INTO `dish` VALUES (1397861683434139649, '清蒸河鲜海鲜', 1397844391040167938, 7, 2, 38800.00, '1234567876543213456', '880eaab0-46a6-426d-9c0b-b7d0a40ed488.jpg', '新鲜的海鲜，清蒸是最好的处理方式。鲜，体会为什么叫海鲜。清蒸是广州最经典的烹饪手法，过去岭南地区由于峻山大岭阻隔，交通不便，经济发展起步慢，自家打的鱼放在锅里煮了就吃，没有太多的讲究，但却发现这清淡的煮法能使鱼的鲜甜跃然舌尖。', 1, 0, '2021-05-27 10:26:11', '2021-05-27 10:26:11', 1, 1, 0);
INSERT INTO `dish` VALUES (1397862198033297410, '老火靓汤', 1397844391040167938, 7, 2, 49800.00, '123456786532455', '9fb8fa2d-4351-4d72-9131-53dd19d6584a.jpg', '老火靓汤又称广府汤，是广府人传承数千年的食补养生秘方，慢火煲煮的中华老火靓汤，火候足，时间长，既取药补之效，又取入口之甘甜。 广府老火汤种类繁多，可以用各种汤料和烹调方法，烹制出各种不同口味、不同功效的汤来。', 1, 0, '2021-05-27 10:28:14', '2021-05-27 10:28:14', 1, 1, 0);
INSERT INTO `dish` VALUES (1397862477831122945, '上汤焗龙虾', 1397844391040167938, 7, 2, 108800.00, '1234567865432', 'acab7eae-c65d-4b13-a3ef-46ff521341bd.png', '上汤焗龙虾是一道色香味俱全的传统名菜，属于粤菜系。此菜以龙虾为主料，配以高汤制成的一道海鲜美食。本品肉质洁白细嫩，味道鲜美，蛋白质含量高，脂肪含量低，营养丰富。是色香味俱全的传统名菜。', 1, 0, '2021-05-27 10:29:20', '2021-05-27 10:29:20', 1, 1, 0);
INSERT INTO `dish` VALUES (1413342036832100354, '北冰洋', 1413341197421846529, 4, 1, 500.00, '', 'bfba9462-37ed-4bcf-b5a6-e8130a562053.jpg', '', 1, 0, '2021-07-09 11:39:35', '2021-07-09 15:12:18', 1, 1, 0);
INSERT INTO `dish` VALUES (1413384757047271425, '王老吉', 1413341197421846529, 4, 1, 500.00, '', 'dbe27fff-d74d-43a6-927d-11d6889782e4.jpg', '', 1, 0, '2021-07-09 14:29:20', '2025-11-23 15:47:59', 1, 1992198172637925377, 0);
INSERT INTO `dish` VALUES (1413385247889891330, '米饭', 1413384954989060097, 4, 1, 200.00, '', 'cdc9f18d-bfd7-43ac-bd30-452e4d5e084f.jpg', '', 1, 0, '2021-07-09 14:31:17', '2021-07-11 16:35:26', 1, 1, 0);

-- ----------------------------
-- Table structure for dish_flavor
-- ----------------------------
DROP TABLE IF EXISTS `dish_flavor`;
CREATE TABLE `dish_flavor`  (
  `id` bigint NOT NULL COMMENT '主键',
  `dish_id` bigint NOT NULL COMMENT '菜品',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '口味名称',
  `value` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '口味数据list',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '菜品口味关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dish_flavor
-- ----------------------------
INSERT INTO `dish_flavor` VALUES (1397849417888346113, 1397849417854791681, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:37:27', '2021-05-27 09:37:27', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397849739297861633, 1397849739276890114, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:38:43', '2021-05-27 09:38:43', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397849739323027458, 1397849739276890114, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:38:43', '2021-05-27 09:38:43', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397849936421761025, 1397849936404983809, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:39:30', '2021-05-27 09:39:30', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397849936438538241, 1397849936404983809, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:39:30', '2021-05-27 09:39:30', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850141015715841, 1397850140982161409, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:40:19', '2021-05-27 09:40:19', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850141040881665, 1397850140982161409, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:40:19', '2021-05-27 09:40:19', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850392120307713, 1397850392090947585, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:41:19', '2021-05-27 09:41:19', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850392137084929, 1397850392090947585, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:41:19', '2021-05-27 09:41:19', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850630734262274, 1397850630700707841, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:42:16', '2021-05-27 09:42:16', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850630755233794, 1397850630700707841, '辣度', '[\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:42:16', '2021-05-27 09:42:16', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850851274960898, 1397850851245600769, '忌口', '[\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:43:08', '2021-05-27 09:43:08', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397850851283349505, 1397850851245600769, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:43:08', '2021-05-27 09:43:08', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397851099523231745, 1397851099502260226, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:44:08', '2021-05-27 09:44:08', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397851099527426050, 1397851099502260226, '辣度', '[\"不辣\",\"微辣\",\"中辣\"]', '2021-05-27 09:44:08', '2021-05-27 09:44:08', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397851370483658754, 1397851370462687234, '温度', '[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]', '2021-05-27 09:45:12', '2021-05-27 09:45:12', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397851370483658755, 1397851370462687234, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:45:12', '2021-05-27 09:45:12', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397851370483658756, 1397851370462687234, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:45:12', '2021-05-27 09:45:12', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397851668283437058, 1397851668262465537, '温度', '[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]', '2021-05-27 09:46:23', '2021-05-27 09:46:23', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397852391180120065, 1397852391150759938, '忌口', '[\"不要葱\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:49:16', '2021-05-27 09:49:16', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397852391196897281, 1397852391150759938, '辣度', '[\"不辣\",\"微辣\",\"重辣\"]', '2021-05-27 09:49:16', '2021-05-27 09:49:16', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397853183307984898, 1397853183287013378, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:52:24', '2021-05-27 09:52:24', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397853423486414850, 1397853423461249026, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:53:22', '2021-05-27 09:53:22', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397853709126905857, 1397853709101740034, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:54:30', '2021-05-27 09:54:30', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397853890283089922, 1397853890262118402, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:55:13', '2021-05-27 09:55:13', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397854133632413697, 1397854133603053569, '温度', '[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]', '2021-05-27 09:56:11', '2021-05-27 09:56:11', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397854652623007745, 1397854652581064706, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 09:58:15', '2021-05-27 09:58:15', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397854652635590658, 1397854652581064706, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:58:15', '2021-05-27 09:58:15', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397854865735593986, 1397854865672679425, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 09:59:06', '2021-05-27 09:59:06', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397855742303186946, 1397855742273826817, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:02:35', '2021-05-27 10:02:35', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397855906497605633, 1397855906468245506, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 10:03:14', '2021-05-27 10:03:14', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397856190573621250, 1397856190540066818, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:04:21', '2021-05-27 10:04:21', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397859056709316609, 1397859056684150785, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:15:45', '2021-05-27 10:15:45', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397859277837217794, 1397859277812051969, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:16:37', '2021-05-27 10:16:37', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397859487502086146, 1397859487476920321, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:17:27', '2021-05-27 10:17:27', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397859757061615618, 1397859757036449794, '甜味', '[\"无糖\",\"少糖\",\"半躺\",\"多糖\",\"全糖\"]', '2021-05-27 10:18:32', '2021-05-27 10:18:32', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397860242086735874, 1397860242057375745, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:20:27', '2021-05-27 10:20:27', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397860963918065665, 1397860963880316929, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:23:19', '2021-05-27 10:23:19', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397861135754506242, 1397861135733534722, '甜味', '[\"无糖\",\"少糖\",\"半躺\",\"多糖\",\"全糖\"]', '2021-05-27 10:24:00', '2021-05-27 10:24:00', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397861370035744769, 1397861370010578945, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-27 10:24:56', '2021-05-27 10:24:56', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397861683459305474, 1397861683434139649, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 10:26:11', '2021-05-27 10:26:11', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397861898467717121, 1397861898438356993, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 10:27:02', '2021-05-27 10:27:02', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397862198054268929, 1397862198033297410, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-27 10:28:14', '2021-05-27 10:28:14', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1397862477835317250, 1397862477831122945, '辣度', '[\"不辣\",\"微辣\",\"中辣\"]', '2021-05-27 10:29:20', '2021-05-27 10:29:20', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398089545865015297, 1398089545676271617, '温度', '[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]', '2021-05-28 01:31:38', '2021-05-28 01:31:38', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398089782323097601, 1398089782285348866, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:32:34', '2021-05-28 01:32:34', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398090003262255106, 1398090003228700673, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-28 01:33:27', '2021-05-28 01:33:27', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398090264554811394, 1398090264517062657, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-28 01:34:29', '2021-05-28 01:34:29', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398090455399837698, 1398090455324340225, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:35:14', '2021-05-28 01:35:14', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398090685449023490, 1398090685419663362, '温度', '[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]', '2021-05-28 01:36:09', '2021-05-28 01:36:09', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398090825358422017, 1398090825329061889, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-28 01:36:43', '2021-05-28 01:36:43', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398091007051476993, 1398091007017922561, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:37:26', '2021-05-28 01:37:26', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398091296164851713, 1398091296131297281, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:38:35', '2021-05-28 01:38:35', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398091546531246081, 1398091546480914433, '忌口', '[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]', '2021-05-28 01:39:35', '2021-05-28 01:39:35', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398091729809747969, 1398091729788776450, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:40:18', '2021-05-28 01:40:18', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398091889499484161, 1398091889449152513, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:40:56', '2021-05-28 01:40:56', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398092095179763713, 1398092095142014978, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:41:45', '2021-05-28 01:41:45', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398092283877306370, 1398092283847946241, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:42:30', '2021-05-28 01:42:30', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398094018939236354, 1398094018893099009, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:49:24', '2021-05-28 01:49:24', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1398094391494094850, 1398094391456346113, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-05-28 01:50:53', '2021-05-28 01:50:53', 1, 1, 0);
INSERT INTO `dish_flavor` VALUES (1399574026165727233, 1399305325713600514, '辣度', '[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]', '2021-06-01 03:50:25', '2021-06-01 03:50:25', 1399309715396669441, 1399309715396669441, 0);
INSERT INTO `dish_flavor` VALUES (1413389684020682754, 1413342036832100354, '温度', '[\"常温\",\"冷藏\"]', '2021-07-09 15:12:18', '2021-07-09 15:12:18', 1, 1, 0);

-- ----------------------------
-- Table structure for employee
-- ----------------------------
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '姓名',
  `username` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '用户名',
  `password` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '密码',
  `phone` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '手机号',
  `sex` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '性别',
  `id_number` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '身份证号',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态 0:禁用，1:正常',
  `role` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT 'staff' COMMENT '角色 admin:管理员 merchant:商家 staff:员工',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '关联的商家ID（商家角色专用）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_username`(`username`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '员工信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of employee
-- ----------------------------
INSERT INTO `employee` VALUES (1, '超级管理员', 'admin', 'e10adc3949ba59abbe56e057f20f883e', '13800000001', '1', '110101199001010001', 1, 'staff', NULL, '2025-11-23 16:06:35', '2025-11-23 16:06:35', 1, 1);
INSERT INTO `employee` VALUES (2, '张三', 'manager', 'e10adc3949ba59abbe56e057f20f883e', '13800000002', '1', '110101199001010002', 1, 'staff', NULL, '2025-11-23 16:06:35', '2025-11-23 16:06:35', 1, 1);
INSERT INTO `employee` VALUES (3, '李四', 'staff', 'e10adc3949ba59abbe56e057f20f883e', '13800000003', '0', '110101199001010003', 1, 'staff', NULL, '2025-11-23 16:06:35', '2025-11-23 16:06:35', 1, 1);

-- ----------------------------
-- Table structure for feedback
-- ----------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈类型',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈内容',
  `images` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片URL',
  `contact` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系方式',
  `status` int NULL DEFAULT 0 COMMENT '状态 0:待处理 1:处理中 2:已处理',
  `reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '回复内容',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '意见反馈表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of feedback
-- ----------------------------

-- ----------------------------
-- Table structure for merchant
-- ----------------------------
DROP TABLE IF EXISTS `merchant`;
CREATE TABLE `merchant`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `canteen_id` bigint NOT NULL COMMENT '所属食堂ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商家名称',
  `window_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '窗口号',
  `contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商家简介',
  `image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商家图片',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '关联员工ID（登录账号）',
  `application_id` bigint NULL DEFAULT NULL COMMENT '关联的申请ID',
  `avg_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '人均消费',
  `rating` decimal(3, 2) NULL DEFAULT 5.00 COMMENT '评分(0-5)',
  `sales_count` int NULL DEFAULT 0 COMMENT '月销量',
  `total_reviews` int NULL DEFAULT 0 COMMENT '总评价数',
  `positive_count` int NULL DEFAULT 0 COMMENT '好评数',
  `negative_count` int NULL DEFAULT 0 COMMENT '差评数',
  `wechat_group_qrcode` varchar(500) NULL DEFAULT NULL COMMENT '微信社群二维码图片URL',
  `tags` varchar(255) NULL DEFAULT NULL COMMENT '商家标签（逗号分隔）',
  `promo` varchar(100) NULL DEFAULT NULL COMMENT '优惠信息',
  `delivery_time` int NULL DEFAULT 20 COMMENT '配送时间（分钟）',
  `delivery_fee` int NULL DEFAULT 0 COMMENT '配送费（分）',
  `min_order_amount` int NULL DEFAULT 0 COMMENT '起送价（分）',
  `open_time` time NULL DEFAULT '07:00:00' COMMENT '营业开始时间',
  `close_time` time NULL DEFAULT '22:00:00' COMMENT '营业结束时间',
  `is_new` int NULL DEFAULT 0 COMMENT '是否为新店 0:否 1:是',
  `food_category_id` bigint NULL DEFAULT NULL COMMENT '美食分类ID',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT 1 COMMENT '状态 0:停业 1:营业 2:待审核',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_canteen_id`(`canteen_id`) USING BTREE,
  INDEX `idx_employee_id`(`employee_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商家表（窗口）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of merchant
-- ----------------------------
INSERT INTO `merchant` VALUES (1, 1, '老张川菜', '1号窗口', '张三', '13800000001', '正宗川菜，麻辣鲜香，招牌菜：宫保鸡丁、麻婆豆腐', NULL, 2, NULL, 25.00, 4.80, 328, 0, 1, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (2, 1, '李记面馆', '2号窗口', '李四', '13800000002', '手工拉面，汤鲜味美，招牌：牛肉拉面、鸡汤面', NULL, NULL, NULL, 18.00, 4.90, 456, 0, 2, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (3, 1, '王家盖浇饭', '3号窗口', '王五', '13800000003', '经济实惠，份量足，招牌：红烧肉盖饭、鱼香肉丝盖浇饭', NULL, NULL, NULL, 15.00, 4.70, 267, 0, 3, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (4, 1, '美味快餐', '4号窗口', '赵六', '13800000004', '快捷方便，营养均衡，招牌：汉堡套餐、鸡腿饭', NULL, NULL, NULL, 20.00, 4.60, 198, 0, 4, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (5, 1, '香辣烧烤', '5号窗口', '孙七', '13800000005', '炭火烧烤，香辣美味', NULL, NULL, NULL, 30.00, 4.75, 156, 0, 5, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (6, 2, '湘菜馆', '1号窗口', '刘八', '13800000006', '地道湘菜，招牌：剁椒鱼头、农家小炒肉', NULL, NULL, NULL, 28.00, 4.75, 234, 0, 1, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (7, 2, '粤菜坊', '2号窗口', '陈九', '13800000007', '清淡养生，招牌：白切鸡、清蒸鱼', NULL, NULL, NULL, 32.00, 4.85, 189, 0, 2, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (8, 2, '东北饺子', '3号窗口', '赵十', '13800000008', '纯手工饺子，招牌：猪肉大葱、三鲜馅', NULL, NULL, NULL, 22.00, 4.65, 143, 0, 3, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (9, 3, '特色小吃', '1号窗口', '周十一', '13800000009', '各地小吃汇聚', NULL, NULL, NULL, 16.00, 4.70, 298, 0, 1, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (10, 3, '素食餐厅', '2号窗口', '吴十二', '13800000010', '健康素食，营养丰富', NULL, NULL, NULL, 24.00, 4.55, 87, 0, 2, 1, '2025-11-23 16:37:51', '2025-11-23 16:37:51');
INSERT INTO `merchant` VALUES (999, 999, '教师餐厅·雅座', NULL, NULL, '0571-88888888', '高品质教师专属餐厅，提供精致餐食', 'teacher_merchant.jpg', NULL, NULL, NULL, 5.00, 0, 0, 999, 1, '2025-11-23 18:15:47', '2025-11-23 18:17:44');

-- ----------------------------
-- Table structure for merchant_announcement
-- ----------------------------
DROP TABLE IF EXISTS `merchant_announcement`;
CREATE TABLE `merchant_announcement`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告内容',
  `type` tinyint NULL DEFAULT 0 COMMENT '公告类型 0:普通公告 1:优惠活动 2:重要通知',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0:停用 1:启用',
  `sort` int NULL DEFAULT 0 COMMENT '排序（数字越大优先级越高）',
  `start_time` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '失效时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_sort`(`sort`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商家公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of merchant_announcement
-- ----------------------------
INSERT INTO `merchant_announcement` VALUES (1, 1, '今日特价', '红烧肉盖饭限时优惠，原价15元，现价12元！', 1, 1, 10, '2025-11-23 17:35:00', '2025-11-30 17:35:00', '2025-11-23 17:35:00', '2025-11-23 17:35:00');
INSERT INTO `merchant_announcement` VALUES (2, 1, '营业时间调整', '本店营业时间调整为：早上7:00-晚上8:00', 2, 1, 5, '2025-11-23 17:35:00', NULL, '2025-11-23 17:35:00', '2025-11-23 17:35:00');
INSERT INTO `merchant_announcement` VALUES (3, 2, '新品上市', '鱼香肉丝盖饭隆重推出，欢迎品尝！', 0, 1, 8, '2025-11-23 17:35:00', NULL, '2025-11-23 17:35:00', '2025-11-23 17:35:00');
INSERT INTO `merchant_announcement` VALUES (4, 3, '王家盖浇饭优惠活动', '本周所有盖浇饭立减3元，欢迎光临！', 1, 1, 10, '2025-11-23 17:35:00', '2025-11-30 17:35:00', '2025-11-23 17:35:00', '2025-11-23 17:35:00');
INSERT INTO `merchant_announcement` VALUES (5, 3, '注意事项', '用餐高峰期请耐心等待，感谢您的理解与支持！', 0, 1, 3, '2025-11-23 17:35:00', NULL, '2025-11-23 17:35:00', '2025-11-23 17:35:00');

-- ----------------------------
-- Table structure for merchant_application
-- ----------------------------
DROP TABLE IF EXISTS `merchant_application`;
CREATE TABLE `merchant_application`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `canteen_id` bigint NOT NULL COMMENT '申请的食堂ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商家名称',
  `window_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '申请窗口号',
  `contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商家简介',
  `business_license` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营业执照照片',
  `avg_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '人均消费',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '经营者身份证号',
  `owner_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '经营者姓名',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录用户名',
  `password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录密码(加密后)',
  `status` tinyint NULL DEFAULT 0 COMMENT '审核状态 0:待审核 1:已通过 2:已拒绝',
  `audit_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核备注',
  `audit_user_id` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '关联的商家ID（审核通过后创建）',
  `employee_id` bigint NULL DEFAULT NULL COMMENT '关联的员工ID（审核通过后创建）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_username`(`username`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_canteen_id`(`canteen_id`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商家入驻申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of merchant_application
-- ----------------------------

-- ----------------------------
-- Table structure for merchant_settings
-- ----------------------------
DROP TABLE IF EXISTS `merchant_settings`;
CREATE TABLE `merchant_settings`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `auto_accept_order` tinyint NULL DEFAULT 0 COMMENT '自动接单 0:关闭 1:开启',
  `business_hours_start` time NULL DEFAULT NULL COMMENT '营业开始时间',
  `business_hours_end` time NULL DEFAULT NULL COMMENT '营业结束时间',
  `min_order_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '起送金额',
  `notice_sound` tinyint NULL DEFAULT 1 COMMENT '订单提示音 0:关闭 1:开启',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_merchant_id`(`merchant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商家设置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of merchant_settings
-- ----------------------------
INSERT INTO `merchant_settings` VALUES (1, 1, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (2, 2, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (3, 3, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (4, 4, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (5, 5, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (6, 6, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (7, 7, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (8, 8, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (9, 9, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (10, 10, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');
INSERT INTO `merchant_settings` VALUES (11, 999, 0, NULL, NULL, 0.00, 1, '2025-11-23 18:58:02', '2025-11-23 18:58:02');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID（为空表示系统通知）',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商家ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知标题',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知内容',
  `notify_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知类型：NEW_ORDER/URGENT_ORDER/ORDER_STATUS/SYSTEM',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联ID（如订单ID）',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读：0未读 1已读',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消息通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------

-- ----------------------------
-- Table structure for order_detail
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '名字',
  `image` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '图片',
  `order_id` bigint NOT NULL COMMENT '订单id',
  `dish_id` bigint NULL DEFAULT NULL COMMENT '菜品id',
  `setmeal_id` bigint NULL DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '口味',
  `number` int NOT NULL DEFAULT 1 COMMENT '数量',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '订单明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_detail
-- ----------------------------
INSERT INTO `order_detail` VALUES (1992182022827003905, '口味蛇', 'http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg', 1992182022764089346, 1397851668262465537, NULL, NULL, 3, 16800.00);
INSERT INTO `order_detail` VALUES (1992183467743670275, '口味蛇', 'http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg', 1992183467743670274, 1397851668262465537, NULL, NULL, 1, 16800.00);
INSERT INTO `order_detail` VALUES (1992185254609530883, '邵阳猪血丸子', 'http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg', 1992185254609530882, 1397851370462687234, NULL, NULL, 1, 13800.00);
INSERT INTO `order_detail` VALUES (1992188067762667523, '邵阳猪血丸子', 'http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg', 1992188067762667522, 1397851370462687234, NULL, NULL, 1, 13800.00);
INSERT INTO `order_detail` VALUES (1992188505035636738, '邵阳猪血丸子', 'http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg', 1992188505035636737, 1397851370462687234, NULL, NULL, 1, 13800.00);
INSERT INTO `order_detail` VALUES (1992190168500797442, '王老吉', 'http://localhost:8080/common/download?name=00874a5e-0df2-446b-8f69-a30eb7d88ee8.png', 1992190168500797441, 1413384757047271425, NULL, NULL, 1, 50000.00);
INSERT INTO `order_detail` VALUES (1992190168500797443, '口味蛇', 'http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg', 1992190168500797441, 1397851668262465537, NULL, NULL, 1, 1680000.00);
INSERT INTO `order_detail` VALUES (1992201798269812739, '白切鸡', '9ec6fc2d-50d2-422e-b954-de87dcd04198.jpeg', 1992201798269812738, 1397860578738352129, NULL, NULL, 1, 6600.00);
INSERT INTO `order_detail` VALUES (1992201798345310209, '清蒸河鲜海鲜', '1405081e-f545-42e1-86a2-f7559ae2e276.jpeg', 1992201798269812738, 1397861683434139649, NULL, NULL, 1, 38800.00);
INSERT INTO `order_detail` VALUES (1992202210053984257, '白切鸡', '9ec6fc2d-50d2-422e-b954-de87dcd04198.jpeg', 1992202209986875393, 1397860578738352129, NULL, NULL, 1, 6600.00);
INSERT INTO `order_detail` VALUES (1992202210053984258, '清蒸河鲜海鲜', '1405081e-f545-42e1-86a2-f7559ae2e276.jpeg', 1992202209986875393, 1397861683434139649, NULL, NULL, 1, 38800.00);
INSERT INTO `order_detail` VALUES (1992205018400559105, '口味蛇', 'http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg', 1992205018333450242, 1397851668262465537, NULL, NULL, 1, 1680000.00);
INSERT INTO `order_detail` VALUES (1992456768235794433, '上汤焗龙虾', 'http://localhost:8080/common/download?name=5b8d2da3-3744-4bb3-acdc-329056b8259d.jpeg', 1992456768206434306, 1397862477831122945, NULL, NULL, 1, 108800.00);
INSERT INTO `order_detail` VALUES (1992456768235794434, '口味蛇', 'http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg', 1992456768206434306, 1397851668262465537, NULL, NULL, 1, 16800.00);
INSERT INTO `order_detail` VALUES (1992475003274424322, '全家福', 'http://localhost:8080/common/download?name=a53a4e6a-3b83-4044-87f9-9d49b30a8fdc.jpg', 1992475003207315458, 1397851099502260226, NULL, NULL, 1, 11800.00);
INSERT INTO `order_detail` VALUES (1992538687489290243, '精品商务套餐B', 'http://localhost:8080/common/download?name=business_set_b.jpg', 1992538687489290242, 99903, NULL, NULL, 1, 2800.00);
INSERT INTO `order_detail` VALUES (1992543188359061506, '王老吉', 'http://localhost:8080/common/download?name=dbe27fff-d74d-43a6-927d-11d6889782e4.jpg', 1992543188359061505, 1413384757047271425, NULL, NULL, 1, 500.00);
INSERT INTO `order_detail` VALUES (1992545399445225475, '北冰洋', 'http://localhost:8080/common/download?name=bfba9462-37ed-4bcf-b5a6-e8130a562053.jpg', 1992545399445225474, 1413342036832100354, NULL, NULL, 1, 500.00);

-- ----------------------------
-- Table structure for order_review
-- ----------------------------
DROP TABLE IF EXISTS `order_review`;
CREATE TABLE `order_review`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商家ID',
  `rating` tinyint NOT NULL COMMENT '评分(1-5星)',
  `taste_rating` tinyint NULL DEFAULT NULL COMMENT '口味评分(1-5星)',
  `service_rating` tinyint NULL DEFAULT NULL COMMENT '服务评分(1-5星)',
  `speed_rating` tinyint NULL DEFAULT NULL COMMENT '速度评分(1-5星)',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价内容',
  `images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价图片（逗号分隔）',
  `is_anonymous` tinyint NULL DEFAULT 0 COMMENT '是否匿名 0:否 1:是',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态 0:已删除 1:正常',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_user` bigint NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_id`(`order_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE,
  INDEX `idx_rating`(`rating`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_review
-- ----------------------------
INSERT INTO `order_review` VALUES (1, 1992543188359061505, 1992535586128621569, NULL, 5, NULL, NULL, NULL, '', NULL, 0, 1, '2025-11-23 18:54:51', '2025-11-23 18:54:51', 1992535586128621569, 1992535586128621569);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint NOT NULL COMMENT '主键',
  `number` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '订单号',
  `status` int NOT NULL DEFAULT 1 COMMENT '订单状态 1待付款，2待派送，3已派送，4已完成，5已取消',
  `refund_status` tinyint NULL DEFAULT 0 COMMENT '退款状态 0:无退款 1:申请中 2:已退款 3:退款失败',
  `refund_reason` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '退款原因',
  `refund_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '退款金额',
  `refund_time` datetime NULL DEFAULT NULL COMMENT '退款时间',
  `review_status` tinyint NULL DEFAULT 0 COMMENT '评价状态 0:未评价 1:已评价',
  `order_type` tinyint(1) NULL DEFAULT 1 COMMENT '订单类型：1即时订单 2预订单',
  `scheduled_time` datetime NULL DEFAULT NULL COMMENT '预约取餐时间',
  `reserved_time` datetime NULL DEFAULT NULL COMMENT '预约时间',
  `reserved_date` date NULL DEFAULT NULL COMMENT '预约日期（用于查询）',
  `is_reminded` tinyint(1) NULL DEFAULT 0 COMMENT '是否已提醒：0否 1是',
  `user_id` bigint NOT NULL COMMENT '下单用户',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商家ID',
  `merchant_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '商家名称',
  `address_book_id` bigint NULL DEFAULT NULL COMMENT '地址id',
  `order_time` datetime NOT NULL COMMENT '下单时间',
  `checkout_time` datetime NOT NULL COMMENT '结账时间',
  `pay_method` int NOT NULL DEFAULT 1 COMMENT '支付方式 1微信,2支付宝',
  `amount` decimal(10, 2) NOT NULL COMMENT '实收金额',
  `remark` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '备注',
  `phone` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `consignee` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `delivery_type` int NULL DEFAULT 1 COMMENT '配送方式 1:到店自取 2:商家外送',
  `delivery_fee` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '配送费',
  `canteen_id` bigint NULL DEFAULT NULL COMMENT '食堂ID',
  `canteen_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '食堂名称',
  `user_coupon_id` bigint NULL DEFAULT NULL COMMENT '用户优惠券ID',
  `coupon_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '优惠券优惠金额',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_type`(`order_type`) USING BTREE,
  INDEX `idx_reserved_time`(`reserved_time`) USING BTREE,
  INDEX `idx_reserved_date`(`reserved_date`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1992182022764089346, '1992182022764089346', 2, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992175182684745729, NULL, NULL, NULL, '2025-11-22 18:43:02', '2025-11-22 18:43:02', 1, 50400.00, '', '13895980231', '到店自取', NULL, '用户0231', 1, 0.00, 1, '第一食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992183467743670274, '1992183467743670274', 2, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992175182684745729, NULL, NULL, NULL, '2025-11-22 18:48:46', '2025-11-22 18:48:46', 1, 16800.00, '', '13895980231', '到店自取', NULL, '用户0231', 1, 0.00, 1, '第一食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992185254609530882, '1992185254609530882', 2, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992175182684745729, NULL, NULL, NULL, '2025-11-22 18:55:52', '2025-11-22 18:55:52', 1, 13800.00, '', '13895980231', '到店自取', NULL, '用户0231', 1, 0.00, 1, '第一食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992188067762667522, '1992188067762667522', 2, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992175182684745729, NULL, NULL, NULL, '2025-11-22 19:07:03', '2025-11-22 19:07:03', 1, 13800.00, '', '13895980231', '到店自取', NULL, '用户0231', 1, 0.00, 1, '第一食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992188505035636737, '1992188505035636737', 2, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992175182684745729, NULL, NULL, NULL, '2025-11-22 19:08:47', '2025-11-22 19:08:47', 1, 13800.00, '', '13895980231', '到店自取', NULL, '用户0231', 1, 0.00, 1, '第一食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992190168500797441, '1992190168500797441', 2, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992175182684745729, NULL, NULL, 1992189513195323394, '2025-11-22 19:15:24', '2025-11-22 19:15:24', 1, 1730003.00, '', '19906454305', '北京市北京市东城区111', NULL, '11', 2, 3.00, 1, '第一食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992201798269812738, '1992201798269812738', 2, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992198172637925377, NULL, NULL, NULL, '2025-11-22 20:01:37', '2025-11-22 20:01:37', 1, 45400.00, '', '13830666354', '到店自取', NULL, '用户6354', 1, 0.00, 1, '食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992202209986875393, '1992202209986875393', 4, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992198172637925377, NULL, NULL, NULL, '2025-11-22 20:03:15', '2025-11-22 20:03:15', 1, 45400.00, '', '13830666354', '到店自取', NULL, '用户6354', 1, 0.00, 1, '食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992205018333450242, '1992205018333450242', 5, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992198172637925377, NULL, NULL, NULL, '2025-11-22 20:14:24', '2025-11-22 20:14:24', 1, 1680000.00, '', '13830666354', '到店自取', NULL, '用户6354', 1, 0.00, 1, '第一食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992456768206434306, '1992456768206434306', 1, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992198172637925377, NULL, NULL, NULL, '2025-11-23 12:54:46', '2025-11-23 12:54:46', 1, 124600.00, '', '13830666354', '到店自取', NULL, '123', 1, 0.00, 1, '食堂', 1992451678196224001, 1000.00);
INSERT INTO `orders` VALUES (1992475003207315458, '1992475003207315458', 4, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992198172637925377, NULL, NULL, NULL, '2025-11-23 14:07:14', '2025-11-23 14:07:14', 1, 10800.00, '', '13830666354', '到店自取', NULL, '123', 1, 0.00, 1, '食堂', 1992474939919462402, 0.00);
INSERT INTO `orders` VALUES (1992538687489290242, '1992538687489290242', 4, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992535586128621569, NULL, NULL, NULL, '2025-11-23 18:20:17', '2025-11-23 18:20:17', 1, 2800.00, '', '13935125699', '到店自取', NULL, '教师-13935125699', 1, 0.00, 1, '食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992543188359061505, '1992543188359061505', 5, 1, '确定要申请退款吗?', 500.00, '2025-11-23 18:47:10', 1, 1, NULL, NULL, NULL, 0, 1992535586128621569, NULL, NULL, NULL, '2025-11-23 18:38:10', '2025-11-23 18:38:10', 1, 500.00, '', '13935125699', '到店自取', NULL, '教师-13935125699', 1, 0.00, NULL, '食堂', NULL, 0.00);
INSERT INTO `orders` VALUES (1992545399445225474, '1992545399445225474', 1, 0, NULL, NULL, NULL, 0, 1, NULL, NULL, NULL, 0, 1992535586128621569, NULL, NULL, NULL, '2025-11-23 18:46:58', '2025-11-23 18:46:58', 1, 500.00, '', '13935125699', '到店自取', NULL, '教师-13935125699', 1, 0.00, NULL, '食堂', NULL, 0.00);

-- ----------------------------
-- Table structure for points_record
-- ----------------------------
DROP TABLE IF EXISTS `points_record`;
CREATE TABLE `points_record`  (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `points` int NOT NULL COMMENT '积分变化（正数为增加，负数为减少）',
  `type` int NOT NULL COMMENT '类型 1:消费获得 2:签到 3:兑换 4:过期',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '说明',
  `order_id` bigint NULL DEFAULT NULL COMMENT '关联订单ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '积分记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of points_record
-- ----------------------------

-- ----------------------------
-- Table structure for points_task
-- ----------------------------
DROP TABLE IF EXISTS `points_task`;
CREATE TABLE `points_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务描述',
  `points` int NOT NULL COMMENT '奖励积分',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务类型：daily-每日，once-一次性',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `status` int NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '积分任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of points_task
-- ----------------------------
INSERT INTO `points_task` VALUES (1, '完成首单', '下单并完成首单', 50, 'once', '📝', 1, '2025-11-22 19:30:46', '2025-11-22 19:30:46');
INSERT INTO `points_task` VALUES (2, '评价订单', '对订单进行评价', 10, 'once', '👍', 1, '2025-11-22 19:30:46', '2025-11-22 19:30:46');
INSERT INTO `points_task` VALUES (3, '每日签到', '每日签到', 5, 'daily', '🎁', 1, '2025-11-22 19:30:46', '2025-11-22 19:30:46');
INSERT INTO `points_task` VALUES (4, '邀请好友', '邀请好友注册', 20, 'once', '👥', 1, '2025-11-22 19:30:46', '2025-11-22 19:30:46');
INSERT INTO `points_task` VALUES (5, '完成首单', '下单并完成首单', 50, 'once', '📝', 1, '2025-11-22 19:39:20', '2025-11-22 19:39:20');
INSERT INTO `points_task` VALUES (6, '评价订单', '对订单进行评价', 10, 'once', '👍', 1, '2025-11-22 19:39:20', '2025-11-22 19:39:20');
INSERT INTO `points_task` VALUES (7, '每日签到', '每日签到', 5, 'daily', '🎁', 1, '2025-11-22 19:39:20', '2025-11-22 19:39:20');
INSERT INTO `points_task` VALUES (8, '邀请好友', '邀请好友注册', 20, 'once', '👥', 1, '2025-11-22 19:39:20', '2025-11-22 19:39:20');

-- ----------------------------
-- Table structure for setmeal
-- ----------------------------
DROP TABLE IF EXISTS `setmeal`;
CREATE TABLE `setmeal`  (
  `id` bigint NOT NULL COMMENT '主键',
  `category_id` bigint NOT NULL COMMENT '菜品分类id',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '套餐名称',
  `price` decimal(10, 2) NOT NULL COMMENT '套餐价格',
  `status` int NULL DEFAULT NULL COMMENT '状态 0:停用 1:启用',
  `code` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '编码',
  `description` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '描述信息',
  `image` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '图片',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_setmeal_name`(`name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '套餐' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of setmeal
-- ----------------------------
INSERT INTO `setmeal` VALUES (1415580119015145474, 1413386191767674881, '儿童套餐A计划', 4000.00, 1, '', '', '61d20592-b37f-4d72-a864-07ad5bb8f3bb.jpg', '2021-07-15 15:52:55', '2021-07-15 15:52:55', 1415576781934608386, 1415576781934608386, 0);

-- ----------------------------
-- Table structure for setmeal_dish
-- ----------------------------
DROP TABLE IF EXISTS `setmeal_dish`;
CREATE TABLE `setmeal_dish`  (
  `id` bigint NOT NULL COMMENT '主键',
  `setmeal_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '套餐id ',
  `dish_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '菜品id',
  `name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '菜品名称 （冗余字段）',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '菜品原价（冗余字段）',
  `copies` int NOT NULL COMMENT '份数',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '套餐菜品关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of setmeal_dish
-- ----------------------------
INSERT INTO `setmeal_dish` VALUES (1415580119052894209, '1415580119015145474', '1397862198033297410', '老火靓汤', 49800.00, 1, 0, '2021-07-15 15:52:55', '2021-07-15 15:52:55', 1415576781934608386, 1415576781934608386, 0);
INSERT INTO `setmeal_dish` VALUES (1415580119061282817, '1415580119015145474', '1413342036832100354', '北冰洋', 500.00, 1, 0, '2021-07-15 15:52:55', '2021-07-15 15:52:55', 1415576781934608386, 1415576781934608386, 0);
INSERT INTO `setmeal_dish` VALUES (1415580119069671426, '1415580119015145474', '1413385247889891330', '米饭', 200.00, 1, 0, '2021-07-15 15:52:55', '2021-07-15 15:52:55', 1415576781934608386, 1415576781934608386, 0);

-- ----------------------------
-- Table structure for shopping_cart
-- ----------------------------
DROP TABLE IF EXISTS `shopping_cart`;
CREATE TABLE `shopping_cart`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '名称',
  `image` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '图片',
  `canteen_id` bigint NULL DEFAULT NULL COMMENT '食堂ID',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商家ID',
  `user_id` bigint NOT NULL COMMENT '主键',
  `dish_id` bigint NULL DEFAULT NULL COMMENT '菜品id',
  `setmeal_id` bigint NULL DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '口味',
  `number` int NOT NULL DEFAULT 1 COMMENT '数量',
  `amount` decimal(10, 2) NOT NULL COMMENT '金额',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '购物车' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of shopping_cart
-- ----------------------------
INSERT INTO `shopping_cart` VALUES (1992173392010412033, '上汤焗龙虾', 'http://localhost:8080/common/download?name=5b8d2da3-3744-4bb3-acdc-329056b8259d.jpeg', NULL, NULL, 1992152220631830529, 1397862477831122945, NULL, NULL, 2, 108800.00, '2025-11-22 18:08:44');
INSERT INTO `shopping_cart` VALUES (1992191642668630018, '邵阳猪血丸子', 'http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg', NULL, NULL, 1992175182684745729, 1397851370462687234, NULL, NULL, 1, 1380000.00, '2025-11-22 19:21:15');
INSERT INTO `shopping_cart` VALUES (1992532684718764034, '口味蛇', 'http://localhost:8080/common/download?name=acab7eae-c65d-4b13-a3ef-46ff521341bd.png', NULL, NULL, 1992198172637925377, 1397851668262465537, NULL, NULL, 1, 16800.00, '2025-11-23 17:56:26');

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置值',
  `config_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'string' COMMENT '配置类型：string/integer/boolean/json',
  `config_group` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'system' COMMENT '配置分组：system/order/payment/delivery',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '配置说明',
  `is_public` tinyint(1) NULL DEFAULT 0 COMMENT '是否公开：0否 1是',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key`) USING BTREE,
  INDEX `idx_config_group`(`config_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'order.auto_accept', 'false', 'boolean', 'order', '是否自动接单', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (2, 'order.timeout_minutes', '30', 'integer', 'order', '订单超时时间(分钟)', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (3, 'order.auto_complete_minutes', '60', 'integer', 'order', '自动完成时间(分钟)', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (4, 'order.print_enabled', 'false', 'boolean', 'order', '是否启用订单打印', 0, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (5, 'order.remind_minutes', '30', 'integer', 'order', '预订单提前提醒时间(分钟)', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (6, 'delivery.fee', '3.00', 'string', 'delivery', '配送费(元)', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (7, 'delivery.free_amount', '30.00', 'string', 'delivery', '免配送费金额(元)', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (8, 'points.ratio', '5', 'integer', 'system', '积分比例(%)', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (9, 'system.name', '智慧食堂系统', 'string', 'system', '系统名称', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');
INSERT INTO `system_config` VALUES (10, 'system.version', '1.0.0', 'string', 'system', '系统版本', 1, '2025-11-23 16:12:30', '2025-11-23 16:12:30');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '姓名',
  `phone` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '手机号',
  `user_type` tinyint NULL DEFAULT 1 COMMENT '用户类型 1:学生 2:教师 3:普通用户',
  `id_card` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '身份证号',
  `real_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '真实姓名',
  `teacher_verified` tinyint NULL DEFAULT 0 COMMENT '教师认证状态 0:未认证 1:待审核 2:已认证 3:已拒绝',
  `sex` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '性别',
  `id_number` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '身份证号',
  `avatar` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '头像',
  `status` int NULL DEFAULT 0 COMMENT '状态 0:禁用，1:正常',
  `balance` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '账户余额（元）',
  `coupon_count` int NOT NULL DEFAULT 0 COMMENT '优惠券数量',
  `points` int NOT NULL DEFAULT 0 COMMENT '积分',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL,
  `update_user` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1417012167126876162, '张三', '13800138000', 1, NULL, NULL, 0, '1', '110101199001010001', NULL, 1, 98.50, 0, 1280, '2025-11-22 17:58:08', '2025-11-23 16:59:11', NULL, NULL);
INSERT INTO `user` VALUES (1417012167126876163, '李四', '13800138001', 1, NULL, NULL, 0, '1', '110101199001010002', NULL, 1, 150.00, 0, 800, '2025-11-22 17:58:08', '2025-11-23 16:59:11', NULL, NULL);
INSERT INTO `user` VALUES (1417012167126876164, '王五', '13800138002', 1, NULL, NULL, 0, '0', '110101199001010003', NULL, 1, 200.00, 0, 500, '2025-11-22 17:58:08', '2025-11-23 16:59:11', NULL, NULL);
INSERT INTO `user` VALUES (1417012167126876165, '赵六', '13800138003', 1, NULL, NULL, 0, '1', '110101199001010004', NULL, 1, 50.00, 0, 200, '2025-11-22 17:58:08', '2025-11-23 16:59:11', NULL, NULL);
INSERT INTO `user` VALUES (1992151503888199682, NULL, '13841782581', 1, NULL, NULL, 0, NULL, NULL, NULL, 1, 0.00, 0, 0, '2025-11-22 17:58:08', '2025-11-22 17:58:08', NULL, NULL);
INSERT INTO `user` VALUES (1992151533797781506, NULL, '13822295204', 1, NULL, NULL, 0, NULL, NULL, NULL, 1, 0.00, 0, 0, '2025-11-22 17:58:08', '2025-11-22 17:58:08', NULL, NULL);
INSERT INTO `user` VALUES (1992152220631830529, '用户5497', '13811245497', 1, NULL, NULL, 0, NULL, NULL, NULL, 1, 0.00, 0, 0, '2025-11-22 17:58:08', '2025-11-22 17:58:08', NULL, NULL);
INSERT INTO `user` VALUES (1992175182684745729, '用户0231', '13895980231', 1, NULL, NULL, 0, NULL, NULL, NULL, 1, 3010.00, 0, 0, '2025-11-22 18:15:51', '2025-11-22 19:08:39', NULL, 1992175182684745729);
INSERT INTO `user` VALUES (1992193136608411650, '用户8209', '13848598209', 1, NULL, NULL, 0, NULL, NULL, NULL, 1, 0.00, 0, 0, '2025-11-22 19:27:12', '2025-11-22 19:27:12', 1992175182684745729, 1992175182684745729);
INSERT INTO `user` VALUES (1992194199516360706, '用户5360', '13852255360', 1, NULL, NULL, 0, NULL, NULL, NULL, 1, 0.00, 0, 0, '2025-11-22 19:31:25', '2025-11-22 19:31:25', NULL, NULL);
INSERT INTO `user` VALUES (1992198172637925377, '123', '13830666354', 1, NULL, NULL, 0, '1', NULL, 'acab7eae-c65d-4b13-a3ef-46ff521341bd.png', 1, 0.00, 4, 0, '2025-11-22 19:47:12', '2025-11-23 16:59:11', NULL, 1992198172637925377);
INSERT INTO `user` VALUES (1992535586128621569, '教师-13935125699', '13935125699', 2, NULL, NULL, 2, NULL, NULL, NULL, 1, 0.00, 0, 0, '2025-11-23 18:07:58', '2025-11-23 18:07:58', NULL, NULL);

-- ----------------------------
-- Table structure for user_browse_history
-- ----------------------------
DROP TABLE IF EXISTS `user_browse_history`;
CREATE TABLE `user_browse_history`  (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `dish_id` bigint NULL DEFAULT NULL COMMENT '菜品ID',
  `canteen_id` bigint NULL DEFAULT NULL COMMENT '餐厅ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID',
  `browse_time` datetime NOT NULL COMMENT '浏览时间',
  `stay_duration` int NULL DEFAULT 0 COMMENT '停留时长（秒）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_dish_id`(`dish_id`) USING BTREE,
  INDEX `idx_browse_time`(`browse_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户浏览历史表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_browse_history
-- ----------------------------

-- ----------------------------
-- Table structure for user_coupon
-- ----------------------------
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon`  (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `coupon_id` bigint NOT NULL COMMENT '优惠券ID',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态：0-未使用，1-已使用，2-已过期',
  `used_time` datetime NULL DEFAULT NULL COMMENT '使用时间',
  `order_id` bigint NULL DEFAULT NULL COMMENT '订单ID',
  `expire_time` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `update_user` bigint NULL DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_coupon_id`(`coupon_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户优惠券表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_coupon
-- ----------------------------

-- ----------------------------
-- Table structure for user_favorite_dish
-- ----------------------------
DROP TABLE IF EXISTS `user_favorite_dish`;
CREATE TABLE `user_favorite_dish`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `dish_id` bigint NOT NULL COMMENT '菜品ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_dish`(`user_id`, `dish_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_dish_id`(`dish_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户收藏菜品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_favorite_dish
-- ----------------------------

-- ----------------------------
-- Table structure for user_favorite_merchant
-- ----------------------------
DROP TABLE IF EXISTS `user_favorite_merchant`;
CREATE TABLE `user_favorite_merchant`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_merchant`(`user_id`, `merchant_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户收藏商家表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_favorite_merchant
-- ----------------------------

-- ----------------------------
-- Table structure for user_feedback
-- ----------------------------
DROP TABLE IF EXISTS `user_feedback`;
CREATE TABLE `user_feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `type` tinyint NOT NULL COMMENT '反馈类型 1:功能建议 2:投诉 3:其他',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '关联商家ID（可选）',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈内容',
  `images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '反馈图片（逗号分隔）',
  `contact` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系方式',
  `status` tinyint NULL DEFAULT 1 COMMENT '处理状态 1:待处理 2:处理中 3:已完成',
  `reply` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复内容',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户反馈表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_feedback
-- ----------------------------

-- ----------------------------
-- Table structure for user_preference
-- ----------------------------
DROP TABLE IF EXISTS `user_preference`;
CREATE TABLE `user_preference`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID',
  `preference_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '偏好类型：taste/category/price',
  `preference_value` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '偏好值',
  `confidence` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '置信度（0-100）',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_preference`(`user_id`, `preference_type`, `preference_value`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户饮食偏好表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_preference
-- ----------------------------

-- ----------------------------
-- Table structure for user_task_record
-- ----------------------------
DROP TABLE IF EXISTS `user_task_record`;
CREATE TABLE `user_task_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `task_id` bigint NOT NULL COMMENT '任务ID',
  `complete_time` datetime NOT NULL COMMENT '完成时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_task`(`user_id`, `task_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_complete_time`(`complete_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户任务完成记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_task_record
-- ----------------------------

-- ----------------------------
-- Table structure for websocket_connection
-- ----------------------------
DROP TABLE IF EXISTS `websocket_connection`;
CREATE TABLE `websocket_connection`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `user_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户类型：MERCHANT/ADMIN/USER',
  `session_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'WebSocket会话ID',
  `connect_time` datetime NOT NULL COMMENT '连接时间',
  `disconnect_time` datetime NULL DEFAULT NULL COMMENT '断开时间',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_session_id`(`session_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'WebSocket连接记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of websocket_connection
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
