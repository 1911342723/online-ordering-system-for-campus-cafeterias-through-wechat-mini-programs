package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.UserFeedback;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户反馈Mapper接口
 */
@Mapper
public interface UserFeedbackMapper extends BaseMapper<UserFeedback> {
}

