package com.java_project.reggie.common;

import com.java_project.reggie.entity.Employee;
import com.java_project.reggie.entity.Merchant;
import com.java_project.reggie.service.EmployeeService;
import com.java_project.reggie.service.MerchantService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * 权限辅助类
 */
@Slf4j
@Component
public class AuthHelper {
    
    @Autowired
    private EmployeeService employeeService;

    @Autowired
    private MerchantService merchantService;
    
    /**
     * 获取当前登录的员工信息
     */
    public Employee getCurrentEmployee() {
        Long empId = BaseContext.getThreadLocal();
        if (empId == null) {
            return null;
        }
        return employeeService.getById(empId);
    }
    
    /**
     * 判断当前用户是否是管理员
     */
    public boolean isAdmin() {
        Employee employee = getCurrentEmployee();
        return employee != null && "admin".equals(employee.getRole());
    }
    
    /**
     * 判断当前用户是否是商家
     */
    public boolean isMerchant() {
        Employee employee = getCurrentEmployee();
        return employee != null && "merchant".equals(employee.getRole());
    }
    
    /**
     * 获取当前商家的ID（如果是商家角色）
     */
    public Long getCurrentMerchantId() {
        Employee employee = getCurrentEmployee();
        if (employee != null && "merchant".equals(employee.getRole())) {
            if (employee.getMerchantId() != null) {
                return employee.getMerchantId();
            }

            // 兼容历史数据：employee.merchant_id 为空时，尝试通过 merchant.employee_id 反查。
            LambdaQueryWrapper<Merchant> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Merchant::getEmployeeId, employee.getId());
            wrapper.last("LIMIT 1");
            Merchant merchant = merchantService.getOne(wrapper);
            if (merchant != null) {
                return merchant.getId();
            }
        }
        return null;
    }
    
    /**
     * 检查当前用户是否有权限访问指定商家的数据
     * @param merchantId 商家ID
     * @return true if authorized
     */
    public boolean canAccessMerchant(Long merchantId) {
        if (isAdmin()) {
            return true; // 管理员可以访问所有商家
        }
        
        if (isMerchant()) {
            Long currentMerchantId = getCurrentMerchantId();
            return merchantId.equals(currentMerchantId); // 商家只能访问自己的数据
        }
        
        return false;
    }
}

