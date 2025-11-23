package com.java_project.reggie.filter;

import com.alibaba.fastjson.JSON;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.StringUtils;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * JWT认证过滤器
 * 用于验证JWT Token并设置用户信息到ThreadLocal
 */
@Slf4j
@WebFilter(filterName = "jwtAuthenticationFilter", urlPatterns = "/*")
public class JwtAuthenticationFilter implements Filter {
    
    //路径匹配器，支持通配符
    public static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();
    
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) 
            throws IOException, ServletException {
        
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;
        
        //设置响应编码
        response.setCharacterEncoding("utf-8");
        
        //1. 获取本次请求的URI
        String requestURI = request.getRequestURI();
        log.info("拦截到请求：{}", requestURI);
        
        //定义不需要处理的请求路径（白名单）
        String[] urls = new String[]{
                "/employee/login",      // 员工登录
                "/employee/logout",     // 员工登出
                "/user/login",          // 用户登录
                "/user/sendMsg",        // 发送验证码
                "/userAuth/**",         // 用户认证接口（快捷登录等）
                "/common/**",           // 静态资源
                "/backend/**",          // 后台静态资源
                "/front/**",            // 前端静态资源
                "/canteen/**",          // 餐厅接口
                "/category/**",         // 分类接口
                "/dish/**",             // 菜品接口
                "/ai/**",               // AI接口
                "/feedback/**",         // 反馈接口
                "/coupon/available",    // 可领取的优惠券列表（无需登录）
                "/announcement/**",     // 公告接口
                "/recommendation/**"    // 推荐接口
        };
        
        //2. 判断本次请求是否需要处理
        boolean check = check(urls, requestURI);
        
        //3. 如果不需要处理，则直接放行
        if (check) {
            log.info("本次请求{}不需要处理", requestURI);
            filterChain.doFilter(request, response);
            return;
        }
        
        //4. 尝试从请求头中获取Token
        String token = request.getHeader("Authorization");
        if (token != null && !token.trim().isEmpty() && token.startsWith("Bearer ")) {
            token = token.substring(7); // 移除 "Bearer " 前缀
        }
        
        //5. 验证Token
        if (token != null && !token.trim().isEmpty() && JwtUtil.validateToken(token)) {
            //Token有效，获取用户ID
            Long userId = JwtUtil.getUserId(token);
            if (userId != null) {
                log.info("JWT认证成功，用户ID：{}", userId);
                //将用户ID存入ThreadLocal，供后续使用
                BaseContext.setThreadLocal(userId);
                filterChain.doFilter(request, response);
                return;
            }
        }
        
        //6. 兼容Session方式的认证（向后兼容）
        if (request.getSession().getAttribute("employee") != null) {
            Long empId = (Long) request.getSession().getAttribute("employee");
            BaseContext.setThreadLocal(empId);
            log.info("Session认证成功（员工），ID：{}", empId);
            filterChain.doFilter(request, response);
            return;
        } else if (request.getSession().getAttribute("user") != null) {
            Long userId = (Long) request.getSession().getAttribute("user");
            BaseContext.setThreadLocal(userId);
            log.info("Session认证成功（用户），ID：{}", userId);
            filterChain.doFilter(request, response);
            return;
        }
        
        //7. 如果既没有有效Token也没有Session，返回未登录状态
        log.info("用户未登录或Token无效");
        response.getWriter().write(JSON.toJSONString(R.error("NOTLOGIN")));
    }
    
    /**
     * 路径匹配检查
     * @param urls 白名单路径数组
     * @param requestURI 当前请求路径
     * @return 是否在白名单中
     */
    public boolean check(String[] urls, String requestURI) {
        for (String url : urls) {
            boolean match = PATH_MATCHER.match(url, requestURI);
            if (match) {
                return true;
            }
        }
        return false;
    }
}

