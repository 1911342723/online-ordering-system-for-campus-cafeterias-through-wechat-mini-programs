package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 社区笔记实体类
 */
@Data
public class Note implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 发布用户ID
     */
    private Long userId;
    
    /**
     * 笔记标题
     */
    private String title;
    
    /**
     * 笔记内容
     */
    private String content;
    
    /**
     * 图片列表（JSON格式，多张图片）
     */
    private String images;
    
    /**
     * 封面图（第一张图）
     */
    private String coverImage;
    
    /**
     * 标签（逗号分隔）
     */
    private String tags;
    
    /**
     * 关联订单ID（必选，防止恶意刷分）
     */
    private Long orderId;
    
    /**
     * 关联商家ID（从订单获取）
     */
    private Long merchantId;
    
    /**
     * 关联菜品ID（可选）
     */
    private Long dishId;
    
    /**
     * 点赞数
     */
    private Integer likeCount;
    
    /**
     * 收藏数
     */
    private Integer collectCount;
    
    /**
     * 评论数
     */
    private Integer commentCount;
    
    /**
     * 转发数
     */
    private Integer shareCount;
    
    /**
     * 浏览数
     */
    private Integer viewCount;
    
    /**
     * 状态 0:草稿 1:已发布 2:已删除 3:审核中
     */
    private Integer status;
    
    /**
     * 是否置顶 0:否 1:是
     */
    private Integer isTop;
    
    /**
     * 是否精华 0:否 1:是
     */
    private Integer isFeatured;
    
    /**
     * 评价类型：positive=好评推荐, negative=吐槽避雷
     * 用于商家红黑榜统计
     */
    private String ratingType;
    
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
     * 发布用户信息
     */
    @TableField(exist = false)
    private String userName;
    
    @TableField(exist = false)
    private String userAvatar;
    
    /**
     * 当前用户是否点赞
     */
    @TableField(exist = false)
    private Boolean isLiked;
    
    /**
     * 当前用户是否收藏
     */
    @TableField(exist = false)
    private Boolean isCollected;
    
    /**
     * 评论列表
     */
    @TableField(exist = false)
    private List<NoteComment> comments;
    
    /**
     * 标签列表
     */
    @TableField(exist = false)
    private List<String> tagList;
    
    /**
     * 图片列表
     */
    @TableField(exist = false)
    private List<String> imageList;
}

