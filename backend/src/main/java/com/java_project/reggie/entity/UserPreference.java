package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户喜好实体
 */
@Data
public class UserPreference implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    // 用户ID
    private Long userId;

    // 分类ID
    private Long categoryId;

    // 菜品ID
    private Long dishId;

    // 喜好分数（0-100）
    private BigDecimal preferenceScore;

    // 订单次数
    private Integer orderCount;

    // 最后订单时间
    private LocalDateTime lastOrderTime;

    // 创建时间
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    // 更新时间
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}

