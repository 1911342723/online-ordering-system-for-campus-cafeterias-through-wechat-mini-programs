package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.dto.UserCouponDto;
import com.java_project.reggie.entity.Coupon;
import com.java_project.reggie.entity.UserCoupon;
import com.java_project.reggie.service.CouponService;
import com.java_project.reggie.service.UserCouponService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 优惠券控制器
 */
@Slf4j
@RestController
@RequestMapping("/coupon")
public class CouponController {

    @Autowired
    private CouponService couponService;
    
    @Autowired
    private UserCouponService userCouponService;

    /**
     * 查询可领取的优惠券列表
     */
    @GetMapping("/available")
    public R<List<Coupon>> available() {
        LambdaQueryWrapper<Coupon> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Coupon::getStatus, 1);
        queryWrapper.gt(Coupon::getRemainCount, 0);
        queryWrapper.orderByDesc(Coupon::getCreateTime);
        
        List<Coupon> list = couponService.list(queryWrapper);
        
        return R.success(list);
    }

    /**
     * 领取优惠券
     */
    @PostMapping("/receive/{id}")
    public R<String> receive(@PathVariable Long id) {
        Long userId = BaseContext.getThreadLocal();
        
        userCouponService.receiveCoupon(userId, id);
        
        return R.success("领取成功");
    }
    
    /**
     * 兑换优惠券（使用积分）
     */
    @PostMapping("/exchange/{id}")
    public R<String> exchange(@PathVariable Long id) {
        Long userId = BaseContext.getThreadLocal();
        
        userCouponService.exchangeCoupon(userId, id);
        
        return R.success("兑换成功");
    }

    /**
     * 查询我的优惠券
     */
    @GetMapping("/my")
    public R<List<UserCouponDto>> my(Integer status) {
        Long userId = BaseContext.getThreadLocal();
        
        LambdaQueryWrapper<UserCoupon> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(UserCoupon::getUserId, userId);
        
        if (status != null) {
            queryWrapper.eq(UserCoupon::getStatus, status);
        }
        
        queryWrapper.orderByDesc(UserCoupon::getCreateTime);
        
        List<UserCoupon> userCoupons = userCouponService.list(queryWrapper);
        
        // 转换为DTO，包含优惠券详情
        List<UserCouponDto> dtoList = userCoupons.stream().map(userCoupon -> {
            UserCouponDto dto = new UserCouponDto();
            BeanUtils.copyProperties(userCoupon, dto);
            
            Coupon coupon = couponService.getById(userCoupon.getCouponId());
            if (coupon != null) {
                dto.setCouponName(coupon.getName());
                dto.setAmount(coupon.getAmount());
                dto.setMinAmount(coupon.getMinAmount());
                dto.setDescription(coupon.getDescription());
            }
            
            // 检查是否过期
            if (dto.getStatus() == 0 && dto.getExpireTime().isBefore(LocalDateTime.now())) {
                dto.setStatus(2); // 已过期
                userCoupon.setStatus(2);
                userCouponService.updateById(userCoupon);
            }
            
            return dto;
        }).collect(Collectors.toList());
        
        return R.success(dtoList);
    }
}

