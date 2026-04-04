package com.java_project.reggie.controller;

import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.CustomException;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.MerchantSettings;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.MerchantSettingsService;
import com.java_project.reggie.service.OrderService;
import com.java_project.reggie.service.UserService;
import com.java_project.reggie.websocket.OrderWebSocketHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 支付控制器
 */
@Slf4j
@RestController
@RequestMapping("/payment")
public class PaymentController {

    private static final BigDecimal CENTS_DIVISOR = new BigDecimal("100");

    @Autowired
    private UserService userService;
    
    @Autowired
    private OrderService orderService;
    
    @Autowired
    private MerchantSettingsService merchantSettingsService;

    /**
     * 统一支付接口
     * payMethod: 1-微信支付 2-支付宝 3-余额支付
     */
    @PostMapping("/pay")
    @Transactional
    public R<Map<String, Object>> pay(@RequestBody Map<String, Object> params) {
        Long orderId = Long.valueOf(params.get("orderId").toString());
        Integer payMethod = Integer.valueOf(params.getOrDefault("payMethod", 3).toString());
        Long userId = BaseContext.getThreadLocal();
        
        log.info("用户{}支付订单{}，支付方式：{}", userId, orderId, payMethod);
        
        // 查询订单
        Orders order = orderService.getById(orderId);
        if (order == null) {
            return R.error("订单不存在");
        }
        
        // 验证订单所属用户
        if (!order.getUserId().equals(userId)) {
            return R.error("无权操作此订单");
        }
        
        // 验证订单状态
        if (order.getStatus() != 1) {
            if (order.getStatus() >= 2) {
                // 已经付款，幂等处理
                Map<String, Object> result = new HashMap<>();
                result.put("orderId", orderId);
                result.put("status", order.getStatus());
                result.put("message", "订单已付款，无需重复支付");
                return R.success(result);
            }
            return R.error("订单状态异常");
        }
        
        // 根据支付方式处理
        if (payMethod == 3) {
            // 余额支付
            User user = userService.getById(userId);
            if (user == null) {
                return R.error("用户不存在");
            }
            
            BigDecimal balance = user.getBalance();
            // 订单金额在系统中按"分"保存，余额按"元"保存，这里统一转为元比较
            BigDecimal orderAmount = normalizeOrderAmountToYuan(order.getAmount());
            
            // 验证余额是否充足
            if (balance.compareTo(orderAmount) < 0) {
                return R.error("余额不足");
            }
            
            // 扣除余额
            BigDecimal newBalance = balance.subtract(orderAmount);
            user.setBalance(newBalance);
            userService.updateById(user);
            
            log.info("余额支付成功，用户{}余额从{}扣除{}元，剩余{}", userId, balance, orderAmount, newBalance);
        } else {
            // 微信/支付宝模拟支付
            log.info("模拟支付成功，支付方式：{}", payMethod == 1 ? "微信" : "支付宝");
        }
        
        // 更新订单支付信息
        order.setPayMethod(payMethod);
        order.setCheckoutTime(LocalDateTime.now());
        
        // 检查商家是否开启自动接单
        Integer newStatus = 2; // 默认：待接单
        if (order.getMerchantId() != null) {
            MerchantSettings settings = merchantSettingsService.getByMerchantId(order.getMerchantId());
            if (settings != null && settings.getAutoAcceptOrder() == 1) {
                newStatus = 3; // 自动接单：直接进入制作中
                log.info("商家{}开启了自动接单，订单{}直接进入制作中", order.getMerchantId(), orderId);
            }
        }
        
        order.setStatus(newStatus);
        orderService.updateById(order);
        
        // 如果是待接单状态，发送WebSocket通知给商家
        if (newStatus == 2 && order.getMerchantId() != null) {
            try {
                Map<String, Object> notificationData = new HashMap<>();
                notificationData.put("orderId", orderId);
                notificationData.put("orderNumber", order.getNumber());
                notificationData.put("amount", order.getAmount());
                notificationData.put("userName", order.getConsignee());
                notificationData.put("orderType", order.getOrderType());
                notificationData.put("scheduledTime", order.getScheduledTime());
                
                OrderWebSocketHandler.sendNewOrderNotification(order.getMerchantId(), notificationData);
                log.info("已向商家{}发送新订单WebSocket通知", order.getMerchantId());
            } catch (Exception e) {
                log.error("发送WebSocket通知失败", e);
            }
        }
        
        log.info("订单{}支付成功，状态更新为：{}", orderId, newStatus == 2 ? "待接单" : "制作中");
        
        Map<String, Object> result = new HashMap<>();
        result.put("orderId", orderId);
        result.put("status", newStatus);
        result.put("message", "支付成功");
        
        return R.success(result);
    }
    
    /**
     * 使用钱包余额支付
     */
    @PostMapping("/balance")
    @Transactional
    public R<Map<String, Object>> payByBalance(@RequestBody Map<String, Object> params) {
        Long orderId = Long.valueOf(params.get("orderId").toString());
        Long userId = BaseContext.getThreadLocal();
        
        log.info("用户{}使用余额支付订单{}", userId, orderId);
        
        // 查询订单
        Orders order = orderService.getById(orderId);
        if (order == null) {
            throw new CustomException("订单不存在");
        }
        
        // 验证订单所属用户
        if (!order.getUserId().equals(userId)) {
            throw new CustomException("无权操作此订单");
        }

        // 查询用户余额
        User user = userService.getById(userId);
        if (user == null) {
            throw new CustomException("用户不存在");
        }
        
        // 验证订单状态
        if (order.getStatus() != 1) {
            if (order.getStatus() >= 2) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "订单已付款，无需重复支付");
                result.put("balance", user.getBalance());
                result.put("orderId", orderId);
                return R.success(result);
            }
            throw new CustomException("订单状态异常，无法支付");
        }
        
        BigDecimal balance = user.getBalance();
        // 订单金额在系统中按"分"保存，余额按"元"保存，这里统一转为元比较
        BigDecimal orderAmount = normalizeOrderAmountToYuan(order.getAmount());
        
        // 验证余额是否充足
        if (balance.compareTo(orderAmount) < 0) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "余额不足");
            result.put("balance", balance);
            result.put("need", orderAmount);
            return R.success(result);
        }
        
        // 扣除余额
        BigDecimal newBalance = balance.subtract(orderAmount);
        user.setBalance(newBalance);
        userService.updateById(user);
        
        // 更新订单状态为待派送
        order.setStatus(2);
        orderService.updateById(order);
        
        log.info("支付成功，用户{}余额从{}扣除{}，剩余{}", userId, balance, orderAmount, newBalance);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "支付成功");
        result.put("balance", newBalance);
        result.put("orderId", orderId);
        
        return R.success(result);
    }

    /**
     * 模拟第三方支付（微信/支付宝）
     */
    @PostMapping("/mock")
    @Transactional
    public R<Map<String, Object>> mockPay(@RequestBody Map<String, Object> params) {
        Long orderId = Long.valueOf(params.get("orderId").toString());
        String payType = params.get("payType").toString(); // wechat 或 alipay
        Long userId = BaseContext.getThreadLocal();
        
        log.info("用户{}使用{}模拟支付订单{}", userId, payType, orderId);
        
        // 查询订单
        Orders order = orderService.getById(orderId);
        if (order == null) {
            throw new CustomException("订单不存在");
        }
        
        // 验证订单所属用户
        if (!order.getUserId().equals(userId)) {
            throw new CustomException("无权操作此订单");
        }
        
        // 验证订单状态
        if (order.getStatus() != 1) {
            if (order.getStatus() >= 2) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "订单已付款，无需重复支付");
                result.put("orderId", orderId);
                result.put("payType", payType);
                return R.success(result);
            }
            throw new CustomException("订单状态异常，无法支付");
        }
        
        // 模拟支付成功，更新订单状态为待派送
        order.setStatus(2);
        orderService.updateById(order);
        
        log.info("模拟支付成功，订单{}状态更新为待派送", orderId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "支付成功");
        result.put("orderId", orderId);
        result.put("payType", payType);
        
        return R.success(result);
    }

    /**
     * 余额充值
     */
    @PostMapping("/recharge")
    @Transactional
    public R<Map<String, Object>> recharge(@RequestBody Map<String, Object> params) {
        BigDecimal amount = new BigDecimal(params.get("amount").toString());
        String payType = params.get("payType").toString(); // wechat 或 alipay
        Long userId = BaseContext.getThreadLocal();
        
        log.info("用户{}充值{}元，支付方式：{}", userId, amount, payType);
        
        // 验证充值金额
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new CustomException("充值金额必须大于0");
        }
        
        if (amount.compareTo(new BigDecimal("10000")) > 0) {
            throw new CustomException("单次充值金额不能超过10000元");
        }
        
        // 查询用户
        User user = userService.getById(userId);
        if (user == null) {
            throw new CustomException("用户不存在");
        }
        
        // 模拟支付成功，增加余额
        BigDecimal oldBalance = user.getBalance();
        BigDecimal newBalance = oldBalance.add(amount);
        user.setBalance(newBalance);
        userService.updateById(user);
        
        log.info("充值成功，用户{}余额从{}增加{}，变为{}", userId, oldBalance, amount, newBalance);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "充值成功");
        result.put("amount", amount);
        result.put("balance", newBalance);
        result.put("payType", payType);
        
        return R.success(result);
    }

    /**
     * 查询用户余额
     */
    @GetMapping("/balance")
    public R<Map<String, Object>> getBalance() {
        Long userId = BaseContext.getThreadLocal();
        User user = userService.getById(userId);
        
        if (user == null) {
            throw new CustomException("用户不存在");
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("balance", user.getBalance());
        result.put("userId", userId);
        
        return R.success(result);
    }

    /**
     * 订单金额统一换算为元。
     * 当前系统订单金额以分为单位（前端展示统一/100），余额以元为单位存储。
     */
    private BigDecimal normalizeOrderAmountToYuan(BigDecimal amountInCents) {
        if (amountInCents == null) {
            return BigDecimal.ZERO;
        }
        return amountInCents.divide(CENTS_DIVISOR, 2, java.math.RoundingMode.HALF_UP);
    }
}

