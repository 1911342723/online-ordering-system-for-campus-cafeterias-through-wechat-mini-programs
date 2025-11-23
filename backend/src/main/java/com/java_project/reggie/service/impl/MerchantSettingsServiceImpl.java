package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.MerchantSettings;
import com.java_project.reggie.mapper.MerchantSettingsMapper;
import com.java_project.reggie.service.MerchantSettingsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

/**
 * 商家设置ServiceImpl
 */
@Slf4j
@Service
public class MerchantSettingsServiceImpl extends ServiceImpl<MerchantSettingsMapper, MerchantSettings> 
        implements MerchantSettingsService {
    
    @Override
    public MerchantSettings getByMerchantId(Long merchantId) {
        LambdaQueryWrapper<MerchantSettings> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantSettings::getMerchantId, merchantId);
        return this.getOne(wrapper);
    }
    
    @Override
    public MerchantSettings getOrCreate(Long merchantId) {
        MerchantSettings settings = getByMerchantId(merchantId);
        if (settings == null) {
            // 创建默认设置
            settings = new MerchantSettings();
            settings.setMerchantId(merchantId);
            settings.setAutoAcceptOrder(0); // 默认关闭自动接单
            settings.setNoticeSound(1); // 默认开启提示音
            settings.setMinOrderAmount(BigDecimal.ZERO);
            this.save(settings);
            log.info("为商家{}创建默认设置", merchantId);
        }
        return settings;
    }
}

