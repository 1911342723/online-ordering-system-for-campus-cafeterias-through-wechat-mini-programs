package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 笔记评论实体类
 */
@Data
public class NoteComment implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 笔记ID
     */
    private Long noteId;
    
    /**
     * 评论用户ID
     */
    private Long userId;
    
    /**
     * 父评论ID（用于回复，0表示一级评论）
     */
    private Long parentId;
    
    /**
     * 被回复用户ID
     */
    private Long replyUserId;
    
    /**
     * 评论内容
     */
    private String content;
    
    /**
     * 点赞数
     */
    private Integer likeCount;
    
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
    
    // ========== 非数据库字段 ==========
    
    /**
     * 评论用户名
     */
    @TableField(exist = false)
    private String userName;
    
    /**
     * 评论用户头像
     */
    @TableField(exist = false)
    private String userAvatar;
    
    /**
     * 被回复用户名
     */
    @TableField(exist = false)
    private String replyUserName;
    
    /**
     * 当前用户是否点赞
     */
    @TableField(exist = false)
    private Boolean isLiked;
    
    /**
     * 子评论列表（回复）
     */
    @TableField(exist = false)
    private List<NoteComment> replies;
}

