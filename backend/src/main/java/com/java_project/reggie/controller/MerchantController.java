package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Canteen;
import com.java_project.reggie.entity.Merchant;
import com.java_project.reggie.service.CanteenService;
import com.java_project.reggie.service.MerchantService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
     * 根据食堂ID获取商家列表（用户端）
     * @param canteenId 食堂ID
     * @return 商家列表
     */
    @GetMapping("/list")
    public R<List<Merchant>> listByCanteen(@RequestParam Long canteenId) {
        log.info("查询食堂商家列表: canteenId={}", canteenId);
        
        LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Merchant::getCanteenId, canteenId);
        queryWrapper.eq(Merchant::getStatus, 1); // 只查营业中的
        queryWrapper.orderByAsc(Merchant::getSort);
        
        List<Merchant> list = merchantService.list(queryWrapper);
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
        
        LambdaQueryWrapper<Merchant> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Merchant::getEmployeeId, employeeId);
        
        Merchant merchant = merchantService.getOne(queryWrapper);
        
        if (merchant != null) {
            // 填充食堂名称
            if (merchant.getCanteenId() != null) {
                Canteen canteen = canteenService.getById(merchant.getCanteenId());
                if (canteen != null) {
                    merchant.setCanteenName(canteen.getName());
                }
            }
            return R.success(merchant);
        }
        
        return R.error("未找到关联的商家信息");
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
}

