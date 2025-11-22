package com.java_project.reggie.dto;

import com.java_project.reggie.entity.OrderDetail;
import com.java_project.reggie.entity.Orders;
import lombok.Data;
import java.util.List;

/**
 * 订单数据传输对象
 * 用于返回订单及其详细信息
 */
@Data
public class OrderDto extends Orders {
    
    // 订单明细列表
    private List<OrderDetail> orderDetails;
    
    // 订单菜品数量
    private Integer sumNum;
}

