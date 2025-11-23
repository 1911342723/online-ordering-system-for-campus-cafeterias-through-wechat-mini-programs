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

    @Autowired
    private com.java_project.reggie.common.AuthHelper authHelper;
    
    @Autowired
    private com.java_project.reggie.service.EmployeeService employeeService;

    @Autowired
    private com.java_project.reggie.service.UserService userService;
    
    @Autowired
    private com.java_project.reggie.service.MerchantService merchantService;
    
    @Autowired
    private com.java_project.reggie.service.CanteenService canteenService;

    /*管理端的订单明细 - 支持商家数据隔离，返回完整信息*/
    @GetMapping("/page")
    public R<Page<OrderDto>> page2(
            Integer page,
            Integer pagesize,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String number,
            @RequestParam(required = false) Integer orderType){
        if (pagesize == null) {
            pagesize = 10; // 提供默认值
        }
        if (page == null) {
            page = 1;
        }
        
        log.info("订单分页查询：page={}, pagesize={}, status={}, number={}, orderType={}", 
                page, pagesize, status, number, orderType);
        
        //构建分页构造器
        Page<Orders> pageInfo = new Page<>(page, pagesize);

        //构造条件构造器
        LambdaQueryWrapper<Orders> queryWrapper = new LambdaQueryWrapper<>();
        
        // 商家数据隔离：商家只能看到自己的订单
        if (authHelper.isMerchant()) {
            Long merchantId = authHelper.getCurrentMerchantId();
            if (merchantId != null) {
                queryWrapper.eq(Orders::getMerchantId, merchantId);
                log.info("商家{}查询订单", merchantId);
            } else {
                log.warn("商家角色但未找到关联的商家ID");
                return R.success(new Page<>()); // 返回空页面
            }
        }
        // 管理员可以看到所有订单，不添加额外条件
        
        // 添加查询条件
        queryWrapper.eq(status != null, Orders::getStatus, status);
        queryWrapper.like(number != null && !number.isEmpty(), Orders::getNumber, number);
        queryWrapper.eq(orderType != null, Orders::getOrderType, orderType);
        
        //添加排序条件
        queryWrapper.orderByDesc(Orders::getOrderTime);
        
        //执行查询
        orderService.page(pageInfo, queryWrapper);
        
        log.info("查询到{}条订单记录", pageInfo.getRecords().size());
        
        // 转换为OrderDto并填充关联信息
        Page<OrderDto> dtoPage = new Page<>();
        BeanUtils.copyProperties(pageInfo, dtoPage, "records");
        
        List<OrderDto> orderDtoList = pageInfo.getRecords().stream().map(order -> {
            OrderDto orderDto = new OrderDto();
            BeanUtils.copyProperties(order, orderDto);
            
            // 填充用户名
            if (order.getUserId() != null) {
                try {
                    com.java_project.reggie.entity.User user = userService.getById(order.getUserId());
                    if (user != null) {
                        orderDto.setUserName(user.getName());
                    }
                } catch (Exception e) {
                    log.warn("获取用户信息失败: userId={}", order.getUserId());
                }
            }
            
            // 填充商家名
            if (order.getMerchantId() != null) {
                try {
                    com.java_project.reggie.entity.Merchant merchant = merchantService.getById(order.getMerchantId());
                    if (merchant != null) {
                        orderDto.setMerchantName(merchant.getName());
                    }
                } catch (Exception e) {
                    log.warn("获取商家信息失败: merchantId={}", order.getMerchantId());
                }
            }
            
            // 填充食堂名
            if (order.getCanteenId() != null) {
                try {
                    com.java_project.reggie.entity.Canteen canteen = canteenService.getById(order.getCanteenId());
                    if (canteen != null) {
                        orderDto.setCanteenName(canteen.getName());
                    }
                } catch (Exception e) {
                    log.warn("获取食堂信息失败: canteenId={}", order.getCanteenId());
                }
            }
            
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

    /**
     * 删除订单（管理端/商家端）
     */
    @DeleteMapping("/{id}")
    public R<String> deleteOrder(@PathVariable Long id) {
        log.info("删除订单: id={}", id);
        
        Orders order = orderService.getById(id);
        if (order == null) {
            return R.error("订单不存在");
        }
        
        // 只允许删除已完成或已取消的订单
        if (order.getStatus() != 5 && order.getStatus() != 6) {
            return R.error("只能删除已完成或已取消的订单");
        }
        
        // 商家权限检查
        if (authHelper.isMerchant()) {
            Long merchantId = authHelper.getCurrentMerchantId();
            if (merchantId != null && !order.getMerchantId().equals(merchantId)) {
                return R.error("无权删除此订单");
            }
        }
        
        boolean deleted = orderService.removeById(id);
        
        if (deleted) {
            return R.success("订单删除成功");
        }
        
        return R.error("删除失败");
    }

    /**
     * 用户取消订单
     */
    @PutMapping("/cancel/{id}")
    public R<String> cancelOrder(@PathVariable Long id) {
        Long userId = BaseContext.getThreadLocal();
        log.info("用户{}取消订单：{}", userId, id);

        Orders order = orderService.getById(id);
        if (order == null) {
            return R.error("订单不存在");
        }

        // 验证订单所属用户
        if (!order.getUserId().equals(userId)) {
            return R.error("无权操作此订单");
        }

        // 只能取消待付款状态的订单
        if (order.getStatus() != 1) {
            return R.error("该订单不可取消");
        }

        // 更新订单状态为已取消(6)
        order.setStatus(6);
        orderService.updateById(order);

        log.info("订单{}已取消", id);
        return R.success("订单已取消");
    }

    /**
     * 用户申请退款
     */
    @PostMapping("/refund/{id}")
    public R<String> applyRefund(@PathVariable Long id, @RequestBody java.util.Map<String, String> request) {
        Long userId = BaseContext.getThreadLocal();
        String reason = request.get("reason");
        
        log.info("用户{}申请退款，订单：{}，原因：{}", userId, id, reason);

        Orders order = orderService.getById(id);
        if (order == null) {
            return R.error("订单不存在");
        }

        // 验证订单所属用户
        if (!order.getUserId().equals(userId)) {
            return R.error("无权操作此订单");
        }

        // 只能对已完成或已取消的订单申请退款
        if (order.getStatus() != 5 && order.getStatus() != 6) {
            return R.error("该订单不可退款");
        }

        // 检查是否已经申请过退款
        if (order.getRefundStatus() != null && order.getRefundStatus() > 0) {
            return R.error("该订单已申请退款");
        }

        // 更新退款信息
        order.setRefundStatus(1); // 退款申请中
        order.setRefundReason(reason);
        order.setRefundAmount(order.getAmount()); // 全额退款
        order.setRefundTime(java.time.LocalDateTime.now());
        
        orderService.updateById(order);

        log.info("订单{}退款申请已提交", id);
        return R.success("退款申请已提交，请等待审核");
    }
}
