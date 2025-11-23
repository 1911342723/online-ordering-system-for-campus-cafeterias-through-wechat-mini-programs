package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 订单评价实体类
 */
@Data
public class OrderReview implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 订单ID
     */
    private Long orderId;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 商家ID
     */
    private Long merchantId;
    
    /**
     * 评分(1-5星)
     */
    private Integer rating;
    
    /**
     * 口味评分(1-5星)
     */
    private Integer tasteRating;
    
    /**
     * 服务评分(1-5星)
     */
    private Integer serviceRating;
    
    /**
     * 速度评分(1-5星)
     */
    private Integer speedRating;
    
    /**
     * 评价内容
     */
    private String content;
    
    /**
     * 商家回复
     */
    private String merchantReply;
    
    /**
     * 商家回复时间
     */
    private LocalDateTime merchantReplyTime;
    
    /**
     * 评价图片（逗号分隔）
     */
    private String images;
    
    /**
     * 是否匿名 0:否 1:是
     */
    private Integer isAnonymous;
    
    /**
     * 状态 0:已删除 1:正常
     */
    private Integer status;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 创建人
     */
    @TableField(fill = FieldFill.INSERT)
    private Long createUser;

    /**
     * 更新人
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updateUser;
    
    /**
     * 用户名称（查询时关联）
     */
    @TableField(exist = false)
    private String userName;
    
    /**
     * 用户头像（查询时关联）
     */
    @TableField(exist = false)
    private String userAvatar;
    
    /**
     * 订单号（查询时关联）
     */
    @TableField(exist = false)
    private String orderNumber;
}

