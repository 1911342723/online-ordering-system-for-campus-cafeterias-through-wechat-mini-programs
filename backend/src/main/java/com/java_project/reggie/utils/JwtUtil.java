package com.java_project.reggie.utils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT工具类 - 用于生成和解析Token
 */
@Slf4j
public class JwtUtil {
    
    // 密钥（建议在生产环境中使用配置文件）
    private static final String SECRET_KEY = "reggie_secret_key_for_jwt_token_generation_2024_very_long_secret";
    
    // Token过期时间（7天）
    private static final long EXPIRATION_TIME = 7 * 24 * 60 * 60 * 1000;
    
    // 生成密钥
    private static Key getSigningKey() {
        return Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
    }
    
    /**
     * 生成Token
     * @param userId 用户ID
     * @param phone 手机号
     * @return JWT Token
     */
    public static String generateToken(Long userId, String phone) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("phone", phone);
        claims.put("type", "user"); // 用户类型：user-普通用户, employee-员工
        
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(userId.toString())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    /**
     * 生成员工Token
     * @param employeeId 员工ID
     * @param username 用户名
     * @return JWT Token
     */
    public static String generateEmployeeToken(Long employeeId, String username) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("employeeId", employeeId);
        claims.put("username", username);
        claims.put("type", "employee");
        
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(employeeId.toString())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    /**
     * 解析Token
     * @param token JWT Token
     * @return Claims
     */
    public static Claims parseToken(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            log.error("Token解析失败: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * 验证Token是否有效
     * @param token JWT Token
     * @return 是否有效
     */
    public static boolean validateToken(String token) {
        try {
            Claims claims = parseToken(token);
            if (claims == null) {
                return false;
            }
            // 检查是否过期
            return claims.getExpiration().after(new Date());
        } catch (Exception e) {
            log.error("Token验证失败: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * 从Token中获取用户ID
     * @param token JWT Token
     * @return 用户ID
     */
    public static Long getUserId(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return null;
        }
        Object userId = claims.get("userId");
        if (userId != null) {
            return Long.valueOf(userId.toString());
        }
        Object employeeId = claims.get("employeeId");
        if (employeeId != null) {
            return Long.valueOf(employeeId.toString());
        }
        return null;
    }
    
    /**
     * 从Token中获取手机号
     * @param token JWT Token
     * @return 手机号
     */
    public static String getPhone(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return null;
        }
        return (String) claims.get("phone");
    }
    
    /**
     * 从Token中获取用户类型
     * @param token JWT Token
     * @return 用户类型
     */
    public static String getUserType(String token) {
        Claims claims = parseToken(token);
        if (claims == null) {
            return null;
        }
        return (String) claims.get("type");
    }
}

