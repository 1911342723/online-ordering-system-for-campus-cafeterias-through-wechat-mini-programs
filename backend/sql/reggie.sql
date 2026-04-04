-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: reggie
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `reggie`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `reggie` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `reggie`;

--
-- Table structure for table `address_book`
--

DROP TABLE IF EXISTS `address_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address_book` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `consignee` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '收货人',
  `sex` tinyint NOT NULL COMMENT '性别 0 女 1 男',
  `phone` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '手机号',
  `province_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省级区划编号',
  `province_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省级名称',
  `city_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市级区划编号',
  `city_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市级名称',
  `district_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区级区划编号',
  `district_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区级名称',
  `detail` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '详细地址',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标签',
  `is_default` tinyint(1) NOT NULL DEFAULT '0' COMMENT '默认 0 否 1是',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='地址管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address_book`
--

LOCK TABLES `address_book` WRITE;
/*!40000 ALTER TABLE `address_book` DISABLE KEYS */;
INSERT INTO `address_book` VALUES (1417414526093082626,1417012167126876162,'张三',1,'13800138000',NULL,NULL,NULL,NULL,NULL,NULL,'昌平区金燕龙办公楼','公司',1,'2021-07-20 17:22:12','2021-07-20 17:26:33',1417012167126876162,1417012167126876162,0),(1417414526093082627,1417012167126876163,'李四',1,'13800138001',NULL,NULL,NULL,NULL,NULL,NULL,'学生宿舍2号楼201','宿舍',1,'2025-11-22 17:58:08','2025-11-22 17:58:08',1417012167126876163,1417012167126876163,0),(1417414526093082628,1417012167126876164,'王五',0,'13800138002',NULL,NULL,NULL,NULL,NULL,NULL,'学生宿舍3号楼301','宿舍',1,'2025-11-22 17:58:08','2025-11-22 17:58:08',1417012167126876164,1417012167126876164,0),(1417414526093082629,1417012167126876165,'赵六',1,'13800138003',NULL,NULL,NULL,NULL,NULL,NULL,'教师公寓A栋101','家',1,'2025-11-22 17:58:08','2025-11-22 17:58:08',1417012167126876165,1417012167126876165,0),(1417414926166769666,1417012167126876162,'小李',1,'13512345678',NULL,NULL,NULL,NULL,NULL,NULL,'测试','家',0,'2021-07-20 17:23:47','2021-07-20 17:23:47',1417012167126876162,1417012167126876162,0),(1992189513195323394,1992175182684745729,'11',1,'19906454305','','北京市','','北京市','','东城区','111','家',1,'2025-11-22 19:12:48','2025-11-22 19:12:48',1992175182684745729,1992175182684745729,0),(1992517235775901697,1992198172637925377,'Yan',1,'19907475647','','北京市','','北京市','','东城区','1','家',0,'2025-11-23 16:55:03','2025-11-23 16:55:03',1992198172637925377,1992198172637925377,0),(2040378831260692482,2040361841687126018,'11',1,'19907575849','','北京市','','北京市','','东城区','11','家',0,'2026-04-04 18:39:56','2026-04-04 18:39:56',2040361841687126018,2040361841687126018,0);
/*!40000 ALTER TABLE `address_book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_chat_history`
--

DROP TABLE IF EXISTS `ai_chat_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_chat_history` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role` varchar(20) NOT NULL COMMENT '角色：user用户/ai助手',
  `content` text NOT NULL COMMENT '消息内容',
  `dishes` text COMMENT '推荐菜品JSON（如果有）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI聊天历史表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_chat_history`
--

LOCK TABLES `ai_chat_history` WRITE;
/*!40000 ALTER TABLE `ai_chat_history` DISABLE KEYS */;
INSERT INTO `ai_chat_history` VALUES (2040363709968433153,2040361841687126018,'user','有什么清淡的菜',NULL,'2026-04-04 17:39:51'),(2040363709985210369,2040361841687126018,'ai','为你推荐几道清淡的菜品😋：\n- 清炒有机时蔬，价格15元，选用当季新鲜有机蔬菜，清爽可口。\n- 精品商务套餐B，价格28元，清淡养生，包含四菜一汤。\n- 养生乌鸡汤，价格18元，滋补养生，暖心暖胃。这些菜品都能满足你清淡饮食的需求哦~ ','[{\"canteenId\":2,\"categoryId\":1397844391040167938,\"code\":\"12345678654\",\"createTime\":\"2021-05-27T10:21:48\",\"createUser\":1,\"description\":\"白切鸡是一道色香味俱全的特色传统名肴，又叫白斩鸡，是粤菜系鸡肴中的一种，始于清代的民间。白切鸡通常选用细骨农家鸡与沙姜、蒜茸等食材，慢火煮浸白切鸡皮爽肉滑，清淡鲜美。著名的泮溪酒家白切鸡，曾获商业部优质产品金鼎奖。湛江白切鸡更是驰名粤港澳。粤菜厨坛中，鸡的菜式有200余款之多，而最为人常食不厌的正是白切鸡，深受食家青睐。\",\"id\":1397860578738352129,\"image\":\"0ca25a1c-fff2-4a51-81e1-b985ac28f5ec.jpg\",\"isDeleted\":0,\"merchantId\":7,\"name\":\"白切鸡\",\"price\":6600.00,\"sort\":34,\"status\":1,\"stock\":999,\"updateTime\":\"2021-05-27T10:21:48\",\"updateUser\":1},{\"canteenId\":2,\"categoryId\":1397844391040167938,\"code\":\"1234567876543213456\",\"createTime\":\"2021-05-27T10:26:11\",\"createUser\":1,\"description\":\"新鲜的海鲜，清蒸是最好的处理方式。鲜，体会为什么叫海鲜。清蒸是广州最经典的烹饪手法，过去岭南地区由于峻山大岭阻隔，交通不便，经济发展起步慢，自家打的鱼放在锅里煮了就吃，没有太多的讲究，但却发现这清淡的煮法能使鱼的鲜甜跃然舌尖。\",\"id\":1397861683434139649,\"image\":\"880eaab0-46a6-426d-9c0b-b7d0a40ed488.jpg\",\"isDeleted\":0,\"merchantId\":7,\"name\":\"清蒸河鲜海鲜\",\"price\":38800.00,\"sort\":34,\"status\":1,\"stock\":999,\"updateTime\":\"2021-05-27T10:26:11\",\"updateUser\":1},{\"canteenId\":999,\"categoryId\":9991,\"code\":\"D99903\",\"createTime\":\"2025-11-23T18:17:44\",\"createUser\":1,\"description\":\"清淡养生，四菜一汤\",\"id\":99903,\"image\":\"business_set_b.jpg\",\"isDeleted\":0,\"merchantId\":10,\"name\":\"精品商务套餐B\",\"price\":2800.00,\"sort\":33,\"status\":1,\"stock\":999,\"updateTime\":\"2025-11-23T18:17:44\",\"updateUser\":1},{\"canteenId\":999,\"categoryId\":9992,\"code\":\"D99906\",\"createTime\":\"2025-11-23T18:17:44\",\"createUser\":1,\"description\":\"当季新鲜有机蔬菜\",\"id\":99906,\"image\":\"organic_veg.jpg\",\"isDeleted\":0,\"merchantId\":999,\"name\":\"清炒有机时蔬\",\"price\":1500.00,\"sort\":15,\"status\":1,\"stock\":999,\"updateTime\":\"2025-11-23T18:17:44\",\"updateUser\":1},{\"canteenId\":999,\"categoryId\":9993,\"code\":\"D99907\",\"createTime\":\"2025-11-23T18:17:44\",\"createUser\":1,\"description\":\"滋补养生，暖心暖胃\",\"id\":99907,\"image\":\"chicken_soup.jpg\",\"isDeleted\":0,\"merchantId\":999,\"name\":\"养生乌鸡汤\",\"price\":1800.00,\"sort\":15,\"status\":1,\"stock\":999,\"updateTime\":\"2025-11-23T18:17:44\",\"updateUser\":1},{\"canteenId\":999,\"categoryId\":9993,\"code\":\"D99908\",\"createTime\":\"2025-11-23T18:17:44\",\"createUser\":1,\"description\":\"美容养颜，胶原蛋白丰富\",\"id\":99908,\"image\":\"fish_maw_soup.jpg\",\"isDeleted\":0,\"merchantId\":999,\"name\":\"花胶鱼肚汤\",\"price\":2500.00,\"sort\":15,\"status\":1,\"stock\":999,\"updateTime\":\"2025-11-23T18:17:44\",\"updateUser\":1},{\"canteenId\":999,\"categoryId\":9994,\"code\":\"D99909\",\"createTime\":\"2025-11-23T18:17:44\",\"createUser\":1,\"description\":\"五谷杂粮，健康主食\",\"id\":99909,\"image\":\"multi_grain_rice.jpg\",\"isDeleted\":0,\"merchantId\":999,\"name\":\"杂粮饭\",\"price\":500.00,\"sort\":15,\"status\":1,\"stock\":999,\"updateTime\":\"2025-11-23T18:17:44\",\"updateUser\":1},{\"canteenId\":999,\"categoryId\":9994,\"code\":\"D99910\",\"createTime\":\"2025-11-23T18:17:44\",\"createUser\":1,\"description\":\"粗纤维，助消化\",\"id\":99910,\"image\":\"whole_wheat_bun.jpg\",\"isDeleted\":0,\"merchantId\":999,\"name\":\"全麦馒头\",\"price\":300.00,\"sort\":15,\"status\":1,\"stock\":999,\"updateTime\":\"2025-11-23T18:17:44\",\"updateUser\":1},{\"canteenId\":1,\"categoryId\":1397844263642378242,\"code\":\"222222222\",\"createTime\":\"2021-05-27T09:38:43\",\"createUser\":1,\"description\":\"来自鲜嫩美味的小鸡，值得一尝\",\"id\":1397849739276890114,\"image\":\"014d3a61-754a-42ce-91e6-ccd318cc029b.jpg\",\"isDeleted\":0,\"merchantId\":3,\"name\":\"辣子鸡\",\"price\":7800.00,\"sort\":14,\"status\":1,\"stock\":999,\"updateTime\":\"2021-05-27T09:38:43\",\"updateUser\":1},{\"canteenId\":1,\"categoryId\":1397844263642378242,\"code\":\"123412341234\",\"createTime\":\"2021-05-27T09:40:19\",\"createUser\":1,\"description\":\"毛氏红烧肉毛氏红烧肉，确定不来一份？\",\"id\":1397850140982161409,\"image\":\"0ca25a1c-fff2-4a51-81e1-b985ac28f5ec.jpg\",\"isDeleted\":0,\"merchantId\":3,\"name\":\"毛氏红烧肉\",\"price\":6800.00,\"sort\":14,\"status\":1,\"stock\":999,\"updateTime\":\"2021-05-27T09:40:19\",\"updateUser\":1}]','2026-04-04 17:39:51');
/*!40000 ALTER TABLE `ai_chat_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcement`
--

DROP TABLE IF EXISTS `announcement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcement` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcement`
--

LOCK TABLES `announcement` WRITE;
/*!40000 ALTER TABLE `announcement` DISABLE KEYS */;
INSERT INTO `announcement` VALUES (1,'欢迎使用智慧餐饮系统','尊敬的用户，欢迎使用我们的智慧餐饮系统！您可以在线点餐、查看菜品、使用优惠券等功能。祝您用餐愉快！',1,0,1,'2025-11-22 19:50:16','2025-12-22 19:50:16','2025-11-22 19:50:16','2025-11-22 19:50:16',NULL,NULL),(2,'新用户福利来袭','新注册用户可领取5元优惠券，满50元即可使用！机不可失，快来领取吧！',2,1,1,'2025-11-22 19:50:16','2025-11-29 19:50:16','2025-11-22 19:50:16','2025-11-23 16:32:39',NULL,1),(3,'周末特惠活动','本周末全场8折优惠！更有多款特色菜品限时供应，敬请期待！',2,1,1,'2025-11-22 19:50:16','2025-11-25 19:50:16','2025-11-22 19:50:16','2025-11-22 19:50:16',NULL,NULL);
/*!40000 ALTER TABLE `announcement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `balance_record`
--

DROP TABLE IF EXISTS `balance_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `balance_record` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `amount` decimal(10,2) NOT NULL COMMENT '金额变化（正数为充值，负数为消费）',
  `type` int NOT NULL COMMENT '类型 1:充值 2:消费 3:退款',
  `balance_before` decimal(10,2) NOT NULL COMMENT '变动前余额',
  `balance_after` decimal(10,2) NOT NULL COMMENT '变动后余额',
  `description` varchar(200) DEFAULT NULL COMMENT '说明',
  `order_id` bigint DEFAULT NULL COMMENT '关联订单ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='余额变动记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `balance_record`
--

LOCK TABLES `balance_record` WRITE;
/*!40000 ALTER TABLE `balance_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `balance_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `canteen`
--

DROP TABLE IF EXISTS `canteen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `canteen` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '餐厅名称',
  `location` varchar(200) DEFAULT NULL COMMENT '位置',
  `description` varchar(500) DEFAULT NULL COMMENT '餐厅描述',
  `image` varchar(200) DEFAULT NULL COMMENT '餐厅图片',
  `address` varchar(200) DEFAULT NULL COMMENT '餐厅地址',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `business_hours` varchar(100) DEFAULT NULL COMMENT '营业时间',
  `rating` decimal(3,1) DEFAULT '4.5' COMMENT '评分',
  `distance` int DEFAULT '0' COMMENT '距离（米）',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态 0:停业 1:营业',
  `is_teacher_canteen` tinyint(1) DEFAULT '0' COMMENT '是否为教师食堂：0-否，1-是',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='餐厅信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canteen`
--

LOCK TABLES `canteen` WRITE;
/*!40000 ALTER TABLE `canteen` DISABLE KEYS */;
INSERT INTO `canteen` VALUES (1,'第一食堂',NULL,'提供多种中式菜品，价格实惠','0cd45fa7-fdef-4e66-b3bb-7adbadbfe496.jpg','校园东区','0371-12345678','07:00-21:00',4.6,100,1,0,1,'2025-11-22 18:22:58','2025-11-23 17:37:42',NULL,NULL),(2,'第二食堂',NULL,'清真餐厅，环境优雅','29d61365-fb54-4e18-8349-51a872a668ed.jpg','校园西区','0371-12345679','07:00-21:00',4.5,200,1,0,2,'2025-11-22 18:22:58','2025-11-23 17:37:54',NULL,NULL),(3,'第三食堂',NULL,'特色小吃，品种丰富','ccd9f6cf-da48-4067-9eda-76b05c9247ea.jpg','校园南区','0371-12345680','07:00-21:00',4.7,150,1,0,3,'2025-11-22 18:22:58','2025-11-23 17:38:03',NULL,1992198172637925377),(999,'教师专属食堂',NULL,'专为教职工提供的优质餐饮服务，营养均衡，环境优雅','teacher_canteen.jpg','行政楼一层西侧','0571-88888888','07:00-20:00',5.0,200,1,0,999,'2025-11-23 18:10:14','2025-11-23 18:13:37',NULL,NULL);
/*!40000 ALTER TABLE `canteen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `canteen_config`
--

DROP TABLE IF EXISTS `canteen_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `canteen_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `canteen_id` bigint NOT NULL COMMENT '食堂ID',
  `is_teacher_only` tinyint DEFAULT '0' COMMENT '是否仅限教师 0:否 1:是',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_canteen_id` (`canteen_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='食堂配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canteen_config`
--

LOCK TABLES `canteen_config` WRITE;
/*!40000 ALTER TABLE `canteen_config` DISABLE KEYS */;
INSERT INTO `canteen_config` VALUES (1,4,1,'2025-11-23 17:46:34','2025-11-23 17:46:34'),(2,999,1,'2025-11-23 18:10:14','2025-11-23 18:13:37');
/*!40000 ALTER TABLE `canteen_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` bigint NOT NULL COMMENT '主键',
  `type` int DEFAULT NULL COMMENT '类型   1 菜品分类 2 套餐分类',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '分类名称',
  `sort` int NOT NULL DEFAULT '0' COMMENT '顺序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='菜品及套餐分类';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (9991,1,'营养套餐',1,'2025-11-23 18:16:54','2025-11-23 18:17:44',1,1),(9992,1,'特色小炒',2,'2025-11-23 18:16:54','2025-11-23 18:17:44',1,1),(9993,1,'养生汤品',3,'2025-11-23 18:16:54','2025-11-23 18:17:44',1,1),(9994,1,'健康主食',4,'2025-11-23 18:16:54','2025-11-23 18:17:44',1,1),(1397844263642378242,1,'湘菜',1,'2021-05-27 09:16:58','2021-07-15 20:25:23',1,1),(1397844303408574465,1,'川菜',2,'2021-05-27 09:17:07','2021-06-02 14:27:22',1,1),(1397844391040167938,1,'粤菜',3,'2021-05-27 09:17:28','2021-07-09 14:37:13',1,1),(1413341197421846529,1,'饮品',11,'2021-07-09 11:36:15','2021-07-09 14:39:15',1,1),(1413342269393674242,2,'商务套餐',5,'2021-07-09 11:40:30','2021-07-09 14:43:45',1,1),(1413384954989060097,1,'主食',12,'2021-07-09 14:30:07','2021-07-09 14:39:19',1,1),(1413386191767674881,2,'儿童套餐',6,'2021-07-09 14:35:02','2021-07-09 14:39:05',1,1);
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon`
--

DROP TABLE IF EXISTS `coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '优惠券名称',
  `amount` decimal(10,2) NOT NULL COMMENT '优惠金额（分）',
  `min_amount` decimal(10,2) NOT NULL COMMENT '最低消费金额（分）',
  `type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'normal' COMMENT '类型：normal-普通券，newbie-新人券，points-积分券',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID（商家券专用）',
  `description` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '描述',
  `total_count` int NOT NULL DEFAULT '0' COMMENT '总数量',
  `remain_count` int NOT NULL DEFAULT '0' COMMENT '剩余数量',
  `valid_days` int NOT NULL DEFAULT '30' COMMENT '有效天数',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='优惠券表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon`
--

LOCK TABLES `coupon` WRITE;
/*!40000 ALTER TABLE `coupon` DISABLE KEYS */;
INSERT INTO `coupon` VALUES (1,'新人专享券',1000.00,3000.00,'1',NULL,'新用户专享，满30减10',1000,999,30,1,'2025-11-23 18:02:02','2026-04-04 17:32:31',NULL,2040361841687126018),(2,'满减优惠券',500.00,2000.00,'1',NULL,'全场通用，满20减5',500,499,30,1,'2025-11-23 18:02:02','2026-04-04 17:32:31',NULL,2040361841687126018),(3,'商家专属券',800.00,2500.00,'2',1,'本店专用，满25减8',200,200,15,1,'2025-11-23 18:02:02','2025-11-23 18:02:02',NULL,NULL);
/*!40000 ALTER TABLE `coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dish`
--

DROP TABLE IF EXISTS `dish`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dish` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '菜品名称',
  `category_id` bigint NOT NULL COMMENT '菜品分类id',
  `merchant_id` bigint DEFAULT NULL COMMENT '所属商家ID',
  `canteen_id` bigint DEFAULT NULL COMMENT '所属餐厅ID',
  `price` decimal(10,2) DEFAULT NULL COMMENT '菜品价格',
  `code` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '菜品编码',
  `image` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '图片',
  `description` varchar(400) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '描述信息',
  `stock` int NOT NULL DEFAULT '999' COMMENT '库存数量',
  `calories` int DEFAULT NULL COMMENT '卡路里（千卡/份）',
  `protein` decimal(5,1) DEFAULT NULL COMMENT '蛋白质（克/份）',
  `fat` decimal(5,1) DEFAULT NULL COMMENT '脂肪（克/份）',
  `carbs` decimal(5,1) DEFAULT NULL COMMENT '碳水化合物（克/份）',
  `fiber` decimal(5,1) DEFAULT NULL COMMENT '膳食纤维（克/份）',
  `nutrition_tags` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '营养标签',
  `status` int NOT NULL DEFAULT '1' COMMENT '0 停售 1 起售',
  `sort` int NOT NULL DEFAULT '0' COMMENT '顺序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_dish_name` (`name`),
  KEY `idx_canteen_id` (`canteen_id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='菜品管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dish`
--

LOCK TABLES `dish` WRITE;
/*!40000 ALTER TABLE `dish` DISABLE KEYS */;
INSERT INTO `dish` VALUES (99901,'营养早餐套餐',9991,10,999,1500.00,'D99901','breakfast_set.jpg','牛奶+鸡蛋+全麦面包+水果',999,NULL,NULL,NULL,NULL,NULL,NULL,1,1,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99902,'精品商务套餐A',9991,10,999,2800.00,'D99902','business_set_a.jpg','荤素搭配，三菜一汤',999,NULL,NULL,NULL,NULL,NULL,NULL,1,2,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99903,'精品商务套餐B',9991,10,999,2800.00,'D99903','business_set_b.jpg','清淡养生，四菜一汤',999,NULL,NULL,NULL,NULL,NULL,NULL,1,3,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99904,'香煎挪威鳕鱼',9992,10,999,3800.00,'D99904','cod_fish.jpg','进口深海鳕鱼，低脂高蛋白',999,NULL,NULL,NULL,NULL,NULL,NULL,1,4,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99905,'黑椒牛柳',9992,10,999,3200.00,'D99905','beef_steak.jpg','优质牛里脊，口感鲜嫩',999,NULL,NULL,NULL,NULL,NULL,NULL,1,5,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99906,'清炒有机时蔬',9992,999,999,1500.00,'D99906','organic_veg.jpg','当季新鲜有机蔬菜',999,NULL,NULL,NULL,NULL,NULL,NULL,1,6,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99907,'养生乌鸡汤',9993,999,999,1800.00,'D99907','chicken_soup.jpg','滋补养生，暖心暖胃',999,NULL,NULL,NULL,NULL,NULL,NULL,1,7,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99908,'花胶鱼肚汤',9993,999,999,2500.00,'D99908','fish_maw_soup.jpg','美容养颜，胶原蛋白丰富',999,NULL,NULL,NULL,NULL,NULL,NULL,1,8,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99909,'杂粮饭',9994,999,999,500.00,'D99909','multi_grain_rice.jpg','五谷杂粮，健康主食',999,NULL,NULL,NULL,NULL,NULL,NULL,1,9,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(99910,'全麦馒头',9994,999,999,300.00,'D99910','whole_wheat_bun.jpg','粗纤维，助消化',999,NULL,NULL,NULL,NULL,NULL,NULL,1,10,'2025-11-23 18:17:44','2025-11-23 18:17:44',1,1,0),(1397849739276890114,'辣子鸡',1397844263642378242,3,1,7800.00,'222222222','014d3a61-754a-42ce-91e6-ccd318cc029b.jpg','来自鲜嫩美味的小鸡，值得一尝',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:38:43','2021-05-27 09:38:43',1,1,0),(1397850140982161409,'毛氏红烧肉',1397844263642378242,3,1,6800.00,'123412341234','0ca25a1c-fff2-4a51-81e1-b985ac28f5ec.jpg','毛氏红烧肉毛氏红烧肉，确定不来一份？',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:40:19','2021-05-27 09:40:19',1,1,0),(1397850392090947585,'组庵鱼翅',1397844263642378242,3,1,4800.00,'123412341234','267ce60f-6a2b-4a43-ba29-ac635aa98071.jpg','组庵鱼翅，看图足以表明好吃程度',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:41:19','2021-05-27 09:41:19',1,1,0),(1397850851245600769,'霸王别姬',1397844263642378242,3,1,12800.00,'123412341234','847efe88-16ed-4e5d-a03c-506ea6013dff.jpg','还有什么比霸王别姬更美味的呢？',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:43:08','2021-05-27 09:43:08',1,1,0),(1397851099502260226,'全家福',1397844263642378242,3,1,11800.00,'23412341234','880eaab0-46a6-426d-9c0b-b7d0a40ed488.jpg','别光吃肉啦，来份全家福吧，让你长寿又美味',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:44:08','2021-05-27 09:44:08',1,1,0),(1397851370462687234,'邵阳猪血丸子',1397844263642378242,3,1,13800.00,'1246812345678','9fb8fa2d-4351-4d72-9131-53dd19d6584a.jpg','看，美味不？来嘛来嘛，这才是最爱吖',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:45:12','2021-05-27 09:45:12',1,1,0),(1397851668262465537,'口味蛇',1397844263642378242,3,1,16800.00,'1234567812345678','acab7eae-c65d-4b13-a3ef-46ff521341bd.png','爬行界的扛把子，东兴-口味蛇，让你欲罢不能',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:46:23','2021-05-27 09:46:23',1,1,0),(1397852391150759938,'辣子鸡丁',1397844303408574465,9,3,8800.00,'2346812468','afc1af5f-d11b-45fd-a8a3-89fc9521bc61.jpg','辣子鸡丁，辣子鸡丁，永远的魂',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:49:16','2021-05-27 09:49:16',1,1,0),(1397853183287013378,'麻辣兔头',1397844303408574465,9,3,19800.00,'123456787654321','bfba9462-37ed-4bcf-b5a6-e8130a562053.jpg','麻辣兔头的详细制作，麻辣鲜香，色泽红润，回味悠长',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:52:24','2021-05-27 09:52:24',1,1,0),(1397853709101740034,'蒜泥白肉',1397844303408574465,9,3,9800.00,'1234321234321','e41b5ff7-fe52-4814-bee6-f8e861c37d99.jpg','多么的有食欲啊',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:54:30','2021-05-27 09:54:30',1,1,0),(1397853890262118402,'鱼香肉丝',1397844303408574465,9,3,3800.00,'1234212321234','cdc9f18d-bfd7-43ac-bd30-452e4d5e084f.jpg','鱼香肉丝简直就是我们童年回忆的一道经典菜，上学的时候点个鱼香肉丝盖饭坐在宿舍床上看着肥皂剧，绝了！现在完美复刻一下上学的时候感觉',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:55:13','2021-05-27 09:55:13',1,1,0),(1397854652581064706,'麻辣水煮鱼',1397844303408574465,9,3,14800.00,'2345312·345321','fb9b7404-dbfd-4e0b-82f3-06926090a535.jpg','鱼片是买的切好的鱼片，放几个虾，增加味道',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:58:15','2021-05-27 09:58:15',1,1,0),(1397854865672679425,'鱼香炒鸡蛋',1397844303408574465,9,3,2000.00,'23456431·23456','014d3a61-754a-42ce-91e6-ccd318cc029b.jpg','鱼香菜也是川味的特色。里面没有鱼却鱼香味',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 09:59:06','2021-05-27 09:59:06',1,1,0),(1397860242057375745,'脆皮烧鹅',1397844391040167938,7,2,12800.00,'123456786543213456','267ce60f-6a2b-4a43-ba29-ac635aa98071.jpg','“广东烤鸭美而香，却胜烧鹅说古冈（今新会），燕瘦环肥各佳妙，君休偏重便宜坊”，可见烧鹅与烧鸭在粤菜之中已早负盛名。作为广州最普遍和最受欢迎的烧烤肉食，以它的“色泽金红，皮脆肉嫩，味香可口”的特色，在省城各大街小巷的烧卤店随处可见。',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 10:20:27','2021-05-27 10:20:27',1,1,0),(1397860578738352129,'白切鸡',1397844391040167938,7,2,6600.00,'12345678654','0ca25a1c-fff2-4a51-81e1-b985ac28f5ec.jpg','白切鸡是一道色香味俱全的特色传统名肴，又叫白斩鸡，是粤菜系鸡肴中的一种，始于清代的民间。白切鸡通常选用细骨农家鸡与沙姜、蒜茸等食材，慢火煮浸白切鸡皮爽肉滑，清淡鲜美。著名的泮溪酒家白切鸡，曾获商业部优质产品金鼎奖。湛江白切鸡更是驰名粤港澳。粤菜厨坛中，鸡的菜式有200余款之多，而最为人常食不厌的正是白切鸡，深受食家青睐。',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 10:21:48','2021-05-27 10:21:48',1,1,0),(1397860792492666881,'烤乳猪',1397844391040167938,7,2,38800.00,'213456432123456','afc1af5f-d11b-45fd-a8a3-89fc9521bc61.jpg','广式烧乳猪主料是小乳猪，辅料是蒜，调料是五香粉、芝麻酱、八角粉等，本菜品主要通过将食材放入炭火中烧烤而成。烤乳猪是广州最著名的特色菜，并且是“满汉全席”中的主打菜肴之一。烤乳猪也是许多年来广东人祭祖的祭品之一，是家家都少不了的应节之物，用乳猪祭完先人后，亲戚们再聚餐食用。',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 10:22:39','2021-05-27 10:22:39',1,1,0),(1397860963880316929,'脆皮乳鸽',1397844391040167938,7,2,10800.00,'1234563212345','847efe88-16ed-4e5d-a03c-506ea6013dff.jpg','“脆皮乳鸽”是广东菜中的一道传统名菜，属于粤菜系，具有皮脆肉嫩、色泽红亮、鲜香味美的特点，常吃可使身体强健，清肺顺气。随着菜品制作工艺的不断发展，逐渐形成了熟炸法、生炸法和烤制法三种制作方法。无论那种制作方法，都是在鸽子经过一系列的加工，挂脆皮水后再加工而成，正宗的“脆皮乳鸽皮脆肉嫩、色泽红亮、鲜香味美、香气馥郁。这三种方法的制作过程都不算复杂，但想达到理想的效果并不容易。',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 10:23:19','2021-05-27 10:23:19',1,1,0),(1397861683434139649,'清蒸河鲜海鲜',1397844391040167938,7,2,38800.00,'1234567876543213456','880eaab0-46a6-426d-9c0b-b7d0a40ed488.jpg','新鲜的海鲜，清蒸是最好的处理方式。鲜，体会为什么叫海鲜。清蒸是广州最经典的烹饪手法，过去岭南地区由于峻山大岭阻隔，交通不便，经济发展起步慢，自家打的鱼放在锅里煮了就吃，没有太多的讲究，但却发现这清淡的煮法能使鱼的鲜甜跃然舌尖。',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 10:26:11','2021-05-27 10:26:11',1,1,0),(1397862198033297410,'老火靓汤',1397844391040167938,7,2,49800.00,'123456786532455','9fb8fa2d-4351-4d72-9131-53dd19d6584a.jpg','老火靓汤又称广府汤，是广府人传承数千年的食补养生秘方，慢火煲煮的中华老火靓汤，火候足，时间长，既取药补之效，又取入口之甘甜。 广府老火汤种类繁多，可以用各种汤料和烹调方法，烹制出各种不同口味、不同功效的汤来。',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 10:28:14','2021-05-27 10:28:14',1,1,0),(1397862477831122945,'上汤焗龙虾',1397844391040167938,7,2,108800.00,'1234567865432','acab7eae-c65d-4b13-a3ef-46ff521341bd.png','上汤焗龙虾是一道色香味俱全的传统名菜，属于粤菜系。此菜以龙虾为主料，配以高汤制成的一道海鲜美食。本品肉质洁白细嫩，味道鲜美，蛋白质含量高，脂肪含量低，营养丰富。是色香味俱全的传统名菜。',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-05-27 10:29:20','2021-05-27 10:29:20',1,1,0),(1413342036832100354,'北冰洋',1413341197421846529,4,1,500.00,'','bfba9462-37ed-4bcf-b5a6-e8130a562053.jpg','',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-07-09 11:39:35','2021-07-09 15:12:18',1,1,0),(1413384757047271425,'王老吉',1413341197421846529,4,1,500.00,'','dbe27fff-d74d-43a6-927d-11d6889782e4.jpg','',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-07-09 14:29:20','2025-11-23 15:47:59',1,1992198172637925377,0),(1413385247889891330,'米饭',1413384954989060097,4,1,200.00,'','cdc9f18d-bfd7-43ac-bd30-452e4d5e084f.jpg','',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2021-07-09 14:31:17','2021-07-11 16:35:26',1,1,0),(1992564785988071426,'11111111111',9991,1,NULL,20000.00,NULL,'e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg','',999,NULL,NULL,NULL,NULL,NULL,NULL,1,0,'2025-11-23 20:04:00','2025-11-23 20:04:00',2,2,0);
/*!40000 ALTER TABLE `dish` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dish_flavor`
--

DROP TABLE IF EXISTS `dish_flavor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dish_flavor` (
  `id` bigint NOT NULL COMMENT '主键',
  `dish_id` bigint NOT NULL COMMENT '菜品',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '口味名称',
  `value` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '口味数据list',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='菜品口味关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dish_flavor`
--

LOCK TABLES `dish_flavor` WRITE;
/*!40000 ALTER TABLE `dish_flavor` DISABLE KEYS */;
INSERT INTO `dish_flavor` VALUES (1397849417888346113,1397849417854791681,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:37:27','2021-05-27 09:37:27',1,1,0),(1397849739297861633,1397849739276890114,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:38:43','2021-05-27 09:38:43',1,1,0),(1397849739323027458,1397849739276890114,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:38:43','2021-05-27 09:38:43',1,1,0),(1397849936421761025,1397849936404983809,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:39:30','2021-05-27 09:39:30',1,1,0),(1397849936438538241,1397849936404983809,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:39:30','2021-05-27 09:39:30',1,1,0),(1397850141015715841,1397850140982161409,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:40:19','2021-05-27 09:40:19',1,1,0),(1397850141040881665,1397850140982161409,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:40:19','2021-05-27 09:40:19',1,1,0),(1397850392120307713,1397850392090947585,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:41:19','2021-05-27 09:41:19',1,1,0),(1397850392137084929,1397850392090947585,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:41:19','2021-05-27 09:41:19',1,1,0),(1397850630734262274,1397850630700707841,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:42:16','2021-05-27 09:42:16',1,1,0),(1397850630755233794,1397850630700707841,'辣度','[\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:42:16','2021-05-27 09:42:16',1,1,0),(1397850851274960898,1397850851245600769,'忌口','[\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:43:08','2021-05-27 09:43:08',1,1,0),(1397850851283349505,1397850851245600769,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:43:08','2021-05-27 09:43:08',1,1,0),(1397851099523231745,1397851099502260226,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:44:08','2021-05-27 09:44:08',1,1,0),(1397851099527426050,1397851099502260226,'辣度','[\"不辣\",\"微辣\",\"中辣\"]','2021-05-27 09:44:08','2021-05-27 09:44:08',1,1,0),(1397851370483658754,1397851370462687234,'温度','[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]','2021-05-27 09:45:12','2021-05-27 09:45:12',1,1,0),(1397851370483658755,1397851370462687234,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:45:12','2021-05-27 09:45:12',1,1,0),(1397851370483658756,1397851370462687234,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:45:12','2021-05-27 09:45:12',1,1,0),(1397851668283437058,1397851668262465537,'温度','[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]','2021-05-27 09:46:23','2021-05-27 09:46:23',1,1,0),(1397852391180120065,1397852391150759938,'忌口','[\"不要葱\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:49:16','2021-05-27 09:49:16',1,1,0),(1397852391196897281,1397852391150759938,'辣度','[\"不辣\",\"微辣\",\"重辣\"]','2021-05-27 09:49:16','2021-05-27 09:49:16',1,1,0),(1397853183307984898,1397853183287013378,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:52:24','2021-05-27 09:52:24',1,1,0),(1397853423486414850,1397853423461249026,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:53:22','2021-05-27 09:53:22',1,1,0),(1397853709126905857,1397853709101740034,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:54:30','2021-05-27 09:54:30',1,1,0),(1397853890283089922,1397853890262118402,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:55:13','2021-05-27 09:55:13',1,1,0),(1397854133632413697,1397854133603053569,'温度','[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]','2021-05-27 09:56:11','2021-05-27 09:56:11',1,1,0),(1397854652623007745,1397854652581064706,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 09:58:15','2021-05-27 09:58:15',1,1,0),(1397854652635590658,1397854652581064706,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:58:15','2021-05-27 09:58:15',1,1,0),(1397854865735593986,1397854865672679425,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 09:59:06','2021-05-27 09:59:06',1,1,0),(1397855742303186946,1397855742273826817,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:02:35','2021-05-27 10:02:35',1,1,0),(1397855906497605633,1397855906468245506,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 10:03:14','2021-05-27 10:03:14',1,1,0),(1397856190573621250,1397856190540066818,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:04:21','2021-05-27 10:04:21',1,1,0),(1397859056709316609,1397859056684150785,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:15:45','2021-05-27 10:15:45',1,1,0),(1397859277837217794,1397859277812051969,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:16:37','2021-05-27 10:16:37',1,1,0),(1397859487502086146,1397859487476920321,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:17:27','2021-05-27 10:17:27',1,1,0),(1397859757061615618,1397859757036449794,'甜味','[\"无糖\",\"少糖\",\"半躺\",\"多糖\",\"全糖\"]','2021-05-27 10:18:32','2021-05-27 10:18:32',1,1,0),(1397860242086735874,1397860242057375745,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:20:27','2021-05-27 10:20:27',1,1,0),(1397860963918065665,1397860963880316929,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:23:19','2021-05-27 10:23:19',1,1,0),(1397861135754506242,1397861135733534722,'甜味','[\"无糖\",\"少糖\",\"半躺\",\"多糖\",\"全糖\"]','2021-05-27 10:24:00','2021-05-27 10:24:00',1,1,0),(1397861370035744769,1397861370010578945,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-27 10:24:56','2021-05-27 10:24:56',1,1,0),(1397861683459305474,1397861683434139649,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 10:26:11','2021-05-27 10:26:11',1,1,0),(1397861898467717121,1397861898438356993,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 10:27:02','2021-05-27 10:27:02',1,1,0),(1397862198054268929,1397862198033297410,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-27 10:28:14','2021-05-27 10:28:14',1,1,0),(1397862477835317250,1397862477831122945,'辣度','[\"不辣\",\"微辣\",\"中辣\"]','2021-05-27 10:29:20','2021-05-27 10:29:20',1,1,0),(1398089545865015297,1398089545676271617,'温度','[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]','2021-05-28 01:31:38','2021-05-28 01:31:38',1,1,0),(1398089782323097601,1398089782285348866,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:32:34','2021-05-28 01:32:34',1,1,0),(1398090003262255106,1398090003228700673,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-28 01:33:27','2021-05-28 01:33:27',1,1,0),(1398090264554811394,1398090264517062657,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-28 01:34:29','2021-05-28 01:34:29',1,1,0),(1398090455399837698,1398090455324340225,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:35:14','2021-05-28 01:35:14',1,1,0),(1398090685449023490,1398090685419663362,'温度','[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]','2021-05-28 01:36:09','2021-05-28 01:36:09',1,1,0),(1398090825358422017,1398090825329061889,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-28 01:36:43','2021-05-28 01:36:43',1,1,0),(1398091007051476993,1398091007017922561,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:37:26','2021-05-28 01:37:26',1,1,0),(1398091296164851713,1398091296131297281,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:38:35','2021-05-28 01:38:35',1,1,0),(1398091546531246081,1398091546480914433,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]','2021-05-28 01:39:35','2021-05-28 01:39:35',1,1,0),(1398091729809747969,1398091729788776450,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:40:18','2021-05-28 01:40:18',1,1,0),(1398091889499484161,1398091889449152513,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:40:56','2021-05-28 01:40:56',1,1,0),(1398092095179763713,1398092095142014978,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:41:45','2021-05-28 01:41:45',1,1,0),(1398092283877306370,1398092283847946241,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:42:30','2021-05-28 01:42:30',1,1,0),(1398094018939236354,1398094018893099009,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:49:24','2021-05-28 01:49:24',1,1,0),(1398094391494094850,1398094391456346113,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-05-28 01:50:53','2021-05-28 01:50:53',1,1,0),(1399574026165727233,1399305325713600514,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]','2021-06-01 03:50:25','2021-06-01 03:50:25',1399309715396669441,1399309715396669441,0),(1413389684020682754,1413342036832100354,'温度','[\"常温\",\"冷藏\"]','2021-07-09 15:12:18','2021-07-09 15:12:18',1,1,0);
/*!40000 ALTER TABLE `dish_flavor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '姓名',
  `username` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '用户名',
  `password` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '密码',
  `phone` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '手机号',
  `sex` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '性别',
  `id_number` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '身份证号',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态 0:禁用，1:正常',
  `role` varchar(20) COLLATE utf8mb3_bin DEFAULT 'staff' COMMENT '角色 admin:管理员 merchant:商家 staff:员工',
  `merchant_id` bigint DEFAULT NULL COMMENT '关联的商家ID（商家角色专用）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='员工信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,'超级管理员','admin','e10adc3949ba59abbe56e057f20f883e','13800000001','1','110101199001010001',1,'staff',NULL,'2025-11-23 16:06:35','2025-11-23 16:06:35',1,1),(2,'张三','zhangsan','e10adc3949ba59abbe56e057f20f883e','13800000002','1','110101199001010002',1,'merchant',1,'2025-11-23 16:06:35','2025-11-23 16:06:35',1,1),(3,'李四','staff','e10adc3949ba59abbe56e057f20f883e','13800000003','0','110101199001010003',1,'staff',NULL,'2025-11-23 16:06:35','2025-11-23 16:06:35',1,1),(4,'李四','lisi','e10adc3949ba59abbe56e057f20f883e','13800000002','1','110101199001010012',1,'merchant',2,'2025-11-23 19:06:39','2025-11-23 19:06:39',1,1),(5,'王五','wangwu','e10adc3949ba59abbe56e057f20f883e','13800000003','1','110101199001010013',1,'merchant',3,'2025-11-23 19:06:39','2025-11-23 19:06:39',1,1),(10,'张老板','merchant1','e10adc3949ba59abbe56e057f20f883e','13800001001','1','110101198001011001',1,'merchant',10,'2025-11-23 20:02:35','2025-11-23 20:02:35',1,1),(11,'李老板','merchant2','e10adc3949ba59abbe56e057f20f883e','13800001002','1','110101198001011002',1,'merchant',11,'2025-11-23 20:02:35','2025-11-23 20:02:35',1,1);
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `type` varchar(50) NOT NULL COMMENT '反馈类型',
  `content` text NOT NULL COMMENT '反馈内容',
  `images` varchar(500) DEFAULT NULL COMMENT '图片URL',
  `contact` varchar(100) DEFAULT NULL COMMENT '联系方式',
  `status` int DEFAULT '0' COMMENT '状态 0:待处理 1:处理中 2:已处理',
  `reply` text COMMENT '回复内容',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='意见反馈表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_category`
--

DROP TABLE IF EXISTS `food_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类标识（如：bbq, noodle, rice）',
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称（如：烧烤、面食、盖饭）',
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类图标（emoji或图片URL）',
  `bg_color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '#FEF3C7' COMMENT '背景颜色（十六进制）',
  `keyword` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '搜索关键词',
  `sort` int DEFAULT '0' COMMENT '排序',
  `status` int DEFAULT '1' COMMENT '状态 0:禁用 1:启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='美食分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_category`
--

LOCK TABLES `food_category` WRITE;
/*!40000 ALTER TABLE `food_category` DISABLE KEYS */;
INSERT INTO `food_category` VALUES (1,'bbq','烧烤','🍢','#FEF3C7','烧烤',1,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(2,'night','夜宵','🌙','#E0E7FF','夜宵',2,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(3,'noodle','面食','🍜','#FCE7F3','面',3,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(4,'rice','盖饭','🍚','#D1FAE5','饭',4,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(5,'hotpot','火锅','🍲','#FEE2E2','火锅',5,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(6,'snack','小吃','🥟','#FEF9C3','小吃',6,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(7,'drink','饮品','🧋','#CFFAFE','饮品',7,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(8,'dessert','甜品','🍰','#FCE7F3','甜品',8,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(9,'western','西餐','🍔','#FFEDD5','西餐',9,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(10,'healthy','轻食','🥗','#DCFCE7','轻食',10,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(11,'sichuan','川菜','🌶️','#FEE2E2','川菜',11,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(12,'cantonese','粤菜','🥢','#FEF3C7','粤菜',12,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(13,'japanese','日料','🍣','#FECACA','日料',13,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(14,'korean','韩餐','🍱','#E0E7FF','韩餐',14,1,'2025-11-29 15:44:50','2025-11-29 15:44:50'),(15,'breakfast','早餐','🥐','#FEF3C7','早餐',15,1,'2025-11-29 15:44:50','2025-11-29 15:44:50');
/*!40000 ALTER TABLE `food_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant`
--

DROP TABLE IF EXISTS `merchant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `canteen_id` bigint NOT NULL COMMENT '所属食堂ID',
  `name` varchar(100) NOT NULL COMMENT '商家名称',
  `window_number` varchar(20) DEFAULT NULL COMMENT '窗口号',
  `contact` varchar(50) DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `description` varchar(500) DEFAULT NULL COMMENT '商家简介',
  `image` varchar(200) DEFAULT NULL COMMENT '商家图片',
  `employee_id` bigint DEFAULT NULL COMMENT '关联员工ID（登录账号）',
  `application_id` bigint DEFAULT NULL COMMENT '关联的申请ID',
  `avg_price` decimal(10,2) DEFAULT NULL COMMENT '人均消费',
  `rating` decimal(3,2) DEFAULT '5.00' COMMENT '评分(0-5)',
  `sales_count` int DEFAULT '0' COMMENT '月销量',
  `total_reviews` int DEFAULT '0' COMMENT '总评价数',
  `positive_count` int DEFAULT '0' COMMENT '好评数（用于红榜统计）',
  `negative_count` int DEFAULT '0' COMMENT '差评数（用于黑榜统计）',
  `wechat_group_qrcode` varchar(500) DEFAULT NULL COMMENT '微信社群二维码',
  `tags` varchar(255) DEFAULT NULL COMMENT '商家标签（逗号分隔）',
  `promo` varchar(100) DEFAULT NULL COMMENT '优惠信息',
  `delivery_time` int DEFAULT '20' COMMENT '配送时间（分钟）',
  `delivery_fee` int DEFAULT '0' COMMENT '配送费（分）',
  `min_order_amount` int DEFAULT '0' COMMENT '起送价（分）',
  `open_time` time DEFAULT '07:00:00' COMMENT '营业开始时间',
  `close_time` time DEFAULT '22:00:00' COMMENT '营业结束时间',
  `is_new` int DEFAULT '0' COMMENT '是否为新店 0:否 1:是',
  `food_category_id` bigint DEFAULT NULL COMMENT '美食分类ID',
  `sort` int DEFAULT '0' COMMENT '排序',
  `status` int DEFAULT '1' COMMENT '状态 0:停业 1:营业 2:待审核',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_canteen_id` (`canteen_id`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_status` (`status`),
  KEY `idx_merchant_positive` (`positive_count` DESC),
  KEY `idx_merchant_negative` (`negative_count` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家表（窗口）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant`
--

LOCK TABLES `merchant` WRITE;
/*!40000 ALTER TABLE `merchant` DISABLE KEYS */;
INSERT INTO `merchant` VALUES (1,2,'老张川菜','1号窗口','张三','13800000001','正宗川菜，麻辣鲜香，招牌菜：宫保鸡丁、麻婆豆腐',NULL,2,NULL,25.00,5.00,328,1,1,0,NULL,'美食,好评','第二杯半价',20,0,0,'07:00:00','22:00:00',1,NULL,1,1,'2025-11-23 16:37:51','2026-04-04 18:49:32'),(2,1,'李记面馆','2号窗口','李四','13800000002','手工拉面，汤鲜味美，招牌：牛肉拉面、鸡汤面',NULL,4,NULL,18.00,4.90,456,0,0,0,NULL,'面食,川菜,经济实惠','新客立减5元',23,0,0,'07:00:00','22:00:00',0,NULL,2,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(3,1,'王家盖浇饭','3号窗口','王五','13800000003','经济实惠，份量足，招牌：红烧肉盖饭、鱼香肉丝盖浇饭',NULL,5,NULL,15.00,4.70,267,0,0,0,NULL,'盖饭,快餐,分量足','新客立减5元',26,0,0,'07:00:00','22:00:00',0,NULL,3,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(4,1,'美味快餐','4号窗口','赵六','13800000004','快捷方便，营养均衡，招牌：汉堡套餐、鸡腿饭',NULL,NULL,NULL,20.00,4.60,198,0,0,0,NULL,'美食,好评','第二杯半价',20,0,0,'07:00:00','22:00:00',1,NULL,4,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(5,1,'香辣烧烤','5号窗口','孙七','13800000005','炭火烧烤，香辣美味',NULL,NULL,NULL,30.00,4.75,156,0,0,0,NULL,'烧烤,夜宵,人气爆棚','第二杯半价',19,0,0,'07:00:00','22:00:00',0,NULL,5,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(6,2,'湘菜馆','1号窗口','刘八','13800000006','地道湘菜，招牌：剁椒鱼头、农家小炒肉',NULL,NULL,NULL,28.00,4.75,234,0,0,0,NULL,'美食,好评','新客立减5元',23,0,0,'07:00:00','22:00:00',0,NULL,1,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(7,2,'粤菜坊','2号窗口','陈九','13800000007','清淡养生，招牌：白切鸡、清蒸鱼',NULL,NULL,NULL,32.00,4.85,189,0,0,0,NULL,'美食,好评','新客立减5元',25,0,0,'07:00:00','22:00:00',0,NULL,2,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(8,2,'东北饺子','3号窗口','赵十','13800000008','纯手工饺子，招牌：猪肉大葱、三鲜馅',NULL,NULL,NULL,22.00,4.65,143,0,0,0,NULL,'美食,好评','新客立减5元',19,0,0,'07:00:00','22:00:00',0,NULL,3,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(9,3,'特色小吃','1号窗口','周十一','13800000009','各地小吃汇聚',NULL,NULL,NULL,16.00,4.70,298,0,0,0,NULL,'美食,好评',NULL,24,0,0,'07:00:00','22:00:00',0,NULL,1,1,'2025-11-23 16:37:51','2025-11-23 16:37:51'),(10,3,'美味早餐铺','2号窗口','吴十二','13800000010','专注营养早餐，健康每一天',NULL,10,NULL,24.00,4.55,87,0,0,0,NULL,'美食,好评',NULL,28,0,0,'07:00:00','22:00:00',1,NULL,2,1,'2025-11-23 16:37:51','2025-11-23 20:02:35'),(11,1,'经典川菜馆','2号窗口','李老板','13800001002','地道川味，麻辣鲜香','http://localhost:8080/common/download?name=0cd45fa7-fdef-4e66-b3bb-7adbadbfe496.jpg',11,NULL,30.00,4.70,256,0,0,0,NULL,'美食,好评','满30减10',16,0,0,'07:00:00','22:00:00',0,NULL,0,1,'2025-11-23 20:02:35','2025-11-23 20:02:35'),(999,999,'教师餐厅·雅座',NULL,NULL,'0571-88888888','高品质教师专属餐厅，提供精致餐食','teacher_merchant.jpg',NULL,NULL,NULL,5.00,0,0,0,0,NULL,'美食,好评','满30减10',29,0,0,'07:00:00','22:00:00',1,NULL,999,1,'2025-11-23 18:15:47','2025-11-23 18:17:44');
/*!40000 ALTER TABLE `merchant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_announcement`
--

DROP TABLE IF EXISTS `merchant_announcement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_announcement` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `title` varchar(100) NOT NULL COMMENT '公告标题',
  `content` varchar(500) NOT NULL COMMENT '公告内容',
  `type` tinyint DEFAULT '0' COMMENT '公告类型 0:普通公告 1:优惠活动 2:重要通知',
  `status` tinyint DEFAULT '1' COMMENT '状态 0:停用 1:启用',
  `sort` int DEFAULT '0' COMMENT '排序（数字越大优先级越高）',
  `start_time` datetime DEFAULT NULL COMMENT '生效时间',
  `end_time` datetime DEFAULT NULL COMMENT '失效时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_announcement`
--

LOCK TABLES `merchant_announcement` WRITE;
/*!40000 ALTER TABLE `merchant_announcement` DISABLE KEYS */;
INSERT INTO `merchant_announcement` VALUES (1,1,'今日特价','红烧肉盖饭限时优惠，原价15元，现价12元！',1,1,10,'2025-11-23 17:35:00','2025-11-30 17:35:00','2025-11-23 17:35:00','2025-11-23 17:35:00',NULL,NULL),(2,1,'营业时间调整','本店营业时间调整为：早上7:00-晚上8:00',2,1,5,'2025-11-23 17:35:00',NULL,'2025-11-23 17:35:00','2025-11-23 17:35:00',NULL,NULL),(3,2,'新品上市','鱼香肉丝盖饭隆重推出，欢迎品尝！',0,1,8,'2025-11-23 17:35:00',NULL,'2025-11-23 17:35:00','2025-11-23 17:35:00',NULL,NULL),(4,3,'王家盖浇饭优惠活动','本周所有盖浇饭立减3元，欢迎光临！',1,1,10,'2025-11-23 17:35:00','2025-11-30 17:35:00','2025-11-23 17:35:00','2025-11-23 17:35:00',NULL,NULL),(5,3,'注意事项','用餐高峰期请耐心等待，感谢您的理解与支持！',0,1,3,'2025-11-23 17:35:00',NULL,'2025-11-23 17:35:00','2025-11-23 17:35:00',NULL,NULL),(6,10,'11111111111111','11111111111111',0,1,0,NULL,NULL,'2025-11-23 20:25:50','2025-11-23 20:25:50',10,10),(7,1,'测试','测试',0,1,0,NULL,NULL,'2026-04-04 18:42:50','2026-04-04 18:42:50',2,2);
/*!40000 ALTER TABLE `merchant_announcement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_application`
--

DROP TABLE IF EXISTS `merchant_application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_application` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `canteen_id` bigint NOT NULL COMMENT '申请的食堂ID',
  `name` varchar(50) NOT NULL COMMENT '商家名称',
  `window_number` varchar(20) DEFAULT NULL COMMENT '申请窗口号',
  `contact` varchar(50) NOT NULL COMMENT '联系人',
  `phone` varchar(20) NOT NULL COMMENT '联系电话',
  `description` varchar(500) DEFAULT NULL COMMENT '商家简介',
  `business_license` varchar(200) DEFAULT NULL COMMENT '营业执照照片',
  `avg_price` decimal(10,2) DEFAULT NULL COMMENT '人均消费',
  `id_card` varchar(18) NOT NULL COMMENT '经营者身份证号',
  `owner_name` varchar(50) NOT NULL COMMENT '经营者姓名',
  `username` varchar(50) NOT NULL COMMENT '登录用户名',
  `password` varchar(200) NOT NULL COMMENT '登录密码(加密后)',
  `status` tinyint DEFAULT '0' COMMENT '审核状态 0:待审核 1:已通过 2:已拒绝',
  `audit_remark` varchar(500) DEFAULT NULL COMMENT '审核备注',
  `audit_user_id` bigint DEFAULT NULL COMMENT '审核人ID',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `merchant_id` bigint DEFAULT NULL COMMENT '关联的商家ID（审核通过后创建）',
  `employee_id` bigint DEFAULT NULL COMMENT '关联的员工ID（审核通过后创建）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  KEY `idx_phone` (`phone`),
  KEY `idx_status` (`status`),
  KEY `idx_canteen_id` (`canteen_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家入驻申请表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_application`
--

LOCK TABLES `merchant_application` WRITE;
/*!40000 ALTER TABLE `merchant_application` DISABLE KEYS */;
/*!40000 ALTER TABLE `merchant_application` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_settings`
--

DROP TABLE IF EXISTS `merchant_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_settings` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `auto_accept_order` tinyint DEFAULT '0' COMMENT '自动接单 0:关闭 1:开启',
  `business_hours_start` time DEFAULT NULL COMMENT '营业开始时间',
  `business_hours_end` time DEFAULT NULL COMMENT '营业结束时间',
  `min_order_amount` decimal(10,2) DEFAULT '0.00' COMMENT '起送金额',
  `notice_sound` tinyint DEFAULT '1' COMMENT '订单提示音 0:关闭 1:开启',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家设置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_settings`
--

LOCK TABLES `merchant_settings` WRITE;
/*!40000 ALTER TABLE `merchant_settings` DISABLE KEYS */;
INSERT INTO `merchant_settings` VALUES (1,1,1,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2026-04-04 18:42:59',NULL,2),(2,2,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(3,3,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(4,4,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(5,5,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(6,6,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(7,7,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(8,8,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(9,9,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(10,10,1,NULL,NULL,30.00,1,'2025-11-23 18:58:02','2025-11-23 20:26:48',NULL,10),(11,999,0,NULL,NULL,0.00,1,'2025-11-23 18:58:02','2025-11-23 18:58:02',NULL,NULL),(16,11,0,'10:00:00','20:00:00',0.00,1,'2025-11-23 20:02:35','2025-11-23 20:02:35',11,11);
/*!40000 ALTER TABLE `merchant_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '接收用户ID',
  `from_user_id` bigint DEFAULT NULL COMMENT '发送用户ID（系统消息为空）',
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息类型：like=点赞, comment=评论, collect=收藏, system=系统',
  `content` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `note_id` bigint DEFAULT NULL COMMENT '关联笔记ID',
  `is_read` tinyint DEFAULT '0' COMMENT '是否已读 0:未读 1:已读',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_type` (`type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=2040381605436268547 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
INSERT INTO `message` VALUES (1,1,2,'like','赞了你的帖子',1,0,'2025-11-29 16:37:26'),(2,1,3,'comment','评论了你的帖子：看着就很有食欲！',1,0,'2025-11-29 16:37:26'),(3,1,NULL,'system','欢迎加入校园美食社区！发布帖子可以获得经验哦~',NULL,1,'2025-11-29 16:37:26'),(2040371173140992001,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:09:31'),(2040371185468051458,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:09:34'),(2040371223845933058,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:09:43'),(2040371590394646529,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:11:10'),(2040371599823441921,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:11:12'),(2040372510440394754,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:14:49'),(2040372517675569153,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:14:51'),(2040372562005168130,2040361841687126018,2,'merchant_chat','111',NULL,1,'2026-04-04 18:15:02'),(2040372980881920002,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:16:42'),(2040373031297454082,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:16:54'),(2040373065053212673,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:17:02'),(2040373082056921089,2,2040361841687126018,'merchant_chat','1111',NULL,1,'2026-04-04 18:17:06'),(2040373161098579970,2040361841687126018,2,'merchant_chat','111',NULL,1,'2026-04-04 18:17:25'),(2040373632248942594,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:19:17'),(2040373933404094466,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:20:29'),(2040373941184528385,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:20:31'),(2040374053847728130,2040361841687126018,2,'merchant_chat','111',NULL,1,'2026-04-04 18:20:57'),(2040374084164157442,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:21:05'),(2040374714920443906,2040361841687126018,2,'merchant_chat','111',NULL,1,'2026-04-04 18:23:35'),(2040374733761257473,2040361841687126018,2,'merchant_chat','1111',NULL,1,'2026-04-04 18:23:40'),(2040375387598655490,2040361841687126018,2,'merchant_chat','111',NULL,1,'2026-04-04 18:26:15'),(2040375487494393857,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:26:39'),(2040375497728495617,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:26:42'),(2040375792269299713,2,2040361841687126018,'merchant_chat','111',NULL,1,'2026-04-04 18:27:52'),(2040377027714125825,2,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040368569946247169 的进度。',NULL,1,'2026-04-04 18:32:46'),(2040377219557367810,2040361841687126018,1,'merchant_chat','1',NULL,1,'2026-04-04 18:33:32'),(2040377232979140609,2040361841687126018,1,'merchant_chat','1',NULL,1,'2026-04-04 18:33:35'),(2040377259575222274,1,2040361841687126018,'merchant_chat','11',NULL,0,'2026-04-04 18:33:42'),(2040379742301270018,1,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040378853008158721 的相关问题。',NULL,0,'2026-04-04 18:43:34'),(2040379751084142594,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:43:36'),(2040379771757867009,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:43:41'),(2040379883120766977,1,2040361841687126018,'merchant_chat','qqq',NULL,0,'2026-04-04 18:44:07'),(2040379896366379010,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:44:10'),(2040379911738503170,1,2040361841687126018,'merchant_chat','2222',NULL,0,'2026-04-04 18:44:14'),(2040380021289590785,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:44:40'),(2040380027396497409,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:44:42'),(2040380036556857346,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:44:44'),(2040380630583549954,1,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040378853008158721 的相关问题。',NULL,0,'2026-04-04 18:47:05'),(2040380637361545218,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:47:07'),(2040380946263646210,1,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040378853008158721 的相关问题。',NULL,0,'2026-04-04 18:48:21'),(2040380986994532354,1,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040378853008158721 的相关问题。',NULL,0,'2026-04-04 18:48:30'),(2040381019353587714,1,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040378853008158721 的相关问题。',NULL,0,'2026-04-04 18:48:38'),(2040381052253708290,1,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040378853008158721 的相关问题。',NULL,0,'2026-04-04 18:48:46'),(2040381584145981441,1,2040361841687126018,'merchant_chat','您好，我想咨询订单 2040378853008158721 的相关问题。',NULL,0,'2026-04-04 18:50:53'),(2040381591397933057,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:50:55'),(2040381605436268546,1,2040361841687126018,'merchant_chat','111',NULL,0,'2026-04-04 18:50:58');
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note`
--

DROP TABLE IF EXISTS `note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `note` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '发布用户ID',
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '笔记标题',
  `content` text COLLATE utf8mb4_unicode_ci COMMENT '笔记内容',
  `images` text COLLATE utf8mb4_unicode_ci COMMENT '图片列表（逗号分隔）',
  `cover_image` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '封面图',
  `tags` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '标签（逗号分隔）',
  `merchant_id` bigint DEFAULT NULL COMMENT '关联商家ID',
  `dish_id` bigint DEFAULT NULL COMMENT '关联菜品ID',
  `order_id` bigint DEFAULT NULL COMMENT '关联订单ID（防止恶意刷分）',
  `like_count` int DEFAULT '0' COMMENT '点赞数',
  `collect_count` int DEFAULT '0' COMMENT '收藏数',
  `comment_count` int DEFAULT '0' COMMENT '评论数',
  `share_count` int DEFAULT '0' COMMENT '转发数',
  `view_count` int DEFAULT '0' COMMENT '浏览数',
  `status` int DEFAULT '1' COMMENT '状态 0:草稿 1:已发布 2:已删除 3:审核中',
  `is_top` int DEFAULT '0' COMMENT '是否置顶 0:否 1:是',
  `is_featured` int DEFAULT '0' COMMENT '是否精华 0:否 1:是',
  `rating_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '评价类型: positive=好评推荐, negative=吐槽避雷',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_note_rating_type` (`rating_type`),
  KEY `idx_note_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2040381245049085954 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='社区笔记表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note`
--

LOCK TABLES `note` WRITE;
/*!40000 ALTER TABLE `note` DISABLE KEYS */;
INSERT INTO `note` VALUES (1,1,'一食堂的红烧肉绝绝子！真的太好吃了😭','今天中午去一食堂吃饭，排队的人超级多！但是为了这口红烧肉一切都值得！\n\n肥而不腻，入口即化，酱汁浓郁，拌饭简直是一绝！\n\n强烈推荐大家去尝试一下！','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80','红烧肉,一食堂,美食打卡',NULL,NULL,NULL,234,56,3,20,1522,1,1,1,'positive','2025-11-29 15:58:23','2026-04-04 17:58:10'),(2,2,'发现一家超好喝的奶茶店！','就在二食堂旁边，叫茶颜悦色，他们家的幽兰拿铁真的绝了！\n\n奶香浓郁，茶味清香，甜度刚刚好，喝完一杯还想再来一杯！','https://images.unsplash.com/photo-1558857563-b371033873b8?w=600&q=80','https://images.unsplash.com/photo-1558857563-b371033873b8?w=600&q=80','奶茶,茶颜悦色,饮品推荐',NULL,NULL,NULL,189,42,5,8,985,1,0,1,'positive','2025-11-29 15:58:23','2026-04-04 17:58:15'),(3,3,'川味面馆的担担面太香了！','作为一个四川人，对担担面有着特殊的情怀。今天终于在学校找到了正宗的味道！\n\n麻辣鲜香，花生碎和芝麻酱的搭配恰到好处，面条劲道有嚼劲。','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80','担担面,川菜,面食',NULL,NULL,NULL,156,38,3,5,759,1,0,0,'negative','2025-11-29 15:58:23','2025-11-29 16:18:48'),(4,1,'轻食沙拉减脂餐分享','最近在减脂，发现学校的轻食沙拉真的很不错！\n\n蔬菜新鲜，鸡胸肉嫩滑，酱汁是油醋汁，热量很低但是味道很好！\n\n推荐给同样在减脂的小伙伴们～','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80','轻食,减脂餐,健康饮食',NULL,NULL,NULL,98,67,8,15,527,1,0,0,'positive','2025-11-29 15:58:23','2025-11-29 16:18:48'),(2040381245049085953,2040361841687126018,'111','111','http://tmp/RvOQMDPGRMWt756c463a4fc6a88bf84aab6679f18af0.jpg','http://tmp/RvOQMDPGRMWt756c463a4fc6a88bf84aab6679f18af0.jpg','',1,NULL,2040378853008158721,0,0,0,0,0,1,0,0,'positive','2026-04-04 18:49:32','2026-04-04 18:49:32');
/*!40000 ALTER TABLE `note` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note_collect`
--

DROP TABLE IF EXISTS `note_collect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `note_collect` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `note_id` bigint NOT NULL COMMENT '笔记ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_note_user` (`note_id`,`user_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1994678003870998531 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note_collect`
--

LOCK TABLES `note_collect` WRITE;
/*!40000 ALTER TABLE `note_collect` DISABLE KEYS */;
/*!40000 ALTER TABLE `note_collect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note_comment`
--

DROP TABLE IF EXISTS `note_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `note_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `note_id` bigint NOT NULL COMMENT '笔记ID',
  `user_id` bigint NOT NULL COMMENT '评论用户ID',
  `parent_id` bigint DEFAULT '0' COMMENT '父评论ID（0表示一级评论）',
  `reply_user_id` bigint DEFAULT NULL COMMENT '被回复用户ID',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `like_count` int DEFAULT '0' COMMENT '点赞数',
  `status` int DEFAULT '1' COMMENT '状态 0:已删除 1:正常',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_note_id` (`note_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1994678033705082882 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记评论表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note_comment`
--

LOCK TABLES `note_comment` WRITE;
/*!40000 ALTER TABLE `note_comment` DISABLE KEYS */;
INSERT INTO `note_comment` VALUES (1,1,2,0,NULL,'看着就很有食欲！明天去吃！',5,1,'2025-11-29 15:58:23','2025-11-29 15:58:23'),(2,1,3,0,NULL,'多少钱一份呀？',2,1,'2025-11-29 15:58:23','2025-11-29 15:58:23'),(3,1,1,2,3,'12块钱一份，超值！',1,1,'2025-11-29 15:58:23','2025-11-29 15:58:23'),(4,2,1,0,NULL,'他们家的声声乌龙也很好喝！',3,1,'2025-11-29 15:58:23','2025-11-29 15:58:23'),(5,2,4,0,NULL,'排队太久了😭',1,1,'2025-11-29 15:58:23','2025-11-29 15:58:23'),(1994678033705082881,1,1992566607716880386,0,NULL,'111',0,1,'2025-11-29 16:01:17','2025-11-29 16:01:17');
/*!40000 ALTER TABLE `note_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note_like`
--

DROP TABLE IF EXISTS `note_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `note_like` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `note_id` bigint NOT NULL COMMENT '笔记ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_note_user` (`note_id`,`user_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1994677995574665218 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='笔记点赞表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note_like`
--

LOCK TABLES `note_like` WRITE;
/*!40000 ALTER TABLE `note_like` DISABLE KEYS */;
/*!40000 ALTER TABLE `note_like` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID（为空表示系统通知）',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID',
  `title` varchar(100) NOT NULL COMMENT '通知标题',
  `content` varchar(500) NOT NULL COMMENT '通知内容',
  `notify_type` varchar(50) NOT NULL COMMENT '通知类型：NEW_ORDER/URGENT_ORDER/ORDER_STATUS/SYSTEM',
  `related_id` bigint DEFAULT NULL COMMENT '关联ID（如订单ID）',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '是否已读：0未读 1已读',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='消息通知表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_completion_log`
--

DROP TABLE IF EXISTS `order_completion_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_completion_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `dish_count` int NOT NULL DEFAULT '1' COMMENT '订单菜品数量',
  `accepted_time` datetime NOT NULL COMMENT '接单时间',
  `completed_time` datetime NOT NULL COMMENT '出餐完成时间',
  `serving_duration_seconds` int NOT NULL COMMENT '出餐耗时（秒）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_completed_time` (`completed_time`),
  KEY `idx_merchant_completed` (`merchant_id`,`completed_time`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出餐完成日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_completion_log`
--

LOCK TABLES `order_completion_log` WRITE;
/*!40000 ALTER TABLE `order_completion_log` DISABLE KEYS */;
INSERT INTO `order_completion_log` VALUES (1,2040363819934695426,1,1,'2026-04-04 17:40:17','2026-04-04 17:47:04',406,'2026-04-04 17:47:04'),(2,2040363819934695426,1,1,'2026-04-04 17:40:17','2026-04-04 17:47:14',416,'2026-04-04 17:47:14'),(3,2040363819934695426,1,1,'2026-04-04 17:40:17','2026-04-04 17:47:15',417,'2026-04-04 17:47:15'),(4,2040363819934695426,1,1,'2026-04-04 17:40:17','2026-04-04 17:47:18',421,'2026-04-04 17:47:18'),(5,2040363819934695426,1,1,'2026-04-04 17:40:17','2026-04-04 17:49:58',581,'2026-04-04 17:49:58'),(6,2040363819934695426,1,1,'2026-04-04 17:40:17','2026-04-04 17:50:08',590,'2026-04-04 17:50:08'),(7,2040363819934695426,1,1,'2026-04-04 17:40:17','2026-04-04 17:50:27',610,'2026-04-04 17:50:27'),(8,2040362254737989634,1,1,'2026-04-04 17:34:04','2026-04-04 17:51:59',1074,'2026-04-04 17:51:59'),(9,2040362254737989634,1,1,'2026-04-04 17:34:04','2026-04-04 17:52:04',1079,'2026-04-04 17:52:04'),(10,2040362254737989634,1,1,'2026-04-04 17:34:04','2026-04-04 17:52:20',1095,'2026-04-04 17:52:20'),(11,2040362254737989634,1,1,'2026-04-04 17:34:04','2026-04-04 17:52:21',1096,'2026-04-04 17:52:21'),(12,2040362254737989634,1,1,'2026-04-04 17:34:04','2026-04-04 17:55:23',1279,'2026-04-04 17:55:23'),(13,2040362254737989634,1,1,'2026-04-04 17:34:04','2026-04-04 17:55:27',1282,'2026-04-04 17:55:27'),(14,2040362254737989634,1,1,'2026-04-04 17:34:04','2026-04-04 17:55:33',1288,'2026-04-04 17:55:33'),(15,2040368569946247169,1,1,'2026-04-04 17:59:10','2026-04-04 18:10:35',684,'2026-04-04 18:10:35'),(16,2040378853008158721,1,3,'2026-04-04 18:40:02','2026-04-04 18:40:23',21,'2026-04-04 18:40:23');
/*!40000 ALTER TABLE `order_completion_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_detail`
--

DROP TABLE IF EXISTS `order_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_detail` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '名字',
  `image` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '图片',
  `order_id` bigint NOT NULL COMMENT '订单id',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品id',
  `setmeal_id` bigint DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '口味',
  `number` int NOT NULL DEFAULT '1' COMMENT '数量',
  `amount` decimal(10,2) NOT NULL COMMENT '金额',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_detail`
--

LOCK TABLES `order_detail` WRITE;
/*!40000 ALTER TABLE `order_detail` DISABLE KEYS */;
INSERT INTO `order_detail` VALUES (1992182022827003905,'口味蛇','http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg',1992182022764089346,1397851668262465537,NULL,NULL,3,16800.00),(1992183467743670275,'口味蛇','http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg',1992183467743670274,1397851668262465537,NULL,NULL,1,16800.00),(1992185254609530883,'邵阳猪血丸子','http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg',1992185254609530882,1397851370462687234,NULL,NULL,1,13800.00),(1992188067762667523,'邵阳猪血丸子','http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg',1992188067762667522,1397851370462687234,NULL,NULL,1,13800.00),(1992188505035636738,'邵阳猪血丸子','http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg',1992188505035636737,1397851370462687234,NULL,NULL,1,13800.00),(1992190168500797442,'王老吉','http://localhost:8080/common/download?name=00874a5e-0df2-446b-8f69-a30eb7d88ee8.png',1992190168500797441,1413384757047271425,NULL,NULL,1,50000.00),(1992190168500797443,'口味蛇','http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg',1992190168500797441,1397851668262465537,NULL,NULL,1,1680000.00),(1992201798269812739,'白切鸡','9ec6fc2d-50d2-422e-b954-de87dcd04198.jpeg',1992201798269812738,1397860578738352129,NULL,NULL,1,6600.00),(1992201798345310209,'清蒸河鲜海鲜','1405081e-f545-42e1-86a2-f7559ae2e276.jpeg',1992201798269812738,1397861683434139649,NULL,NULL,1,38800.00),(1992202210053984257,'白切鸡','9ec6fc2d-50d2-422e-b954-de87dcd04198.jpeg',1992202209986875393,1397860578738352129,NULL,NULL,1,6600.00),(1992202210053984258,'清蒸河鲜海鲜','1405081e-f545-42e1-86a2-f7559ae2e276.jpeg',1992202209986875393,1397861683434139649,NULL,NULL,1,38800.00),(1992205018400559105,'口味蛇','http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg',1992205018333450242,1397851668262465537,NULL,NULL,1,1680000.00),(1992456768235794433,'上汤焗龙虾','http://localhost:8080/common/download?name=5b8d2da3-3744-4bb3-acdc-329056b8259d.jpeg',1992456768206434306,1397862477831122945,NULL,NULL,1,108800.00),(1992456768235794434,'口味蛇','http://localhost:8080/common/download?name=0f4bd884-dc9c-4cf9-b59e-7d5958fec3dd.jpg',1992456768206434306,1397851668262465537,NULL,NULL,1,16800.00),(1992475003274424322,'全家福','http://localhost:8080/common/download?name=a53a4e6a-3b83-4044-87f9-9d49b30a8fdc.jpg',1992475003207315458,1397851099502260226,NULL,NULL,1,11800.00),(1992538687489290243,'精品商务套餐B','http://localhost:8080/common/download?name=business_set_b.jpg',1992538687489290242,99903,NULL,NULL,1,2800.00),(1992543188359061506,'王老吉','http://localhost:8080/common/download?name=dbe27fff-d74d-43a6-927d-11d6889782e4.jpg',1992543188359061505,1413384757047271425,NULL,NULL,1,500.00),(1992545399445225475,'北冰洋','http://localhost:8080/common/download?name=bfba9462-37ed-4bcf-b5a6-e8130a562053.jpg',1992545399445225474,1413342036832100354,NULL,NULL,1,500.00),(1992556995336765441,'营养早餐套餐','http://localhost:8080/common/download?name=breakfast_set.jpg',1992556995269656577,99901,NULL,NULL,1,1500.00),(1992557407292915715,'麻辣水煮鱼','http://localhost:8080/common/download?name=fb9b7404-dbfd-4e0b-82f3-06926090a535.jpg',1992557407292915714,1397854652581064706,NULL,NULL,1,14800.00),(1992558898904870915,'营养早餐套餐','http://localhost:8080/common/download?name=breakfast_set.jpg',1992558898904870914,99901,NULL,NULL,1,1500.00),(1992565051307159555,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',1992565051307159554,1992564785988071426,NULL,NULL,1,20000.00),(1992565533878587395,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',1992565533878587394,1992564785988071426,NULL,NULL,1,20000.00),(1992565905003188226,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',1992565905003188225,1992564785988071426,NULL,NULL,1,20000.00),(1992566640084324355,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',1992566640084324354,1992564785988071426,NULL,NULL,1,20000.00),(1992567301446373378,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',1992567301446373377,1992564785988071426,NULL,NULL,1,20000.00),(2040361930350518274,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',2040361930350518273,1992564785988071426,NULL,NULL,1,20000.00),(2040362254737989635,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',2040362254737989634,1992564785988071426,NULL,NULL,1,20000.00),(2040363820001804289,'11111111111','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80',2040363819934695426,1992564785988071426,NULL,NULL,1,20000.00),(2040368569946247170,'11111111111','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80',2040368569946247169,1992564785988071426,NULL,NULL,1,20000.00),(2040378853075267585,'11111111111','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80',2040378853008158721,1992564785988071426,NULL,NULL,1,20000.00),(2040378853075267586,'白切鸡','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80',2040378853008158721,1397860578738352000,NULL,NULL,1,6600.00),(2040378853075267587,'脆皮烧鹅','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80',2040378853008158721,1397860242057375745,NULL,NULL,1,12800.00);
/*!40000 ALTER TABLE `order_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_review`
--

DROP TABLE IF EXISTS `order_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_review` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID',
  `rating` tinyint NOT NULL COMMENT '评分(1-5星)',
  `taste_rating` tinyint DEFAULT NULL COMMENT '口味评分(1-5星)',
  `service_rating` tinyint DEFAULT NULL COMMENT '服务评分(1-5星)',
  `speed_rating` tinyint DEFAULT NULL COMMENT '速度评分(1-5星)',
  `content` varchar(500) DEFAULT NULL COMMENT '评价内容',
  `merchant_reply` text COMMENT '商家回复',
  `merchant_reply_time` datetime DEFAULT NULL COMMENT '商家回复时间',
  `images` varchar(1000) DEFAULT NULL COMMENT '评价图片（逗号分隔）',
  `is_anonymous` tinyint DEFAULT '0' COMMENT '是否匿名 0:否 1:是',
  `status` tinyint DEFAULT '1' COMMENT '状态 0:已删除 1:正常',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_rating` (`rating`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_review`
--

LOCK TABLES `order_review` WRITE;
/*!40000 ALTER TABLE `order_review` DISABLE KEYS */;
INSERT INTO `order_review` VALUES (1,1992543188359061505,1992535586128621569,NULL,5,NULL,NULL,NULL,'',NULL,NULL,NULL,0,1,'2025-11-23 18:54:51','2025-11-23 18:54:51',1992535586128621569,1992535586128621569),(2,1992567301446373377,1992566607716880386,10,5,NULL,NULL,NULL,'',NULL,NULL,NULL,0,1,'2025-11-23 20:18:20','2025-11-23 20:18:20',1992566607716880386,1992566607716880386),(3,2040368569946247169,2040361841687126018,1,5,5,5,5,'',NULL,NULL,NULL,0,1,'2026-04-04 18:11:01','2026-04-04 18:11:01',2040361841687126018,2040361841687126018);
/*!40000 ALTER TABLE `order_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint NOT NULL COMMENT '主键',
  `number` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '订单号',
  `status` int NOT NULL DEFAULT '1' COMMENT '订单状态 1待付款，2待派送，3已派送，4已完成，5已取消',
  `refund_status` tinyint DEFAULT '0' COMMENT '退款状态 0:无退款 1:申请中 2:已退款 3:退款失败',
  `refund_reason` varchar(200) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '退款原因',
  `refund_amount` decimal(10,2) DEFAULT NULL COMMENT '退款金额',
  `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
  `review_status` tinyint DEFAULT '0' COMMENT '评价状态 0:未评价 1:已评价',
  `order_type` tinyint(1) DEFAULT '1' COMMENT '订单类型：1即时订单 2预订单',
  `scheduled_time` datetime DEFAULT NULL COMMENT '预约取餐时间',
  `reserved_time` datetime DEFAULT NULL COMMENT '预约时间',
  `reserved_date` date DEFAULT NULL COMMENT '预约日期（用于查询）',
  `is_reminded` tinyint(1) DEFAULT '0' COMMENT '是否已提醒：0否 1是',
  `user_id` bigint NOT NULL COMMENT '下单用户',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID',
  `merchant_name` varchar(50) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '商家名称',
  `address_book_id` bigint DEFAULT NULL COMMENT '地址id',
  `order_time` datetime NOT NULL COMMENT '下单时间',
  `accepted_time` datetime DEFAULT NULL COMMENT '商家接单时间',
  `completed_time` datetime DEFAULT NULL COMMENT '出餐完成时间',
  `picked_up_time` datetime DEFAULT NULL COMMENT '用户取餐时间',
  `checkout_time` datetime DEFAULT NULL COMMENT '结账时间（支付成功时间）',
  `pay_method` int NOT NULL DEFAULT '1' COMMENT '支付方式 1微信,2支付宝',
  `amount` decimal(10,2) NOT NULL COMMENT '实收金额',
  `remark` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '备注',
  `phone` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `consignee` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `delivery_type` int DEFAULT '1' COMMENT '配送方式 1:到店自取 2:商家外送',
  `delivery_fee` decimal(10,2) DEFAULT '0.00' COMMENT '配送费',
  `canteen_id` bigint DEFAULT NULL COMMENT '食堂ID',
  `canteen_name` varchar(100) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '食堂名称',
  `user_coupon_id` bigint DEFAULT NULL COMMENT '用户优惠券ID',
  `coupon_amount` decimal(10,2) DEFAULT '0.00' COMMENT '优惠券优惠金额',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_order_type` (`order_type`),
  KEY `idx_reserved_time` (`reserved_time`),
  KEY `idx_reserved_date` (`reserved_date`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1992182022764089346,'1992182022764089346',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992175182684745729,10,NULL,NULL,'2025-11-22 18:43:02',NULL,NULL,NULL,'2025-11-22 18:43:02',1,50400.00,'','13895980231','到店自取',NULL,'用户0231',1,0.00,1,'第一食堂',NULL,0.00),(1992183467743670274,'1992183467743670274',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992175182684745729,10,NULL,NULL,'2025-11-22 18:48:46',NULL,NULL,NULL,'2025-11-22 18:48:46',1,16800.00,'','13895980231','到店自取',NULL,'用户0231',1,0.00,1,'第一食堂',NULL,0.00),(1992185254609530882,'1992185254609530882',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992175182684745729,10,NULL,NULL,'2025-11-22 18:55:52',NULL,NULL,NULL,'2025-11-22 18:55:52',1,13800.00,'','13895980231','到店自取',NULL,'用户0231',1,0.00,1,'第一食堂',NULL,0.00),(1992188067762667522,'1992188067762667522',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992175182684745729,10,NULL,NULL,'2025-11-22 19:07:03',NULL,NULL,NULL,'2025-11-22 19:07:03',1,13800.00,'','13895980231','到店自取',NULL,'用户0231',1,0.00,1,'第一食堂',NULL,0.00),(1992188505035636737,'1992188505035636737',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992175182684745729,10,NULL,NULL,'2025-11-22 19:08:47',NULL,NULL,NULL,'2025-11-22 19:08:47',1,13800.00,'','13895980231','到店自取',NULL,'用户0231',1,0.00,1,'第一食堂',NULL,0.00),(1992190168500797441,'1992190168500797441',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992175182684745729,10,NULL,1992189513195323394,'2025-11-22 19:15:24',NULL,NULL,NULL,'2025-11-22 19:15:24',1,1730003.00,'','19906454305','北京市北京市东城区111',NULL,'11',2,3.00,1,'第一食堂',NULL,0.00),(1992201798269812738,'1992201798269812738',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992198172637925377,10,NULL,NULL,'2025-11-22 20:01:37',NULL,NULL,NULL,'2025-11-22 20:01:37',1,45400.00,'','13830666354','到店自取',NULL,'用户6354',1,0.00,1,'食堂',NULL,0.00),(1992202209986875393,'1992202209986875393',4,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992198172637925377,10,NULL,NULL,'2025-11-22 20:03:15',NULL,NULL,NULL,'2025-11-22 20:03:15',1,45400.00,'','13830666354','到店自取',NULL,'用户6354',1,0.00,1,'食堂',NULL,0.00),(1992205018333450242,'1992205018333450242',5,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992198172637925377,10,NULL,NULL,'2025-11-22 20:14:24',NULL,NULL,NULL,'2025-11-22 20:14:24',1,1680000.00,'','13830666354','到店自取',NULL,'用户6354',1,0.00,1,'第一食堂',NULL,0.00),(1992456768206434306,'1992456768206434306',1,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992198172637925377,10,NULL,NULL,'2025-11-23 12:54:46',NULL,NULL,NULL,'2025-11-23 12:54:46',1,124600.00,'','13830666354','到店自取',NULL,'123',1,0.00,1,'食堂',1992451678196224001,1000.00),(1992475003207315458,'1992475003207315458',4,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992198172637925377,10,NULL,NULL,'2025-11-23 14:07:14',NULL,NULL,NULL,'2025-11-23 14:07:14',1,10800.00,'','13830666354','到店自取',NULL,'123',1,0.00,1,'食堂',1992474939919462402,0.00),(1992538687489290242,'1992538687489290242',4,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 18:20:17',NULL,NULL,NULL,'2025-11-23 18:20:17',1,2800.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,1,'食堂',NULL,0.00),(1992543188359061505,'1992543188359061505',5,1,'确定要申请退款吗?',500.00,'2025-11-23 18:47:10',1,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 18:38:10',NULL,NULL,NULL,'2025-11-23 18:38:10',1,500.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992545399445225474,'1992545399445225474',1,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 18:46:58',NULL,NULL,NULL,'2025-11-23 18:46:58',1,500.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992556995269656577,'1992556995269656577',3,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 19:33:02',NULL,NULL,NULL,'2025-11-23 19:33:02',1,1500.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992557407292915714,'1992557407292915714',3,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 19:34:40',NULL,NULL,NULL,'2025-11-23 19:34:40',1,14800.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992558898904870914,'1992558898904870914',3,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 19:40:36',NULL,NULL,NULL,'2025-11-23 19:47:12',3,1500.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992565051307159554,'1992565051307159554',3,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 20:05:03',NULL,NULL,NULL,'2025-11-23 20:05:03',1,20000.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992565533878587394,'1992565533878587394',3,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 20:06:58',NULL,NULL,NULL,'2025-11-23 20:07:03',1,20000.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992565905003188225,'1992565905003188225',3,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992535586128621569,10,NULL,NULL,'2025-11-23 20:08:26',NULL,NULL,NULL,'2025-11-23 20:08:31',1,20000.00,'','13935125699','到店自取',NULL,'教师-13935125699',1,0.00,3,'食堂',NULL,0.00),(1992566640084324354,'1992566640084324354',3,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,1992566607716880386,10,NULL,NULL,'2025-11-23 20:11:22',NULL,NULL,NULL,'2025-11-23 20:11:26',1,20000.00,'','13828545015','到店自取',NULL,'学生-13828545015',1,0.00,3,'食堂',NULL,0.00),(2040361930350518273,'2040361930350518273',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,2040361841687126018,1,NULL,NULL,'2026-04-04 17:32:47',NULL,NULL,NULL,'2026-04-04 17:32:55',1,20000.00,'','13848442066','到店自取',NULL,'学生-13848442066',1,0.00,1,'食堂',NULL,0.00),(2040362254737989634,'2040362254737989634',2,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,2040361841687126018,1,NULL,NULL,'2026-04-04 17:34:04',NULL,'2026-04-04 17:55:33',NULL,'2026-04-04 17:34:55',2,20000.00,'','13848442066','到店自取',NULL,'学生-13848442066',1,0.00,1,'食堂',NULL,0.00),(2040363819934695426,'2040363819934695426',6,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,2040361841687126018,1,NULL,NULL,'2026-04-04 17:40:17',NULL,'2026-04-04 17:50:27',NULL,'2026-04-04 17:40:23',1,20000.00,'','13848442066','到店自取',NULL,'学生-13848442066',1,0.00,1,'食堂',NULL,0.00),(2040368569946247169,'2040368569946247169',5,0,NULL,NULL,NULL,1,1,NULL,NULL,NULL,0,2040361841687126018,1,'老张川菜',NULL,'2026-04-04 17:59:10',NULL,'2026-04-04 18:10:35',NULL,'2026-04-04 18:02:50',3,20000.00,'','13848442066','到店自取',NULL,'学生-13848442066',1,0.00,NULL,'食堂',NULL,0.00),(2040378853008158721,'2040378853008158721',5,0,NULL,NULL,NULL,0,1,NULL,NULL,NULL,0,2040361841687126018,1,'老张川菜',2040378831260692482,'2026-04-04 18:40:02',NULL,'2026-04-04 18:40:23',NULL,'2026-04-04 18:40:08',3,39700.00,'','19907575849','北京市北京市东城区11',NULL,'11',1,0.00,NULL,'食堂',NULL,0.00);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders_merchant_backfill_backup`
--

DROP TABLE IF EXISTS `orders_merchant_backfill_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders_merchant_backfill_backup` (
  `order_id` bigint NOT NULL,
  `old_merchant_id` bigint DEFAULT NULL,
  `old_canteen_id` bigint DEFAULT NULL,
  `old_canteen_name` varchar(100) DEFAULT NULL,
  `backup_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='orders merchant backfill backup';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_merchant_backfill_backup`
--

LOCK TABLES `orders_merchant_backfill_backup` WRITE;
/*!40000 ALTER TABLE `orders_merchant_backfill_backup` DISABLE KEYS */;
INSERT INTO `orders_merchant_backfill_backup` VALUES (2040361930350518273,NULL,NULL,'食堂','2026-04-04 17:46:12'),(2040362254737989634,NULL,NULL,'食堂','2026-04-04 17:46:12'),(2040363819934695426,NULL,NULL,'食堂','2026-04-04 17:46:12');
/*!40000 ALTER TABLE `orders_merchant_backfill_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `points_record`
--

DROP TABLE IF EXISTS `points_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `points_record` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `points` int NOT NULL COMMENT '积分变化（正数为增加，负数为减少）',
  `type` int NOT NULL COMMENT '类型 1:消费获得 2:签到 3:兑换 4:过期',
  `description` varchar(200) DEFAULT NULL COMMENT '说明',
  `order_id` bigint DEFAULT NULL COMMENT '关联订单ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='积分记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `points_record`
--

LOCK TABLES `points_record` WRITE;
/*!40000 ALTER TABLE `points_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `points_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `points_task`
--

DROP TABLE IF EXISTS `points_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `points_task` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '任务名称',
  `description` varchar(200) DEFAULT NULL COMMENT '任务描述',
  `points` int NOT NULL COMMENT '奖励积分',
  `type` varchar(20) NOT NULL COMMENT '任务类型：daily-每日，once-一次性',
  `icon` varchar(50) DEFAULT NULL COMMENT '图标',
  `status` int DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='积分任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `points_task`
--

LOCK TABLES `points_task` WRITE;
/*!40000 ALTER TABLE `points_task` DISABLE KEYS */;
INSERT INTO `points_task` VALUES (1,'完成首单','下单并完成首单',50,'once','📝',1,'2025-11-22 19:30:46','2025-11-22 19:30:46'),(2,'评价订单','对订单进行评价',10,'once','👍',1,'2025-11-22 19:30:46','2025-11-22 19:30:46'),(3,'每日签到','每日签到',5,'daily','🎁',1,'2025-11-22 19:30:46','2025-11-22 19:30:46'),(4,'邀请好友','邀请好友注册',20,'once','👥',1,'2025-11-22 19:30:46','2025-11-22 19:30:46'),(5,'完成首单','下单并完成首单',50,'once','📝',1,'2025-11-22 19:39:20','2025-11-22 19:39:20'),(6,'评价订单','对订单进行评价',10,'once','👍',1,'2025-11-22 19:39:20','2025-11-22 19:39:20'),(7,'每日签到','每日签到',5,'daily','🎁',1,'2025-11-22 19:39:20','2025-11-22 19:39:20'),(8,'邀请好友','邀请好友注册',20,'once','👥',1,'2025-11-22 19:39:20','2025-11-22 19:39:20');
/*!40000 ALTER TABLE `points_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `setmeal`
--

DROP TABLE IF EXISTS `setmeal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setmeal` (
  `id` bigint NOT NULL COMMENT '主键',
  `category_id` bigint NOT NULL COMMENT '菜品分类id',
  `name` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '套餐名称',
  `price` decimal(10,2) NOT NULL COMMENT '套餐价格',
  `status` int DEFAULT NULL COMMENT '状态 0:停用 1:启用',
  `code` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '编码',
  `description` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '描述信息',
  `image` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '图片',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_setmeal_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='套餐';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `setmeal`
--

LOCK TABLES `setmeal` WRITE;
/*!40000 ALTER TABLE `setmeal` DISABLE KEYS */;
INSERT INTO `setmeal` VALUES (1415580119015145474,1413386191767674881,'儿童套餐A计划',4000.00,1,'','','61d20592-b37f-4d72-a864-07ad5bb8f3bb.jpg','2021-07-15 15:52:55','2021-07-15 15:52:55',1415576781934608386,1415576781934608386,0);
/*!40000 ALTER TABLE `setmeal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `setmeal_dish`
--

DROP TABLE IF EXISTS `setmeal_dish`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setmeal_dish` (
  `id` bigint NOT NULL COMMENT '主键',
  `setmeal_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '套餐id ',
  `dish_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '菜品id',
  `name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '菜品名称 （冗余字段）',
  `price` decimal(10,2) DEFAULT NULL COMMENT '菜品原价（冗余字段）',
  `copies` int NOT NULL COMMENT '份数',
  `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_user` bigint NOT NULL COMMENT '创建人',
  `update_user` bigint NOT NULL COMMENT '修改人',
  `is_deleted` int NOT NULL DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='套餐菜品关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `setmeal_dish`
--

LOCK TABLES `setmeal_dish` WRITE;
/*!40000 ALTER TABLE `setmeal_dish` DISABLE KEYS */;
INSERT INTO `setmeal_dish` VALUES (1415580119052894209,'1415580119015145474','1397862198033297410','老火靓汤',49800.00,1,0,'2021-07-15 15:52:55','2021-07-15 15:52:55',1415576781934608386,1415576781934608386,0),(1415580119061282817,'1415580119015145474','1413342036832100354','北冰洋',500.00,1,0,'2021-07-15 15:52:55','2021-07-15 15:52:55',1415576781934608386,1415576781934608386,0),(1415580119069671426,'1415580119015145474','1413385247889891330','米饭',200.00,1,0,'2021-07-15 15:52:55','2021-07-15 15:52:55',1415576781934608386,1415576781934608386,0);
/*!40000 ALTER TABLE `setmeal_dish` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shopping_cart`
--

DROP TABLE IF EXISTS `shopping_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shopping_cart` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '名称',
  `image` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '图片',
  `canteen_id` bigint DEFAULT NULL COMMENT '食堂ID',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID',
  `user_id` bigint NOT NULL COMMENT '主键',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品id',
  `setmeal_id` bigint DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '口味',
  `number` int NOT NULL DEFAULT '1' COMMENT '数量',
  `amount` decimal(10,2) NOT NULL COMMENT '金额',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='购物车';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shopping_cart`
--

LOCK TABLES `shopping_cart` WRITE;
/*!40000 ALTER TABLE `shopping_cart` DISABLE KEYS */;
INSERT INTO `shopping_cart` VALUES (1992173392010412033,'上汤焗龙虾','http://localhost:8080/common/download?name=5b8d2da3-3744-4bb3-acdc-329056b8259d.jpeg',NULL,NULL,1992152220631830529,1397862477831122945,NULL,NULL,2,108800.00,'2025-11-22 18:08:44'),(1992191642668630018,'邵阳猪血丸子','http://localhost:8080/common/download?name=2a50628e-7758-4c51-9fbb-d37c61cdacad.jpg',NULL,NULL,1992175182684745729,1397851370462687234,NULL,NULL,1,1380000.00,'2025-11-22 19:21:15'),(1992532684718764034,'口味蛇','http://localhost:8080/common/download?name=acab7eae-c65d-4b13-a3ef-46ff521341bd.png',NULL,NULL,1992198172637925377,1397851668262465537,NULL,NULL,1,16800.00,'2025-11-23 17:56:26'),(1992570546294116353,'11111111111','http://localhost:8080/common/download?name=e8d26c1d-2c7c-424f-9531-49169cf96a36.jpg',NULL,NULL,1992566607716880386,1992564785988071426,NULL,NULL,1,20000.00,'2025-11-23 20:26:53'),(1994669418382417922,'霸王别姬','http://localhost:8080/common/download?name=847efe88-16ed-4e5d-a03c-506ea6013dff.jpg',NULL,NULL,1992566607716880386,1397850851245600769,NULL,NULL,1,12800.00,'2025-11-29 15:27:03');
/*!40000 ALTER TABLE `shopping_cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_config`
--

DROP TABLE IF EXISTS `system_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `config_key` varchar(100) NOT NULL COMMENT '配置键',
  `config_value` varchar(500) NOT NULL COMMENT '配置值',
  `config_type` varchar(50) DEFAULT 'string' COMMENT '配置类型：string/integer/boolean/json',
  `config_group` varchar(50) DEFAULT 'system' COMMENT '配置分组：system/order/payment/delivery',
  `description` varchar(200) DEFAULT NULL COMMENT '配置说明',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '是否公开：0否 1是',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`),
  KEY `idx_config_group` (`config_group`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_config`
--

LOCK TABLES `system_config` WRITE;
/*!40000 ALTER TABLE `system_config` DISABLE KEYS */;
INSERT INTO `system_config` VALUES (1,'order.auto_accept','false','boolean','order','是否自动接单',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(2,'order.timeout_minutes','30','integer','order','订单超时时间(分钟)',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(3,'order.auto_complete_minutes','60','integer','order','自动完成时间(分钟)',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(4,'order.print_enabled','false','boolean','order','是否启用订单打印',0,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(5,'order.remind_minutes','30','integer','order','预订单提前提醒时间(分钟)',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(6,'delivery.fee','3.00','string','delivery','配送费(元)',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(7,'delivery.free_amount','30.00','string','delivery','免配送费金额(元)',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(8,'points.ratio','5','integer','system','积分比例(%)',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(9,'system.name','智慧食堂系统','string','system','系统名称',1,'2025-11-23 16:12:30','2025-11-23 16:12:30'),(10,'system.version','1.0.0','string','system','系统版本',1,'2025-11-23 16:12:30','2025-11-23 16:12:30');
/*!40000 ALTER TABLE `system_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '姓名',
  `phone` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '手机号',
  `user_type` tinyint DEFAULT '1' COMMENT '用户类型 1:学生 2:教师 3:普通用户',
  `id_card` varchar(18) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '身份证号',
  `real_name` varchar(50) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '真实姓名',
  `teacher_verified` tinyint DEFAULT '0' COMMENT '教师认证状态 0:未认证 1:待审核 2:已认证 3:已拒绝',
  `sex` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '性别',
  `id_number` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '身份证号',
  `avatar` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL COMMENT '头像',
  `status` int DEFAULT '0' COMMENT '状态 0:禁用，1:正常',
  `balance` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '账户余额（元）',
  `coupon_count` int NOT NULL DEFAULT '0' COMMENT '优惠券数量',
  `signature` varchar(100) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '个性签名',
  `exp` int DEFAULT '0' COMMENT '经验值',
  `post_count` int DEFAULT '0' COMMENT '发帖数量',
  `collect_count` int DEFAULT '0' COMMENT '收藏数量',
  `like_count` int DEFAULT '0' COMMENT '获赞数量',
  `health_goal` varchar(20) COLLATE utf8mb3_bin DEFAULT 'none' COMMENT '健康目标: lose_fat, gain_muscle, balanced, none',
  `daily_calorie_target` int DEFAULT NULL COMMENT '每日目标卡路里摄入（千卡）',
  `dietary_restrictions` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL COMMENT '饮食禁忌（逗号分隔）',
  `points` int NOT NULL DEFAULT '0' COMMENT '积分',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL,
  `update_user` bigint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_exp` (`exp` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='用户信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1417012167126876162,'张三','13800138000',1,NULL,NULL,0,'1','110101199001010001',NULL,1,98.50,0,NULL,0,0,0,0,'none',NULL,NULL,1280,'2025-11-22 17:58:08','2025-11-23 16:59:11',NULL,NULL),(1417012167126876163,'李四','13800138001',1,NULL,NULL,0,'1','110101199001010002',NULL,1,150.00,0,NULL,0,0,0,0,'none',NULL,NULL,800,'2025-11-22 17:58:08','2025-11-23 16:59:11',NULL,NULL),(1417012167126876164,'王五','13800138002',1,NULL,NULL,0,'0','110101199001010003',NULL,1,200.00,0,NULL,0,0,0,0,'none',NULL,NULL,500,'2025-11-22 17:58:08','2025-11-23 16:59:11',NULL,NULL),(1417012167126876165,'赵六','13800138003',1,NULL,NULL,0,'1','110101199001010004',NULL,1,50.00,0,NULL,0,0,0,0,'none',NULL,NULL,200,'2025-11-22 17:58:08','2025-11-23 16:59:11',NULL,NULL),(1992151503888199682,NULL,'13841782581',1,NULL,NULL,0,NULL,NULL,NULL,1,0.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-22 17:58:08','2025-11-22 17:58:08',NULL,NULL),(1992151533797781506,NULL,'13822295204',1,NULL,NULL,0,NULL,NULL,NULL,1,0.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-22 17:58:08','2025-11-22 17:58:08',NULL,NULL),(1992152220631830529,'用户5497','13811245497',1,NULL,NULL,0,NULL,NULL,NULL,1,0.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-22 17:58:08','2025-11-22 17:58:08',NULL,NULL),(1992175182684745729,'用户0231','13895980231',1,NULL,NULL,0,NULL,NULL,NULL,1,3010.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-22 18:15:51','2025-11-22 19:08:39',NULL,1992175182684745729),(1992193136608411650,'用户8209','13848598209',1,NULL,NULL,0,NULL,NULL,NULL,1,0.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-22 19:27:12','2025-11-22 19:27:12',1992175182684745729,1992175182684745729),(1992194199516360706,'用户5360','13852255360',1,NULL,NULL,0,NULL,NULL,NULL,1,0.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-22 19:31:25','2025-11-22 19:31:25',NULL,NULL),(1992198172637925377,'123','13830666354',1,NULL,NULL,0,'1',NULL,'acab7eae-c65d-4b13-a3ef-46ff521341bd.png',1,0.00,4,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-22 19:47:12','2025-11-23 16:59:11',NULL,1992198172637925377),(1992535586128621569,'教师-13935125699','13935125699',2,NULL,NULL,2,NULL,NULL,NULL,1,0.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-23 18:07:58','2025-11-23 18:07:58',NULL,NULL),(1992566607716880386,'学生-13828545015','13828545015',1,NULL,NULL,0,NULL,NULL,NULL,1,0.00,0,NULL,0,0,0,0,'none',NULL,NULL,0,'2025-11-23 20:11:14','2025-11-29 16:50:47',1992535586128621569,1992566607716880386),(2040361841687126018,'学生-13848442066','13848442066',1,NULL,NULL,0,NULL,NULL,NULL,1,1403.00,2,NULL,0,0,0,0,'none',NULL,NULL,0,'2026-04-04 17:32:26','2026-04-04 18:40:08',NULL,2040361841687126018);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_browse_history`
--

DROP TABLE IF EXISTS `user_browse_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_browse_history` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户浏览历史表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_browse_history`
--

LOCK TABLES `user_browse_history` WRITE;
/*!40000 ALTER TABLE `user_browse_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_browse_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_coupon`
--

DROP TABLE IF EXISTS `user_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_coupon` (
  `id` bigint NOT NULL COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `coupon_id` bigint NOT NULL COMMENT '优惠券ID',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态：0-未使用，1-已使用，2-已过期',
  `used_time` datetime DEFAULT NULL COMMENT '使用时间',
  `order_id` bigint DEFAULT NULL COMMENT '订单ID',
  `expire_time` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_coupon_id` (`coupon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin COMMENT='用户优惠券表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_coupon`
--

LOCK TABLES `user_coupon` WRITE;
/*!40000 ALTER TABLE `user_coupon` DISABLE KEYS */;
INSERT INTO `user_coupon` VALUES (2040361861832368130,2040361841687126018,1,0,NULL,NULL,'2026-05-04 17:32:31','2026-04-04 17:32:31','2026-04-04 17:32:31',2040361841687126018,2040361841687126018),(2040361864676106242,2040361841687126018,2,0,NULL,NULL,'2026-05-04 17:32:31','2026-04-04 17:32:31','2026-04-04 17:32:31',2040361841687126018,2040361841687126018);
/*!40000 ALTER TABLE `user_coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_favorite_dish`
--

DROP TABLE IF EXISTS `user_favorite_dish`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_favorite_dish` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `dish_id` bigint NOT NULL COMMENT '菜品ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_dish` (`user_id`,`dish_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_dish_id` (`dish_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户收藏菜品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_favorite_dish`
--

LOCK TABLES `user_favorite_dish` WRITE;
/*!40000 ALTER TABLE `user_favorite_dish` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_favorite_dish` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_favorite_merchant`
--

DROP TABLE IF EXISTS `user_favorite_merchant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_favorite_merchant` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_merchant` (`user_id`,`merchant_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户收藏商家表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_favorite_merchant`
--

LOCK TABLES `user_favorite_merchant` WRITE;
/*!40000 ALTER TABLE `user_favorite_merchant` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_favorite_merchant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_feedback`
--

DROP TABLE IF EXISTS `user_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_feedback` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `type` tinyint NOT NULL COMMENT '反馈类型 1:功能建议 2:投诉 3:其他',
  `merchant_id` bigint DEFAULT NULL COMMENT '关联商家ID（可选）',
  `content` varchar(1000) NOT NULL COMMENT '反馈内容',
  `images` varchar(1000) DEFAULT NULL COMMENT '反馈图片（逗号分隔）',
  `contact` varchar(100) DEFAULT NULL COMMENT '联系方式',
  `status` tinyint DEFAULT '1' COMMENT '处理状态 1:待处理 2:处理中 3:已完成',
  `reply` varchar(1000) DEFAULT NULL COMMENT '回复内容',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户反馈表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_feedback`
--

LOCK TABLES `user_feedback` WRITE;
/*!40000 ALTER TABLE `user_feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_preference`
--

DROP TABLE IF EXISTS `user_preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_preference` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `preference_type` varchar(50) NOT NULL COMMENT '偏好类型：taste/category/price',
  `preference_value` varchar(200) NOT NULL COMMENT '偏好值',
  `confidence` decimal(5,2) DEFAULT '0.00' COMMENT '置信度（0-100）',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_preference` (`user_id`,`preference_type`,`preference_value`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户饮食偏好表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_preference`
--

LOCK TABLES `user_preference` WRITE;
/*!40000 ALTER TABLE `user_preference` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_preference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_task_record`
--

DROP TABLE IF EXISTS `user_task_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_task_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `task_id` bigint NOT NULL COMMENT '任务ID',
  `complete_time` datetime NOT NULL COMMENT '完成时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_task` (`user_id`,`task_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_complete_time` (`complete_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户任务完成记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_task_record`
--

LOCK TABLES `user_task_record` WRITE;
/*!40000 ALTER TABLE `user_task_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_task_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_merchant_black_list`
--

DROP TABLE IF EXISTS `v_merchant_black_list`;
/*!50001 DROP VIEW IF EXISTS `v_merchant_black_list`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_merchant_black_list` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `image`,
 1 AS `description`,
 1 AS `rating`,
 1 AS `sales_count`,
 1 AS `positive_count`,
 1 AS `negative_count`,
 1 AS `score`,
 1 AS `negative_rate`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_merchant_red_list`
--

DROP TABLE IF EXISTS `v_merchant_red_list`;
/*!50001 DROP VIEW IF EXISTS `v_merchant_red_list`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_merchant_red_list` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `image`,
 1 AS `description`,
 1 AS `rating`,
 1 AS `sales_count`,
 1 AS `positive_count`,
 1 AS `negative_count`,
 1 AS `score`,
 1 AS `positive_rate`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `websocket_connection`
--

DROP TABLE IF EXISTS `websocket_connection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `websocket_connection` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `user_type` varchar(20) NOT NULL COMMENT '用户类型：MERCHANT/ADMIN/USER',
  `session_id` varchar(100) NOT NULL COMMENT 'WebSocket会话ID',
  `connect_time` datetime NOT NULL COMMENT '连接时间',
  `disconnect_time` datetime DEFAULT NULL COMMENT '断开时间',
  `ip_address` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_session_id` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='WebSocket连接记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `websocket_connection`
--

LOCK TABLES `websocket_connection` WRITE;
/*!40000 ALTER TABLE `websocket_connection` DISABLE KEYS */;
/*!40000 ALTER TABLE `websocket_connection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'reggie'
--

--
-- Dumping routines for database 'reggie'
--

--
-- Current Database: `reggie`
--

USE `reggie`;

--
-- Final view structure for view `v_merchant_black_list`
--

/*!50001 DROP VIEW IF EXISTS `v_merchant_black_list`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_merchant_black_list` AS select `m`.`id` AS `id`,`m`.`name` AS `name`,`m`.`image` AS `image`,`m`.`description` AS `description`,`m`.`rating` AS `rating`,`m`.`sales_count` AS `sales_count`,`m`.`positive_count` AS `positive_count`,`m`.`negative_count` AS `negative_count`,(`m`.`positive_count` - `m`.`negative_count`) AS `score`,round(((`m`.`negative_count` * 100.0) / nullif((`m`.`positive_count` + `m`.`negative_count`),0)),1) AS `negative_rate` from `merchant` `m` where ((`m`.`status` = 1) and (`m`.`negative_count` > 0)) order by `m`.`negative_count` desc,`negative_rate` desc limit 20 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_merchant_red_list`
--

/*!50001 DROP VIEW IF EXISTS `v_merchant_red_list`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_merchant_red_list` AS select `m`.`id` AS `id`,`m`.`name` AS `name`,`m`.`image` AS `image`,`m`.`description` AS `description`,`m`.`rating` AS `rating`,`m`.`sales_count` AS `sales_count`,`m`.`positive_count` AS `positive_count`,`m`.`negative_count` AS `negative_count`,(`m`.`positive_count` - `m`.`negative_count`) AS `score`,round(((`m`.`positive_count` * 100.0) / nullif((`m`.`positive_count` + `m`.`negative_count`),0)),1) AS `positive_rate` from `merchant` `m` where ((`m`.`status` = 1) and ((`m`.`positive_count` + `m`.`negative_count`) > 0)) order by `m`.`positive_count` desc,`score` desc limit 20 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-04 18:55:21
