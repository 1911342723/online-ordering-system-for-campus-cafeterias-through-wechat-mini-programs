package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.dto.DishDto;
import com.java_project.reggie.entity.*;
import com.java_project.reggie.mapper.UserBrowseHistoryMapper;
import com.java_project.reggie.mapper.UserPreferenceMapper;
import com.java_project.reggie.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 推荐服务实现 — 混合推荐算法
 *
 * 算法核心思路:
 * finalScore = α × collaborativeFilteringScore + β × contentBasedScore + γ × hotScore
 *
 * 其中 α/β/γ 根据就餐时段动态调整:
 * - 早餐(6-9时):   α=0.2, β=0.5, γ=0.3  → 偏重健康营养内容推荐
 * - 午餐(11-14时): α=0.5, β=0.2, γ=0.3  → 偏重协同过滤热门推荐
 * - 晚餐(17-20时): α=0.3, β=0.5, γ=0.2  → 偏重健康减脂内容推荐
 * - 其他时段:      α=0.3, β=0.3, γ=0.4  → 均衡推荐+热门
 *
 * 协同过滤: 基于用户-菜品订购矩阵，计算用户间余弦相似度，推荐相似用户喜欢的菜品
 * 内容推荐: 基于菜品营养标签（卡路里/蛋白质/脂肪），匹配用户健康目标
 * 热度推荐: 基于菜品近期被订购频次
 * 时间衰减: 所有历史数据均采用指数衰减加权 weight = e^(-λ × Δdays)
 */
@Slf4j
@Service
public class RecommendationServiceImpl implements RecommendationService {

    @Autowired
    private UserBrowseHistoryMapper browseHistoryMapper;

    @Autowired
    private UserPreferenceMapper preferenceMapper;

    @Autowired
    private DishService dishService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderDetailService orderDetailService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private UserService userService;

    // 时间衰减系数 λ，约7天半衰期: ln(2)/7 ≈ 0.099
    private static final double DECAY_LAMBDA = 0.099;

    // 协同过滤中取的相似用户数量上限
    private static final int TOP_SIMILAR_USERS = 10;

    @Override
    public List<DishDto> getTodayRecommendations(Long userId, Integer limit) {
        if (limit == null || limit <= 0) {
            limit = 10;
        }

        log.info("开始为用户{}生成今日推荐，数量：{}", userId, limit);

        // 1. 获取所有在售菜品
        LambdaQueryWrapper<Dish> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Dish::getStatus, 1);
        List<Dish> allDishes = dishService.list(queryWrapper);

        if (allDishes.isEmpty()) {
            log.warn("没有在售菜品可供推荐");
            return new ArrayList<>();
        }

        // 2. 检查是否为新用户
        boolean isNewUser = userId == null || userId == 0L || isUserNew(userId);

        if (isNewUser) {
            log.info("用户{}为新用户，使用热门推荐", userId);
            return getHotRecommendations(allDishes, limit);
        }

        // 3. 老用户: 使用混合推荐算法
        log.info("用户{}为老用户，使用混合推荐算法", userId);
        return getHybridRecommendations(userId, allDishes, limit);
    }

    /**
     * 混合推荐核心算法
     */
    private List<DishDto> getHybridRecommendations(Long userId, List<Dish> allDishes, Integer limit) {
        // 1. 获取当前时段权重
        double[] weights = getMealTimeWeights();
        double alphaCollaborative = weights[0];
        double betaContent = weights[1];
        double gammaHot = weights[2];

        log.info("当前时段权重: 协同过滤α={}, 内容推荐β={}, 热度γ={}", alphaCollaborative, betaContent, gammaHot);

        // 2. 计算协同过滤分数
        Map<Long, Double> collaborativeScores = calculateCollaborativeFilteringScores(userId, allDishes);

        // 3. 计算内容推荐分数（基于营养匹配）
        Map<Long, Double> contentScores = calculateContentBasedScores(userId, allDishes);

        // 4. 计算热度分数
        Map<Long, Double> hotScores = calculateHotScores(allDishes);

        // 5. 混合加权计算最终分数
        Map<Long, Double> finalScores = new HashMap<>();
        for (Dish dish : allDishes) {
            Long dishId = dish.getId();
            double cfScore = collaborativeScores.getOrDefault(dishId, 0.0);
            double ctScore = contentScores.getOrDefault(dishId, 0.0);
            double htScore = hotScores.getOrDefault(dishId, 0.0);

            double finalScore = alphaCollaborative * cfScore
                              + betaContent * ctScore
                              + gammaHot * htScore;

            // 添加少量随机探索因子，增加推荐多样性
            finalScore += Math.random() * 5.0;

            finalScores.put(dishId, finalScore);
        }

        // 6. 按分数排序取前N个
        List<Long> topDishIds = finalScores.entrySet().stream()
                .sorted((e1, e2) -> Double.compare(e2.getValue(), e1.getValue()))
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        List<DishDto> result = buildDishDtoList(allDishes, topDishIds);
        log.info("为用户{}生成混合推荐完成，推荐{}道菜品", userId, result.size());
        return result;
    }

    // ======================== 协同过滤 ========================

    /**
     * 基于用户的协同过滤 (User-based Collaborative Filtering)
     *
     * 步骤：
     * 1. 构建当前用户的菜品偏好向量（基于历史订单，带时间衰减）
     * 2. 构建其他活跃用户的偏好向量
     * 3. 计算当前用户与其他用户的余弦相似度
     * 4. 取TOP-K相似用户，将他们喜欢但当前用户未点过的菜品作为推荐
     */
    private Map<Long, Double> calculateCollaborativeFilteringScores(Long userId, List<Dish> allDishes) {
        Map<Long, Double> scores = new HashMap<>();

        try {
            // 1. 构建当前用户的偏好向量: Map<dishId, 加权分数>
            Map<Long, Double> currentUserVector = buildUserPreferenceVector(userId);

            if (currentUserVector.isEmpty()) {
                return scores;
            }

            // 2. 获取有订单的其他用户列表（最近30天内有订单的活跃用户）
            LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
            LambdaQueryWrapper<Orders> userQuery = new LambdaQueryWrapper<>();
            userQuery.ne(Orders::getUserId, userId)
                     .ge(Orders::getOrderTime, thirtyDaysAgo)
                     .eq(Orders::getStatus, 4); // 已完成的订单
            List<Orders> otherOrders = orderService.list(userQuery);

            Set<Long> otherUserIds = otherOrders.stream()
                    .map(Orders::getUserId)
                    .collect(Collectors.toSet());

            if (otherUserIds.isEmpty()) {
                return scores;
            }

            // 3. 为每个其他用户构建偏好向量并计算相似度
            List<Map.Entry<Long, Double>> similarities = new ArrayList<>();
            for (Long otherUserId : otherUserIds) {
                Map<Long, Double> otherVector = buildUserPreferenceVector(otherUserId);
                if (!otherVector.isEmpty()) {
                    double similarity = cosineSimilarity(currentUserVector, otherVector);
                    if (similarity > 0.01) { // 过滤掉相似度极低的用户
                        similarities.add(new AbstractMap.SimpleEntry<>(otherUserId, similarity));
                    }
                }
            }

            // 4. 取TOP-K相似用户
            similarities.sort((a, b) -> Double.compare(b.getValue(), a.getValue()));
            List<Map.Entry<Long, Double>> topSimilarUsers = similarities.subList(
                    0, Math.min(TOP_SIMILAR_USERS, similarities.size()));

            // 5. 从相似用户的喜好中推荐菜品（当前用户没点过的菜品得分更高）
            Set<Long> currentUserDishes = currentUserVector.keySet();
            for (Map.Entry<Long, Double> entry : topSimilarUsers) {
                Long similarUserId = entry.getKey();
                double similarity = entry.getValue();
                Map<Long, Double> similarUserVector = buildUserPreferenceVector(similarUserId);

                for (Map.Entry<Long, Double> dishEntry : similarUserVector.entrySet()) {
                    Long dishId = dishEntry.getKey();
                    double dishScore = dishEntry.getValue();

                    // 相似度 × 该用户对菜品的偏好分
                    double weighted = similarity * dishScore;

                    // 当前用户没点过的菜品额外加分（新菜品发现）
                    if (!currentUserDishes.contains(dishId)) {
                        weighted *= 1.5;
                    }

                    scores.merge(dishId, weighted, Double::sum);
                }
            }

            // 归一化到 0-100
            normalizeScores(scores, 100.0);

        } catch (Exception e) {
            log.error("协同过滤计算异常: {}", e.getMessage(), e);
        }

        return scores;
    }

    /**
     * 构建用户偏好向量（带时间衰减）
     * 向量维度为菜品ID，值为加权订购次数
     */
    private Map<Long, Double> buildUserPreferenceVector(Long userId) {
        Map<Long, Double> vector = new HashMap<>();

        // 获取用户最近60天的已完成订单
        LocalDateTime sixtyDaysAgo = LocalDateTime.now().minusDays(60);
        LambdaQueryWrapper<Orders> orderWrapper = new LambdaQueryWrapper<>();
        orderWrapper.eq(Orders::getUserId, userId)
                    .eq(Orders::getStatus, 4)
                    .ge(Orders::getOrderTime, sixtyDaysAgo)
                    .orderByDesc(Orders::getOrderTime);
        List<Orders> orders = orderService.list(orderWrapper);

        for (Orders order : orders) {
            // 计算时间衰减权重
            long daysAgo = ChronoUnit.DAYS.between(order.getOrderTime(), LocalDateTime.now());
            double timeWeight = Math.exp(-DECAY_LAMBDA * daysAgo);

            // 获取订单明细
            LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
            detailWrapper.eq(OrderDetail::getOrderId, order.getId());
            List<OrderDetail> details = orderDetailService.list(detailWrapper);

            for (OrderDetail detail : details) {
                if (detail.getDishId() != null) {
                    // 带时间衰减的累加: 数量 × 时间权重
                    double weightedScore = detail.getNumber() * timeWeight;
                    vector.merge(detail.getDishId(), weightedScore, Double::sum);
                }
            }
        }

        return vector;
    }

    /**
     * 计算两个向量的余弦相似度
     * cos(A, B) = (A · B) / (||A|| × ||B||)
     */
    private double cosineSimilarity(Map<Long, Double> vectorA, Map<Long, Double> vectorB) {
        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;

        // 找到共同维度
        Set<Long> allKeys = new HashSet<>(vectorA.keySet());
        allKeys.addAll(vectorB.keySet());

        for (Long key : allKeys) {
            double a = vectorA.getOrDefault(key, 0.0);
            double b = vectorB.getOrDefault(key, 0.0);
            dotProduct += a * b;
            normA += a * a;
            normB += b * b;
        }

        if (normA == 0 || normB == 0) {
            return 0.0;
        }

        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    // ======================== 基于内容推荐（营养匹配） ========================

    /**
     * 基于内容的推荐 — 营养标签与用户健康目标匹配
     *
     * 根据菜品的卡路里、蛋白质、脂肪等营养属性，
     * 结合用户设置的健康目标（减脂/增肌/均衡），计算匹配得分
     */
    private Map<Long, Double> calculateContentBasedScores(Long userId, List<Dish> allDishes) {
        Map<Long, Double> scores = new HashMap<>();

        try {
            // 获取用户健康目标
            User user = userService.getById(userId);
            String healthGoal = (user != null && user.getHealthGoal() != null) ? user.getHealthGoal() : "none";
            Integer calorieTarget = (user != null) ? user.getDailyCalorieTarget() : null;
            String restrictions = (user != null) ? user.getDietaryRestrictions() : null;

            // 解析饮食禁忌
            Set<String> restrictionSet = new HashSet<>();
            if (restrictions != null && !restrictions.isEmpty()) {
                for (String r : restrictions.split(",")) {
                    restrictionSet.add(r.trim());
                }
            }

            // 获取用户偏好分类（基于历史）
            List<Long> preferredCategories = getUserPreferredCategories(userId);

            for (Dish dish : allDishes) {
                double score = 0.0;

                // 1. 根据健康目标进行营养匹配
                score += calculateNutritionMatchScore(dish, healthGoal, calorieTarget);

                // 2. 饮食禁忌过滤（包含禁忌关键词的菜品扣分）
                if (!restrictionSet.isEmpty()) {
                    String dishInfo = (dish.getName() + " " +
                            (dish.getDescription() != null ? dish.getDescription() : "") + " " +
                            (dish.getNutritionTags() != null ? dish.getNutritionTags() : "")).toLowerCase();
                    for (String restriction : restrictionSet) {
                        if (dishInfo.contains(restriction.toLowerCase())) {
                            score -= 30.0; // 命中禁忌的菜品大幅扣分
                        }
                    }
                }

                // 3. 用户偏好分类加分
                if (preferredCategories.contains(dish.getCategoryId())) {
                    score += 15.0;
                }

                // 4. 营养标签匹配加分
                if (dish.getNutritionTags() != null) {
                    score += calculateNutritionTagBonus(dish.getNutritionTags(), healthGoal);
                }

                scores.put(dish.getId(), Math.max(0, score));
            }

            // 归一化到 0-100
            normalizeScores(scores, 100.0);

        } catch (Exception e) {
            log.error("内容推荐计算异常: {}", e.getMessage(), e);
        }

        return scores;
    }

    /**
     * 计算菜品与用户健康目标的营养匹配分
     */
    private double calculateNutritionMatchScore(Dish dish, String healthGoal, Integer calorieTarget) {
        double score = 20.0; // 基础分

        Integer calories = dish.getCalories();
        BigDecimal protein = dish.getProtein();
        BigDecimal fat = dish.getFat();

        switch (healthGoal) {
            case "lose_fat":
                // 减脂目标: 偏好低卡、低脂、高蛋白
                if (calories != null) {
                    if (calories <= 300) score += 30.0;
                    else if (calories <= 500) score += 15.0;
                    else if (calories > 700) score -= 10.0;
                }
                if (fat != null && fat.compareTo(new BigDecimal("10")) < 0) {
                    score += 15.0;
                }
                if (protein != null && protein.compareTo(new BigDecimal("20")) > 0) {
                    score += 10.0;
                }
                break;

            case "gain_muscle":
                // 增肌目标: 偏好高蛋白、适量碳水
                if (protein != null) {
                    if (protein.compareTo(new BigDecimal("25")) > 0) score += 30.0;
                    else if (protein.compareTo(new BigDecimal("15")) > 0) score += 15.0;
                }
                if (calories != null && calories >= 400 && calories <= 800) {
                    score += 10.0;
                }
                break;

            case "balanced":
                // 均衡饮食: 营养均衡，不偏不倚
                if (calories != null && calories >= 300 && calories <= 600) {
                    score += 20.0;
                }
                if (protein != null && protein.compareTo(new BigDecimal("10")) > 0 &&
                    fat != null && fat.compareTo(new BigDecimal("20")) < 0) {
                    score += 15.0;
                }
                break;

            default:
                // 无特定目标，适度偏好中等卡路里的菜品
                if (calories != null && calories >= 200 && calories <= 600) {
                    score += 10.0;
                }
                break;
        }

        // 如果用户设置了每日卡路里目标，单餐不超过目标的40%加分
        if (calorieTarget != null && calories != null) {
            int mealTarget = calorieTarget / 3; // 单餐目标约为每日1/3
            if (calories <= mealTarget) {
                score += 10.0;
            }
        }

        return score;
    }

    /**
     * 根据营养标签和健康目标计算额外加分
     */
    private double calculateNutritionTagBonus(String nutritionTags, String healthGoal) {
        double bonus = 0.0;
        String tags = nutritionTags.toLowerCase();

        switch (healthGoal) {
            case "lose_fat":
                if (tags.contains("低卡")) bonus += 10.0;
                if (tags.contains("低脂")) bonus += 10.0;
                if (tags.contains("高蛋白")) bonus += 5.0;
                if (tags.contains("高纤维")) bonus += 5.0;
                if (tags.contains("高热量")) bonus -= 5.0;
                break;
            case "gain_muscle":
                if (tags.contains("高蛋白")) bonus += 15.0;
                if (tags.contains("低卡")) bonus -= 3.0; // 增肌不宜太低卡
                break;
            case "balanced":
                if (tags.contains("均衡")) bonus += 10.0;
                if (tags.contains("高纤维")) bonus += 5.0;
                break;
            default:
                break;
        }

        return bonus;
    }

    // ======================== 热度推荐 ========================

    /**
     * 基于菜品近期被订购次数的热度分数
     */
    private Map<Long, Double> calculateHotScores(List<Dish> allDishes) {
        Map<Long, Double> scores = new HashMap<>();

        try {
            // 统计最近7天所有已完成订单中各菜品被订购的次数
            LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
            LambdaQueryWrapper<Orders> orderWrapper = new LambdaQueryWrapper<>();
            orderWrapper.eq(Orders::getStatus, 4)
                        .ge(Orders::getOrderTime, sevenDaysAgo);
            List<Orders> recentOrders = orderService.list(orderWrapper);

            Map<Long, Integer> dishOrderCount = new HashMap<>();
            for (Orders order : recentOrders) {
                LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
                detailWrapper.eq(OrderDetail::getOrderId, order.getId());
                List<OrderDetail> details = orderDetailService.list(detailWrapper);

                for (OrderDetail detail : details) {
                    if (detail.getDishId() != null) {
                        dishOrderCount.merge(detail.getDishId(), detail.getNumber(), Integer::sum);
                    }
                }
            }

            // 转换为分数
            for (Dish dish : allDishes) {
                int count = dishOrderCount.getOrDefault(dish.getId(), 0);
                scores.put(dish.getId(), (double) count);
            }

            // 归一化到 0-100
            normalizeScores(scores, 100.0);

        } catch (Exception e) {
            log.error("热度分数计算异常: {}", e.getMessage(), e);
        }

        return scores;
    }

    // ======================== 时段权重 ========================

    /**
     * 根据当前时段返回三种推荐策略的权重 [α_协同, β_内容, γ_热度]
     */
    private double[] getMealTimeWeights() {
        int hour = LocalTime.now().getHour();

        if (hour >= 6 && hour < 9) {
            // 早餐: 偏重健康营养内容推荐
            return new double[]{0.2, 0.5, 0.3};
        } else if (hour >= 11 && hour < 14) {
            // 午餐: 偏重协同过滤热门推荐
            return new double[]{0.5, 0.2, 0.3};
        } else if (hour >= 17 && hour < 20) {
            // 晚餐: 偏重健康减脂内容推荐
            return new double[]{0.3, 0.5, 0.2};
        } else {
            // 其他时段: 均衡推荐+偏向热门
            return new double[]{0.3, 0.3, 0.4};
        }
    }

    // ======================== 新用户热门推荐 ========================

    /**
     * 新用户推荐：热门菜品（结合价格适中度和随机多样性）
     */
    private List<DishDto> getHotRecommendations(List<Dish> allDishes, Integer limit) {
        Map<Long, Double> hotScores = calculateHotScores(allDishes);

        // 热度基础上加价格因素和随机探索
        for (Dish dish : allDishes) {
            double score = hotScores.getOrDefault(dish.getId(), 0.0);

            // 价格适中菜品加分
            BigDecimal price = dish.getPrice();
            if (price != null) {
                double priceValue = price.doubleValue();
                if (priceValue >= 800 && priceValue <= 3000) {
                    score += 20.0; // 8-30元区间
                } else if (priceValue < 800) {
                    score += 10.0;
                }
            }

            // 随机多样性
            score += Math.random() * 30.0;
            hotScores.put(dish.getId(), score);
        }

        List<Long> topDishIds = hotScores.entrySet().stream()
                .sorted((e1, e2) -> Double.compare(e2.getValue(), e1.getValue()))
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        return buildDishDtoList(allDishes, topDishIds);
    }

    // ======================== 工具方法 ========================

    private boolean isUserNew(Long userId) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Orders::getUserId, userId).eq(Orders::getStatus, 4);
        return orderService.count(wrapper) == 0;
    }

    private List<Long> getUserPreferredCategories(Long userId) {
        LambdaQueryWrapper<UserPreference> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserPreference::getUserId, userId)
                .isNotNull(UserPreference::getCategoryId)
                .orderByDesc(UserPreference::getPreferenceScore)
                .last("LIMIT 10");
        return preferenceMapper.selectList(wrapper).stream()
                .map(UserPreference::getCategoryId)
                .collect(Collectors.toList());
    }

    /**
     * 归一化分数到指定最大值
     */
    private void normalizeScores(Map<Long, Double> scores, double maxTarget) {
        if (scores.isEmpty()) return;
        double maxScore = scores.values().stream().mapToDouble(Double::doubleValue).max().orElse(1.0);
        if (maxScore > 0) {
            scores.replaceAll((k, v) -> (v / maxScore) * maxTarget);
        }
    }

    private List<DishDto> buildDishDtoList(List<Dish> allDishes, List<Long> dishIds) {
        List<DishDto> recommendations = new ArrayList<>();
        for (Long dishId : dishIds) {
            Dish dish = allDishes.stream()
                    .filter(d -> d.getId().equals(dishId))
                    .findFirst()
                    .orElse(null);
            if (dish != null) {
                DishDto dishDto = new DishDto();
                BeanUtils.copyProperties(dish, dishDto);
                if (dish.getCategoryId() != null) {
                    Category category = categoryService.getById(dish.getCategoryId());
                    if (category != null) {
                        dishDto.setCategoryName(category.getName());
                    }
                }
                recommendations.add(dishDto);
            }
        }
        return recommendations;
    }

    // ======================== 浏览历史和偏好更新 ========================

    @Override
    public void recordBrowseHistory(Long userId, Long dishId, Long canteenId, Long categoryId, Integer stayDuration) {
        UserBrowseHistory history = new UserBrowseHistory();
        history.setUserId(userId);
        history.setDishId(dishId);
        history.setCanteenId(canteenId);
        history.setCategoryId(categoryId);
        history.setBrowseTime(LocalDateTime.now());
        history.setStayDuration(stayDuration != null ? stayDuration : 0);
        browseHistoryMapper.insert(history);
        log.info("记录用户{}浏览历史：菜品{}", userId, dishId);
    }

    @Override
    public void updateUserPreferenceByOrder(Long userId) {
        LambdaQueryWrapper<Orders> orderWrapper = new LambdaQueryWrapper<>();
        orderWrapper.eq(Orders::getUserId, userId)
                .orderByDesc(Orders::getOrderTime)
                .last("LIMIT 10");
        List<Orders> recentOrders = orderService.list(orderWrapper);

        for (Orders order : recentOrders) {
            LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
            detailWrapper.eq(OrderDetail::getOrderId, order.getId());
            List<OrderDetail> details = orderDetailService.list(detailWrapper);
            for (OrderDetail detail : details) {
                updatePreferenceScore(userId, detail.getDishId());
            }
        }
        log.info("更新用户{}的喜好数据完成", userId);
    }

    private void updatePreferenceScore(Long userId, Long dishId) {
        if (dishId == null) return;
        LambdaQueryWrapper<UserPreference> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserPreference::getUserId, userId)
                .eq(UserPreference::getDishId, dishId);
        UserPreference preference = preferenceMapper.selectOne(wrapper);

        if (preference == null) {
            preference = new UserPreference();
            preference.setUserId(userId);
            preference.setDishId(dishId);
            preference.setPreferenceScore(BigDecimal.valueOf(10));
            preference.setOrderCount(1);
            preference.setLastOrderTime(LocalDateTime.now());
            preferenceMapper.insert(preference);
        } else {
            BigDecimal newScore = preference.getPreferenceScore().add(BigDecimal.valueOf(5));
            if (newScore.compareTo(BigDecimal.valueOf(100)) > 0) {
                newScore = BigDecimal.valueOf(100);
            }
            preference.setPreferenceScore(newScore);
            preference.setOrderCount(preference.getOrderCount() + 1);
            preference.setLastOrderTime(LocalDateTime.now());
            preferenceMapper.updateById(preference);
        }
    }
}
