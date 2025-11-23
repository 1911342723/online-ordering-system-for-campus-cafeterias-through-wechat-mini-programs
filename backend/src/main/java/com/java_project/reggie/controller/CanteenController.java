package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Canteen;
import com.java_project.reggie.entity.CanteenConfig;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.CanteenConfigService;
import com.java_project.reggie.service.CanteenService;
import com.java_project.reggie.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 餐厅控制器
 */
@Slf4j
@RestController
@RequestMapping("/canteen")
public class CanteenController {

    @Autowired
    private CanteenService canteenService;

    @Autowired
    private CanteenConfigService canteenConfigService;

    @Autowired
    private UserService userService;

    /**
     * 获取餐厅列表（根据用户类型筛选）
     * @return 餐厅列表
     */
    @GetMapping("/list")
    public R<List<Canteen>> list() {
        log.info("查询餐厅列表");
        
        // 获取当前用户
        Long userId = BaseContext.getThreadLocal();
        User user = null;
        Integer userType = 1; // 默认学生
        
        if (userId != null) {
            user = userService.getById(userId);
            if (user != null) {
                userType = user.getUserType() != null ? user.getUserType() : 1;
            }
        }
        
        LambdaQueryWrapper<Canteen> queryWrapper = new LambdaQueryWrapper<>();
        // 只查询营业中的餐厅
        queryWrapper.eq(Canteen::getStatus, 1);
        // 按排序字段升序排列
        queryWrapper.orderByAsc(Canteen::getSort);
        
        List<Canteen> list = canteenService.list(queryWrapper);
        
        // 过滤教师食堂
        final Integer finalUserType = userType;
        list = list.stream().filter(canteen -> {
            // 查询食堂配置
            LambdaQueryWrapper<CanteenConfig> configQuery = new LambdaQueryWrapper<>();
            configQuery.eq(CanteenConfig::getCanteenId, canteen.getId());
            CanteenConfig config = canteenConfigService.getOne(configQuery);
            
            // 如果食堂仅限教师，则只有教师才能看到
            if (config != null && config.getIsTeacherOnly() == 1) {
                return finalUserType == 2; // 只有教师能看到
            }
            
            return true; // 其他食堂所有人都能看到
        }).collect(Collectors.toList());
        
        log.info("查询到{}个餐厅（用户类型：{}）", list.size(), userType);
        
        return R.success(list);
    }

    /**
     * 根据ID获取餐厅详情
     * @param id 餐厅ID
     * @return 餐厅详情
     */
    @GetMapping("/{id}")
    public R<Canteen> getById(@PathVariable Long id) {
        log.info("查询餐厅详情，id：{}", id);
        
        Canteen canteen = canteenService.getById(id);
        if (canteen == null) {
            return R.error("餐厅不存在");
        }
        
        return R.success(canteen);
    }

    /**
     * 分页查询餐厅（管理端）
     * @param page 页码
     * @param pageSize 每页大小
     * @param name 餐厅名称（可选）
     * @return 分页结果
     */
    @GetMapping("/page")
    public R<Page<Canteen>> page(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String name) {
        
        log.info("分页查询餐厅，page：{}，pageSize：{}，name：{}", page, pageSize, name);
        
        Page<Canteen> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<Canteen> queryWrapper = new LambdaQueryWrapper<>();
        
        // 根据名称模糊查询
        if (name != null && !name.isEmpty()) {
            queryWrapper.like(Canteen::getName, name);
        }
        
        // 按排序字段升序排列
        queryWrapper.orderByAsc(Canteen::getSort);
        
        canteenService.page(pageInfo, queryWrapper);
        return R.success(pageInfo);
    }

    /**
     * 新增餐厅（管理端）
     * @param canteen 餐厅信息
     * @return 操作结果
     */
    @PostMapping
    public R<String> save(@RequestBody Canteen canteen) {
        log.info("新增餐厅：{}", canteen);
        canteenService.save(canteen);
        return R.success("新增餐厅成功");
    }

    /**
     * 更新餐厅（管理端）
     * @param canteen 餐厅信息
     * @return 操作结果
     */
    @PutMapping
    public R<String> update(@RequestBody Canteen canteen) {
        log.info("更新餐厅：{}", canteen);
        canteenService.updateById(canteen);
        return R.success("更新餐厅成功");
    }

    /**
     * 删除餐厅（管理端）
     * @param id 餐厅ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public R<String> delete(@PathVariable Long id) {
        log.info("删除餐厅，id：{}", id);
        canteenService.removeById(id);
        return R.success("删除餐厅成功");
    }

    /**
     * 更新餐厅状态（管理端）
     * @param status 状态 0:停业 1:营业
     * @param ids 餐厅ID列表
     * @return 操作结果
     */
    @PostMapping("/status/{status}")
    public R<String> updateStatus(@PathVariable Integer status, @RequestParam List<Long> ids) {
        log.info("批量更新餐厅状态，status：{}，ids：{}", status, ids);
        
        for (Long id : ids) {
            Canteen canteen = new Canteen();
            canteen.setId(id);
            canteen.setStatus(status);
            canteenService.updateById(canteen);
        }
        
        return R.success("更新状态成功");
    }
}

