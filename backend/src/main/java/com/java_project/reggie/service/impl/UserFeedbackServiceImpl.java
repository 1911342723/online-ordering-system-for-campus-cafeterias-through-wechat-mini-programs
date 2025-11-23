package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.UserFeedback;
import com.java_project.reggie.mapper.UserFeedbackMapper;
import com.java_project.reggie.service.UserFeedbackService;
import org.springframework.stereotype.Service;

/**
 * 用户反馈Service实现类
 */
@Service
public class UserFeedbackServiceImpl extends ServiceImpl<UserFeedbackMapper, UserFeedback> implements UserFeedbackService {
}

