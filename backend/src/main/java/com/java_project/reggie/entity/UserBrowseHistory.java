package com.java_project.reggie.entity;

import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户浏览历史实体
 */
@Data
public class UserBrowseHistory implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    // 用户ID
    private Long userId;

    // 菜品ID
    private Long dishId;

    // 餐厅ID
    private Long canteenId;

    // 分类ID
    private Long categoryId;

    // 浏览时间
    private LocalDateTime browseTime;

    // 停留时长（秒）
    private Integer stayDuration;
}

