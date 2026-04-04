package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.entity.Category;
import com.java_project.reggie.entity.Dish;
import com.java_project.reggie.entity.DishFlavor;
import com.java_project.reggie.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

/**
 * AI推荐服务实现 — 基于LLM意图解析的智能菜品检索
 *
 * 核心流程:
 * 1. 调用LLM解析用户自然语言，提取结构化意图（类别/口味/忌口/健康偏好等）
 * 2. 基于提取的关键词和意图，对菜品库进行多维度评分匹配
 * 3. 自动匹配菜品口味选项（如"不加葱蒜"→勾选"不要葱""不要蒜"）
 */
@Service
@Slf4j
public class AIRecommendServiceImpl implements AIRecommendService {

    @Autowired
    private DishService dishService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private MerchantService merchantService;

    @Autowired
    private DishFlavorService dishFlavorService;

    @Autowired
    private LLMService llmService;

    @Override
    public List<Dish> searchRelevantDishes(String userQuery) {
        log.info("AI检索菜品，用户查询：{}", userQuery);

        // 1. 调用LLM解析用户意图
        Map<String, Object> intent = llmService.parseUserIntent(userQuery);
        log.info("LLM解析意图结果：{}", intent);

        String category = (String) intent.getOrDefault("category", "");
        String taste = (String) intent.getOrDefault("taste", "");
        String priceRange = (String) intent.getOrDefault("priceRange", "");
        String healthPref = (String) intent.getOrDefault("healthPreference", "");
        List<String> keywords = (List<String>) intent.getOrDefault("keywords", new ArrayList<>());
        List<String> restrictions = (List<String>) intent.getOrDefault("restrictions", new ArrayList<>());

        // 2. 查询所有在售菜品
        LambdaQueryWrapper<Dish> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Dish::getStatus, 1);
        List<Dish> allDishes = dishService.list(queryWrapper);

        if (allDishes.isEmpty()) {
            log.warn("没有找到在售菜品");
            return new ArrayList<>();
        }

        // 3. 获取分类映射
        Map<Long, String> categoryMap = new HashMap<>();
        try {
            List<Category> categories = categoryService.list();
            for (Category cat : categories) {
                categoryMap.put(cat.getId(), cat.getName());
            }
        } catch (Exception e) {
            log.warn("获取分类映射失败", e);
        }

        // 4. 获取商家评分映射
        Map<Long, BigDecimal> merchantRatings = new HashMap<>();
        try {
            List<com.java_project.reggie.entity.Merchant> merchants = merchantService.list();
            for (com.java_project.reggie.entity.Merchant m : merchants) {
                if (m.getId() != null && m.getRating() != null) {
                    merchantRatings.put(m.getId(), m.getRating());
                }
            }
        } catch (Exception e) {
            log.warn("获取商家评分失败", e);
        }

        // 5. 根据LLM解析的意图进行多维度评分
        List<Dish> rankedDishes = allDishes.stream()
                .map(dish -> {
                    int score = calculateIntentMatchScore(
                            dish, category, taste, priceRange, healthPref,
                            keywords, restrictions, categoryMap, merchantRatings, userQuery
                    );
                    dish.setSort(score); // 临时用sort字段存储分数
                    return dish;
                })
                .filter(dish -> dish.getSort() > 0)
                .sorted((a, b) -> Integer.compare(b.getSort(), a.getSort()))
                .limit(10)
                .collect(Collectors.toList());

        log.info("检索到{}个相关菜品", rankedDishes.size());
        return rankedDishes;
    }

    /**
     * 根据LLM解析的用户意图，自动匹配菜品口味选项
     *
     * @param dishId 菜品ID
     * @param restrictions 用户的忌口列表（如["不要葱","不要蒜"]）
     * @return 匹配到的口味选项 Map<口味名称, 选中的值>，如 {"忌口": ["不要葱","不要蒜"]}
     */
    public Map<String, List<String>> matchFlavorOptions(Long dishId, List<String> restrictions) {
        Map<String, List<String>> matchedFlavors = new HashMap<>();

        if (restrictions == null || restrictions.isEmpty() || dishId == null) {
            return matchedFlavors;
        }

        try {
            // 查询该菜品的口味选项
            LambdaQueryWrapper<DishFlavor> flavorWrapper = new LambdaQueryWrapper<>();
            flavorWrapper.eq(DishFlavor::getDishId, dishId);
            List<DishFlavor> flavors = dishFlavorService.list(flavorWrapper);

            for (DishFlavor flavor : flavors) {
                if (flavor.getValue() == null) continue;

                // 解析口味选项值列表（JSON数组格式）
                String valueStr = flavor.getValue();
                List<String> options = new ArrayList<>();
                try {
                    com.alibaba.fastjson.JSONArray arr = com.alibaba.fastjson.JSON.parseArray(valueStr);
                    for (int i = 0; i < arr.size(); i++) {
                        options.add(arr.getString(i));
                    }
                } catch (Exception e) {
                    continue;
                }

                // 匹配用户忌口与口味选项
                List<String> matched = new ArrayList<>();
                for (String restriction : restrictions) {
                    for (String option : options) {
                        // 模糊匹配: "不要葱" 匹配 "不要葱"
                        if (option.contains(restriction) || restriction.contains(option)) {
                            matched.add(option);
                        }
                    }
                }

                if (!matched.isEmpty()) {
                    matchedFlavors.put(flavor.getName(), matched);
                }
            }
        } catch (Exception e) {
            log.error("匹配口味选项异常", e);
        }

        return matchedFlavors;
    }

    /**
     * 基于LLM意图的多维度匹配评分
     */
    private int calculateIntentMatchScore(
            Dish dish, String category, String taste, String priceRange,
            String healthPref, List<String> keywords, List<String> restrictions,
            Map<Long, String> categoryMap, Map<Long, BigDecimal> merchantRatings,
            String originalQuery) {

        int score = 0;
        String dishName = dish.getName().toLowerCase();
        String dishDesc = (dish.getDescription() != null ? dish.getDescription() : "").toLowerCase();
        String dishInfo = dishName + " " + dishDesc;
        String nutritionTags = dish.getNutritionTags() != null ? dish.getNutritionTags().toLowerCase() : "";

        // 1. 类别匹配（权重最高）
        if (!category.isEmpty()) {
            // 检查菜品所属分类是否匹配
            String catName = categoryMap.getOrDefault(dish.getCategoryId(), "");
            if (catName.contains(category) || category.contains(catName)) {
                score += 30;
            }
            // 检查菜名/描述是否包含类别关键词
            if (dishInfo.contains(category.toLowerCase())) {
                score += 15;
            }
        }

        // 2. 口味匹配
        if (!taste.isEmpty()) {
            if (dishInfo.contains(taste.toLowerCase())) {
                score += 20;
            }
        }

        // 3. 关键词匹配
        for (String keyword : keywords) {
            if (keyword.length() >= 1 && dishInfo.contains(keyword.toLowerCase())) {
                score += 10;
            }
        }

        // 4. 原始查询直接匹配（菜名命中加分）
        if (dishName.contains(originalQuery.toLowerCase())) {
            score += 25;
        }

        // 5. 价格偏好
        if (!priceRange.isEmpty() && dish.getPrice() != null) {
            double priceYuan = dish.getPrice().doubleValue() / 100.0;
            if (priceRange.contains("便宜") || priceRange.contains("实惠")) {
                if (priceYuan <= 15) score += 15;
                else if (priceYuan <= 25) score += 8;
            }
        }

        // 6. 健康偏好匹配（基于营养标签和卡路里）
        if (!healthPref.isEmpty()) {
            if (healthPref.contains("低卡") || healthPref.contains("减脂")) {
                if (dish.getCalories() != null && dish.getCalories() <= 350) score += 20;
                if (nutritionTags.contains("低卡") || nutritionTags.contains("低脂")) score += 10;
            } else if (healthPref.contains("高蛋白") || healthPref.contains("增肌")) {
                if (dish.getProtein() != null && dish.getProtein().compareTo(new BigDecimal("20")) > 0) score += 20;
                if (nutritionTags.contains("高蛋白")) score += 10;
            } else if (healthPref.contains("健康")) {
                if (nutritionTags.contains("均衡") || nutritionTags.contains("高纤维")) score += 10;
            }
        }

        // 7. 忌口过滤（包含忌口食材的菜品扣分）
        for (String restriction : restrictions) {
            String keyword = restriction.replace("不要", "").replace("不加", "").replace("去", "");
            if (dishInfo.contains(keyword.toLowerCase())) {
                score -= 20; // 包含忌口食材的菜品大幅扣分
            }
        }

        // 8. 商家评分加权
        if (dish.getMerchantId() != null && merchantRatings.containsKey(dish.getMerchantId())) {
            BigDecimal rating = merchantRatings.get(dish.getMerchantId());
            if (rating != null) {
                score += rating.multiply(new BigDecimal("3")).intValue();
            }
        }

        return score;
    }

    @Override
    public String formatDishesInfo(List<Dish> dishes) {
        if (dishes == null || dishes.isEmpty()) {
            return "暂无符合条件的菜品。";
        }

        StringBuilder sb = new StringBuilder();
        int index = 1;

        for (Dish dish : dishes) {
            String categoryName = "";
            if (dish.getCategoryId() != null) {
                Category category = categoryService.getById(dish.getCategoryId());
                if (category != null) {
                    categoryName = category.getName();
                }
            }

            sb.append(index++).append(". ")
              .append("【").append(dish.getName()).append("】\n")
              .append("   价格：").append(String.format("%.0f", dish.getPrice().doubleValue())).append("分\n");

            if (!categoryName.isEmpty()) {
                sb.append("   分类：").append(categoryName).append("\n");
            }

            if (dish.getDescription() != null && !dish.getDescription().isEmpty()) {
                sb.append("   描述：").append(dish.getDescription()).append("\n");
            }

            // 营养信息
            if (dish.getCalories() != null) {
                sb.append("   热量：").append(dish.getCalories()).append("千卡");
                if (dish.getProtein() != null) sb.append("  蛋白质：").append(dish.getProtein()).append("g");
                if (dish.getFat() != null) sb.append("  脂肪：").append(dish.getFat()).append("g");
                sb.append("\n");
            }

            if (dish.getNutritionTags() != null) {
                sb.append("   营养标签：").append(dish.getNutritionTags()).append("\n");
            }

            sb.append("\n");
        }

        return sb.toString();
    }
}
