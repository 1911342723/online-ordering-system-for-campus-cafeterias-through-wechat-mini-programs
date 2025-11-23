package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.dto.CouponAvailableDto;
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
     * 查询可领取的优惠券列表（包含用户领取状态）
     * @param type 优惠券类型 1:平台券 2:商家券
     * @param merchantId 商家ID（查询商家券时必传）
     */
    @GetMapping("/available")
    public R<List<CouponAvailableDto>> available(
            @RequestParam(required = false) Integer type,
            @RequestParam(required = false) Long merchantId) {
        
        log.info("查询可领取优惠券: type={}, merchantId={}", type, merchantId);
        
        LambdaQueryWrapper<Coupon> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Coupon::getStatus, 1);
        queryWrapper.gt(Coupon::getRemainCount, 0);
        
        // 根据类型筛选
        if (type != null) {
            queryWrapper.eq(Coupon::getType, type);
            
            // 如果是商家券，需要指定商家ID
            if (type == 2 && merchantId != null) {
                queryWrapper.eq(Coupon::getMerchantId, merchantId);
            }
        } else {
            // 默认只查询平台券（用于首页）
            queryWrapper.eq(Coupon::getType, 1);
        }
        
        queryWrapper.orderByDesc(Coupon::getCreateTime);
        
        List<Coupon> list = couponService.list(queryWrapper);
        
        // 获取当前用户ID（如果已登录）
        Long userId = null;
        try {
            userId = BaseContext.getThreadLocal();
        } catch (Exception e) {
            log.warn("用户未登录");
        }
        
        // 转换为DTO，包含是否已领取信息
        final Long finalUserId = userId;
        List<CouponAvailableDto> dtoList = list.stream().map(coupon -> {
            CouponAvailableDto dto = new CouponAvailableDto();
            BeanUtils.copyProperties(coupon, dto);
            
            // 检查用户是否已领取
            if (finalUserId != null) {
                LambdaQueryWrapper<UserCoupon> userCouponQuery = new LambdaQueryWrapper<>();
                userCouponQuery.eq(UserCoupon::getUserId, finalUserId);
                userCouponQuery.eq(UserCoupon::getCouponId, coupon.getId());
                long count = userCouponService.count(userCouponQuery);
                dto.setReceived(count > 0);
            } else {
                dto.setReceived(false);
            }
            
            return dto;
        }).collect(Collectors.toList());
        
        log.info("查询到{}张可领取优惠券", dtoList.size());
        
        return R.success(dtoList);
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

