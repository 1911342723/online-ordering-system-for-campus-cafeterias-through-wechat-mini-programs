package com.java_project.reggie.controller;

import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.dto.DishDto;
import com.java_project.reggie.service.RecommendationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 推荐控制器
 */
@Slf4j
@RestController
@RequestMapping("/recommendation")
public class RecommendationController {

    @Autowired
    private RecommendationService recommendationService;

    /**
     * 获取今日推荐
     */
    @GetMapping("/today")
    public R<List<DishDto>> getTodayRecommendations(@RequestParam(required = false, defaultValue = "10") Integer limit) {
        Long userId = BaseContext.getThreadLocal();
        
        // 如果用户未登录，使用默认推荐
        if (userId == null) {
            userId = 0L;
        }
        
        log.info("获取今日推荐，用户ID：{}，数量：{}", userId, limit);
        
        try {
            List<DishDto> recommendations = recommendationService.getTodayRecommendations(userId, limit);
            return R.success(recommendations);
        } catch (Exception e) {
            log.error("获取今日推荐异常: {}", e.getMessage(), e);
            return R.success(new java.util.ArrayList<>());
        }
    }

    /**
     * 记录用户浏览历史
     */
    @PostMapping("/browse")
    public R<String> recordBrowse(@RequestBody Map<String, Object> params) {
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }

        Long dishId = params.get("dishId") != null ? Long.valueOf(params.get("dishId").toString()) : null;
        Long canteenId = params.get("canteenId") != null ? Long.valueOf(params.get("canteenId").toString()) : null;
        Long categoryId = params.get("categoryId") != null ? Long.valueOf(params.get("categoryId").toString()) : null;
        Integer stayDuration = params.get("stayDuration") != null ? Integer.valueOf(params.get("stayDuration").toString()) : 0;

        recommendationService.recordBrowseHistory(userId, dishId, canteenId, categoryId, stayDuration);
        return R.success("记录成功");
    }
}

