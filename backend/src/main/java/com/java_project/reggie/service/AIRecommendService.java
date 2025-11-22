package com.java_project.reggie.service;

import com.java_project.reggie.entity.Dish;

import java.util.List;

/**
 * AI推荐服务接口
 */
public interface AIRecommendService {
    
    /**
     * 根据用户查询检索相关菜品
     * @param userQuery 用户查询
     * @return 相关菜品列表
     */
    List<Dish> searchRelevantDishes(String userQuery);
    
    /**
     * 将菜品列表转换为文本描述
     * @param dishes 菜品列表
     * @return 文本描述
     */
    String formatDishesInfo(List<Dish> dishes);
}

