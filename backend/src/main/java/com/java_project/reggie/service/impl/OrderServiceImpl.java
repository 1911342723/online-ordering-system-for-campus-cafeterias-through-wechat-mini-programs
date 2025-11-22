package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.IdWorker;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.CustomException;
import com.java_project.reggie.entity.*;
import com.java_project.reggie.mapper.OrderMapper;
import com.java_project.reggie.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderServiceImpl extends ServiceImpl<OrderMapper,Orders> implements OrderService {
    @Autowired
    private ShoppingCartService shoppingCartService;
    @Autowired
    private UserService userService;
    @Autowired
    private AddressService addressService;
    @Autowired
    private OrderDtailService orderDtailService;
    @Autowired
    private OrderMapper orderMapper;


    /**
     * 用户下单
     * @param orders
     */
    @Transactional
    public void submit(Orders orders) {
        //获得当前用户id
        Long userId = BaseContext.getThreadLocal();

        //查询当前用户的购物车数据
        LambdaQueryWrapper<ShoppingCart> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ShoppingCart::getUserId,userId);
        List<ShoppingCart> shoppingCarts = shoppingCartService.list(wrapper);

        if(shoppingCarts == null || shoppingCarts.size() == 0){
            throw new CustomException("购物车为空，不能下单");
        }

        //查询用户数据
        User user = userService.getById(userId);

        //查询地址数据（仅在外送时需要）
        AddressBook addressBook = null;
        if (orders.getDeliveryType() != null && orders.getDeliveryType() == 2) {
            // 外送时需要地址
        Long addressBookId = orders.getAddressBookId();
            if(addressBookId == null){
                throw new CustomException("外送订单必须选择收货地址");
            }
            addressBook = addressService.getById(addressBookId);
        if(addressBook == null){
                throw new CustomException("收货地址不存在，不能下单");
            }
        }

        long orderId = IdWorker.getId();//订单号

        // 使用BigDecimal计算总金额，避免精度问题
        final BigDecimal[] totalDishAmount = {BigDecimal.ZERO};

        List<OrderDetail> orderDetails = shoppingCarts.stream().map((item) -> {
            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setOrderId(orderId);
            orderDetail.setNumber(item.getNumber());
            orderDetail.setDishFlavor(item.getDishFlavor());
            orderDetail.setDishId(item.getDishId());
            orderDetail.setSetmealId(item.getSetmealId());
            orderDetail.setName(item.getName());
            orderDetail.setImage(item.getImage());
            orderDetail.setAmount(item.getAmount());
            // 累加金额：单价 * 数量
            totalDishAmount[0] = totalDishAmount[0].add(item.getAmount().multiply(new BigDecimal(item.getNumber())));
            return orderDetail;
        }).collect(Collectors.toList());


        // 计算总金额（菜品金额）
        BigDecimal dishAmount = totalDishAmount[0];
        
        // 处理配送方式和配送费
        if (orders.getDeliveryType() == null) {
            orders.setDeliveryType(1); // 默认自取
        }
        
        // 计算配送费
        BigDecimal deliveryFee = BigDecimal.ZERO;
        if (orders.getDeliveryType() == 2) {
            // 外送收取配送费（可根据距离动态计算）
            deliveryFee = new BigDecimal("3.00"); // 固定3元配送费
        }
        orders.setDeliveryFee(deliveryFee);
        
        // 计算最终总金额 = 菜品金额 + 配送费
        BigDecimal totalAmount = dishAmount.add(deliveryFee);
        
        orders.setId(orderId);
        orders.setOrderTime(LocalDateTime.now());
        orders.setCheckoutTime(LocalDateTime.now());
        orders.setStatus(1); // 待付款 - 订单提交后需要先支付
        orders.setAmount(totalAmount); // 总金额（含配送费）
        orders.setUserId(userId);
        orders.setNumber(String.valueOf(orderId));
        //orders.setUserName(user.getName());
        
        // 根据配送方式设置地址信息
        if (orders.getDeliveryType() == 1) {
            // 到店自取
            orders.setConsignee(user.getName() != null ? user.getName() : "");
            orders.setPhone(user.getPhone() != null ? user.getPhone() : "");
            orders.setAddress("到店自取");
        } else {
            // 外送
        orders.setConsignee(addressBook.getConsignee());
        orders.setPhone(addressBook.getPhone());
        orders.setAddress((addressBook.getProvinceName() == null ? "" : addressBook.getProvinceName())
                + (addressBook.getCityName() == null ? "" : addressBook.getCityName())
                + (addressBook.getDistrictName() == null ? "" : addressBook.getDistrictName())
                + (addressBook.getDetail() == null ? "" : addressBook.getDetail()));
        }
        
        //向订单表插入数据，一条数据
        this.save(orders);

        //向订单明细表插入数据，多条数据
        orderDtailService.saveBatch(orderDetails);

        //清空购物车数据
        shoppingCartService.remove(wrapper);
    }



    public boolean updateOrderStatus(Long id, Integer status) {
        // 创建一个更新的 Order 对象
        Orders order = new Orders();
        order.setId(id);
        order.setStatus(status);

        // 使用MyBatis-Plus的更新方法
        int updatedRows = orderMapper.updateById(order);

        return updatedRows > 0;
    }
}