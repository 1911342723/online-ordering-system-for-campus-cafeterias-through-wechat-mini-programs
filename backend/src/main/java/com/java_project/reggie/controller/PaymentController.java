package com.java_project.reggie.controller;

import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.CustomException;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.OrderService;
import com.java_project.reggie.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * 支付控制器
 */
@Slf4j
@RestController
@RequestMapping("/payment")
public class PaymentController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private OrderService orderService;

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
        
        // 验证订单状态
        if (order.getStatus() != 1) {
            throw new CustomException("订单状态异常，无法支付");
        }
        
        // 查询用户余额
        User user = userService.getById(userId);
        if (user == null) {
            throw new CustomException("用户不存在");
        }
        
        BigDecimal balance = user.getBalance();
        BigDecimal orderAmount = order.getAmount();
        
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
}

