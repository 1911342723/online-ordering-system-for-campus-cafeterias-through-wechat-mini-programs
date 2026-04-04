package com.java_project.reggie.controller;


import com.alibaba.fastjson.JSON;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Dish;
import com.java_project.reggie.entity.ShoppingCart;
import com.java_project.reggie.service.DishService;
import com.java_project.reggie.service.ShoppingCartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/shoppingCart")
public class shoppingCartController {
    @Autowired
    private ShoppingCartService shoppingCartService;

    @Autowired
    private DishService dishService;


    @PostMapping("/add")
    public R<ShoppingCart> add(@RequestBody ShoppingCart shoppingCart){
        //设置用户id，指定是谁的购物车数据
        Long Id = BaseContext.getThreadLocal();
        shoppingCart.setUserId(Id);

        // 前端可能未传 merchantId/canteenId，后端兜底从菜品信息补齐。
        if (shoppingCart.getDishId() != null) {
            Dish dish = dishService.getById(shoppingCart.getDishId());
            if (dish != null) {
                if (shoppingCart.getMerchantId() == null) {
                    shoppingCart.setMerchantId(dish.getMerchantId());
                }
                if (shoppingCart.getCanteenId() == null) {
                    shoppingCart.setCanteenId(dish.getCanteenId());
                }
                if (shoppingCart.getAmount() == null) {
                    shoppingCart.setAmount(dish.getPrice());
                }
                if (shoppingCart.getImage() == null || shoppingCart.getImage().trim().isEmpty()) {
                    shoppingCart.setImage(dish.getImage());
                }
                if (shoppingCart.getName() == null || shoppingCart.getName().trim().isEmpty()) {
                    shoppingCart.setName(dish.getName());
                }
            }
        }

        //查询当前是菜品还是套餐
        LambdaQueryWrapper<ShoppingCart> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ShoppingCart::getUserId,Id);

        Long dishId = shoppingCart.getDishId();
        if(dishId!=null){
            //如果在保存的就是菜品
            queryWrapper.eq(ShoppingCart::getDishId,dishId);
        }
        else {
            //否则就是套餐
            queryWrapper.eq(ShoppingCart::getSetmealId,shoppingCart.getSetmealId());
        }

        ShoppingCart one = shoppingCartService.getOne(queryWrapper);

        if(one!=null){
            //如果存在，数量加1
            Integer number = one.getNumber();
            one.setNumber(number+1);
            shoppingCartService.updateById(one);
        }
        else {
            //否则默认数量就是1
            shoppingCart.setNumber(1);
            shoppingCart.setCreateTime(LocalDateTime.now());
            shoppingCartService.save(shoppingCart);
            one = shoppingCart;
        }
        //返回购物车数据
        return R.success(one);
    }

    @GetMapping("/list")
    public R<List<ShoppingCart>> list(){
        LambdaQueryWrapper<ShoppingCart> queryWrapper =new LambdaQueryWrapper<>();
        //根据id匹配
        queryWrapper.eq(ShoppingCart::getUserId,BaseContext.getThreadLocal());

        queryWrapper.orderByAsc(ShoppingCart::getCreateTime);

        List<ShoppingCart> list = shoppingCartService.list(queryWrapper);

        return R.success(list);

    }

    @PostMapping("/sub")
    public R<ShoppingCart> sub(@RequestBody ShoppingCart shoppingCart){
        Long dishId = shoppingCart.getDishId();
        LambdaQueryWrapper<ShoppingCart> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ShoppingCart::getUserId,BaseContext.getThreadLocal());

        if(dishId!=null){
            queryWrapper.eq(ShoppingCart::getDishId,dishId);
        }else{
            queryWrapper.eq(ShoppingCart::getSetmealId,shoppingCart.getSetmealId());
        }

        ShoppingCart cartServiceOne = shoppingCartService.getOne(queryWrapper);
        
        if(cartServiceOne != null){
            Integer number = cartServiceOne.getNumber();
            if(number == 1){
                shoppingCartService.remove(queryWrapper);
            }else{
                cartServiceOne.setNumber(number-1);
                shoppingCartService.updateById(cartServiceOne);
            }
        }
        
        return R.success(cartServiceOne);
    }

    @DeleteMapping("/clean")
    public R<String> delete(){
        LambdaQueryWrapper<ShoppingCart> queryWrapper = new LambdaQueryWrapper<>();

        queryWrapper.eq(ShoppingCart::getUserId,BaseContext.getThreadLocal());

        shoppingCartService.remove(queryWrapper);

        return R.success("清空成功！");
    }
}
