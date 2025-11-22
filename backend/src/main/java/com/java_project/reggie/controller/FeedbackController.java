package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Feedback;
import com.java_project.reggie.service.FeedbackService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 意见反馈控制器
 */
@Slf4j
@RestController
@RequestMapping("/feedback")
public class FeedbackController {

    @Autowired
    private FeedbackService feedbackService;

    /**
     * 提交反馈
     */
    @PostMapping("/submit")
    public R<String> submit(@RequestBody Feedback feedback) {
        Long userId = BaseContext.getThreadLocal();
        
        feedback.setUserId(userId);
        feedback.setStatus(0); // 待处理
        
        feedbackService.save(feedback);
        
        log.info("用户{}提交反馈：{}", userId, feedback.getType());
        
        return R.success("提交成功");
    }

    /**
     * 查询我的反馈列表
     */
    @GetMapping("/list")
    public R<Page<Feedback>> list(int page, int pageSize) {
        Long userId = BaseContext.getThreadLocal();
        
        Page<Feedback> pageInfo = new Page<>(page, pageSize);
        
        LambdaQueryWrapper<Feedback> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Feedback::getUserId, userId);
        queryWrapper.orderByDesc(Feedback::getCreateTime);
        
        feedbackService.page(pageInfo, queryWrapper);
        
        return R.success(pageInfo);
    }
}

