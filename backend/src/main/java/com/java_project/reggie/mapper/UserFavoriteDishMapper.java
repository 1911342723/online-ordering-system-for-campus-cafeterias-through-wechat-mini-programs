package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.UserFavoriteDish;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户收藏菜品Mapper接口
 */
@Mapper
public interface UserFavoriteDishMapper extends BaseMapper<UserFavoriteDish> {
}

