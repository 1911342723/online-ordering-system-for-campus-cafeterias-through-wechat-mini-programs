package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.UserService;
import com.java_project.reggie.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

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
        
        userService.updateById(user);
        
        log.info("用户{}更新信息", userId);
        
        return R.success(user);
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
}
