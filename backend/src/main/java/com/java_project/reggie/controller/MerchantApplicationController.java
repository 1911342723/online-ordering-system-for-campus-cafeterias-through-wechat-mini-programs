package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Canteen;
import com.java_project.reggie.entity.MerchantApplication;
import com.java_project.reggie.service.CanteenService;
import com.java_project.reggie.service.MerchantApplicationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.DigestUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 商家入驻申请Controller
 */
@Slf4j
@RestController
@RequestMapping("/merchantApplication")
public class MerchantApplicationController {
    
    @Autowired
    private MerchantApplicationService applicationService;
    
    @Autowired
    private CanteenService canteenService;
    
    /**
     * 提交商家入驻申请（无需登录）
     */
    @PostMapping
    public R<String> apply(@RequestBody MerchantApplication application) {
        log.info("商家入驻申请: {}", application.getName());
        
        // 验证必填字段
        if (!StringUtils.hasText(application.getName()) || 
            !StringUtils.hasText(application.getContact()) ||
            !StringUtils.hasText(application.getPhone()) ||
            !StringUtils.hasText(application.getUsername()) ||
            !StringUtils.hasText(application.getPassword())) {
            return R.error("请填写完整信息");
        }
        
        // 检查用户名是否已存在
        LambdaQueryWrapper<MerchantApplication> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantApplication::getUsername, application.getUsername());
        if (applicationService.count(wrapper) > 0) {
            return R.error("该用户名已被使用");
        }
        
        // 密码加密
        String md5Password = DigestUtils.md5DigestAsHex(application.getPassword().getBytes());
        application.setPassword(md5Password);
        
        // 设置默认状态
        application.setStatus(0); // 待审核
        
        applicationService.save(application);
        
        return R.success("申请提交成功，请等待审核");
    }
    
    /**
     * 分页查询商家申请（管理员）
     */
    @GetMapping("/page")
    public R<Page<MerchantApplication>> page(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String name) {
        
        log.info("分页查询商家申请: page={}, pageSize={}, status={}, name={}", page, pageSize, status, name);
        
        Page<MerchantApplication> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<MerchantApplication> wrapper = new LambdaQueryWrapper<>();
        
        // 条件查询
        wrapper.eq(status != null, MerchantApplication::getStatus, status);
        wrapper.like(StringUtils.hasText(name), MerchantApplication::getName, name);
        wrapper.orderByDesc(MerchantApplication::getCreateTime);
        
        applicationService.page(pageInfo, wrapper);
        
        // 关联食堂名称
        List<MerchantApplication> records = pageInfo.getRecords();
        records.forEach(app -> {
            if (app.getCanteenId() != null) {
                Canteen canteen = canteenService.getById(app.getCanteenId());
                if (canteen != null) {
                    app.setCanteenName(canteen.getName());
                }
            }
        });
        
        return R.success(pageInfo);
    }
    
    /**
     * 查询申请详情
     */
    @GetMapping("/{id}")
    public R<MerchantApplication> getById(@PathVariable Long id) {
        MerchantApplication application = applicationService.getById(id);
        if (application == null) {
            return R.error("申请不存在");
        }
        
        // 关联食堂名称
        if (application.getCanteenId() != null) {
            Canteen canteen = canteenService.getById(application.getCanteenId());
            if (canteen != null) {
                application.setCanteenName(canteen.getName());
            }
        }
        
        return R.success(application);
    }
    
    /**
     * 审核商家申请（管理员）
     */
    @PostMapping("/audit")
    public R<String> audit(@RequestBody AuditDTO auditDTO) {
        Long userId = BaseContext.getThreadLocal();
        log.info("审核商家申请: applicationId={}, approved={}, userId={}", 
                auditDTO.getApplicationId(), auditDTO.getApproved(), userId);
        
        try {
            boolean success = applicationService.auditApplication(
                    auditDTO.getApplicationId(), 
                    auditDTO.getApproved(), 
                    auditDTO.getRemark(), 
                    userId);
            
            if (success) {
                return R.success(auditDTO.getApproved() ? "审核通过" : "已拒绝申请");
            } else {
                return R.error("审核失败");
            }
        } catch (Exception e) {
            log.error("审核失败", e);
            return R.error(e.getMessage());
        }
    }
    
    /**
     * 获取待审核数量
     */
    @GetMapping("/pendingCount")
    public R<Long> pendingCount() {
        LambdaQueryWrapper<MerchantApplication> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantApplication::getStatus, 0);
        long count = applicationService.count(wrapper);
        return R.success(count);
    }
    
    /**
     * 审核DTO
     */
    @lombok.Data
    public static class AuditDTO {
        private Long applicationId;
        private Boolean approved;
        private String remark;
    }
}
