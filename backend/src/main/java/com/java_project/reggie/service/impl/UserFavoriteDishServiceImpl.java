package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.UserFavoriteDish;
import com.java_project.reggie.mapper.UserFavoriteDishMapper;
import com.java_project.reggie.service.UserFavoriteDishService;
import org.springframework.stereotype.Service;

/**
 * 用户收藏菜品Service实现类
 */
@Service
public class UserFavoriteDishServiceImpl extends ServiceImpl<UserFavoriteDishMapper, UserFavoriteDish> implements UserFavoriteDishService {
}

