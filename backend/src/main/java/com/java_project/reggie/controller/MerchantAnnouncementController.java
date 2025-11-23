package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Merchant;
import com.java_project.reggie.entity.MerchantAnnouncement;
import com.java_project.reggie.service.MerchantAnnouncementService;
import com.java_project.reggie.service.MerchantService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 商家公告管理Controller
 */
@Slf4j
@RestController
@RequestMapping("/merchantAnnouncement")
public class MerchantAnnouncementController {

    @Autowired
    private MerchantAnnouncementService merchantAnnouncementService;

    @Autowired
    private MerchantService merchantService;

    /**
     * 分页查询公告列表（管理端）
     */
    @GetMapping("/page")
    public R<Page<MerchantAnnouncement>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) Long merchantId,
            @RequestParam(required = false) String title) {
        
        log.info("分页查询商家公告: page={}, pageSize={}, merchantId={}, title={}", page, pageSize, merchantId, title);
        
        Page<MerchantAnnouncement> pageInfo = new Page<>(page, pageSize);
        
        LambdaQueryWrapper<MerchantAnnouncement> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(merchantId != null, MerchantAnnouncement::getMerchantId, merchantId);
        queryWrapper.like(StringUtils.hasText(title), MerchantAnnouncement::getTitle, title);
        queryWrapper.orderByDesc(MerchantAnnouncement::getSort).orderByDesc(MerchantAnnouncement::getCreateTime);
        
        merchantAnnouncementService.page(pageInfo, queryWrapper);
        
        // 填充商家名称
        pageInfo.getRecords().forEach(announcement -> {
            if (announcement.getMerchantId() != null) {
                Merchant merchant = merchantService.getById(announcement.getMerchantId());
                if (merchant != null) {
                    announcement.setMerchantName(merchant.getName());
                }
            }
        });
        
        return R.success(pageInfo);
    }

    /**
     * 获取商家的有效公告列表（用户端）
     */
    @GetMapping("/active")
    public R<List<MerchantAnnouncement>> getActiveAnnouncements(@RequestParam Long merchantId) {
        log.info("查询商家有效公告: merchantId={}", merchantId);
        
        LambdaQueryWrapper<MerchantAnnouncement> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(MerchantAnnouncement::getMerchantId, merchantId);
        queryWrapper.eq(MerchantAnnouncement::getStatus, 1); // 只查启用的
        
        // 时间范围内的公告
        LocalDateTime now = LocalDateTime.now();
        queryWrapper.and(wrapper -> wrapper
            .isNull(MerchantAnnouncement::getStartTime)
            .or()
            .le(MerchantAnnouncement::getStartTime, now)
        );
        queryWrapper.and(wrapper -> wrapper
            .isNull(MerchantAnnouncement::getEndTime)
            .or()
            .ge(MerchantAnnouncement::getEndTime, now)
        );
        
        queryWrapper.orderByDesc(MerchantAnnouncement::getSort).orderByDesc(MerchantAnnouncement::getCreateTime);
        queryWrapper.last("LIMIT 10"); // 最多返回10条
        
        List<MerchantAnnouncement> list = merchantAnnouncementService.list(queryWrapper);
        return R.success(list);
    }

    /**
     * 根据ID查询公告
     */
    @GetMapping("/{id}")
    public R<MerchantAnnouncement> getById(@PathVariable Long id) {
        log.info("查询公告详情: id={}", id);
        
        MerchantAnnouncement announcement = merchantAnnouncementService.getById(id);
        
        if (announcement != null) {
            // 填充商家名称
            if (announcement.getMerchantId() != null) {
                Merchant merchant = merchantService.getById(announcement.getMerchantId());
                if (merchant != null) {
                    announcement.setMerchantName(merchant.getName());
                }
            }
            return R.success(announcement);
        }
        
        return R.error("公告不存在");
    }

    /**
     * 新增公告
     */
    @PostMapping
    public R<String> add(@RequestBody MerchantAnnouncement announcement) {
        log.info("新增商家公告: {}", announcement);
        
        // 设置默认值
        if (announcement.getStatus() == null) {
            announcement.setStatus(1);
        }
        if (announcement.getSort() == null) {
            announcement.setSort(0);
        }
        
        boolean saved = merchantAnnouncementService.save(announcement);
        
        if (saved) {
            return R.success("公告发布成功");
        }
        
        return R.error("公告发布失败");
    }

    /**
     * 更新公告
     */
    @PutMapping
    public R<String> update(@RequestBody MerchantAnnouncement announcement) {
        log.info("更新商家公告: {}", announcement);
        
        boolean updated = merchantAnnouncementService.updateById(announcement);
        
        if (updated) {
            return R.success("公告更新成功");
        }
        
        return R.error("公告更新失败");
    }

    /**
     * 删除公告
     */
    @DeleteMapping("/{id}")
    public R<String> delete(@PathVariable Long id) {
        log.info("删除商家公告: id={}", id);
        
        boolean deleted = merchantAnnouncementService.removeById(id);
        
        if (deleted) {
            return R.success("公告删除成功");
        }
        
        return R.error("公告删除失败");
    }

    /**
     * 更新公告状态
     */
    @PutMapping("/status/{id}")
    public R<String> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        log.info("更新公告状态: id={}, status={}", id, status);
        
        MerchantAnnouncement announcement = new MerchantAnnouncement();
        announcement.setId(id);
        announcement.setStatus(status);
        
        boolean updated = merchantAnnouncementService.updateById(announcement);
        
        if (updated) {
            return R.success("状态更新成功");
        }
        
        return R.error("状态更新失败");
    }
}

