package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Canteen;
import com.java_project.reggie.entity.FoodCategory;
import com.java_project.reggie.entity.Merchant;
import com.java_project.reggie.service.CanteenService;
import com.java_project.reggie.service.FoodCategoryService;
import com.java_project.reggie.service.MerchantService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 商家管理Controller
 */
@Slf4j
@RestController
@RequestMapping("/merchant")
public class MerchantController {

    @Autowired
    private MerchantService merchantService;

    @Autowired
    private CanteenService canteenService;
    
    @Autowired
    private FoodCategoryService foodCategoryService;

    /**
     * 分页查询商家列表（管理端）
     * @param page 页码
     * @param pageSize 每页数量
     * @param name 商家名称
     * @param canteenId 食堂ID
     * @return 分页结果
     */
    @GetMapping("/page")
    public R<Page<Merchant>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) Long canteenId) {
        
        log.info("商家分页查询: page={}, pageSize={}, name={}, canteenId={}", page, pageSize, name, canteenId);
        
        Page<Merchant> pageInfo = new Page<>(page, pageSize);
        
        LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.like(StringUtils.hasText(name), Merchant::getName, name);
        queryWrapper.eq(canteenId != null, Merchant::getCanteenId, canteenId);
        queryWrapper.orderByAsc(Merchant::getSort).orderByDesc(Merchant::getUpdateTime);
        
        merchantService.page(pageInfo, queryWrapper);
        
        // 填充食堂名称
        pageInfo.getRecords().forEach(merchant -> {
            if (merchant.getCanteenId() != null) {
                Canteen canteen = canteenService.getById(merchant.getCanteenId());
                if (canteen != null) {
                    merchant.setCanteenName(canteen.getName());
                }
            }
        });
        
        return R.success(pageInfo);
    }

    /**
     * 获取商家列表（用户端）- 支持分页、搜索、排序、分类筛选
     * @param canteenId 食堂ID（可选）
     * @param keyword 搜索关键词（可选，搜索名称和标签）
     * @param categoryId 美食分类ID（可选）
     * @param sortBy 排序方式：default/sales/rating/distance（可选）
     * @param status 营业状态（可选）
     * @param page 页码
     * @param pageSize 每页数量
     * @return 商家列表
     */
    @GetMapping("/list")
    public R<List<Merchant>> list(
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false, defaultValue = "default") String sortBy,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "20") int pageSize) {
        
        log.info("查询商家列表: canteenId={}, keyword={}, categoryId={}, sortBy={}, status={}, page={}, pageSize={}", 
                canteenId, keyword, categoryId, sortBy, status, page, pageSize);
        
        try {
            LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
            
            // 食堂筛选
            queryWrapper.eq(canteenId != null, Merchant::getCanteenId, canteenId);
            
            // 美食分类筛选
            queryWrapper.eq(categoryId != null, Merchant::getFoodCategoryId, categoryId);
            
            // 状态筛选（默认只查营业中的）
            if (status != null) {
                queryWrapper.eq(Merchant::getStatus, status);
            } else {
                queryWrapper.eq(Merchant::getStatus, 1);
            }
            
            // 关键词搜索（名称或标签）
            if (StringUtils.hasText(keyword)) {
                queryWrapper.and(wrapper -> 
                    wrapper.like(Merchant::getName, keyword)
                           .or()
                           .like(Merchant::getTags, keyword)
                           .or()
                           .like(Merchant::getDescription, keyword)
                );
            }
            
            // 基础排序
            queryWrapper.orderByAsc(Merchant::getSort);
            
            List<Merchant> list = merchantService.list(queryWrapper);
            
            // 填充额外信息
            for (Merchant merchant : list) {
                // 填充食堂名称
                if (merchant.getCanteenId() != null) {
                    try {
                        Canteen canteen = canteenService.getById(merchant.getCanteenId());
                        if (canteen != null) {
                            merchant.setCanteenName(canteen.getName());
                        }
                    } catch (Exception e) {
                        log.warn("填充食堂名称失败: merchantId={}, canteenId={}", merchant.getId(), merchant.getCanteenId());
                    }
                }
                
                // 填充美食分类名称
                if (merchant.getFoodCategoryId() != null) {
                    try {
                        FoodCategory category = foodCategoryService.getById(merchant.getFoodCategoryId());
                        if (category != null) {
                            merchant.setFoodCategoryName(category.getName());
                        }
                    } catch (Exception e) {
                        log.warn("填充美食分类名称失败: merchantId={}, foodCategoryId={}", merchant.getId(), merchant.getFoodCategoryId());
                    }
                }
                
                // 设置默认值
                if (merchant.getDeliveryTime() == null) {
                    merchant.setDeliveryTime(15 + (int)(Math.random() * 15)); // 15-30分钟
                }
                if (merchant.getDistance() == null) {
                    merchant.setDistance(100 + (int)(Math.random() * 400)); // 100-500米
                }
                if (merchant.getTags() == null || merchant.getTags().isEmpty()) {
                    merchant.setTags("美食,好评");
                }
            }
            
            // 应用排序
            switch (sortBy) {
                case "sales":
                    list = list.stream()
                        .sorted(Comparator.comparingInt(m -> m.getSalesCount() != null ? -m.getSalesCount() : 0))
                        .collect(Collectors.toList());
                    break;
                case "rating":
                    list = list.stream()
                        .sorted(Comparator.comparing(
                            (Merchant m) -> m.getRating() != null ? m.getRating() : java.math.BigDecimal.ZERO)
                            .reversed())
                        .collect(Collectors.toList());
                    break;
                case "distance":
                    list = list.stream()
                        .sorted(Comparator.comparingInt(m -> m.getDistance() != null ? m.getDistance() : Integer.MAX_VALUE))
                        .collect(Collectors.toList());
                    break;
                default:
                    // 综合排序：已经按sort排序
                    break;
            }
            
            // 分页处理
            int start = (page - 1) * pageSize;
            int end = Math.min(start + pageSize, list.size());
            
            if (start >= list.size()) {
                return R.success(new java.util.ArrayList<>());
            }
            
            return R.success(list.subList(start, end));
        } catch (Exception e) {
            log.error("查询商家列表异常: {}", e.getMessage(), e);
            return R.success(new java.util.ArrayList<>());
        }
    }

    /**
     * 获取热门商家（首页展示）
     * @param limit 数量限制
     * @return 热门商家列表
     */
    @GetMapping("/hot")
    public R<List<Merchant>> getHotMerchants(@RequestParam(defaultValue = "6") int limit) {
        log.info("获取热门商家: limit={}", limit);
        
        LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Merchant::getStatus, 1);
        queryWrapper.orderByDesc(Merchant::getSalesCount);
        queryWrapper.last("LIMIT " + limit);
        
        List<Merchant> list = merchantService.list(queryWrapper);
        
        // 填充额外信息
        for (Merchant merchant : list) {
            if (merchant.getCanteenId() != null) {
                Canteen canteen = canteenService.getById(merchant.getCanteenId());
                if (canteen != null) {
                    merchant.setCanteenName(canteen.getName());
                }
            }
            
            // 设置默认值
            if (merchant.getDeliveryTime() == null) {
                merchant.setDeliveryTime(15 + (int)(Math.random() * 15));
            }
            if (merchant.getDistance() == null) {
                merchant.setDistance(100 + (int)(Math.random() * 400));
            }
            if (merchant.getTags() == null || merchant.getTags().isEmpty()) {
                merchant.setTags("美食,好评");
            }
        }
        
        return R.success(list);
    }

    /**
     * 根据员工ID获取商家信息
     * @param employeeId 员工ID
     * @return 商家信息
     */
    @GetMapping("/byEmployee/{employeeId}")
    public R<Merchant> getByEmployeeId(@PathVariable Long employeeId) {
        log.info("根据员工ID查询商家: employeeId={}", employeeId);
        
        try {
            LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(Merchant::getEmployeeId, employeeId);
            
            Merchant merchant = merchantService.getOne(queryWrapper);
            
            if (merchant != null) {
                // 填充食堂名称
                if (merchant.getCanteenId() != null) {
                    try {
                        Canteen canteen = canteenService.getById(merchant.getCanteenId());
                        if (canteen != null) {
                            merchant.setCanteenName(canteen.getName());
                        }
                    } catch (Exception e) {
                        log.warn("填充食堂名称失败: {}", e.getMessage());
                    }
                }
                return R.success(merchant);
            }
            
            return R.error("未找到关联的商家信息");
        } catch (Exception e) {
            log.error("根据员工ID查询商家异常: {}", e.getMessage(), e);
            return R.error("查询商家信息失败");
        }
    }

    /**
     * 根据ID查询商家详情
     * @param id 商家ID
     * @return 商家详情
     */
    @GetMapping("/{id}")
    public R<Merchant> getById(@PathVariable Long id) {
        log.info("查询商家详情: id={}", id);
        
        Merchant merchant = merchantService.getById(id);
        
        if (merchant != null) {
            // 填充食堂名称
            if (merchant.getCanteenId() != null) {
                Canteen canteen = canteenService.getById(merchant.getCanteenId());
                if (canteen != null) {
                    merchant.setCanteenName(canteen.getName());
                }
            }
            
            // 填充美食分类名称
            if (merchant.getFoodCategoryId() != null) {
                FoodCategory category = foodCategoryService.getById(merchant.getFoodCategoryId());
                if (category != null) {
                    merchant.setFoodCategoryName(category.getName());
                }
            }
            
            return R.success(merchant);
        }
        
        return R.error("商家不存在");
    }

    /**
     * 新增商家
     * @param merchant 商家信息
     * @return 操作结果
     */
    @PostMapping
    public R<String> add(@RequestBody Merchant merchant) {
        log.info("新增商家: {}", merchant);
        
        // 设置默认值
        if (merchant.getRating() == null) {
            merchant.setRating(new java.math.BigDecimal("5.00"));
        }
        if (merchant.getSalesCount() == null) {
            merchant.setSalesCount(0);
        }
        if (merchant.getStatus() == null) {
            merchant.setStatus(1); // 默认营业
        }
        if (merchant.getDeliveryTime() == null) {
            merchant.setDeliveryTime(20); // 默认20分钟
        }
        if (merchant.getDeliveryFee() == null) {
            merchant.setDeliveryFee(0); // 默认免配送费
        }
        if (merchant.getIsNew() == null) {
            merchant.setIsNew(1); // 默认为新店
        }
        
        boolean saved = merchantService.save(merchant);
        
        if (saved) {
            return R.success("商家添加成功");
        }
        
        return R.error("商家添加失败");
    }

    /**
     * 更新商家
     * @param merchant 商家信息
     * @return 操作结果
     */
    @PutMapping
    public R<String> update(@RequestBody Merchant merchant) {
        log.info("更新商家: {}", merchant);
        
        boolean updated = merchantService.updateById(merchant);
        
        if (updated) {
            return R.success("商家更新成功");
        }
        
        return R.error("商家更新失败");
    }

    /**
     * 更新商家状态
     * @param id 商家ID
     * @param status 状态 0:停业 1:营业 2:待审核
     * @return 操作结果
     */
    @PutMapping("/status/{id}")
    public R<String> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        log.info("更新商家状态: id={}, status={}", id, status);
        
        Merchant merchant = new Merchant();
        merchant.setId(id);
        merchant.setStatus(status);
        
        boolean updated = merchantService.updateById(merchant);
        
        if (updated) {
            String statusName = status == 0 ? "停业" : (status == 1 ? "营业" : "待审核");
            return R.success("商家已" + statusName);
        }
        
        return R.error("状态更新失败");
    }

    /**
     * 删除商家
     * @param id 商家ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public R<String> delete(@PathVariable Long id) {
        log.info("删除商家: id={}", id);
        
        // TODO: 检查是否有关联的菜品或订单，如果有则不允许删除
        
        boolean deleted = merchantService.removeById(id);
        
        if (deleted) {
            return R.success("商家删除成功");
        }
        
        return R.error("商家删除失败");
    }
    
    /**
     * 获取商家红榜（好评最多）
     * @param limit 限制数量
     * @return 红榜商家列表
     */
    @GetMapping("/redList")
    public R<List<Merchant>> getRedList(@RequestParam(defaultValue = "10") int limit) {
        log.info("获取商家红榜: limit={}", limit);
        
        try {
            LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(Merchant::getStatus, 1); // 只查营业中的
            queryWrapper.gt(Merchant::getPositiveCount, 0); // 至少有好评
            queryWrapper.orderByDesc(Merchant::getPositiveCount); // 按好评数降序
            queryWrapper.last("LIMIT " + limit);
            
            List<Merchant> list = merchantService.list(queryWrapper);
            
            return R.success(list);
        } catch (Exception e) {
            log.error("获取商家红榜异常: {}", e.getMessage(), e);
            return R.success(new java.util.ArrayList<>());
        }
    }
    
    /**
     * 获取商家黑榜（差评最多）
     * @param limit 限制数量
     * @return 黑榜商家列表
     */
    @GetMapping("/blackList")
    public R<List<Merchant>> getBlackList(@RequestParam(defaultValue = "10") int limit) {
        log.info("获取商家黑榜: limit={}", limit);
        
        try {
            LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(Merchant::getStatus, 1); // 只查营业中的
            queryWrapper.gt(Merchant::getNegativeCount, 0); // 至少有差评
            queryWrapper.orderByDesc(Merchant::getNegativeCount); // 按差评数降序
            queryWrapper.last("LIMIT " + limit);
            
            List<Merchant> list = merchantService.list(queryWrapper);
            
            return R.success(list);
        } catch (Exception e) {
            log.error("获取商家黑榜异常: {}", e.getMessage(), e);
            return R.success(new java.util.ArrayList<>());
        }
    }
    
    /**
     * 获取商家评价统计
     * @param id 商家ID
     * @return 评价统计信息
     */
    @GetMapping("/{id}/ratingStats")
    public R<java.util.Map<String, Object>> getRatingStats(@PathVariable Long id) {
        log.info("获取商家评价统计: id={}", id);
        
        Merchant merchant = merchantService.getById(id);
        if (merchant == null) {
            return R.error("商家不存在");
        }
        
        int positive = merchant.getPositiveCount() != null ? merchant.getPositiveCount() : 0;
        int negative = merchant.getNegativeCount() != null ? merchant.getNegativeCount() : 0;
        int total = positive + negative;
        double positiveRate = total > 0 ? (positive * 100.0 / total) : 0;
        
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        stats.put("positiveCount", positive);
        stats.put("negativeCount", negative);
        stats.put("totalCount", total);
        stats.put("positiveRate", Math.round(positiveRate * 10) / 10.0); // 保留一位小数
        
        return R.success(stats);
    }
}

