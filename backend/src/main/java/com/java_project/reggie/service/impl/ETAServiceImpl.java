package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.entity.OrderCompletionLog;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.mapper.OrderCompletionLogMapper;
import com.java_project.reggie.service.ETAService;
import com.java_project.reggie.service.OrderService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 取餐排队ETA预估服务实现
 *
 * 核心算法原理：
 *
 * 1. 队列深度统计:
 *    统计当前商家（档口）下，状态为"已接单但未出餐"的订单总量
 *    即 status=2 (待派送/制作中) 的订单数量
 *
 * 2. 加权平均出餐速度:
 *    获取该商家过去60分钟内的出餐完成日志
 *    对每条日志的出餐耗时 serving_duration_seconds 进行时间衰减加权:
 *
 *    weight_i = e^(-λ × Δminutes)
 *    其中 λ = 0.05 (衰减系数，约14分钟半衰期)
 *    Δminutes = (当前时间 − 该日志出餐完成时间) 的分钟数
 *
 *    越近的出餐记录权重越大，越能反映当前的出餐速度
 *
 *    weighted_avg_serving_time = Σ(weight_i × serving_time_i) / Σ(weight_i)
 *
 * 3. 最终ETA计算:
 *    ETA_seconds = queue_length × weighted_avg_serving_time
 *    ETA_minutes = ceil(ETA_seconds / 60)
 *
 * 4. 冷启动处理:
 *    如果没有历史出餐数据，使用默认值：每单5分钟出餐
 */
@Slf4j
@Service
public class ETAServiceImpl implements ETAService {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderCompletionLogMapper completionLogMapper;

    // 时间衰减系数 λ = 0.05，约14分钟半衰期 (ln(2)/0.05 ≈ 13.86)
    private static final double DECAY_LAMBDA = 0.05;

    // 默认出餐时间（秒）— 冷启动时使用
    private static final int DEFAULT_SERVING_TIME_SECONDS = 300; // 5分钟

    // 历史数据窗口（分钟）
    private static final int HISTORY_WINDOW_MINUTES = 60;

    @Override
    public Map<String, Object> getEstimatedWaitTime(Long merchantId) {
        Map<String, Object> result = new HashMap<>();

        try {
            // ====== Step 1: 计算当前排队订单数（队列深度） ======
            int queueLength = calculateQueueLength(merchantId);

            // ====== Step 2: 计算加权平均出餐时间 ======
            double avgServingTimeSeconds = calculateWeightedAvgServingTime(merchantId);

            // ====== Step 3: 计算最终ETA ======
            double etaSeconds = queueLength * avgServingTimeSeconds;
            int etaMinutes = (int) Math.ceil(etaSeconds / 60.0);

            // 最低1分钟，最高不超过120分钟
            if (queueLength > 0) {
                etaMinutes = Math.max(1, Math.min(etaMinutes, 120));
            } else {
                etaMinutes = 0;
            }

            // ====== Step 4: 判断繁忙状态 ======
            String status;
            if (queueLength == 0) {
                status = "空闲";
            } else if (queueLength <= 3) {
                status = "空闲";
            } else if (queueLength <= 8) {
                status = "适中";
            } else {
                status = "繁忙";
            }

            result.put("estimatedMinutes", etaMinutes);
            result.put("queueLength", queueLength);
            result.put("avgServingTime", (int) avgServingTimeSeconds);
            result.put("status", status);

            log.info("商家{}的ETA预估: 排队{}单, 加权平均出餐{:.0f}秒, 预计等待{}分钟, 状态:{}",
                    merchantId, queueLength, avgServingTimeSeconds, etaMinutes, status);

        } catch (Exception e) {
            log.error("ETA预估计算异常，商家ID: {}", merchantId, e);
            result.put("estimatedMinutes", -1);
            result.put("queueLength", 0);
            result.put("avgServingTime", DEFAULT_SERVING_TIME_SECONDS);
            result.put("status", "未知");
        }

        return result;
    }

    /**
     * 计算当前排队订单数（队列深度）
     *
     * 统计该商家下 status=2（待派送/制作中）的订单数量
     * 这些是已接单但尚未完成的订单
     */
    private int calculateQueueLength(Long merchantId) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Orders::getMerchantId, merchantId)
               .eq(Orders::getStatus, 2); // 状态2: 制作中/待派送
        long count = orderService.count(wrapper);
        return (int) count;
    }

    /**
     * 计算加权平均出餐时间（带时间衰减）
     *
     * 算法：
     * 1. 获取过去60分钟内该商家的所有出餐完成记录
     * 2. 对每条记录计算时间衰减权重: weight = e^(-λ × Δminutes)
     * 3. 加权平均: Σ(weight × servingTime) / Σ(weight)
     *
     * @return 加权平均出餐时间（秒）
     */
    private double calculateWeightedAvgServingTime(Long merchantId) {
        LocalDateTime windowStart = LocalDateTime.now().minusMinutes(HISTORY_WINDOW_MINUTES);

        // 查询历史出餐日志
        LambdaQueryWrapper<OrderCompletionLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OrderCompletionLog::getMerchantId, merchantId)
               .ge(OrderCompletionLog::getCompletedTime, windowStart)
               .orderByDesc(OrderCompletionLog::getCompletedTime);
        List<OrderCompletionLog> logs = completionLogMapper.selectList(wrapper);

        // 冷启动: 没有历史数据时使用默认值
        if (logs.isEmpty()) {
            log.info("商家{}无历史出餐数据，使用默认出餐时间{}秒", merchantId, DEFAULT_SERVING_TIME_SECONDS);
            return DEFAULT_SERVING_TIME_SECONDS;
        }

        // 计算加权平均
        double weightedSum = 0.0;
        double weightTotal = 0.0;
        LocalDateTime now = LocalDateTime.now();

        for (OrderCompletionLog logEntry : logs) {
            // 计算该记录距现在的分钟数
            long minutesAgo = ChronoUnit.MINUTES.between(logEntry.getCompletedTime(), now);
            if (minutesAgo < 0) minutesAgo = 0;

            // 时间衰减权重: weight = e^(-λ × Δminutes)
            double weight = Math.exp(-DECAY_LAMBDA * minutesAgo);

            // 出餐耗时（秒）
            int servingTime = logEntry.getServingDurationSeconds();
            if (servingTime <= 0) servingTime = DEFAULT_SERVING_TIME_SECONDS;

            weightedSum += weight * servingTime;
            weightTotal += weight;
        }

        if (weightTotal == 0) {
            return DEFAULT_SERVING_TIME_SECONDS;
        }

        double weightedAvg = weightedSum / weightTotal;

        log.info("商家{}的加权平均出餐时间: {:.1f}秒 (基于{}条记录)", merchantId, weightedAvg, logs.size());
        return weightedAvg;
    }

    @Override
    public void recordOrderCompletion(Long orderId, Long merchantId, Integer dishCount) {
        try {
            // 查询订单获取接单时间
            Orders order = orderService.getById(orderId);
            if (order == null) {
                log.warn("记录出餐完成失败: 订单{}不存在", orderId);
                return;
            }

            LocalDateTime acceptedTime = order.getAcceptedTime();
            LocalDateTime completedTime = LocalDateTime.now();

            // 如果没有接单时间，使用下单时间作为近似
            if (acceptedTime == null) {
                acceptedTime = order.getOrderTime();
            }

            // 计算出餐耗时（秒）
            int servingDuration = (int) Duration.between(acceptedTime, completedTime).getSeconds();
            if (servingDuration <= 0) servingDuration = 1;

            // 写入出餐日志
            OrderCompletionLog logEntry = new OrderCompletionLog();
            logEntry.setOrderId(orderId);
            logEntry.setMerchantId(merchantId);
            logEntry.setDishCount(dishCount != null ? dishCount : 1);
            logEntry.setAcceptedTime(acceptedTime);
            logEntry.setCompletedTime(completedTime);
            logEntry.setServingDurationSeconds(servingDuration);
            logEntry.setCreateTime(LocalDateTime.now());

            completionLogMapper.insert(logEntry);

            log.info("记录出餐完成: 订单{}, 商家{}, 菜品{}道, 耗时{}秒",
                    orderId, merchantId, dishCount, servingDuration);

        } catch (Exception e) {
            log.error("记录出餐完成异常: orderId={}, merchantId={}", orderId, merchantId, e);
        }
    }
}
