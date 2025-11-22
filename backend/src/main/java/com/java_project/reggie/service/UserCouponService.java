package com.java_project.reggie.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.java_project.reggie.entity.UserCoupon;

public interface UserCouponService extends IService<UserCoupon> {
    /**
     * 领取优惠券
     */
    boolean receiveCoupon(Long userId, Long couponId);
    
    /**
     * 兑换优惠券（使用积分）
     */
    boolean exchangeCoupon(Long userId, Long couponId);
}

