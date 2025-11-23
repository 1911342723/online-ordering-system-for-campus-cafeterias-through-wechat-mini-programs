package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商家实体类
 */
@Data
public class Merchant implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 所属食堂ID
     */
    private Long canteenId;
    
    /**
     * 商家名称
     */
    private String name;
    
    /**
     * 窗口号
     */
    private String windowNumber;
    
    /**
     * 联系人
     */
    private String contact;
    
    /**
     * 联系电话
     */
    private String phone;
    
    /**
     * 商家简介
     */
    private String description;
    
    /**
     * 商家图片
     */
    private String image;
    
    /**
     * 关联员工ID（登录账号）
     */
    private Long employeeId;
    
    /**
     * 人均消费
     */
    private BigDecimal avgPrice;
    
    /**
     * 评分(0-5)
     */
    private BigDecimal rating;
    
    /**
     * 月销量
     */
    private Integer salesCount;

    /**
     * 总评价数
     */
    private Integer totalReviews;
    
    /**
     * 排序
     */
    private Integer sort;
    
    /**
     * 状态 0:停业 1:营业 2:待审核
     */
    private Integer status;
    
    /**
     * 关联的申请ID
     */
    private Long applicationId;
    
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
     * 食堂名称（查询时关联）
     */
    @TableField(exist = false)
    private String canteenName;
}
