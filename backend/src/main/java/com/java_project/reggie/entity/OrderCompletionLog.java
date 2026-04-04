package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 出餐完成日志（用于ETA预估计算）
 */
@Data
public class OrderCompletionLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    //订单ID
    private Long orderId;

    //商家ID（档口）
    private Long merchantId;

    //该订单菜品数量
    private Integer dishCount;

    //接单时间
    private LocalDateTime acceptedTime;

    //出餐完成时间
    private LocalDateTime completedTime;

    //出餐耗时（秒）
    private Integer servingDurationSeconds;

    //记录创建时间
    private LocalDateTime createTime;
}
