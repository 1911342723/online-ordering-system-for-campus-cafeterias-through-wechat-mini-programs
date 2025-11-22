package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.Canteen;
import com.java_project.reggie.mapper.CanteenMapper;
import com.java_project.reggie.service.CanteenService;
import org.springframework.stereotype.Service;

/**
 * 餐厅服务实现类
 */
@Service
public class CanteenServiceImpl extends ServiceImpl<CanteenMapper, Canteen> implements CanteenService {
}

