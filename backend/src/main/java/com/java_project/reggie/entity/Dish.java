package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 菜品
 */
@Data
public class Dish implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;


    //菜品名称
    private String name;


    //菜品分类id
    private Long categoryId;


    //所属餐厅ID
    private Long canteenId;

    //所属商家ID
    private Long merchantId;

    //菜品价格
    private BigDecimal price;


    //商品码
    private String code;


    //图片
    private String image;


    //描述信息
    private String description;

    //库存数量
    private Integer stock;

    //卡路里（千卡/份）
    private Integer calories;

    //蛋白质（克/份）
    private java.math.BigDecimal protein;

    //脂肪（克/份）
    private java.math.BigDecimal fat;

    //碳水化合物（克/份）
    private java.math.BigDecimal carbs;

    //膳食纤维（克/份）
    private java.math.BigDecimal fiber;

    //营养标签（逗号分隔，如：高蛋白,低脂,低卡）
    private String nutritionTags;

    //0 停售 1 起售
    private Integer status;


    //顺序
    private Integer sort;


    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;


    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;


    @TableField(fill = FieldFill.INSERT)
    private Long createUser;


    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updateUser;


    //是否删除
    private Integer isDeleted;

}
