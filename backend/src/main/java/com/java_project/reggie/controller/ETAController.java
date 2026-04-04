package com.java_project.reggie.controller;

import com.java_project.reggie.common.R;
import com.java_project.reggie.service.ETAService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 取餐排队ETA预估控制器
 *
 * 提供接口供前端查询指定商家（档口）的预估取餐等待时间
 */
@Slf4j
@RestController
@RequestMapping("/eta")
public class ETAController {

    @Autowired
    private ETAService etaService;

    /**
     * 查询指定商家的预估取餐等待时间
     *
     * @param merchantId 商家（档口）ID
     * @return {
     *   estimatedMinutes: 预估等待分钟数,
     *   queueLength: 当前排队订单数,
     *   avgServingTime: 加权平均出餐时间(秒),
     *   status: "空闲"/"适中"/"繁忙"
     * }
     */
    @GetMapping("/{merchantId}")
    public R<Map<String, Object>> getEstimatedWaitTime(@PathVariable Long merchantId) {
        log.info("查询商家{}的ETA预估", merchantId);

        if (merchantId == null) {
            return R.error("商家ID不能为空");
        }

        Map<String, Object> etaInfo = etaService.getEstimatedWaitTime(merchantId);
        return R.success(etaInfo);
    }

    /**
     * 批量查询多个商家的ETA
     *
     * @param merchantIds 商家ID列表（逗号分隔）
     */
    @GetMapping("/batch")
    public R<Map<Long, Map<String, Object>>> batchGetETA(@RequestParam String merchantIds) {
        log.info("批量查询ETA: {}", merchantIds);

        Map<Long, Map<String, Object>> result = new java.util.HashMap<>();

        try {
            String[] ids = merchantIds.split(",");
            for (String idStr : ids) {
                Long id = Long.parseLong(idStr.trim());
                Map<String, Object> etaInfo = etaService.getEstimatedWaitTime(id);
                result.put(id, etaInfo);
            }
        } catch (NumberFormatException e) {
            return R.error("商家ID格式错误");
        }

        return R.success(result);
    }
}
