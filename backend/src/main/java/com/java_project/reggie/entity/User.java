package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
import java.io.Serializable;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
/**
 * 用户信息
 */
@Data
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;


    //姓名
    private String name;


    //手机号
    private String phone;
    
    
    //用户类型 1:学生 2:教师 3:普通用户
    private Integer userType;
    
    
    //真实姓名
    private String realName;
    
    
    //教师认证状态 0:未认证 1:待审核 2:已认证 3:已拒绝
    private Integer teacherVerified;


    //性别 0 女 1 男
    private String sex;


    //身份证号（教师认证用）
    private String idCard;


    //身份证号
    private String idNumber;


    //头像
    private String avatar;


    //状态 0:禁用，1:正常
    private Integer status;


    //账户余额（元）
    private BigDecimal balance = BigDecimal.ZERO;


    //优惠券数量
    private Integer couponCount = 0;
    
    
    //积分
    private Integer points = 0;
    
    
    //个性签名
    private String signature;
    
    
    //经验值
    private Integer exp = 0;
    
    
    //发帖数量
    private Integer postCount = 0;
    
    
    //收藏数量
    private Integer collectCount = 0;
    
    
    //获赞数量
    private Integer likeCount = 0;


    //创建时间
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;


    //更新时间
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;


    //创建人
    @TableField(fill = FieldFill.INSERT)
    private Long createUser;


    //修改人
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updateUser;
}
