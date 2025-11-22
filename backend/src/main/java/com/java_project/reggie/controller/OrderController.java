package com.java_project.reggie.controller;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.CustomException;
import com.java_project.reggie.common.R;
import com.java_project.reggie.dto.OrderDto;
import com.java_project.reggie.entity.OrderDetail;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.service.OrderDtailService;
import com.java_project.reggie.service.OrderService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/order")
public class OrderController {
    @Autowired
    private OrderService orderService;
    @Autowired
    private OrderDtailService orderDtailService;

    /*
    * 用户下单
    * */
    @PostMapping("/submit")
    public R<String> submit(@RequestBody Orders orders){
        orderService.submit(orders);
        return R.success("下单成功！");
    }

    /*根据ID获取订单详情 - 包含订单明细*/
    @GetMapping("/{id}")
    public R<OrderDto> getById(@PathVariable Long id){
        log.info("查询订单详情，订单ID：{}", id);
        
        Orders order = orderService.getById(id);
        if (order == null) {
            throw new CustomException("订单不存在");
        }
        
        // 验证订单所属用户（可选，根据业务需求）
        Long currentUserId = BaseContext.getThreadLocal();
        if (currentUserId != null && !order.getUserId().equals(currentUserId)) {
            throw new CustomException("无权查看此订单");
        }
        
        // 转换为OrderDto并查询订单详情
        OrderDto orderDto = new OrderDto();
        BeanUtils.copyProperties(order, orderDto);
        
        // 查询订单详情
        LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
        detailWrapper.eq(OrderDetail::getOrderId, order.getId());
        List<OrderDetail> orderDetails = orderDtailService.list(detailWrapper);
        orderDto.setOrderDetails(orderDetails);
        
        return R.success(orderDto);
    }

    /*订单分页查询（用户端）- 包含订单详情*/
    @GetMapping("/userPage")
    public R<Page<OrderDto>> page(Integer page, Integer pageSize, Integer status){
        log.info("订单分页查询：page={}, pageSize={}, status={}", page, pageSize, status);
        
        if (pageSize == null) {
            pageSize = 10; // 提供默认值
        }
        
        if (page == null) {
            page = 1;
        }
        
        // 获取当前用户ID
        Long userId = BaseContext.getThreadLocal();
        
        //构建分页构造器
        Page<Orders> pageInfo = new Page<>(page, pageSize);

        //构造条件构造器
        LambdaQueryWrapper<Orders> queryWrapper = new LambdaQueryWrapper<>();
        
        // 只查询当前用户的订单
        queryWrapper.eq(userId != null, Orders::getUserId, userId);
        
        // 如果指定了状态，按状态筛选
        queryWrapper.eq(status != null, Orders::getStatus, status);
        
        // 按下单时间倒序排列
        queryWrapper.orderByDesc(Orders::getOrderTime);
        
        //执行查询
        orderService.page(pageInfo, queryWrapper);
        
        log.info("查询到{}条订单", pageInfo.getRecords().size());
        
        // 转换为OrderDto，包含订单详情
        Page<OrderDto> dtoPage = new Page<>();
        BeanUtils.copyProperties(pageInfo, dtoPage, "records");
        
        List<OrderDto> orderDtoList = pageInfo.getRecords().stream().map(order -> {
            OrderDto orderDto = new OrderDto();
            BeanUtils.copyProperties(order, orderDto);
            
            // 查询订单详情
            LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
            detailWrapper.eq(OrderDetail::getOrderId, order.getId());
            List<OrderDetail> orderDetails = orderDtailService.list(detailWrapper);
            orderDto.setOrderDetails(orderDetails);
            
            // 计算总数量
            int sumNum = orderDetails.stream().mapToInt(OrderDetail::getNumber).sum();
            orderDto.setSumNum(sumNum);
            
            return orderDto;
        }).collect(Collectors.toList());
        
        dtoPage.setRecords(orderDtoList);
        
        return R.success(dtoPage);
    }

    /*管理端的订单明细*/
    @GetMapping("/page")
    public R<Page> page2(Integer page,Integer pagesize){
        if (pagesize == null) {
            pagesize = 10; // 提供默认值
        }
        //构建分页构造器，基于Mybatis-plus的插件
        Page pageInfo = new Page(page,pagesize);

        //构造条件构造器
        LambdaQueryWrapper<Orders> queryWrapper =new LambdaQueryWrapper();
        //添加排序条件
        queryWrapper.orderByDesc(Orders::getOrderTime);
        //执行查询
        //queryWrapper.eq(Orders::getUserId, BaseContext.getThreadLocal());
        //List<Orders> list =null;


        //list.set(1,orderService.getOne(queryWrapper));
        //pageInfo.setOrders(list);
        orderService.page(pageInfo,queryWrapper);
        return R.success(pageInfo);
    }

    /*管理端点击派送*/
    @PutMapping
    public R<String> updateOrderStatus(@RequestBody Orders request) {

        boolean updated = orderService.updateOrderStatus(request.getId(), request.getStatus());

        if (updated) {
            return R.success("Order status updated successfully.");
        } else {
            return R.error("修改失败");
        }
    }
}
