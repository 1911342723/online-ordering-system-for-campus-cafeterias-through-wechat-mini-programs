package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.CanteenConfig;
import com.java_project.reggie.mapper.CanteenConfigMapper;
import com.java_project.reggie.service.CanteenConfigService;
import org.springframework.stereotype.Service;

/**
 * 食堂配置Service实现类
 */
@Service
public class CanteenConfigServiceImpl extends ServiceImpl<CanteenConfigMapper, CanteenConfig> implements CanteenConfigService {
}

