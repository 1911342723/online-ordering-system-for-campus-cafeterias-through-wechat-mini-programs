package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.FoodCategory;
import org.apache.ibatis.annotations.Mapper;

/**
 * 美食分类Mapper
 */
@Mapper
public interface FoodCategoryMapper extends BaseMapper<FoodCategory> {
}

