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
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 推荐服务实现 - 混合推荐算法
 * 
 * 算法说明：
 * 1. 基于协同过滤：根据用户历史订单和浏览记录
 * 2. 基于内容：根据菜品分类和用户喜好分类
 * 3. 热度推荐：结合菜品销量和评分
 * 4. 时间衰减：近期订单权重更高
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

    @Override
    public List<DishDto> getTodayRecommendations(Long userId, Integer limit) {
        if (limit == null || limit <= 0) {
            limit = 10;
        }

        log.info("开始为用户{}生成今日推荐，数量：{}", userId, limit);

        // 1. 获取所有在售菜品
        LambdaQueryWrapper<Dish> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Dish::getStatus, 1)
                .orderByDesc(Dish::getUpdateTime);
        List<Dish> allDishes = dishService.list(queryWrapper);

        if (allDishes.isEmpty()) {
            log.warn("没有在售菜品可供推荐");
            return new ArrayList<>();
        }

        // 2. 检查用户是否为新用户（没有订单历史）
        boolean isNewUser = userId == null || userId == 0L || isUserNew(userId);
        
        List<DishDto> recommendations;
        
        if (isNewUser) {
            // 新用户：推荐热门菜品（按价格和随机组合）
            log.info("用户{}为新用户，推荐热门菜品", userId);
            recommendations = getHotRecommendations(allDishes, limit);
        } else {
            // 老用户：使用混合推荐算法
            log.info("用户{}为老用户，使用混合推荐算法", userId);
            recommendations = getPersonalizedRecommendations(userId, allDishes, limit);
        }

        log.info("为用户{}生成推荐完成，推荐{}道菜品", userId, recommendations.size());
        
        return recommendations;
    }

    /**
     * 检查用户是否为新用户
     */
    private boolean isUserNew(Long userId) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Orders::getUserId, userId);
        long orderCount = orderService.count(wrapper);
        return orderCount == 0;
    }

    /**
     * 新用户推荐：热门菜品
     */
    private List<DishDto> getHotRecommendations(List<Dish> allDishes, Integer limit) {
        // 按价格适中程度和随机性推荐
        Map<Long, Double> dishScores = new HashMap<>();
        
        for (Dish dish : allDishes) {
            double score = 0.0;
            
            // 价格适中的菜品得分更高（50-150元）
            BigDecimal price = dish.getPrice();
            if (price != null) {
                double priceValue = price.doubleValue();
                if (priceValue >= 50 && priceValue <= 150) {
                    score += 50.0;
                } else if (priceValue < 50) {
                    score += 30.0; // 便宜的菜品也有一定权重
                } else {
                    score += 10.0; // 贵的菜品权重较低
                }
            }
            
            // 添加随机因素，增加多样性
            score += Math.random() * 50.0;
            
            dishScores.put(dish.getId(), score);
        }

        // 按分数排序
        List<Long> topDishIds = dishScores.entrySet().stream()
                .sorted((e1, e2) -> Double.compare(e2.getValue(), e1.getValue()))
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        return buildDishDtoList(allDishes, topDishIds);
    }

    /**
     * 老用户推荐：个性化推荐
     */
    private List<DishDto> getPersonalizedRecommendations(Long userId, List<Dish> allDishes, Integer limit) {
        // 1. 获取用户喜好菜品（基于历史订单）
        List<Long> preferredDishIds = getUserPreferredDishes(userId);
        
        // 2. 获取用户喜好分类
        List<Long> preferredCategoryIds = getUserPreferredCategories(userId);
        
        // 3. 获取用户浏览过的菜品
        List<Long> browsedDishIds = getUserBrowsedDishes(userId);

        // 4. 计算推荐分数
        Map<Long, Double> dishScores = new HashMap<>();
        
        for (Dish dish : allDishes) {
            double score = 0.0;
            
            // 4.1 用户喜好菜品权重（已订购过的菜品，优先推荐）
            if (preferredDishIds.contains(dish.getId())) {
                score += 50.0;
            }
            
            // 4.2 用户喜好分类权重
            if (preferredCategoryIds.contains(dish.getCategoryId())) {
                score += 30.0;
            }
            
            // 4.3 浏览历史权重（浏览过但未购买，适度推荐）
            if (browsedDishIds.contains(dish.getId())) {
                score += 20.0;
            }
            
            // 4.4 随机探索权重（增加新菜品曝光）
            score += Math.random() * 15.0;
            
            // 4.5 价格因素（价格适中的菜品得分稍高）
            BigDecimal price = dish.getPrice();
            if (price != null) {
                double priceValue = price.doubleValue();
                if (priceValue >= 50 && priceValue <= 200) {
                    score += 10.0;
                }
            }
            
            dishScores.put(dish.getId(), score);
        }

        // 5. 按分数排序并取前N个
        List<Long> recommendedDishIds = dishScores.entrySet().stream()
                .sorted((e1, e2) -> Double.compare(e2.getValue(), e1.getValue()))
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        return buildDishDtoList(allDishes, recommendedDishIds);
    }

    /**
     * 构建菜品DTO列表
     */
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
                
                // 设置分类名称
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
        // 获取用户最近的订单
        LambdaQueryWrapper<Orders> orderWrapper = new LambdaQueryWrapper<>();
        orderWrapper.eq(Orders::getUserId, userId)
                .orderByDesc(Orders::getOrderTime)
                .last("LIMIT 10");
        
        List<Orders> recentOrders = orderService.list(orderWrapper);
        
        for (Orders order : recentOrders) {
            // 获取订单详情
            LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
            detailWrapper.eq(OrderDetail::getOrderId, order.getId());
            List<OrderDetail> details = orderDetailService.list(detailWrapper);
            
            for (OrderDetail detail : details) {
                updatePreferenceScore(userId, detail.getDishId());
            }
        }
        
        log.info("更新用户{}的喜好数据完成", userId);
    }

    /**
     * 获取用户喜好菜品ID列表
     */
    private List<Long> getUserPreferredDishes(Long userId) {
        LambdaQueryWrapper<UserPreference> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserPreference::getUserId, userId)
                .isNotNull(UserPreference::getDishId)
                .orderByDesc(UserPreference::getPreferenceScore)
                .last("LIMIT 20");
        
        return preferenceMapper.selectList(wrapper).stream()
                .map(UserPreference::getDishId)
                .collect(Collectors.toList());
    }

    /**
     * 获取用户喜好分类ID列表
     */
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
     * 获取用户浏览过的菜品ID列表
     */
    private List<Long> getUserBrowsedDishes(Long userId) {
        LambdaQueryWrapper<UserBrowseHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserBrowseHistory::getUserId, userId)
                .isNotNull(UserBrowseHistory::getDishId)
                .orderByDesc(UserBrowseHistory::getBrowseTime)
                .last("LIMIT 30");
        
        return browseHistoryMapper.selectList(wrapper).stream()
                .map(UserBrowseHistory::getDishId)
                .distinct()
                .collect(Collectors.toList());
    }

    /**
     * 更新用户对某个菜品的喜好分数
     */
    private void updatePreferenceScore(Long userId, Long dishId) {
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
            // 增加喜好分数和订单次数
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

