#!/bin/bash
# ============================================
# 数据库初始化入口脚本
# 按顺序执行所有 SQL 文件
# ============================================

echo "=========================================="
echo "  开始初始化数据库: reggie"
echo "=========================================="

# 1. 主数据库结构和初始数据
echo "[1/5] 导入主数据库结构和初始数据..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" reggie < /docker-entrypoint-initdb.d/sql/reggie.sql

# 2. 创建消息表
if [ -f "/docker-entrypoint-initdb.d/sql/create_message_table.sql" ]; then
  echo "[2/5] 创建消息表..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" reggie < /docker-entrypoint-initdb.d/sql/create_message_table.sql
fi

# 3. 创建笔记表
if [ -f "/docker-entrypoint-initdb.d/sql/create_note_tables.sql" ]; then
  echo "[3/5] 创建笔记表..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" reggie < /docker-entrypoint-initdb.d/sql/create_note_tables.sql
fi

# 4. 更新笔记评分
if [ -f "/docker-entrypoint-initdb.d/sql/update_note_rating.sql" ]; then
  echo "[4/5] 更新笔记评分结构..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" reggie < /docker-entrypoint-initdb.d/sql/update_note_rating.sql
fi

# 5. 更新用户资料
if [ -f "/docker-entrypoint-initdb.d/sql/update_user_profile.sql" ]; then
  echo "[5/5] 更新用户资料结构..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" reggie < /docker-entrypoint-initdb.d/sql/update_user_profile.sql
fi

# 6. 修复商家和菜品结构字段
if [ -f "/docker-entrypoint-initdb.d/sql/fix_merchant_fields.sql" ]; then
  echo "[6/7] 修复商家和菜品字段..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" reggie < /docker-entrypoint-initdb.d/sql/fix_merchant_fields.sql
fi

# 7. 进一步更新商家表并创建美食分类
if [ -f "/docker-entrypoint-initdb.d/sql/update_merchant_and_food_category.sql" ]; then
  echo "[7/7] 创建并更新美食分类..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" reggie < /docker-entrypoint-initdb.d/sql/update_merchant_and_food_category.sql
fi

echo "=========================================="
echo "  数据库初始化完成！"
echo "=========================================="
