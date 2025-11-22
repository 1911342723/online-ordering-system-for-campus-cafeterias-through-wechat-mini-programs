package com.java_project.reggie.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 公告实体
 */
@Data
public class Announcement implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    // 公告标题
    private String title;

    // 公告内容
    private String content;

    // 公告类型：1-系统公告，2-活动公告，3-紧急通知
    private Integer type;

    // 优先级：0-普通，1-重要，2-紧急
    private Integer priority;

    // 状态：0-已下架，1-已发布
    private Integer status;

    // 开始时间
    private LocalDateTime startTime;

    // 结束时间
    private LocalDateTime endTime;

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

