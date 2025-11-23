package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 优惠券实体
 */
@Data
public class Coupon implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    private String name;
    
    /**
     * 优惠券类型 1:平台券 2:商家券
     */
    private Integer type;
    
    /**
     * 商家ID（商家券专用）
     */
    private Long merchantId;
    
    private BigDecimal amount; // 优惠金额
    
    private BigDecimal minAmount; // 最低消费金额
    
    private String description;
    
    private Integer totalCount; // 总数量
    
    private Integer remainCount; // 剩余数量
    
    private Integer validDays; // 有效天数
    
    private Integer status; // 0-禁用，1-启用
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    @TableField(fill = FieldFill.INSERT)
    private Long createUser;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updateUser;
}

