package com.java_project.reggie.common;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component//由Spring接管
//实现源数据处理器类，由Mybatis提供
public class MyMetaObjectHnader implements MetaObjectHandler {
    //执行insert语句自动执行
    @Override
    public void insertFill(MetaObject metaObject) {
        // 检查字段是否存在再设置，避免对没有这些字段的实体报错
        if (metaObject.hasSetter("createTime")) {
            metaObject.setValue("createTime", LocalDateTime.now());
        }
        if (metaObject.hasSetter("updateTime")) {
            metaObject.setValue("updateTime", LocalDateTime.now());
        }
        //线程Id被设置为id名了，可以用于动态获取
        if (metaObject.hasSetter("createUser")) {
            metaObject.setValue("createUser", BaseContext.getThreadLocal());
        }
        if (metaObject.hasSetter("updateUser")) {
            metaObject.setValue("updateUser", BaseContext.getThreadLocal());
        }
    }
    //执行update语句自动执行
    @Override
    public void updateFill(MetaObject metaObject) {
        if (metaObject.hasSetter("updateTime")) {
            metaObject.setValue("updateTime", LocalDateTime.now());
        }
        if (metaObject.hasSetter("updateUser")) {
            metaObject.setValue("updateUser", BaseContext.getThreadLocal());
        }
    }
}
