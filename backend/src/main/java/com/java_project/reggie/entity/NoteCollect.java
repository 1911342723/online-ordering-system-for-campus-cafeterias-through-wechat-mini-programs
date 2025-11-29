package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 笔记收藏记录实体类
 */
@Data
public class NoteCollect implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 笔记ID
     */
    private Long noteId;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

