package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商家入驻申请实体类
 */
@Data
public class MerchantApplication implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 申请的食堂ID
     */
    private Long canteenId;
    
    /**
     * 商家名称
     */
    private String name;
    
    /**
     * 申请窗口号
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
     * 营业执照照片
     */
    private String businessLicense;
    
    /**
     * 人均消费
     */
    private BigDecimal avgPrice;
    
    /**
     * 经营者身份证号
     */
    private String idCard;
    
    /**
     * 经营者姓名
     */
    private String ownerName;
    
    /**
     * 登录用户名(申请时填写)
     */
    private String username;
    
    /**
     * 登录密码(加密后)
     */
    private String password;
    
    /**
     * 审核状态 0:待审核 1:已通过 2:已拒绝
     */
    private Integer status;
    
    /**
     * 审核备注
     */
    private String auditRemark;
    
    /**
     * 审核人ID
     */
    private Long auditUserId;
    
    /**
     * 审核时间
     */
    private LocalDateTime auditTime;
    
    /**
     * 关联的商家ID（审核通过后创建）
     */
    private Long merchantId;
    
    /**
     * 关联的员工ID（审核通过后创建）
     */
    private Long employeeId;
    
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

