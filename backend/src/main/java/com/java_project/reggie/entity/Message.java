package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 消息实体类
 */
@Data
public class Message implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 商家ID
     */
    private Long merchantId;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 用户名称（冗余字段）
     */
    private String userName;
    
    /**
     * 消息内容
     */
    private String content;
    
    /**
     * 是否来自商家
     */
    private Boolean fromMerchant;
    
    /**
     * 状态 0-未读 1-已读
     */
    private Integer status;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

