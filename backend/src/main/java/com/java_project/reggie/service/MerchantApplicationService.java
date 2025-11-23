package com.java_project.reggie.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.java_project.reggie.entity.MerchantApplication;

/**
 * 商家入驻申请Service
 */
public interface MerchantApplicationService extends IService<MerchantApplication> {
    
    /**
     * 审核商家申请
     * @param applicationId 申请ID
     * @param approved 是否通过
     * @param remark 审核备注
     * @param auditUserId 审核人ID
     * @return 是否成功
     */
    boolean auditApplication(Long applicationId, boolean approved, String remark, Long auditUserId);
}

