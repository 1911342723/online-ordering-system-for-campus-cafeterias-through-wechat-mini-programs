package com.java_project.reggie.controller;

import com.java_project.reggie.common.AuthHelper;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.service.CanteenService;
import com.java_project.reggie.service.ETAService;
import com.java_project.reggie.service.EmployeeService;
import com.java_project.reggie.service.MerchantService;
import com.java_project.reggie.service.OrderDtailService;
import com.java_project.reggie.service.OrderService;
import com.java_project.reggie.service.RecommendationService;
import com.java_project.reggie.service.UserService;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OrderStatusFlowTest {

    @InjectMocks
    private OrderController orderController;

    @Mock
    private OrderService orderService;
    @Mock
    private OrderDtailService orderDtailService;
    @Mock
    private ETAService etaService;
    @Mock
    private RecommendationService recommendationService;
    @Mock
    private AuthHelper authHelper;
    @Mock
    private EmployeeService employeeService;
    @Mock
    private UserService userService;
    @Mock
    private MerchantService merchantService;
    @Mock
    private CanteenService canteenService;

    @Test
    void acceptOrderShouldKeepStatusAsCooking() {
        Orders existingOrder = new Orders();
        existingOrder.setId(1001L);
        existingOrder.setUserId(2001L);
        existingOrder.setMerchantId(3001L);
        existingOrder.setStatus(2);

        when(orderService.getById(1001L)).thenReturn(existingOrder);
        when(authHelper.isMerchant()).thenReturn(false);
        when(authHelper.isAdmin()).thenReturn(true);
        when(orderService.updateOrderStatus(1001L, 3)).thenReturn(true);
        when(orderDtailService.list(any())).thenReturn(Collections.emptyList());

        Map<String, Object> request = new HashMap<String, Object>();
        request.put("id", "1001");
        request.put("status", 3);

        R<String> result = orderController.updateOrderStatus(request);

        Assertions.assertEquals(Integer.valueOf(1), result.getCode());

        ArgumentCaptor<Orders> captor = ArgumentCaptor.forClass(Orders.class);
        verify(orderService).updateById(captor.capture());
        Assertions.assertEquals(Integer.valueOf(3), captor.getValue().getStatus(), "记录完成时间时不能把状态回写成旧值");
    }

    @Test
    void shouldRejectIllegalTransitionFromPendingToCompleted() {
        Orders existingOrder = new Orders();
        existingOrder.setId(1002L);
        existingOrder.setUserId(2002L);
        existingOrder.setStatus(2);

        when(orderService.getById(1002L)).thenReturn(existingOrder);
        when(authHelper.isMerchant()).thenReturn(false);
        when(authHelper.isAdmin()).thenReturn(true);

        Map<String, Object> request = new HashMap<String, Object>();
        request.put("id", 1002L);
        request.put("status", 5);

        R<String> result = orderController.updateOrderStatus(request);

        Assertions.assertEquals(Integer.valueOf(0), result.getCode());
        Assertions.assertTrue(result.getMsg().contains("流转非法"));
        verify(orderService, never()).updateOrderStatus(any(Long.class), any(Integer.class));
    }

    @Test
    void shouldAllowTransitionToReadyAndCompleted() {
        Orders cookingOrder = new Orders();
        cookingOrder.setId(1003L);
        cookingOrder.setUserId(2003L);
        cookingOrder.setStatus(3);

        when(orderService.getById(1003L)).thenReturn(cookingOrder);
        when(authHelper.isMerchant()).thenReturn(false);
        when(authHelper.isAdmin()).thenReturn(true);
        when(orderService.updateOrderStatus(1003L, 4)).thenReturn(true);

        Map<String, Object> toReady = new HashMap<String, Object>();
        toReady.put("id", 1003L);
        toReady.put("status", 4);

        R<String> readyResult = orderController.updateOrderStatus(toReady);
        Assertions.assertEquals(Integer.valueOf(1), readyResult.getCode());

        Orders readyOrder = new Orders();
        readyOrder.setId(1004L);
        readyOrder.setUserId(2004L);
        readyOrder.setStatus(4);

        when(orderService.getById(1004L)).thenReturn(readyOrder);
        when(orderService.updateOrderStatus(1004L, 5)).thenReturn(true);

        Map<String, Object> toCompleted = new HashMap<String, Object>();
        toCompleted.put("id", 1004L);
        toCompleted.put("status", 5);

        R<String> completedResult = orderController.updateOrderStatus(toCompleted);
        Assertions.assertEquals(Integer.valueOf(1), completedResult.getCode());

        verify(recommendationService).updateUserPreferenceByOrder(2004L);
    }
}
