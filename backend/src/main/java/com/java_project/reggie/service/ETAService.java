package com.java_project.reggie.service;

import java.util.Map;

/**
 * 取餐排队ETA预估服务接口
 *
 * 核心算法：
 * ETA = 当前排队订单数 × 加权平均出餐时间
 *
 * 加权平均出餐时间使用时间衰减机制：
 * weight_i = e^(-λ × (now - completed_time_i).minutes)
 * weighted_avg = Σ(weight_i × serving_time_i) / Σ(weight_i)
 */
public interface ETAService {

    /**
     * 获取指定商家（档口）的预估取餐等待时间
     *
     * @param merchantId 商家（档口）ID
     * @return 预估信息 Map:
     *   - estimatedMinutes: 预估等待分钟数
     *   - queueLength: 当前排队订单数
     *   - avgServingTime: 加权平均出餐时间（秒）
     *   - status: 状态描述（空闲/适中/繁忙）
     */
    Map<String, Object> getEstimatedWaitTime(Long merchantId);

    /**
     * 记录一笔订单的出餐完成数据（供ETA计算使用）
     *
     * @param orderId 订单ID
     * @param merchantId 商家ID
     * @param dishCount 菜品数量
     */
    void recordOrderCompletion(Long orderId, Long merchantId, Integer dishCount);
}
