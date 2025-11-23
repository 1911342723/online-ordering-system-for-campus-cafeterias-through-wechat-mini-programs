package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.OrderReview;
import com.java_project.reggie.mapper.OrderReviewMapper;
import com.java_project.reggie.service.OrderReviewService;
import org.springframework.stereotype.Service;

/**
 * 订单评价Service实现类
 */
@Service
public class OrderReviewServiceImpl extends ServiceImpl<OrderReviewMapper, OrderReview> implements OrderReviewService {
}

