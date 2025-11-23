package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.common.CustomException;
import com.java_project.reggie.entity.Coupon;
import com.java_project.reggie.entity.UserCoupon;
import com.java_project.reggie.mapper.UserCouponMapper;
import com.java_project.reggie.service.CouponService;
import com.java_project.reggie.service.UserCouponService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
public class UserCouponServiceImpl extends ServiceImpl<UserCouponMapper, UserCoupon> implements UserCouponService {

    @Autowired
    private CouponService couponService;
    
    @Autowired
    private com.java_project.reggie.service.UserService userService;

    @Override
    @Transactional
    public boolean receiveCoupon(Long userId, Long couponId) {
        Coupon coupon = couponService.getById(couponId);
        if (coupon == null) {
            throw new CustomException("优惠券不存在");
        }
        
        if (coupon.getStatus() != 1) {
            throw new CustomException("优惠券已下架");
        }
        
        if (coupon.getRemainCount() <= 0) {
            throw new CustomException("优惠券已领完");
        }
        
        // 【重要】检查用户是否已经领取过该优惠券
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<UserCoupon> queryWrapper = 
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<>();
        queryWrapper.eq(UserCoupon::getUserId, userId);
        queryWrapper.eq(UserCoupon::getCouponId, couponId);
        long count = this.count(queryWrapper);
        
        if (count > 0) {
            throw new CustomException("您已经领取过该优惠券了");
        }
        
        // 减少剩余数量
        coupon.setRemainCount(coupon.getRemainCount() - 1);
        couponService.updateById(coupon);
        
        // 创建用户优惠券
        UserCoupon userCoupon = new UserCoupon();
        userCoupon.setUserId(userId);
        userCoupon.setCouponId(couponId);
        userCoupon.setStatus(0); // 未使用
        userCoupon.setExpireTime(LocalDateTime.now().plusDays(coupon.getValidDays()));
        this.save(userCoupon);
        
        // 更新用户的优惠券数量
        com.java_project.reggie.entity.User user = userService.getById(userId);
        if (user != null) {
            int currentCount = user.getCouponCount() == null ? 0 : user.getCouponCount();
            user.setCouponCount(currentCount + 1);
            userService.updateById(user);
            log.info("用户{}的优惠券数量更新为{}", userId, user.getCouponCount());
        }
        
        log.info("用户{}领取优惠券{}", userId, couponId);
        
        return true;
    }

    @Override
    @Transactional
    public boolean exchangeCoupon(Long userId, Long couponId) {
        // 暂时禁用积分兑换功能
        throw new CustomException("积分兑换功能暂未开放");
    }
}

