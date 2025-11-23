package com.java_project.reggie.dto;

import com.java_project.reggie.entity.Coupon;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 可领取优惠券DTO（包含是否已领取信息）
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class CouponAvailableDto extends Coupon {
    
    /**
     * 当前用户是否已领取
     */
    private Boolean received;
}

