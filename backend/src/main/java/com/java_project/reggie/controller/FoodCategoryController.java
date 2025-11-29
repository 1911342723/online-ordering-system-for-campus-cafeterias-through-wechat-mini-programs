package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.FoodCategory;
import com.java_project.reggie.entity.Merchant;
import com.java_project.reggie.service.FoodCategoryService;
import com.java_project.reggie.service.MerchantService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 美食分类Controller（用于首页金刚区）
 */
@Slf4j
@RestController
@RequestMapping("/foodCategory")
public class FoodCategoryController {

    @Autowired
    private FoodCategoryService foodCategoryService;
    
    @Autowired
    private MerchantService merchantService;

    /**
     * 获取所有启用的美食分类（用户端首页）
     * @return 分类列表
     */
    @GetMapping("/list")
    public R<List<FoodCategory>> list() {
        log.info("获取美食分类列表");
        
        LambdaQueryWrapper<FoodCategory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(FoodCategory::getStatus, 1);
        queryWrapper.orderByAsc(FoodCategory::getSort);
        
        List<FoodCategory> list = foodCategoryService.list(queryWrapper);
        
        // 统计每个分类下的商家数量
        for (FoodCategory category : list) {
            LambdaQueryWrapper<Merchant> merchantWrapper = new LambdaQueryWrapper<>();
            merchantWrapper.eq(Merchant::getStatus, 1);
            merchantWrapper.eq(Merchant::getFoodCategoryId, category.getId());
            long count = merchantService.count(merchantWrapper);
            category.setMerchantCount((int) count);
        }
        
        return R.success(list);
    }

    /**
     * 分页查询美食分类（管理端）
     */
    @GetMapping("/page")
    public R<Page<FoodCategory>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String name) {
        
        log.info("美食分类分页查询: page={}, pageSize={}, name={}", page, pageSize, name);
        
        Page<FoodCategory> pageInfo = new Page<>(page, pageSize);
        
        LambdaQueryWrapper<FoodCategory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.like(StringUtils.hasText(name), FoodCategory::getName, name);
        queryWrapper.orderByAsc(FoodCategory::getSort);
        
        foodCategoryService.page(pageInfo, queryWrapper);
        
        return R.success(pageInfo);
    }

    /**
     * 根据ID查询分类详情
     */
    @GetMapping("/{id}")
    public R<FoodCategory> getById(@PathVariable Long id) {
        log.info("查询美食分类详情: id={}", id);
        
        FoodCategory category = foodCategoryService.getById(id);
        
        if (category != null) {
            return R.success(category);
        }
        
        return R.error("分类不存在");
    }

    /**
     * 根据code查询分类
     */
    @GetMapping("/code/{code}")
    public R<FoodCategory> getByCode(@PathVariable String code) {
        log.info("根据code查询美食分类: code={}", code);
        
        LambdaQueryWrapper<FoodCategory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(FoodCategory::getCode, code);
        
        FoodCategory category = foodCategoryService.getOne(queryWrapper);
        
        if (category != null) {
            return R.success(category);
        }
        
        return R.error("分类不存在");
    }

    /**
     * 新增美食分类
     */
    @PostMapping
    public R<String> add(@RequestBody FoodCategory category) {
        log.info("新增美食分类: {}", category);
        
        // 检查code是否重复
        LambdaQueryWrapper<FoodCategory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(FoodCategory::getCode, category.getCode());
        if (foodCategoryService.count(queryWrapper) > 0) {
            return R.error("分类标识已存在");
        }
        
        // 设置默认值
        if (category.getStatus() == null) {
            category.setStatus(1);
        }
        if (category.getSort() == null) {
            category.setSort(0);
        }
        
        boolean saved = foodCategoryService.save(category);
        
        if (saved) {
            return R.success("分类添加成功");
        }
        
        return R.error("分类添加失败");
    }

    /**
     * 更新美食分类
     */
    @PutMapping
    public R<String> update(@RequestBody FoodCategory category) {
        log.info("更新美食分类: {}", category);
        
        boolean updated = foodCategoryService.updateById(category);
        
        if (updated) {
            return R.success("分类更新成功");
        }
        
        return R.error("分类更新失败");
    }

    /**
     * 更新分类状态
     */
    @PutMapping("/status/{id}")
    public R<String> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        log.info("更新美食分类状态: id={}, status={}", id, status);
        
        FoodCategory category = new FoodCategory();
        category.setId(id);
        category.setStatus(status);
        
        boolean updated = foodCategoryService.updateById(category);
        
        if (updated) {
            return R.success(status == 1 ? "分类已启用" : "分类已禁用");
        }
        
        return R.error("状态更新失败");
    }

    /**
     * 删除美食分类
     */
    @DeleteMapping("/{id}")
    public R<String> delete(@PathVariable Long id) {
        log.info("删除美食分类: id={}", id);
        
        // 检查是否有关联的商家
        LambdaQueryWrapper<Merchant> merchantWrapper = new LambdaQueryWrapper<>();
        merchantWrapper.eq(Merchant::getFoodCategoryId, id);
        long count = merchantService.count(merchantWrapper);
        
        if (count > 0) {
            return R.error("该分类下有" + count + "个商家，无法删除");
        }
        
        boolean deleted = foodCategoryService.removeById(id);
        
        if (deleted) {
            return R.success("分类删除成功");
        }
        
        return R.error("分类删除失败");
    }
}

