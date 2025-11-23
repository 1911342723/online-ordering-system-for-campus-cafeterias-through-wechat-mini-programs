package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户收藏菜品实体类
 */
@Data
public class UserFavoriteDish implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 菜品ID
     */
    private Long dishId;
    
    /**
     * 收藏时间
     */
    private LocalDateTime createTime;
}

