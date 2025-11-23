package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.common.CustomException;
import com.java_project.reggie.entity.*;
import com.java_project.reggie.mapper.MerchantApplicationMapper;
import com.java_project.reggie.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商家入驻申请ServiceImpl
 */
@Slf4j
@Service
public class MerchantApplicationServiceImpl extends ServiceImpl<MerchantApplicationMapper, MerchantApplication> 
        implements MerchantApplicationService {
    
    @Autowired
    private MerchantService merchantService;
    
    @Autowired
    private EmployeeService employeeService;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean auditApplication(Long applicationId, boolean approved, String remark, Long auditUserId) {
        // 获取申请信息
        MerchantApplication application = this.getById(applicationId);
        if (application == null) {
            throw new CustomException("申请不存在");
        }
        
        if (application.getStatus() != 0) {
            throw new CustomException("该申请已审核");
        }
        
        // 更新申请状态
        application.setStatus(approved ? 1 : 2);
        application.setAuditRemark(remark);
        application.setAuditUserId(auditUserId);
        application.setAuditTime(LocalDateTime.now());
        
        if (approved) {
            // 审核通过，创建商家和员工账号
            try {
                // 1. 创建员工账号
                Employee employee = new Employee();
                employee.setUsername(application.getUsername());
                employee.setName(application.getContact());
                employee.setPassword(application.getPassword()); // 已加密
                employee.setPhone(application.getPhone());
                employee.setIdNumber(application.getIdCard());
                employee.setStatus(1); // 启用
                employee.setRole("merchant"); // 商家角色
                
                employeeService.save(employee);
                application.setEmployeeId(employee.getId());
                
                // 2. 创建商家
                Merchant merchant = new Merchant();
                merchant.setCanteenId(application.getCanteenId());
                merchant.setName(application.getName());
                merchant.setWindowNumber(application.getWindowNumber());
                merchant.setContact(application.getContact());
                merchant.setPhone(application.getPhone());
                merchant.setDescription(application.getDescription());
                merchant.setEmployeeId(employee.getId());
                merchant.setAvgPrice(application.getAvgPrice());
                merchant.setRating(BigDecimal.valueOf(5.0)); // 默认5分
                merchant.setSalesCount(0);
                merchant.setTotalReviews(0);
                merchant.setSort(999);
                merchant.setStatus(1); // 营业
                merchant.setApplicationId(application.getId());
                
                merchantService.save(merchant);
                application.setMerchantId(merchant.getId());
                
                // 3. 更新员工的merchant_id
                employee.setMerchantId(merchant.getId());
                employeeService.updateById(employee);
                
                log.info("商家入驻审核通过，创建商家ID: {}, 员工ID: {}", merchant.getId(), employee.getId());
                
            } catch (Exception e) {
                log.error("创建商家和员工账号失败", e);
                throw new CustomException("审核通过但创建账号失败：" + e.getMessage());
            }
        }
        
        return this.updateById(application);
    }
}

