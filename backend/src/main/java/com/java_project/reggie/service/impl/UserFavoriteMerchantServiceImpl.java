package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.UserFavoriteMerchant;
import com.java_project.reggie.mapper.UserFavoriteMerchantMapper;
import com.java_project.reggie.service.UserFavoriteMerchantService;
import org.springframework.stereotype.Service;

/**
 * 用户收藏商家Service实现类
 */
@Service
public class UserFavoriteMerchantServiceImpl extends ServiceImpl<UserFavoriteMerchantMapper, UserFavoriteMerchant> implements UserFavoriteMerchantService {
}

