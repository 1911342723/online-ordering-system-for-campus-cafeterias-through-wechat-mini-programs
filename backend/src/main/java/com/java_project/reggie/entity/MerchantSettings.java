package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 商家设置实体类
 */
@Data
public class MerchantSettings implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    
    /**
     * 商家ID
     */
    private Long merchantId;
    
    /**
     * 自动接单 0:关闭 1:开启
     */
    private Integer autoAcceptOrder;
    
    /**
     * 营业开始时间
     */
    private LocalTime businessHoursStart;
    
    /**
     * 营业结束时间
     */
    private LocalTime businessHoursEnd;
    
    /**
     * 起送金额
     */
    private BigDecimal minOrderAmount;
    
    /**
     * 订单提示音 0:关闭 1:开启
     */
    private Integer noticeSound;
    
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
     * 创建人
     */
    @TableField(fill = FieldFill.INSERT)
    private Long createUser;
    
    /**
     * 更新人
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updateUser;
}

