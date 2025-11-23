package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.UserFavoriteMerchant;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户收藏商家Mapper接口
 */
@Mapper
public interface UserFavoriteMerchantMapper extends BaseMapper<UserFavoriteMerchant> {
}

