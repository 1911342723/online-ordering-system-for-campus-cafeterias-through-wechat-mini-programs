package com.java_project.reggie.controller;

import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.MerchantSettingsService;
import com.java_project.reggie.service.OrderService;
import com.java_project.reggie.service.UserService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PaymentFlowTest {

    @InjectMocks
    private PaymentController paymentController;

    @Mock
    private UserService userService;
    @Mock
    private OrderService orderService;
    @Mock
    private MerchantSettingsService merchantSettingsService;

    @AfterEach
    void clearContext() {
        BaseContext.setThreadLocal(null);
    }

    @Test
    void balancePayShouldUseYuanAgainstCentsOrderAmount() {
        BaseContext.setThreadLocal(1L);

        Orders order = new Orders();
        order.setId(9001L);
        order.setUserId(1L);
        order.setStatus(1);
        order.setAmount(new BigDecimal("15000")); // 150.00元（分）

        User user = new User();
        user.setId(1L);
        user.setBalance(new BigDecimal("200.00")); // 元

        when(orderService.getById(9001L)).thenReturn(order);
        when(userService.getById(1L)).thenReturn(user);

        Map<String, Object> req = new HashMap<String, Object>();
        req.put("orderId", "9001");
        req.put("payMethod", 3);

        R<Map<String, Object>> result = paymentController.pay(req);

        Assertions.assertEquals(Integer.valueOf(1), result.getCode());

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userService).updateById(userCaptor.capture());
        Assertions.assertEquals(new BigDecimal("50.00"), userCaptor.getValue().getBalance());
    }

    @Test
    void balancePayShouldFailWhenYuanIsReallyInsufficient() {
        BaseContext.setThreadLocal(2L);

        Orders order = new Orders();
        order.setId(9002L);
        order.setUserId(2L);
        order.setStatus(1);
        order.setAmount(new BigDecimal("20000")); // 200.00元（分）

        User user = new User();
        user.setId(2L);
        user.setBalance(new BigDecimal("100.00"));

        when(orderService.getById(9002L)).thenReturn(order);
        when(userService.getById(2L)).thenReturn(user);

        Map<String, Object> req = new HashMap<String, Object>();
        req.put("orderId", "9002");
        req.put("payMethod", 3);

        R<Map<String, Object>> result = paymentController.pay(req);

        Assertions.assertEquals(Integer.valueOf(0), result.getCode());
        Assertions.assertEquals("余额不足", result.getMsg());
    }
}
