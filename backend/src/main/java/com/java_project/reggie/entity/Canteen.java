package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 餐厅实体类
 */
@Data
public class Canteen implements Serializable {

    private static final long serialVersionUID = 1L;

    // 主键
    private Long id;

    // 餐厅名称
    private String name;

    // 餐厅描述
    private String description;

    // 餐厅图片
    private String image;

    // 餐厅地址
    private String address;

    // 联系电话
    private String phone;

    // 营业时间
    private String businessHours;

    // 评分
    private BigDecimal rating;

    // 距离（米）
    private Integer distance;

    // 状态 0:停业 1:营业
    private Integer status;

    // 排序
    private Integer sort;

    // 创建时间
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    // 更新时间
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    // 创建人
    @TableField(fill = FieldFill.INSERT)
    private Long createUser;

    // 修改人
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updateUser;
}

