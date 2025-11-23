package com.java_project.reggie.entity;

import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单
 */
@Data
public class Orders implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    //订单号
    private String number;

    //订单状态 1待付款，2待派送，3已派送，4已完成，5已取消
    private Integer status;
    
    
    //订单类型 1:立即下单 2:预订单
    private Integer orderType;
    
    
    //预约取餐时间
    private LocalDateTime scheduledTime;


    //下单用户id
    private Long userId;

    //地址id
    private Long addressBookId;


    //下单时间
    private LocalDateTime orderTime;


    //结账时间
    private LocalDateTime checkoutTime;


    //支付方式 1微信，2支付宝
    private Integer payMethod;


    //实收金额
    private BigDecimal amount;

    //备注
    private String remark;

    //用户名
    private String userName;

    //手机号
    private String phone;

    //地址
    private String address;

    //收货人
    private String consignee;

    //配送方式 1:自取 2:外送
    private Integer deliveryType = 1;

    //配送费
    private BigDecimal deliveryFee = BigDecimal.ZERO;

    //餐厅ID
    private Long canteenId;

    //餐厅名称
    private String canteenName;

    //商家ID
    private Long merchantId;

    //商家名称
    private String merchantName;

    //用户优惠券ID
    private Long userCouponId;

    //优惠券优惠金额
    private BigDecimal couponAmount = BigDecimal.ZERO;

    //退款状态 0:无退款 1:申请中 2:已退款 3:退款失败
    private Integer refundStatus = 0;

    //退款原因
    private String refundReason;

    //退款金额
    private BigDecimal refundAmount;

    //退款时间
    private LocalDateTime refundTime;

    //评价状态 0:未评价 1:已评价
    private Integer reviewStatus = 0;
}
