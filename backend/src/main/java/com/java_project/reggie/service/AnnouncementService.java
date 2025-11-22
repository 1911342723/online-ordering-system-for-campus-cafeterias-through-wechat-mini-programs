package com.java_project.reggie.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.java_project.reggie.entity.Announcement;

import java.util.List;

public interface AnnouncementService extends IService<Announcement> {
    
    /**
     * 获取有效的公告列表（已发布且在有效期内）
     */
    List<Announcement> getActiveAnnouncements();
}

