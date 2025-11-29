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
     * 接收用户ID
     */
    private Long userId;
    
    /**
     * 发送用户ID（系统消息为空）
     */
    private Long fromUserId;
    
    /**
     * 消息类型：like=点赞, comment=评论, collect=收藏, system=系统
     */
    private String type;
    
    /**
     * 消息内容
     */
    private String content;
    
    /**
     * 关联笔记ID
     */
    private Long noteId;
    
    /**
     * 是否已读 0:未读 1:已读
     */
    private Integer isRead;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    // ========== 非数据库字段 ==========
    
    /**
     * 发送用户名称
     */
    @TableField(exist = false)
    private String fromUserName;
    
    /**
     * 发送用户头像
     */
    @TableField(exist = false)
    private String fromUserAvatar;
    
    /**
     * 关联笔记标题
     */
    @TableField(exist = false)
    private String noteTitle;
}
