package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.OrderService;
import com.java_project.reggie.service.UserService;
import com.java_project.reggie.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private OrderService orderService;

    /**
     * 发送验证码
     */
    @PostMapping("/sendMsg")
    public R<String> sendMsg(@RequestBody Map<String, String> params, HttpSession session) {
        String phone = params.get("phone");

        if (phone == null || phone.isEmpty()) {
            return R.error("手机号不能为空");
        }

        // 生成验证码
        String code = String.valueOf((int)((Math.random() * 9 + 1) * 100000));

        log.info("验证码：{}", code);

        // 保存验证码到session
        session.setAttribute(phone, code);

        return R.success("验证码发送成功");
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public R<Map<String, Object>> login(@RequestBody Map<String, String> params, HttpSession session) {
        String phone = params.get("phone");
        String code = params.get("code");

        // 如果提供了验证码，则进行验证码校验
        if (code != null && !code.isEmpty()) {
            // 从session获取验证码
            String savedCode = (String) session.getAttribute(phone);

            // 验证码校验
            if (savedCode == null || !savedCode.equals(code)) {
                return R.error("验证码错误");
            }
        }
        // 如果没有提供验证码，跳过验证（开发模式）

        // 查询用户
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getPhone, phone);
        User user = userService.getOne(queryWrapper);

        // 如果是新用户，自动注册
        if (user == null) {
            user = new User();
            user.setPhone(phone);
            user.setName("用户" + phone.substring(phone.length() - 4));
            user.setStatus(1);
            user.setBalance(java.math.BigDecimal.ZERO);
            user.setCouponCount(0);
            userService.save(user);
        }

        // 生成JWT Token
            String token = JwtUtil.generateToken(user.getId(), user.getPhone());

        // 保存到session
        session.setAttribute("user", user.getId());

        // 返回用户信息和token
        Map<String, Object> result = new HashMap<>();
        result.put("user", user);
        result.put("token", token);

        log.info("用户{}登录成功", phone);

        return R.success(result);
    }

    /**
     * 获取用户信息
     */
    @GetMapping("/info")
    public R<User> info() {
        Long userId = BaseContext.getThreadLocal();
        User user = userService.getById(userId);

        if (user != null) {
            // 确保余额、优惠券数不为null
            if (user.getBalance() == null) user.setBalance(java.math.BigDecimal.ZERO);
            if (user.getCouponCount() == null) user.setCouponCount(0);

            return R.success(user);
        }

        return R.error("用户不存在");
    }

    /**
     * 更新用户信息
     */
    @PutMapping("/update")
    public R<User> update(@RequestBody User userParam) {
        Long userId = BaseContext.getThreadLocal();

        User user = userService.getById(userId);
        if (user == null) {
            return R.error("用户不存在");
        }

        // 只允许更新这些字段
        if (userParam.getName() != null && !userParam.getName().trim().isEmpty()) {
            user.setName(userParam.getName());
        }
        if (userParam.getSex() != null) {
            user.setSex(userParam.getSex());
        }
        if (userParam.getAvatar() != null) {
            user.setAvatar(userParam.getAvatar());
        }
        // 支持更新个性签名
        if (userParam.getSignature() != null) {
            user.setSignature(userParam.getSignature());
        }

        userService.updateById(user);

        // 返回更新后的用户信息（重新从数据库获取确保数据一致）
        User updatedUser = userService.getById(userId);

        log.info("用户{}更新信息成功", userId);

        return R.success(updatedUser);
    }

    /**
     * 更新用户昵称（兼容老接口）
     */
    @PutMapping("/updateNickname")
    public R<String> updateNickname(@RequestBody Map<String, String> params) {
        Long userId = BaseContext.getThreadLocal();
        String nickname = params.get("nickname");

        if (nickname == null || nickname.trim().isEmpty()) {
            return R.error("昵称不能为空");
        }

        User user = userService.getById(userId);
        if (user == null) {
            return R.error("用户不存在");
        }

        user.setName(nickname);
        userService.updateById(user);

        log.info("用户{}修改昵称为：{}", userId, nickname);

        return R.success("修改成功");
    }

    // ========================================
    // 以下为管理端新增接口
    // ========================================

    /**
     * 分页查询用户列表（管理后台）
     */
    @GetMapping("/page")
    public R<Page<User>> page(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String keyword) {

        log.info("分页查询用户: page={}, pageSize={}, keyword={}", page, pageSize, keyword);

        Page<User> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();

        // 按关键词搜索（手机号或昵称）
        if (!StringUtils.isEmpty(keyword)) {
            queryWrapper.like(User::getName, keyword)
                    .or()
                    .like(User::getPhone, keyword);
        }

        // 按创建时间倒序
        queryWrapper.orderByDesc(User::getCreateTime);

        userService.page(pageInfo, queryWrapper);
        return R.success(pageInfo);
    }

    /**
     * 根据ID获取用户详情（管理后台）
     */
    @GetMapping("/{id}")
    public R<User> getById(@PathVariable Long id) {
        User user = userService.getById(id);
        if (user == null) {
            return R.error("用户不存在");
        }
        return R.success(user);
    }

    /**
     * 冻结/解冻用户账号（管理后台）
     */
    @PutMapping("/status")
    public R<String> changeStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());

        log.info("修改用户状态: id={}, status={}", id, status);

        User user = userService.getById(id);
        if (user == null) {
            return R.error("用户不存在");
        }

        user.setStatus(status);
        userService.updateById(user);

        return R.success(status == 1 ? "用户已解冻" : "用户已冻结");
    }

    /**
     * 获取用户消费统计（管理后台）
     */
    @GetMapping("/{id}/stats")
    public R<Map<String, Object>> getUserStats(@PathVariable Long id) {
        User user = userService.getById(id);
        if (user == null) {
            return R.error("用户不存在");
        }

        // 统计用户订单数据
        LambdaQueryWrapper<Orders> orderQuery = new LambdaQueryWrapper<>();
        orderQuery.eq(Orders::getUserId, id);
        int totalOrders = orderService.count(orderQuery);

        // 统计已完成订单
        LambdaQueryWrapper<Orders> completedQuery = new LambdaQueryWrapper<>();
        completedQuery.eq(Orders::getUserId, id).eq(Orders::getStatus, 4);
        int completedOrders = orderService.count(completedQuery);

        // 统计消费总额 - 查询已完成订单
        List<Orders> completedOrderList = orderService.list(completedQuery);
        BigDecimal totalSpent = completedOrderList.stream()
                .map(Orders::getAmount)
                .filter(a -> a != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalOrders", totalOrders);
        stats.put("completedOrders", completedOrders);
        stats.put("totalSpent", totalSpent);
        stats.put("balance", user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO);
        stats.put("couponCount", user.getCouponCount() != null ? user.getCouponCount() : 0);

        return R.success(stats);
    }

    /**
     * 查看用户订单记录（管理后台）
     */
    @GetMapping("/{userId}/orders")
    public R<Page<Orders>> getUserOrders(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {

        Page<Orders> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<Orders> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Orders::getUserId, userId);
        queryWrapper.orderByDesc(Orders::getOrderTime);

        orderService.page(pageInfo, queryWrapper);
        return R.success(pageInfo);
    }
}
