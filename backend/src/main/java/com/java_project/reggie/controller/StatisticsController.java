package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.common.AuthHelper;
import com.java_project.reggie.common.R;
import com.java_project.reggie.dto.MerchantStatisticsDto;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.entity.Dish;
import com.java_project.reggie.entity.OrderDetail;
import com.java_project.reggie.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

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

    @Autowired
    private OrderService orderService;

    @Autowired
    private UserService userService;

    @Autowired
    private DishService dishService;

    @Autowired(required = false)
    private OrderDetailService orderDetailService;

    // ========================================
    // 商家端统计接口（原有）
    // ========================================

    /**
     * 获取商家数据概览
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

    // ========================================
    // 管理端平台统计接口（新增）
    // ========================================

    /**
     * 平台概览数据
     */
    @GetMapping("/overview")
    public R<Map<String, Object>> getPlatformOverview(
            @RequestParam(required = false) String period) {

        log.info("获取平台概览数据，时间段：{}", period);

        Map<String, Object> overview = new HashMap<>();

        // 总用户数
        int totalUsers = userService.count();
        overview.put("totalUsers", totalUsers);

        // 今日新增用户
        LambdaQueryWrapper<User> todayUserQuery = new LambdaQueryWrapper<>();
        todayUserQuery.ge(User::getCreateTime, LocalDate.now().atStartOfDay());
        int todayNewUsers = userService.count(todayUserQuery);
        overview.put("todayNewUsers", todayNewUsers);

        // 总订单数
        int totalOrders = orderService.count();
        overview.put("totalOrders", totalOrders);

        // 今日订单数
        LambdaQueryWrapper<Orders> todayOrderQuery = new LambdaQueryWrapper<>();
        todayOrderQuery.ge(Orders::getOrderTime, LocalDate.now().atStartOfDay());
        int todayOrders = orderService.count(todayOrderQuery);
        overview.put("todayOrders", todayOrders);

        // 总营收（已完成订单）
        LambdaQueryWrapper<Orders> completedQuery = new LambdaQueryWrapper<>();
        completedQuery.eq(Orders::getStatus, 4);
        List<Orders> completedOrders = orderService.list(completedQuery);
        BigDecimal totalRevenue = completedOrders.stream()
                .map(Orders::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        overview.put("totalRevenue", totalRevenue);

        // 今日营收
        LambdaQueryWrapper<Orders> todayCompletedQuery = new LambdaQueryWrapper<>();
        todayCompletedQuery.eq(Orders::getStatus, 4)
                .ge(Orders::getOrderTime, LocalDate.now().atStartOfDay());
        List<Orders> todayCompletedOrders = orderService.list(todayCompletedQuery);
        BigDecimal todayRevenue = todayCompletedOrders.stream()
                .map(Orders::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        overview.put("todayRevenue", todayRevenue);

        // 总菜品数
        int totalDishes = dishService.count();
        overview.put("totalDishes", totalDishes);

        return R.success(overview);
    }

    /**
     * 订单统计
     */
    @GetMapping("/order")
    public R<Map<String, Object>> getOrderStatistics(
            @RequestParam(defaultValue = "week") String period) {

        log.info("获取订单统计，时间段：{}", period);

        LocalDateTime startTime = getStartTime(period);
        Map<String, Object> stats = new HashMap<>();

        // 各状态订单数量
        for (int status = 1; status <= 5; status++) {
            LambdaQueryWrapper<Orders> query = new LambdaQueryWrapper<>();
            query.eq(Orders::getStatus, status);
            if (startTime != null) {
                query.ge(Orders::getOrderTime, startTime);
            }
            stats.put("status" + status, orderService.count(query));
        }

        // 按日期分组统计订单数量
        LambdaQueryWrapper<Orders> periodQuery = new LambdaQueryWrapper<>();
        if (startTime != null) {
            periodQuery.ge(Orders::getOrderTime, startTime);
        }
        periodQuery.orderByAsc(Orders::getOrderTime);
        List<Orders> orderList = orderService.list(periodQuery);

        Map<String, Long> dailyOrders = orderList.stream()
                .filter(o -> o.getOrderTime() != null)
                .collect(Collectors.groupingBy(
                        o -> o.getOrderTime().toLocalDate().toString(),
                        LinkedHashMap::new,
                        Collectors.counting()));

        stats.put("dailyOrders", dailyOrders);

        return R.success(stats);
    }

    /**
     * 营收统计
     */
    @GetMapping("/revenue")
    public R<Map<String, Object>> getRevenueStatistics(
            @RequestParam(defaultValue = "week") String period) {

        log.info("获取营收统计，时间段：{}", period);

        LocalDateTime startTime = getStartTime(period);
        Map<String, Object> stats = new HashMap<>();

        // 获取已完成的订单
        LambdaQueryWrapper<Orders> query = new LambdaQueryWrapper<>();
        query.eq(Orders::getStatus, 4);
        if (startTime != null) {
            query.ge(Orders::getOrderTime, startTime);
        }
        query.orderByAsc(Orders::getOrderTime);
        List<Orders> orderList = orderService.list(query);

        // 总营收
        BigDecimal totalRevenue = orderList.stream()
                .map(Orders::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        stats.put("totalRevenue", totalRevenue);
        stats.put("totalOrders", orderList.size());

        // 按日期分组统计营收
        Map<String, BigDecimal> dailyRevenue = new LinkedHashMap<>();
        for (Orders order : orderList) {
            if (order.getOrderTime() != null && order.getAmount() != null) {
                String date = order.getOrderTime().toLocalDate().toString();
                dailyRevenue.merge(date, order.getAmount(), BigDecimal::add);
            }
        }
        stats.put("dailyRevenue", dailyRevenue);

        return R.success(stats);
    }

    /**
     * 用户增长统计
     */
    @GetMapping("/user")
    public R<Map<String, Object>> getUserStatistics(
            @RequestParam(defaultValue = "week") String period) {

        log.info("获取用户统计，时间段：{}", period);

        LocalDateTime startTime = getStartTime(period);
        Map<String, Object> stats = new HashMap<>();

        // 总用户数
        stats.put("totalUsers", userService.count());

        // 时间段内新增用户
        LambdaQueryWrapper<User> query = new LambdaQueryWrapper<>();
        if (startTime != null) {
            query.ge(User::getCreateTime, startTime);
        }
        query.orderByAsc(User::getCreateTime);
        List<User> newUsers = userService.list(query);
        stats.put("newUsers", newUsers.size());

        // 按日期分组统计新注册用户数
        Map<String, Long> dailyNewUsers = newUsers.stream()
                .filter(u -> u.getCreateTime() != null)
                .collect(Collectors.groupingBy(
                        u -> u.getCreateTime().toLocalDate().toString(),
                        LinkedHashMap::new,
                        Collectors.counting()));
        stats.put("dailyNewUsers", dailyNewUsers);

        // 活跃用户数（有订单的用户）
        LambdaQueryWrapper<Orders> activeQuery = new LambdaQueryWrapper<>();
        if (startTime != null) {
            activeQuery.ge(Orders::getOrderTime, startTime);
        }
        List<Orders> recentOrders = orderService.list(activeQuery);
        long activeUsers = recentOrders.stream()
                .map(Orders::getUserId)
                .filter(Objects::nonNull)
                .distinct()
                .count();
        stats.put("activeUsers", activeUsers);

        return R.success(stats);
    }

    /**
     * 各食堂营收对比
     */
    @GetMapping("/canteen-revenue")
    public R<List<Map<String, Object>>> getCanteenRevenue(
            @RequestParam(defaultValue = "week") String period) {

        log.info("获取食堂营收对比，时间段：{}", period);

        LocalDateTime startTime = getStartTime(period);

        LambdaQueryWrapper<Orders> query = new LambdaQueryWrapper<>();
        query.eq(Orders::getStatus, 4);
        if (startTime != null) {
            query.ge(Orders::getOrderTime, startTime);
        }
        List<Orders> orderList = orderService.list(query);

        // 按食堂分组统计营收
        Map<String, BigDecimal> canteenRevenueMap = new LinkedHashMap<>();
        Map<String, Integer> canteenOrderCountMap = new LinkedHashMap<>();
        for (Orders order : orderList) {
            String canteenName = order.getCanteenName() != null ? order.getCanteenName() : "未知食堂";
            canteenRevenueMap.merge(canteenName, order.getAmount() != null ? order.getAmount() : BigDecimal.ZERO, BigDecimal::add);
            canteenOrderCountMap.merge(canteenName, 1, Integer::sum);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<String, BigDecimal> entry : canteenRevenueMap.entrySet()) {
            Map<String, Object> item = new HashMap<>();
            item.put("canteenName", entry.getKey());
            item.put("revenue", entry.getValue());
            item.put("orderCount", canteenOrderCountMap.getOrDefault(entry.getKey(), 0));
            result.add(item);
        }

        // 按营收降序排列
        result.sort((a, b) -> ((BigDecimal) b.get("revenue")).compareTo((BigDecimal) a.get("revenue")));

        return R.success(result);
    }

    /**
     * 热门菜品排行
     */
    @GetMapping("/popular-dishes")
    public R<List<Map<String, Object>>> getPopularDishes(
            @RequestParam(defaultValue = "week") String period,
            @RequestParam(defaultValue = "10") Integer limit) {

        log.info("获取热门菜品排行，时间段：{}，数量：{}", period, limit);

        LocalDateTime startTime = getStartTime(period);

        // 查询时间段内的订单详情
        if (orderDetailService != null) {
            LambdaQueryWrapper<OrderDetail> query = new LambdaQueryWrapper<>();
            List<OrderDetail> details = orderDetailService.list(query);

            // 按菜品名称分组统计数量
            Map<String, Integer> dishCountMap = new LinkedHashMap<>();
            Map<String, BigDecimal> dishAmountMap = new LinkedHashMap<>();
            Map<String, String> dishImageMap = new LinkedHashMap<>();
            for (OrderDetail detail : details) {
                String dishName = detail.getName() != null ? detail.getName() : "未知菜品";
                dishCountMap.merge(dishName, detail.getNumber() != null ? detail.getNumber() : 1, Integer::sum);
                BigDecimal itemAmount = detail.getAmount() != null ? detail.getAmount().multiply(BigDecimal.valueOf(detail.getNumber() != null ? detail.getNumber() : 1)) : BigDecimal.ZERO;
                dishAmountMap.merge(dishName, itemAmount, BigDecimal::add);
                if (detail.getImage() != null) {
                    dishImageMap.putIfAbsent(dishName, detail.getImage());
                }
            }

            List<Map<String, Object>> result = new ArrayList<>();
            for (Map.Entry<String, Integer> entry : dishCountMap.entrySet()) {
                Map<String, Object> item = new HashMap<>();
                item.put("name", entry.getKey());
                item.put("count", entry.getValue());
                item.put("amount", dishAmountMap.getOrDefault(entry.getKey(), BigDecimal.ZERO));
                item.put("image", dishImageMap.getOrDefault(entry.getKey(), ""));
                result.add(item);
            }

            // 按销量降序
            result.sort((a, b) -> ((Integer) b.get("count")).compareTo((Integer) a.get("count")));

            // 限制返回数量
            if (result.size() > limit) {
                result = result.subList(0, limit);
            }

            return R.success(result);
        }

        // 如果没有 OrderDetailService，返回空列表
        return R.success(new ArrayList<>());
    }

    /**
     * 高峰期流量分析
     */
    @GetMapping("/peak-traffic")
    public R<Map<String, Object>> getPeakTraffic(
            @RequestParam(defaultValue = "week") String period) {

        log.info("获取高峰期流量分析，时间段：{}", period);

        LocalDateTime startTime = getStartTime(period);

        LambdaQueryWrapper<Orders> query = new LambdaQueryWrapper<>();
        if (startTime != null) {
            query.ge(Orders::getOrderTime, startTime);
        }
        List<Orders> orderList = orderService.list(query);

        // 按小时分组统计
        Map<Integer, Long> hourlyOrders = orderList.stream()
                .filter(o -> o.getOrderTime() != null)
                .collect(Collectors.groupingBy(
                        o -> o.getOrderTime().getHour(),
                        TreeMap::new,
                        Collectors.counting()));

        // 按星期分组统计
        Map<Integer, Long> weekdayOrders = orderList.stream()
                .filter(o -> o.getOrderTime() != null)
                .collect(Collectors.groupingBy(
                        o -> o.getOrderTime().getDayOfWeek().getValue(),
                        TreeMap::new,
                        Collectors.counting()));

        Map<String, Object> result = new HashMap<>();
        result.put("hourlyOrders", hourlyOrders);
        result.put("weekdayOrders", weekdayOrders);
        result.put("totalOrders", orderList.size());

        // 找出高峰时段
        if (!hourlyOrders.isEmpty()) {
            int peakHour = hourlyOrders.entrySet().stream()
                    .max(Map.Entry.comparingByValue())
                    .map(Map.Entry::getKey)
                    .orElse(12);
            result.put("peakHour", peakHour);
            result.put("peakHourLabel", peakHour + ":00-" + (peakHour + 1) + ":00");
        }

        return R.success(result);
    }

    // ========================================
    // 工具方法
    // ========================================

    /**
     * 根据 period 参数计算起始时间
     */
    private LocalDateTime getStartTime(String period) {
        if (period == null) return null;
        switch (period) {
            case "today":
                return LocalDate.now().atStartOfDay();
            case "week":
                return LocalDate.now().minusWeeks(1).atStartOfDay();
            case "month":
                return LocalDate.now().minusMonths(1).atStartOfDay();
            case "year":
                return LocalDate.now().minusYears(1).atStartOfDay();
            default:
                return LocalDate.now().minusWeeks(1).atStartOfDay();
        }
    }
}
