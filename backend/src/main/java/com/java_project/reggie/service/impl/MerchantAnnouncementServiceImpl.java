package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.MerchantAnnouncement;
import com.java_project.reggie.mapper.MerchantAnnouncementMapper;
import com.java_project.reggie.service.MerchantAnnouncementService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 商家公告Service实现类
 */
@Slf4j
@Service
public class MerchantAnnouncementServiceImpl extends ServiceImpl<MerchantAnnouncementMapper, MerchantAnnouncement> implements MerchantAnnouncementService {
}

