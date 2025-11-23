package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.IdWorker;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.CustomException;
import com.java_project.reggie.entity.*;
import com.java_project.reggie.mapper.OrderMapper;
import com.java_project.reggie.service.*;
import com.java_project.reggie.websocket.OrderWebSocketHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j

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
    @Autowired
    private UserCouponService userCouponService;
    
    @Autowired
    private CanteenService canteenService;
    
    @Autowired
    private MerchantService merchantService;
    @Autowired
    private CouponService couponService;
    @Autowired
    private MerchantSettingsService merchantSettingsService;


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
        
        // 从购物车获取食堂和商家信息
        if (!shoppingCarts.isEmpty()) {
            ShoppingCart firstItem = shoppingCarts.get(0);
            orders.setCanteenId(firstItem.getCanteenId());
            orders.setMerchantId(firstItem.getMerchantId());
            
            // 查询食堂名称
            if (firstItem.getCanteenId() != null) {
                Canteen canteen = canteenService.getById(firstItem.getCanteenId());
                if (canteen != null) {
                    orders.setCanteenName(canteen.getName());
                }
            }
            
            // 查询商家名称
            if (firstItem.getMerchantId() != null) {
                Merchant merchant = merchantService.getById(firstItem.getMerchantId());
                if (merchant != null) {
                    orders.setMerchantName(merchant.getName());
                }
            }
        }

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
        
        // 计算配送费（单位：分）
        BigDecimal deliveryFee = BigDecimal.ZERO;
        if (orders.getDeliveryType() == 2) {
            // 外送收取配送费（可根据距离动态计算）
            deliveryFee = new BigDecimal("300"); // 固定3元配送费（300分）
        }
        orders.setDeliveryFee(deliveryFee);
        
        // 处理优惠券
        BigDecimal couponAmount = BigDecimal.ZERO;
        if (orders.getUserCouponId() != null) {
            UserCoupon userCoupon = userCouponService.getById(orders.getUserCouponId());
            if (userCoupon != null && userCoupon.getStatus() == 0) {
                // 验证优惠券是否过期
                if (userCoupon.getExpireTime().isAfter(LocalDateTime.now())) {
                    Coupon coupon = couponService.getById(userCoupon.getCouponId());
                    if (coupon != null) {
                        // 验证订单金额是否满足优惠券使用条件
                        if (dishAmount.compareTo(coupon.getMinAmount()) >= 0) {
                            couponAmount = coupon.getAmount();
                        } else {
                            throw new CustomException("订单金额不满足优惠券使用条件");
                        }
                    }
                } else {
                    throw new CustomException("优惠券已过期");
                }
            } else {
                throw new CustomException("优惠券无效或已使用");
            }
        }
        orders.setCouponAmount(couponAmount);
        
        // 计算最终总金额 = 菜品金额 + 配送费 - 优惠券优惠
        BigDecimal totalAmount = dishAmount.add(deliveryFee).subtract(couponAmount);
        // 确保总金额不为负数
        if (totalAmount.compareTo(BigDecimal.ZERO) < 0) {
            totalAmount = BigDecimal.ZERO;
        }
        
        orders.setId(orderId);
        orders.setOrderTime(LocalDateTime.now());
        // 注意：checkout_time在支付成功后才设置，提交订单时不设置
        // orders.setCheckoutTime(LocalDateTime.now());
        
        // 订单提交后状态为待付款(1)，支付成功后才变为待接单(2)或制作中(3)
        orders.setStatus(1); // 1-待付款
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
        
        // 更新优惠券状态为已使用
        if (orders.getUserCouponId() != null) {
            UserCoupon userCoupon = userCouponService.getById(orders.getUserCouponId());
            if (userCoupon != null) {
                userCoupon.setStatus(1); // 1-已使用
                userCoupon.setUsedTime(LocalDateTime.now());
                userCoupon.setOrderId(orderId);
                userCouponService.updateById(userCoupon);
            }
        }

        //清空购物车数据
        shoppingCartService.remove(wrapper);
        
        // 订单提交成功，状态为待付款，WebSocket通知在支付成功后发送
        log.info("订单{}创建成功，状态：待付款，总金额：{}元", orderId, totalAmount);
        log.info("等待用户支付...");
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