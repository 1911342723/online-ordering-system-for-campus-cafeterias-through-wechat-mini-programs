package com.java_project.reggie.service;

import com.java_project.reggie.dto.MerchantStatisticsDto;

import java.util.List;
import java.util.Map;

/**
 * 统计分析Service
 */
public interface StatisticsService {
    
    /**
     * 获取商家统计数据
     */
    MerchantStatisticsDto getMerchantStatistics(Long merchantId, String period);
    
    /**
     * 获取营收趋势
     */
    List<Map<String, Object>> getRevenueTrend(Long merchantId, String period);
    
    /**
     * 获取热门菜品排行
     */
    List<Map<String, Object>> getTopDishes(Long merchantId, Integer limit);
}

