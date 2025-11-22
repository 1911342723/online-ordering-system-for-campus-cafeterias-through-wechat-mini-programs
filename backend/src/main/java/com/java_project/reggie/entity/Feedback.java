package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 意见反馈实体
 */
@Data
public class Feedback implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    // 用户ID
    private Long userId;
    
    // 反馈类型：bug-功能异常，suggest-功能建议，service-服务问题，food-菜品问题，delivery-配送问题，other-其他
    private String type;
    
    // 反馈内容
    private String content;
    
    // 图片URL（多张图片用逗号分隔）
    private String images;
    
    // 联系方式
    private String contact;
    
    // 状态：0-待处理，1-处理中，2-已处理
    private Integer status;
    
    // 回复内容
    private String reply;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}

