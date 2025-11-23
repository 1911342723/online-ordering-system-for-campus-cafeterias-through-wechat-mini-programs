package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.UserFeedback;
import com.java_project.reggie.service.UserFeedbackService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 用户反馈Controller
 */
@Slf4j
@RestController
@RequestMapping("/feedback")
public class FeedbackController {

    @Autowired
    private UserFeedbackService feedbackService;

    /**
     * 提交反馈
     */
    @PostMapping
    public R<String> submitFeedback(@RequestBody UserFeedback feedback) {
        Long userId = BaseContext.getThreadLocal();
        feedback.setUserId(userId);
        feedback.setStatus(1); // 待处理

        log.info("用户{}提交反馈", userId);

        feedbackService.save(feedback);
        return R.success("感谢您的反馈，我们会及时处理");
    }

    /**
     * 查询我的反馈列表
     */
    @GetMapping("/my/list")
    public R<Page<UserFeedback>> getMyFeedbacks(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        
        Long userId = BaseContext.getThreadLocal();
        log.info("查询用户{}的反馈列表", userId);

        Page<UserFeedback> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<UserFeedback> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(UserFeedback::getUserId, userId);
        queryWrapper.orderByDesc(UserFeedback::getCreateTime);

        feedbackService.page(pageInfo, queryWrapper);
        return R.success(pageInfo);
    }

    /**
     * 查询反馈详情
     */
    @GetMapping("/{id}")
    public R<UserFeedback> getFeedback(@PathVariable Long id) {
        Long userId = BaseContext.getThreadLocal();
        
        UserFeedback feedback = feedbackService.getById(id);
        if (feedback == null || !feedback.getUserId().equals(userId)) {
            return R.error("无权查看此反馈");
        }

        return R.success(feedback);
    }

    /**
     * 分页查询反馈列表（管理员）
     */
    @GetMapping("/page")
    public R<Page<UserFeedback>> getFeedbackPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer type) {
        
        log.info("分页查询反馈列表, page={}, pageSize={}, status={}, type={}", page, pageSize, status, type);

        Page<UserFeedback> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<UserFeedback> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(status != null, UserFeedback::getStatus, status);
        queryWrapper.eq(type != null, UserFeedback::getType, type);
        queryWrapper.orderByDesc(UserFeedback::getCreateTime);

        feedbackService.page(pageInfo, queryWrapper);
        return R.success(pageInfo);
    }

    /**
     * 更新反馈状态（管理员）
     */
    @PutMapping("/{id}/status")
    public R<String> updateFeedbackStatus(@PathVariable Long id, @RequestParam Integer status) {
        log.info("更新反馈{}状态: {}", id, status);

        UserFeedback feedback = feedbackService.getById(id);
        if (feedback == null) {
            return R.error("反馈不存在");
        }

        feedback.setStatus(status);
        feedbackService.updateById(feedback);
        return R.success("状态更新成功");
    }

    /**
     * 回复反馈（管理员）
     */
    @PutMapping("/{id}/reply")
    public R<String> replyFeedback(@PathVariable Long id, @RequestParam String reply) {
        log.info("回复反馈{}: {}", id, reply);

        UserFeedback feedback = feedbackService.getById(id);
        if (feedback == null) {
            return R.error("反馈不存在");
        }

        feedback.setReply(reply);
        feedback.setStatus(3); // 已完成
        feedbackService.updateById(feedback);
        return R.success("回复成功");
    }
}
