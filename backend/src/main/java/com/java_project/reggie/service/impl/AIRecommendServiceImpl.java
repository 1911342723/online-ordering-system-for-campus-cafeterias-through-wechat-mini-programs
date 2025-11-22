package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.entity.Category;
import com.java_project.reggie.entity.Dish;
import com.java_project.reggie.service.AIRecommendService;
import com.java_project.reggie.service.CategoryService;
import com.java_project.reggie.service.DishService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

/**
 * AI推荐服务实现
 */
@Service
@Slf4j
public class AIRecommendServiceImpl implements AIRecommendService {
    
    @Autowired
    private DishService dishService;
    
    @Autowired
    private CategoryService categoryService;
    
    // 关键词映射
    private static final Map<String, List<String>> KEYWORD_MAP = new HashMap<>();
    
    static {
        // 口味关键词
        KEYWORD_MAP.put("辣", Arrays.asList("辣", "川菜", "麻", "香辣", "麻辣", "宫保", "水煮", "麻婆"));
        KEYWORD_MAP.put("清淡", Arrays.asList("清淡", "清炒", "蒸", "煮", "素", "时蔬", "青菜"));
        KEYWORD_MAP.put("酸", Arrays.asList("酸", "醋", "番茄", "酸甜", "糖醋"));
        KEYWORD_MAP.put("甜", Arrays.asList("甜", "糖", "蜜", "红烧"));
        
        // 营养关键词
        KEYWORD_MAP.put("营养", Arrays.asList("营养", "健康", "蛋白", "维生素", "套餐"));
        KEYWORD_MAP.put("蛋白", Arrays.asList("肉", "鸡", "鱼", "蛋", "豆腐", "牛"));
        KEYWORD_MAP.put("蔬菜", Arrays.asList("菜", "素", "蔬", "青", "瓜", "豆"));
        
        // 类型关键词
        KEYWORD_MAP.put("主食", Arrays.asList("饭", "面", "粉", "馒头", "饼"));
        KEYWORD_MAP.put("汤", Arrays.asList("汤", "羹"));
        KEYWORD_MAP.put("炒菜", Arrays.asList("炒", "烧", "煎", "炸"));
        
        // 预算关键词
        KEYWORD_MAP.put("便宜", Arrays.asList("实惠", "便宜", "经济"));
        KEYWORD_MAP.put("实惠", Arrays.asList("实惠", "便宜", "经济"));
    }
    
    @Override
    public List<Dish> searchRelevantDishes(String userQuery) {
        log.info("检索菜品，用户查询：{}", userQuery);
        
        // 提取关键词
        Set<String> keywords = extractKeywords(userQuery);
        log.info("提取到的关键词：{}", keywords);
        
        // 查询所有在售菜品
        LambdaQueryWrapper<Dish> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Dish::getStatus, 1); // 在售状态
        List<Dish> allDishes = dishService.list(queryWrapper);
        
        if (allDishes.isEmpty()) {
            log.warn("没有找到在售菜品");
            return new ArrayList<>();
        }
        
        // 根据关键词匹配度排序
        List<Dish> rankedDishes = allDishes.stream()
                .map(dish -> {
                    int score = calculateMatchScore(dish, keywords, userQuery);
                    dish.setSort(score); // 临时用sort字段存储分数
                    return dish;
                })
                .filter(dish -> dish.getSort() > 0) // 过滤掉不匹配的
                .sorted((a, b) -> Integer.compare(b.getSort(), a.getSort())) // 按分数降序
                .limit(10) // 最多返回10个
                .collect(Collectors.toList());
        
        log.info("检索到{}个相关菜品", rankedDishes.size());
        return rankedDishes;
    }
    
    @Override
    public String formatDishesInfo(List<Dish> dishes) {
        if (dishes == null || dishes.isEmpty()) {
            return "抱歉，目前没有符合条件的菜品。";
        }
        
        StringBuilder sb = new StringBuilder();
        int index = 1;
        
        for (Dish dish : dishes) {
            // 获取分类名称
            String categoryName = "";
            if (dish.getCategoryId() != null) {
                Category category = categoryService.getById(dish.getCategoryId());
                if (category != null) {
                    categoryName = category.getName();
                }
            }
            
            sb.append(index++).append(". ")
              .append("【").append(dish.getName()).append("】\n")
              .append("   价格：¥").append(String.format("%.2f", dish.getPrice().doubleValue() / 100.0)).append("\n");
            
            if (categoryName != null && !categoryName.isEmpty()) {
                sb.append("   分类：").append(categoryName).append("\n");
            }
            
            if (dish.getDescription() != null && !dish.getDescription().isEmpty()) {
                sb.append("   描述：").append(dish.getDescription()).append("\n");
            }
            
            sb.append("\n");
        }
        
        return sb.toString();
    }
    
    /**
     * 提取关键词
     */
    private Set<String> extractKeywords(String query) {
        Set<String> keywords = new HashSet<>();
        String lowerQuery = query.toLowerCase();
        
        // 遍历关键词映射
        for (Map.Entry<String, List<String>> entry : KEYWORD_MAP.entrySet()) {
            for (String keyword : entry.getValue()) {
                if (lowerQuery.contains(keyword)) {
                    keywords.add(keyword);
                }
            }
        }
        
        // 如果没有匹配到预定义关键词，直接使用用户输入的词
        if (keywords.isEmpty()) {
            keywords.addAll(Arrays.asList(query.split("\\s+")));
        }
        
        return keywords;
    }
    
    /**
     * 计算匹配分数
     */
    private int calculateMatchScore(Dish dish, Set<String> keywords, String userQuery) {
        int score = 0;
        String dishInfo = (dish.getName() + " " + 
                          (dish.getDescription() != null ? dish.getDescription() : "")).toLowerCase();
        
        // 关键词匹配
        for (String keyword : keywords) {
            if (dishInfo.contains(keyword.toLowerCase())) {
                score += 10; // 每个关键词匹配加10分
            }
        }
        
        // 菜名完全匹配加分
        if (dishInfo.contains(userQuery.toLowerCase())) {
            score += 20;
        }
        
        // 价格因素（便宜的菜品略加分）
        if (userQuery.contains("便宜") || userQuery.contains("实惠")) {
            if (dish.getPrice() != null) {
                if (dish.getPrice().compareTo(new BigDecimal("2000")) < 0) { // 20元以下
                    score += 15;
                } else if (dish.getPrice().compareTo(new BigDecimal("3000")) < 0) { // 30元以下
                    score += 5;
                }
            }
        }
        
        return score;
    }
}

