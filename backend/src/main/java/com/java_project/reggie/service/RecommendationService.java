package com.java_project.reggie.service;

import com.java_project.reggie.dto.DishDto;

import java.util.List;

/**
 * 推荐服务接口
 */
public interface RecommendationService {
    
    /**
     * 获取今日推荐（混合推荐算法）
     * @param userId 用户ID
     * @param limit 推荐数量
     * @return 推荐菜品列表
     */
    List<DishDto> getTodayRecommendations(Long userId, Integer limit);
    
    /**
     * 记录用户浏览历史
     * @param userId 用户ID
     * @param dishId 菜品ID
     * @param canteenId 餐厅ID
     * @param categoryId 分类ID
     * @param stayDuration 停留时长（秒）
     */
    void recordBrowseHistory(Long userId, Long dishId, Long canteenId, Long categoryId, Integer stayDuration);
    
    /**
     * 更新用户喜好（基于订单）
     * @param userId 用户ID
     */
    void updateUserPreferenceByOrder(Long userId);
}

