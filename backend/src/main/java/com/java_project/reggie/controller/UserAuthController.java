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

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * 用户认证Controller
 */
@Slf4j
@RestController
@RequestMapping("/userAuth")
public class UserAuthController {

    @Autowired
    private UserService userService;

    /**
     * 提交教师认证申请
     */
    @PostMapping("/teacher/apply")
    public R<String> applyTeacherVerification(@RequestBody Map<String, String> params) {
        Long userId = BaseContext.getThreadLocal();
        log.info("用户{}提交教师认证申请", userId);

        String realName = params.get("realName");
        String idCard = params.get("idCard");

        if (realName == null || idCard == null) {
            return R.error("请填写真实姓名和身份证号");
        }

        User user = userService.getById(userId);
        if (user == null) {
            return R.error("用户不存在");
        }

        if (user.getTeacherVerified() != null && user.getTeacherVerified() == 2) {
            return R.error("您已通过教师认证");
        }

        user.setRealName(realName);
        user.setIdNumber(idCard);
        user.setTeacherVerified(1); // 待审核
        userService.updateById(user);

        return R.success("认证申请已提交，请等待审核");
    }

    /**
     * 审核教师认证（管理员）
     */
    @PutMapping("/teacher/verify/{userId}")
    public R<String> verifyTeacher(
            @PathVariable Long userId,
            @RequestParam Boolean approved,
            @RequestParam(required = false) String reason) {
        
        log.info("审核教师认证: userId={}, approved={}", userId, approved);

        User user = userService.getById(userId);
        if (user == null) {
            return R.error("用户不存在");
        }

        if (approved) {
            user.setUserType(2); // 设置为教师
            user.setTeacherVerified(2); // 已认证
            userService.updateById(user);
            return R.success("审核通过");
        } else {
            user.setTeacherVerified(3); // 已拒绝
            userService.updateById(user);
            return R.success("已拒绝认证" + (reason != null ? "：" + reason : ""));
        }
    }

    /**
     * 查询教师认证状态
     */
    @GetMapping("/teacher/status")
    public R<Map<String, Object>> getTeacherStatus() {
        Long userId = BaseContext.getThreadLocal();
        User user = userService.getById(userId);

        Map<String, Object> result = new HashMap<>();
        result.put("userType", user.getUserType());
        result.put("teacherVerified", user.getTeacherVerified());
        result.put("realName", user.getRealName());

        return R.success(result);
    }

    /**
     * 快捷教师登录（测试用）
     */
    @PostMapping("/teacher/quickLogin")
    public R<Map<String, Object>> quickTeacherLogin(@RequestBody Map<String, String> request) {
        String phone = request.get("phone");
        log.info("快捷教师登录: phone={}", phone);

        // 查找或创建教师账号
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getPhone, phone);
        User user = userService.getOne(queryWrapper);

        if (user == null) {
            // 创建新的教师账号
            user = new User();
            user.setPhone(phone);
            user.setName("教师-" + phone);
            user.setStatus(1);
            user.setUserType(2); // 教师
            user.setTeacherVerified(2); // 已认证
            user.setBalance(BigDecimal.ZERO);
            user.setCouponCount(0);
            userService.save(user);
            log.info("创建新教师账号: userId={}", user.getId());
        } else {
            // 更新为教师权限
            user.setUserType(2);
            user.setTeacherVerified(2);
            userService.updateById(user);
            log.info("更新用户{}为教师权限", user.getId());
        }

        // 生成JWT Token
            String token = JwtUtil.generateToken(user.getId(), phone);

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("user", user);

        return R.success(result);
    }

    /**
     * 快捷学生登录（测试用）
     */
    @PostMapping("/student/quickLogin")
    public R<Map<String, Object>> quickStudentLogin(@RequestBody Map<String, String> request) {
        String phone = request.get("phone");
        log.info("快捷学生登录: phone={}", phone);

        // 查找或创建学生账号
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getPhone, phone);
        User user = userService.getOne(queryWrapper);

        if (user == null) {
            // 创建新的学生账号
            user = new User();
            user.setPhone(phone);
            user.setName("学生-" + phone);
            user.setStatus(1);
            user.setUserType(1); // 学生
            user.setTeacherVerified(0); // 未认证
            user.setBalance(BigDecimal.ZERO);
            user.setCouponCount(0);
            userService.save(user);
            log.info("创建新学生账号: userId={}", user.getId());
        }

        // 生成JWT Token
            String token = JwtUtil.generateToken(user.getId(), phone);

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("user", user);

        return R.success(result);
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/current")
    public R<User> getCurrentUser() {
        Long userId = BaseContext.getThreadLocal();
        User user = userService.getById(userId);
        return R.success(user);
    }
}

