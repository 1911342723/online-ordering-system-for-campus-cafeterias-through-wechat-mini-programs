package com.java_project.reggie.dto;

import com.java_project.reggie.entity.UserCoupon;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 用户优惠券DTO
 */
@Data
public class UserCouponDto extends UserCoupon {
    
    private String couponName;
    
    private BigDecimal amount;
    
    private BigDecimal minAmount;
    
    private String description;
}

