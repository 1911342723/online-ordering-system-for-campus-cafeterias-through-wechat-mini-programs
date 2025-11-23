package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户优惠券实体
 */
@Data
public class UserCoupon implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    private Long userId;
    
    private Long couponId;
    
    private Integer status; // 0-未使用，1-已使用，2-已过期
    
    private LocalDateTime usedTime;
    
    private Long orderId;
    
    private LocalDateTime expireTime;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    @TableField(fill = FieldFill.INSERT)
    private Long createUser;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updateUser;
}

