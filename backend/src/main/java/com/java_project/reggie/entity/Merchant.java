package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;

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
     * 好评数（用于红榜统计）
     */
    private Integer positiveCount;
    
    /**
     * 差评数（用于黑榜统计）
     */
    private Integer negativeCount;
    
    /**
     * 微信社群二维码图片URL（商家入驻必填）
     */
    private String wechatGroupQrcode;
    
    /**
     * 商家标签（逗号分隔，如：烧烤,夜宵,人气爆棚）
     */
    private String tags;
    
    /**
     * 优惠信息（如：满30减10）
     */
    private String promo;
    
    /**
     * 配送时间（分钟）
     */
    private Integer deliveryTime;
    
    /**
     * 配送费（分）
     */
    private Integer deliveryFee;
    
    /**
     * 起送价（分）
     */
    private Integer minOrderAmount;
    
    /**
     * 营业开始时间
     */
    private LocalTime openTime;
    
    /**
     * 营业结束时间
     */
    private LocalTime closeTime;
    
    /**
     * 是否为新店 0:否 1:是
     */
    private Integer isNew;
    
    /**
     * 美食分类ID（关联food_category表）
     */
    private Long foodCategoryId;
    
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
    
    /**
     * 美食分类名称（查询时关联）
     */
    @TableField(exist = false)
    private String foodCategoryName;
    
    /**
     * 距离（米，前端计算或传入）
     */
    @TableField(exist = false)
    private Integer distance;
}
