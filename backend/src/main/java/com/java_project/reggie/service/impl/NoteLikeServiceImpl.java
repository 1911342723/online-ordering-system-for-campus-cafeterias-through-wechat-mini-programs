package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.NoteLike;
import com.java_project.reggie.mapper.NoteLikeMapper;
import com.java_project.reggie.service.NoteLikeService;
import org.springframework.stereotype.Service;

/**
 * 笔记点赞Service实现类
 */
@Service
public class NoteLikeServiceImpl extends ServiceImpl<NoteLikeMapper, NoteLike> implements NoteLikeService {
}

