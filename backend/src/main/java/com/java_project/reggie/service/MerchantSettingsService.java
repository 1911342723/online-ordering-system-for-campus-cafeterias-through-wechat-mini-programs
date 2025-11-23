package com.java_project.reggie.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.java_project.reggie.entity.MerchantSettings;

/**
 * 商家设置Service
 */
public interface MerchantSettingsService extends IService<MerchantSettings> {
    
    /**
     * 根据商家ID获取设置
     */
    MerchantSettings getByMerchantId(Long merchantId);
    
    /**
     * 获取或创建商家设置
     */
    MerchantSettings getOrCreate(Long merchantId);
}

