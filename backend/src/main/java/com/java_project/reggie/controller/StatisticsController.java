package com.java_project.reggie.controller;

import com.java_project.reggie.common.AuthHelper;
import com.java_project.reggie.common.R;
import com.java_project.reggie.dto.MerchantStatisticsDto;
import com.java_project.reggie.service.StatisticsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 统计分析Controller
 */
@Slf4j
@RestController
@RequestMapping("/statistics")
public class StatisticsController {

    @Autowired
    private StatisticsService statisticsService;
    
    @Autowired
    private AuthHelper authHelper;

    /**
     * 获取商家数据概览
     * @param period 时间段: week-本周, month-本月
     */
    @GetMapping("/merchant/overview")
    public R<MerchantStatisticsDto> getMerchantOverview(
            @RequestParam(defaultValue = "week") String period) {
        
        Long merchantId = authHelper.getCurrentMerchantId();
        if (merchantId == null) {
            return R.error("未找到商家信息");
        }
        
        log.info("获取商家{}的数据概览，时间段：{}", merchantId, period);
        
        MerchantStatisticsDto statistics = statisticsService.getMerchantStatistics(merchantId, period);
        return R.success(statistics);
    }
    
    /**
     * 获取营收趋势
     */
    @GetMapping("/merchant/revenue-trend")
    public R<Object> getRevenueTrend(
            @RequestParam(defaultValue = "week") String period) {
        
        Long merchantId = authHelper.getCurrentMerchantId();
        if (merchantId == null) {
            return R.error("未找到商家信息");
        }
        
        log.info("获取商家{}的营收趋势，时间段：{}", merchantId, period);
        
        Object data = statisticsService.getRevenueTrend(merchantId, period);
        return R.success(data);
    }
    
    /**
     * 获取热门菜品排行
     */
    @GetMapping("/merchant/top-dishes")
    public R<Object> getTopDishes(
            @RequestParam(defaultValue = "10") Integer limit) {
        
        Long merchantId = authHelper.getCurrentMerchantId();
        if (merchantId == null) {
            return R.error("未找到商家信息");
        }
        
        log.info("获取商家{}的热门菜品Top{}", merchantId, limit);
        
        Object data = statisticsService.getTopDishes(merchantId, limit);
        return R.success(data);
    }
}

