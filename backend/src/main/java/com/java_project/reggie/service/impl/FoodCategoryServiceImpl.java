package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.FoodCategory;
import com.java_project.reggie.mapper.FoodCategoryMapper;
import com.java_project.reggie.service.FoodCategoryService;
import org.springframework.stereotype.Service;

/**
 * 美食分类Service实现类
 */
@Service
public class FoodCategoryServiceImpl extends ServiceImpl<FoodCategoryMapper, FoodCategory> implements FoodCategoryService {
}

