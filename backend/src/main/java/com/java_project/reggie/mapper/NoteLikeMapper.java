package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.NoteLike;
import org.apache.ibatis.annotations.Mapper;

/**
 * 笔记点赞Mapper
 */
@Mapper
public interface NoteLikeMapper extends BaseMapper<NoteLike> {
}

