# 多阶段构建 - 构建阶段
FROM docker.m.daocloud.io/library/maven:3.8.6-openjdk-17 AS builder

WORKDIR /app

# 复制pom.xml并下载依赖（利用Docker缓存）
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 复制源代码并构建
COPY src ./src
RUN mvn clean package -DskipTests -B

# 运行阶段
FROM docker.m.daocloud.io/library/eclipse-temurin:17-jdk-alpine

# 安装必要的工具
RUN apk add --no-cache curl tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app

# 创建上传文件目录
RUN mkdir -p /app/upload

# 从构建阶段复制jar包
COPY --from=builder /app/target/*.jar app.jar

# 复制食品图片资源到上传目录（容器内初始化用）
COPY src/main/resources/food_img/ /app/upload/

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/employee/page?page=1\&pageSize=1 || exit 1

# 启动应用
ENTRYPOINT ["java", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-Dspring.profiles.active=prod", \
  "-Xms256m", \
  "-Xmx512m", \
  "-jar", \
  "app.jar"]
