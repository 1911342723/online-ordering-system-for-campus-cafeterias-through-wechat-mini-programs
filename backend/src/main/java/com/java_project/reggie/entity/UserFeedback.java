package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户反馈实体类
 */
@Data
public class UserFeedback implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 反馈类型 1:功能建议 2:投诉 3:其他
     */
    private Integer type;
    
    /**
     * 关联商家ID（可选）
     */
    private Long merchantId;
    
    /**
     * 反馈内容
     */
    private String content;
    
    /**
     * 反馈图片（逗号分隔）
     */
    private String images;
    
    /**
     * 联系方式
     */
    private String contact;
    
    /**
     * 处理状态 1:待处理 2:处理中 3:已完成
     */
    private Integer status;
    
    /**
     * 回复内容
     */
    private String reply;
    
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
}

