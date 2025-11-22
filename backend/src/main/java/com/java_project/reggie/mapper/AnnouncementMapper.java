package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.Announcement;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AnnouncementMapper extends BaseMapper<Announcement> {
}

