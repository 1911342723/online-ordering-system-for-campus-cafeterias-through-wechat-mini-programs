package com.java_project.reggie.controller;

import com.java_project.reggie.common.R;
import com.java_project.reggie.service.OrderService;
import com.java_project.reggie.service.UserService;
import com.java_project.reggie.service.DishService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.lang.management.ManagementFactory;
import java.lang.management.RuntimeMXBean;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 系统管理Controller（管理后台）
 * 处理 /system/logs 和 /system/info
 * 注意: /system/config 由 SystemConfigController 处理
 */
@Slf4j
@RestController
@RequestMapping("/system")
public class SystemController {

    @Autowired
    private UserService userService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private DishService dishService;

    /**
     * 获取操作日志
     * 前端调用: GET /system/logs
     */
    @GetMapping("/logs")
    public R<Map<String, Object>> getOperationLogs(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer pageSize,
            @RequestParam(required = false) String keyword) {

        log.info("获取操作日志: page={}, pageSize={}, keyword={}", page, pageSize, keyword);

        Map<String, Object> result = new HashMap<>();

        // 构建模拟日志数据（实际项目应从数据库读取）
        List<Map<String, Object>> logs = new ArrayList<>();

        String[] actions = {"用户登录", "修改菜品", "新增订单", "审核商家", "修改配置", "导出数据"};
        String[] operators = {"admin", "system", "admin"};

        LocalDateTime now = LocalDateTime.now();
        for (int i = 0; i < Math.min(pageSize, 20); i++) {
            Map<String, Object> logItem = new HashMap<>();
            logItem.put("id", (page - 1) * pageSize + i + 1);
            logItem.put("action", actions[i % actions.length]);
            logItem.put("operator", operators[i % operators.length]);
            logItem.put("ip", "192.168.1." + (100 + i));
            logItem.put("time", now.minusHours(i).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            logItem.put("detail", actions[i % actions.length] + " 操作成功");
            logs.add(logItem);
        }

        result.put("records", logs);
        result.put("total", 100);
        result.put("current", page);
        result.put("size", pageSize);

        return R.success(result);
    }

    /**
     * 获取系统运行信息
     * 前端调用: GET /system/info
     */
    @GetMapping("/info")
    public R<Map<String, Object>> getSystemInfo() {
        log.info("获取系统运行信息");

        Map<String, Object> info = new LinkedHashMap<>();

        // JVM 信息
        Runtime runtime = Runtime.getRuntime();
        info.put("javaVersion", System.getProperty("java.version"));
        info.put("osName", System.getProperty("os.name"));
        info.put("osArch", System.getProperty("os.arch"));

        // 内存使用
        long maxMemory = runtime.maxMemory() / (1024 * 1024);
        long totalMemory = runtime.totalMemory() / (1024 * 1024);
        long freeMemory = runtime.freeMemory() / (1024 * 1024);
        long usedMemory = totalMemory - freeMemory;

        info.put("maxMemory", maxMemory + " MB");
        info.put("totalMemory", totalMemory + " MB");
        info.put("usedMemory", usedMemory + " MB");
        info.put("freeMemory", freeMemory + " MB");

        // 运行时间
        RuntimeMXBean runtimeBean = ManagementFactory.getRuntimeMXBean();
        long uptimeMs = runtimeBean.getUptime();
        Duration uptime = Duration.ofMillis(uptimeMs);
        info.put("uptime", String.format("%d天%d小时%d分钟",
                uptime.toDays(), uptime.toHours() % 24, uptime.toMinutes() % 60));

        // 数据统计
        info.put("totalUsers", userService.count());
        info.put("totalOrders", orderService.count());
        info.put("totalDishes", dishService.count());

        // 可用处理器数
        info.put("processors", runtime.availableProcessors());

        return R.success(info);
    }
}
