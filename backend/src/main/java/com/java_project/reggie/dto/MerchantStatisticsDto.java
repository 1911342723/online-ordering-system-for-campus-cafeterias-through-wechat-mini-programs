package com.java_project.reggie.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 商家统计数据DTO
 */
@Data
public class MerchantStatisticsDto {
    
    /**
     * 今日订单数
     */
    private Integer todayOrders;
    
    /**
     * 今日订单增长率(%)
     */
    private Double todayOrdersTrend;
    
    /**
     * 今日营业额(分)
     */
    private BigDecimal todayRevenue;
    
    /**
     * 今日营业额增长率(%)
     */
    private Double todayRevenueTrend;
    
    /**
     * 待处理订单数
     */
    private Integer pendingOrders;
    
    /**
     * 待处理订单增长率(%)
     */
    private Double pendingOrdersTrend;
    
    /**
     * 总用户数
     */
    private Integer totalUsers;
    
    /**
     * 用户增长率(%)
     */
    private Double totalUsersTrend;
    
    /**
     * 营收趋势数据(7天或30天)
     */
    private List<Map<String, Object>> revenueTrend;
    
    /**
     * 热门菜品Top5
     */
    private List<Map<String, Object>> topDishes;
    
    /**
     * 订单状态分布
     */
    private Map<String, Integer> orderStatusDistribution;
}

