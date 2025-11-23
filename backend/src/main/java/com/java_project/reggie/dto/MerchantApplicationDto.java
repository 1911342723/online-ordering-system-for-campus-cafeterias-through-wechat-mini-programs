package com.java_project.reggie.dto;

import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 商家入驻申请DTO
 */
@Data
public class MerchantApplicationDto implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * 登录账号（员工用户名）
     */
    private String username;
    
    /**
     * 商家名称
     */
    private String name;
    
    /**
     * 所属食堂ID
     */
    private Long canteenId;
    
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
     * 人均消费
     */
    private BigDecimal avgPrice;
    
    /**
     * 排序
     */
    private Integer sort;
}

