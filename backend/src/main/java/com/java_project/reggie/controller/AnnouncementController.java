package com.java_project.reggie.controller;

import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Announcement;
import com.java_project.reggie.service.AnnouncementService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 公告控制器
 */
@Slf4j
@RestController
@RequestMapping("/announcement")
public class AnnouncementController {

    @Autowired
    private AnnouncementService announcementService;

    /**
     * 获取有效公告列表（前端用户使用）
     */
    @GetMapping("/active")
    public R<List<Announcement>> getActiveAnnouncements() {
        log.info("获取有效公告列表");
        List<Announcement> announcements = announcementService.getActiveAnnouncements();
        return R.success(announcements);
    }

    /**
     * 获取所有公告（管理员使用）
     */
    @GetMapping("/list")
    public R<List<Announcement>> list() {
        List<Announcement> announcements = announcementService.list();
        return R.success(announcements);
    }

    /**
     * 根据ID获取公告详情
     */
    @GetMapping("/{id}")
    public R<Announcement> getById(@PathVariable Long id) {
        Announcement announcement = announcementService.getById(id);
        return R.success(announcement);
    }

    /**
     * 新增公告
     */
    @PostMapping
    public R<String> save(@RequestBody Announcement announcement) {
        log.info("新增公告：{}", announcement);
        announcementService.save(announcement);
        return R.success("新增公告成功");
    }

    /**
     * 更新公告
     */
    @PutMapping
    public R<String> update(@RequestBody Announcement announcement) {
        log.info("更新公告：{}", announcement);
        announcementService.updateById(announcement);
        return R.success("更新公告成功");
    }

    /**
     * 删除公告
     */
    @DeleteMapping("/{id}")
    public R<String> delete(@PathVariable Long id) {
        log.info("删除公告：{}", id);
        announcementService.removeById(id);
        return R.success("删除公告成功");
    }
}

