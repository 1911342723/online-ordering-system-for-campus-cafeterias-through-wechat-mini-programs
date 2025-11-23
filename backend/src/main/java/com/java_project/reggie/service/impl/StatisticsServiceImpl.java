package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.dto.MerchantStatisticsDto;
import com.java_project.reggie.entity.OrderDetail;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.mapper.OrderDetailMapper;
import com.java_project.reggie.mapper.OrderMapper;
import com.java_project.reggie.service.StatisticsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 统计分析ServiceImpl
 */
@Slf4j
@Service
public class StatisticsServiceImpl implements StatisticsService {

    @Autowired
    private OrderMapper orderMapper;
    
    @Autowired
    private OrderDetailMapper orderDetailMapper;

    @Override
    public MerchantStatisticsDto getMerchantStatistics(Long merchantId, String period) {
        MerchantStatisticsDto dto = new MerchantStatisticsDto();
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime todayStart = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        LocalDateTime yesterdayStart = todayStart.minusDays(1);
        LocalDateTime yesterdayEnd = todayStart.minusSeconds(1);
        
        // 今日数据
        LambdaQueryWrapper<Orders> todayWrapper = new LambdaQueryWrapper<>();
        todayWrapper.eq(Orders::getMerchantId, merchantId)
                .ge(Orders::getOrderTime, todayStart)
                .le(Orders::getOrderTime, now)
                .in(Orders::getStatus, Arrays.asList(2, 3, 4, 5)); // 排除待付款和已取消
        List<Orders> todayOrders = orderMapper.selectList(todayWrapper);
        
        // 昨日数据（用于计算增长率）
        LambdaQueryWrapper<Orders> yesterdayWrapper = new LambdaQueryWrapper<>();
        yesterdayWrapper.eq(Orders::getMerchantId, merchantId)
                .ge(Orders::getOrderTime, yesterdayStart)
                .le(Orders::getOrderTime, yesterdayEnd)
                .in(Orders::getStatus, Arrays.asList(2, 3, 4, 5));
        List<Orders> yesterdayOrders = orderMapper.selectList(yesterdayWrapper);
        
        // 今日订单数
        dto.setTodayOrders(todayOrders.size());
        
        // 今日订单增长率
        if (yesterdayOrders.size() > 0) {
            double trend = ((todayOrders.size() - yesterdayOrders.size()) * 100.0) / yesterdayOrders.size();
            dto.setTodayOrdersTrend(Math.round(trend * 10) / 10.0);
        } else {
            dto.setTodayOrdersTrend(todayOrders.size() > 0 ? 100.0 : 0.0);
        }
        
        // 今日营业额
        BigDecimal todayRevenue = todayOrders.stream()
                .map(Orders::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        dto.setTodayRevenue(todayRevenue);
        
        // 昨日营业额（用于计算增长率）
        BigDecimal yesterdayRevenue = yesterdayOrders.stream()
                .map(Orders::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        // 今日营业额增长率
        if (yesterdayRevenue.compareTo(BigDecimal.ZERO) > 0) {
            double revenueTrend = todayRevenue.subtract(yesterdayRevenue)
                    .multiply(new BigDecimal("100"))
                    .divide(yesterdayRevenue, 1, RoundingMode.HALF_UP)
                    .doubleValue();
            dto.setTodayRevenueTrend(revenueTrend);
        } else {
            dto.setTodayRevenueTrend(todayRevenue.compareTo(BigDecimal.ZERO) > 0 ? 100.0 : 0.0);
        }
        
        // 待处理订单数（待接单 + 制作中）
        LambdaQueryWrapper<Orders> pendingWrapper = new LambdaQueryWrapper<>();
        pendingWrapper.eq(Orders::getMerchantId, merchantId)
                .in(Orders::getStatus, Arrays.asList(2, 3));
        int pendingCount = orderMapper.selectCount(pendingWrapper).intValue();
        dto.setPendingOrders(pendingCount);
        dto.setPendingOrdersTrend(0.0); // 待处理订单暂时不计算增长率
        
        // 总用户数（下过单的用户）
        LambdaQueryWrapper<Orders> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.eq(Orders::getMerchantId, merchantId)
                .select(Orders::getUserId)
                .groupBy(Orders::getUserId);
        int totalUsers = orderMapper.selectList(userWrapper).size();
        dto.setTotalUsers(totalUsers);
        dto.setTotalUsersTrend(0.0); // 总用户数暂时不计算增长率
        
        // 营收趋势
        dto.setRevenueTrend(getRevenueTrend(merchantId, period));
        
        // 热门菜品Top5
        dto.setTopDishes(getTopDishes(merchantId, 5));
        
        // 订单状态分布
        Map<String, Integer> statusDistribution = new HashMap<>();
        LambdaQueryWrapper<Orders> statusWrapper = new LambdaQueryWrapper<>();
        statusWrapper.eq(Orders::getMerchantId, merchantId)
                .ge(Orders::getOrderTime, todayStart);
        List<Orders> allTodayOrders = orderMapper.selectList(statusWrapper);
        
        statusDistribution.put("pending", (int) allTodayOrders.stream().filter(o -> o.getStatus() == 2).count());
        statusDistribution.put("processing", (int) allTodayOrders.stream().filter(o -> o.getStatus() == 3).count());
        statusDistribution.put("delivering", (int) allTodayOrders.stream().filter(o -> o.getStatus() == 4).count());
        statusDistribution.put("completed", (int) allTodayOrders.stream().filter(o -> o.getStatus() == 5).count());
        statusDistribution.put("cancelled", (int) allTodayOrders.stream().filter(o -> o.getStatus() == 6).count());
        
        dto.setOrderStatusDistribution(statusDistribution);
        
        return dto;
    }

    @Override
    public List<Map<String, Object>> getRevenueTrend(Long merchantId, String period) {
        List<Map<String, Object>> result = new ArrayList<>();
        
        int days = "month".equals(period) ? 30 : 7;
        LocalDate today = LocalDate.now();
        
        for (int i = days - 1; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            LocalDateTime startTime = LocalDateTime.of(date, LocalTime.MIN);
            LocalDateTime endTime = LocalDateTime.of(date, LocalTime.MAX);
            
            LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Orders::getMerchantId, merchantId)
                    .ge(Orders::getOrderTime, startTime)
                    .le(Orders::getOrderTime, endTime)
                    .in(Orders::getStatus, Arrays.asList(2, 3, 4, 5));
            
            List<Orders> dayOrders = orderMapper.selectList(wrapper);
            BigDecimal dayRevenue = dayOrders.stream()
                    .map(Orders::getAmount)
                    .filter(Objects::nonNull)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            Map<String, Object> dataPoint = new HashMap<>();
            if ("month".equals(period)) {
                dataPoint.put("date", date.format(DateTimeFormatter.ofPattern("MM/dd")));
            } else {
                dataPoint.put("date", date.format(DateTimeFormatter.ofPattern("EEE", Locale.ENGLISH)));
            }
            dataPoint.put("revenue", dayRevenue.divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP)); // 分转元
            dataPoint.put("orders", dayOrders.size());
            
            result.add(dataPoint);
        }
        
        return result;
    }

    @Override
    public List<Map<String, Object>> getTopDishes(Long merchantId, Integer limit) {
        // 获取最近30天的订单详情
        LocalDateTime startTime = LocalDateTime.now().minusDays(30);
        
        LambdaQueryWrapper<Orders> orderWrapper = new LambdaQueryWrapper<>();
        orderWrapper.eq(Orders::getMerchantId, merchantId)
                .ge(Orders::getOrderTime, startTime)
                .in(Orders::getStatus, Arrays.asList(2, 3, 4, 5))
                .select(Orders::getId);
        
        List<Orders> orders = orderMapper.selectList(orderWrapper);
        
        if (orders.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<Long> orderIds = orders.stream().map(Orders::getId).collect(Collectors.toList());
        
        // 查询订单详情
        LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
        detailWrapper.in(OrderDetail::getOrderId, orderIds);
        List<OrderDetail> details = orderDetailMapper.selectList(detailWrapper);
        
        // 按菜品统计销量
        Map<String, Map<String, Object>> dishStats = new HashMap<>();
        for (OrderDetail detail : details) {
            String dishName = detail.getName();
            if (!dishStats.containsKey(dishName)) {
                Map<String, Object> stats = new HashMap<>();
                stats.put("name", dishName);
                stats.put("count", 0);
                stats.put("image", detail.getImage());
                dishStats.put(dishName, stats);
            }
            Map<String, Object> stats = dishStats.get(dishName);
            stats.put("count", (Integer) stats.get("count") + detail.getNumber());
        }
        
        // 排序并取前N
        List<Map<String, Object>> result = dishStats.values().stream()
                .sorted((a, b) -> ((Integer) b.get("count")).compareTo((Integer) a.get("count")))
                .limit(limit)
                .collect(Collectors.toList());
        
        return result;
    }
}

