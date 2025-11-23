package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.*;
import com.java_project.reggie.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 收藏功能Controller
 */
@Slf4j
@RestController
@RequestMapping("/favorite")
public class FavoriteController {

    @Autowired
    private UserFavoriteMerchantService favoriteMerchantService;
    
    @Autowired
    private UserFavoriteDishService favoriteDishService;
    
    @Autowired
    private MerchantService merchantService;
    
    @Autowired
    private DishService dishService;

    /**
     * 收藏/取消收藏商家
     */
    @PostMapping("/merchant/{merchantId}")
    public R<String> toggleFavoriteMerchant(@PathVariable Long merchantId) {
        Long userId = BaseContext.getThreadLocal();
        
        LambdaQueryWrapper<UserFavoriteMerchant> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFavoriteMerchant::getUserId, userId)
                .eq(UserFavoriteMerchant::getMerchantId, merchantId);
        
        UserFavoriteMerchant favorite = favoriteMerchantService.getOne(wrapper);
        
        if (favorite != null) {
            // 已收藏，取消收藏
            favoriteMerchantService.removeById(favorite.getId());
            log.info("用户{}取消收藏商家{}", userId, merchantId);
            return R.success("已取消收藏");
        } else {
            // 未收藏，添加收藏
            UserFavoriteMerchant newFavorite = new UserFavoriteMerchant();
            newFavorite.setUserId(userId);
            newFavorite.setMerchantId(merchantId);
            favoriteMerchantService.save(newFavorite);
            log.info("用户{}收藏商家{}", userId, merchantId);
            return R.success("收藏成功");
        }
    }

    /**
     * 收藏/取消收藏菜品
     */
    @PostMapping("/dish/{dishId}")
    public R<String> toggleFavoriteDish(@PathVariable Long dishId) {
        Long userId = BaseContext.getThreadLocal();
        
        LambdaQueryWrapper<UserFavoriteDish> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFavoriteDish::getUserId, userId)
                .eq(UserFavoriteDish::getDishId, dishId);
        
        UserFavoriteDish favorite = favoriteDishService.getOne(wrapper);
        
        if (favorite != null) {
            // 已收藏，取消收藏
            favoriteDishService.removeById(favorite.getId());
            log.info("用户{}取消收藏菜品{}", userId, dishId);
            return R.success("已取消收藏");
        } else {
            // 未收藏，添加收藏
            UserFavoriteDish newFavorite = new UserFavoriteDish();
            newFavorite.setUserId(userId);
            newFavorite.setDishId(dishId);
            favoriteDishService.save(newFavorite);
            log.info("用户{}收藏菜品{}", userId, dishId);
            return R.success("收藏成功");
        }
    }

    /**
     * 检查是否已收藏商家
     */
    @GetMapping("/merchant/{merchantId}/check")
    public R<Boolean> checkFavoriteMerchant(@PathVariable Long merchantId) {
        Long userId = BaseContext.getThreadLocal();
        
        LambdaQueryWrapper<UserFavoriteMerchant> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFavoriteMerchant::getUserId, userId)
                .eq(UserFavoriteMerchant::getMerchantId, merchantId);
        
        int count = favoriteMerchantService.count(wrapper);
        return R.success(count > 0);
    }

    /**
     * 检查是否已收藏菜品
     */
    @GetMapping("/dish/{dishId}/check")
    public R<Boolean> checkFavoriteDish(@PathVariable Long dishId) {
        Long userId = BaseContext.getThreadLocal();
        
        LambdaQueryWrapper<UserFavoriteDish> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFavoriteDish::getUserId, userId)
                .eq(UserFavoriteDish::getDishId, dishId);
        
        int count = favoriteDishService.count(wrapper);
        return R.success(count > 0);
    }

    /**
     * 获取我的收藏商家列表
     */
    @GetMapping("/merchant/my")
    public R<List<Map<String, Object>>> getMyFavoriteMerchants() {
        Long userId = BaseContext.getThreadLocal();
        
        LambdaQueryWrapper<UserFavoriteMerchant> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFavoriteMerchant::getUserId, userId)
                .orderByDesc(UserFavoriteMerchant::getCreateTime);
        
        List<UserFavoriteMerchant> favorites = favoriteMerchantService.list(wrapper);
        
        List<Map<String, Object>> result = favorites.stream().map(fav -> {
            Merchant merchant = merchantService.getById(fav.getMerchantId());
            Map<String, Object> map = new HashMap<>();
            map.put("id", fav.getId());
            map.put("merchantId", merchant.getId());
            map.put("name", merchant.getName());
            map.put("image", merchant.getImage());
            map.put("description", merchant.getDescription());
            map.put("avgPrice", merchant.getAvgPrice());
            map.put("rating", merchant.getRating());
            map.put("salesCount", merchant.getSalesCount());
            map.put("createTime", fav.getCreateTime());
            return map;
        }).collect(Collectors.toList());
        
        return R.success(result);
    }

    /**
     * 获取我的收藏菜品列表
     */
    @GetMapping("/dish/my")
    public R<List<Map<String, Object>>> getMyFavoriteDishes() {
        Long userId = BaseContext.getThreadLocal();
        
        LambdaQueryWrapper<UserFavoriteDish> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFavoriteDish::getUserId, userId)
                .orderByDesc(UserFavoriteDish::getCreateTime);
        
        List<UserFavoriteDish> favorites = favoriteDishService.list(wrapper);
        
        List<Map<String, Object>> result = favorites.stream().map(fav -> {
            Dish dish = dishService.getById(fav.getDishId());
            Map<String, Object> map = new HashMap<>();
            map.put("id", fav.getId());
            map.put("dishId", dish.getId());
            map.put("name", dish.getName());
            map.put("image", dish.getImage());
            map.put("description", dish.getDescription());
            map.put("price", dish.getPrice());
            map.put("status", dish.getStatus());
            map.put("createTime", fav.getCreateTime());
            return map;
        }).collect(Collectors.toList());
        
        return R.success(result);
    }
}
