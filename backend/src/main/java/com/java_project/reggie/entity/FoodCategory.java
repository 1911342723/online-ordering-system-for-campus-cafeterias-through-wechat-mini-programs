package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 美食分类实体类（用于首页金刚区展示）
 */
@Data
public class FoodCategory implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 分类标识（如：bbq, noodle, rice）
     */
    private String code;
    
    /**
     * 分类名称（如：烧烤、面食、盖饭）
     */
    private String name;
    
    /**
     * 分类图标（emoji或图片URL）
     */
    private String icon;
    
    /**
     * 背景颜色（十六进制，如：#FEF3C7）
     */
    private String bgColor;
    
    /**
     * 搜索关键词（用于筛选商家）
     */
    private String keyword;
    
    /**
     * 排序
     */
    private Integer sort;
    
    /**
     * 状态 0:禁用 1:启用
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
     * 该分类下的商家数量（查询时计算）
     */
    @TableField(exist = false)
    private Integer merchantCount;
}

