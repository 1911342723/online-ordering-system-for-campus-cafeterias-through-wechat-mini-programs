package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.MerchantApplication;
import org.apache.ibatis.annotations.Mapper;

/**
 * 商家入驻申请Mapper
 */
@Mapper
public interface MerchantApplicationMapper extends BaseMapper<MerchantApplication> {
}

