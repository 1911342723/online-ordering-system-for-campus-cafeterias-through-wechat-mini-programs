package com.java_project.reggie.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.R;
import com.java_project.reggie.dto.DishDto;
import com.java_project.reggie.entity.*;
import com.java_project.reggie.service.CategoryService;
import com.java_project.reggie.service.DishFlavorService;
import com.java_project.reggie.service.DishService;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RequestMapping("/dish")
@Slf4j
@RestController
public class DishFlavorController {
    @Autowired
    private DishFlavorService dishFlavorService;

    @Autowired
    private DishService dishService;

    @Autowired
    private CategoryService categoryService;
    
    @Autowired
    private com.java_project.reggie.common.AuthHelper authHelper;

    /*分页查询 - 支持商家数据隔离*/
    @GetMapping("/page")
    public R<Page> page(int page, Integer pagesize, String name){
        log.info("page:{} , pagesize:{}", page, pagesize);
        if (pagesize == null) {
            pagesize = 10; // 提供默认值
        }
        // 构建分页构造器，基于Mybatis-plus的插件
        Page<Dish> pageInfo = new Page<>(page, pagesize);
        Page<DishDto> dishDtoPage = new Page<>();
        // 构造条件构造器
        LambdaQueryWrapper<Dish> queryWrapper = new LambdaQueryWrapper<>();

        // 商家数据隔离：商家只能看到自己的菜品
        if (authHelper.isMerchant()) {
            Long merchantId = authHelper.getCurrentMerchantId();
            if (merchantId != null) {
                queryWrapper.eq(Dish::getMerchantId, merchantId);
                log.info("商家{}查询菜品", merchantId);
            } else {
                log.warn("商家角色但未找到关联的商家ID");
                return R.success(new Page()); // 返回空页面
            }
        }
        // 管理员可以看到所有菜品，不添加额外条件
        
        // 添加过滤条件
        queryWrapper.like(name != null, Dish::getName, name);

        // 添加排序条件
        queryWrapper.orderByDesc(Dish::getUpdateTime);

        // 执行分页查询

        dishService.page(pageInfo, queryWrapper);

        BeanUtils.copyProperties(pageInfo, dishDtoPage, "records");

        List<Dish> records = pageInfo.getRecords();

        List<DishDto> list = records.stream().map((item) -> {
            DishDto dishDto = new DishDto();

            BeanUtils.copyProperties(item, dishDto);

            Long categoryId = item.getCategoryId();
            if (categoryId != null) {
                if (categoryService == null) {
                    throw new NullPointerException("CategoryService is null");
                }
                Category category = categoryService.getById(categoryId);
                if (category != null) {
                    String categoryName = category.getName();
                    if (categoryName != null) {
                        dishDto.setCategoryName(categoryName);
                    } else {
                        log.warn("Category name is null for categoryId: {}", categoryId);
                    }
                } else {
                    log.warn("Category is null for categoryId: {}", categoryId);
                }
            } else {
                log.warn("CategoryId is null for dish: {}", item.getId());
            }

            return dishDto;
        }).collect(Collectors.toList());

        dishDtoPage.setRecords(list);

        return R.success(dishDtoPage);
    }


    //处理新增菜品上传的JSON数据 - 自动关联当前商家
    @PostMapping
    public R<String> upload(@RequestBody DishDto dishDto){
        //操作数据库，保存数据
        /*因为这里要同时操作两张表，Dish和DishFlavor
        * 所以这里要拓展一下*/
        
        // 商家角色自动设置merchantId
        if (authHelper.isMerchant()) {
            Long merchantId = authHelper.getCurrentMerchantId();
            if (merchantId != null) {
                dishDto.setMerchantId(merchantId);
                log.info("商家{}新增菜品", merchantId);
            } else {
                return R.error("未找到关联的商家信息");
            }
        } else if (dishDto.getMerchantId() == null) {
            // 管理员必须指定merchantId
            return R.error("请指定商家ID");
        }
        
        dishService.saveWithFlavor(dishDto);

        return R.success("新增菜品成功！");
    }

    @GetMapping("/{id}")
    public R<DishDto> change (@PathVariable Long id){
        DishDto dishDto = dishService.getByIdWithFlavor(id);
        return R.success(dishDto);
    }

    @PutMapping
    public  R<DishDto> update(@RequestBody DishDto dishDto){
        // 权限检查：商家只能更新自己的菜品
        if (authHelper.isMerchant()) {
            Dish existingDish = dishService.getById(dishDto.getId());
            if (existingDish != null && !authHelper.canAccessMerchant(existingDish.getMerchantId())) {
                return R.error("无权修改此菜品");
            }
        }
        
        dishService.updateWithFlavor(dishDto);
        // Redis缓存已禁用
        // String key = "dish_"+dishDto.getCategoryId()+"_1";
        // redisTemplate.delete(key);

        return R.success(dishDto);
    }

    public DishFlavorService getDishFlavorService() {
        return dishFlavorService;
    }
    /*
    * 添加菜品，返回一个List集合
    * */
    @GetMapping("list")
    public R<List<DishDto>> list(Dish dish ){
        List<DishDto> dishDtoList = null;
        
        try {
            // Redis缓存已禁用，直接查询数据库
            log.info("从数据库查询菜品列表，canteenId：{}，categoryId：{}，status：{}", 
                dish.getCanteenId(), dish.getCategoryId(), dish.getStatus());

            //没有数据就是没缓存，查询数据库
            //构造查询条件
            LambdaQueryWrapper<Dish> queryWrapper = new LambdaQueryWrapper<>();
            //添加查询条件 - 支持根据canteenId查询
            queryWrapper.eq(dish.getCanteenId()!=null,Dish::getCanteenId,dish.getCanteenId());
            // 支持按商家查询（小程序菜单会传merchantId）
            queryWrapper.eq(dish.getMerchantId()!=null,Dish::getMerchantId,dish.getMerchantId());
            queryWrapper.eq(dish.getCategoryId()!=null,Dish::getCategoryId,dish.getCategoryId());
            //查询状态是1的，为在售状态的
            queryWrapper.eq(Dish::getStatus,1);

            // 商家登录态下强制只查当前商家，避免越权或参数错误
            if (authHelper.isMerchant()) {
                Long currentMerchantId = authHelper.getCurrentMerchantId();
                if (currentMerchantId != null) {
                    queryWrapper.eq(Dish::getMerchantId, currentMerchantId);
                } else {
                    log.warn("商家角色但未找到关联商家ID，返回空菜品列表");
                    return R.success(new ArrayList<>());
                }
            }

            //添加排序条件
            queryWrapper.orderByAsc(Dish::getSort).orderByDesc(Dish::getUpdateTime);
            //开始查询
            List<Dish> list = dishService.list(queryWrapper);

            //bean拷贝，通过流的形式
            dishDtoList = list.stream().map((item) -> {
                DishDto dishDto = new DishDto();

                BeanUtils.copyProperties(item, dishDto);

                Long categoryId = item.getCategoryId();
                if (categoryId != null) {
                    if (categoryService == null) {
                        throw new NullPointerException("CategoryService is null");
                    }
                    Category category = categoryService.getById(categoryId);
                    if (category != null) {
                        String categoryName = category.getName();
                        if (categoryName != null) {
                            dishDto.setCategoryName(categoryName);
                        } else {
                            log.warn("Category name is null for categoryId: {}", categoryId);
                        }
                    } else {
                        log.warn("Category is null for categoryId: {}", categoryId);
                    }
                } else {
                    log.warn("CategoryId is null for dish: {}", item.getId());
                }
                //当前菜品的id
                Long id = item.getId();
                LambdaQueryWrapper<DishFlavor> queryWrapper1 = new LambdaQueryWrapper<>();
                queryWrapper1.eq(DishFlavor::getDishId,id);
                List<DishFlavor> dishFlavors = dishFlavorService.list(queryWrapper1);
                dishDto.setFlavors(dishFlavors);
                return dishDto;
            }).collect(Collectors.toList());

            log.info("查询到{}道菜品, merchantId={}, categoryId={}, canteenId={}",
                dishDtoList.size(), dish.getMerchantId(), dish.getCategoryId(), dish.getCanteenId());
            return R.success(dishDtoList);
        } catch (Exception e) {
            log.error("查询菜品列表异常: {}", e.getMessage(), e);
            return R.success(new ArrayList<>());
        }
    }

    /*
     * 菜品状态更改
     * */
    @PostMapping("/status/{status}")
    public R<String> DishStatusChange(@PathVariable int status,@RequestParam List<Long> ids){
        //获取用户id
//        Long EmpId = (Long) request.getSession().getAttribute("employee");
//        //设置更新信息
//        employee.setUpdateUser(EmpId);
//        employee.setUpdateTime(LocalDateTime.now());
        // 更新数据库
        LambdaQueryWrapper<Dish> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.in(Dish::getId,ids); // 根据传入的ids筛选出需要更新的Setmeal

        // 假设你有一个setmealService来操作数据库
        List<Dish> DishToUpdate = dishService.list(queryWrapper);

        for (Dish dish : DishToUpdate) {
            dish.setStatus(status); // 设置新的状态码
        }
        dishService.updateBatchById(DishToUpdate);
        return R.success("更新成功！");
    }


    /*
    * 菜品的删除
    * */
    @DeleteMapping
    public R<String> deleteDish(@RequestParam List<Long> ids){
        dishService.deleteDish(ids);
        return R.success("删除成功！");
    }

}
