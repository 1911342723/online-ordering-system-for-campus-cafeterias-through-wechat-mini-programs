package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.Announcement;
import com.java_project.reggie.mapper.AnnouncementMapper;
import com.java_project.reggie.service.AnnouncementService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
public class AnnouncementServiceImpl extends ServiceImpl<AnnouncementMapper, Announcement> implements AnnouncementService {

    @Override
    public List<Announcement> getActiveAnnouncements() {
        LambdaQueryWrapper<Announcement> queryWrapper = new LambdaQueryWrapper<>();
        LocalDateTime now = LocalDateTime.now();
        
        queryWrapper.eq(Announcement::getStatus, 1) // 已发布
                .and(wrapper -> wrapper
                        .isNull(Announcement::getStartTime)
                        .or()
                        .le(Announcement::getStartTime, now)
                )
                .and(wrapper -> wrapper
                        .isNull(Announcement::getEndTime)
                        .or()
                        .ge(Announcement::getEndTime, now)
                )
                .orderByDesc(Announcement::getPriority)
                .orderByDesc(Announcement::getCreateTime);
        
        return this.list(queryWrapper);
    }
}

