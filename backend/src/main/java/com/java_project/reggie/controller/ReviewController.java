package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.OrderReview;
import com.java_project.reggie.entity.Orders;
import com.java_project.reggie.entity.Merchant;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.OrderReviewService;
import com.java_project.reggie.service.OrderService;
import com.java_project.reggie.service.MerchantService;
import com.java_project.reggie.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 评价功能Controller
 */
@Slf4j
@RestController
@RequestMapping("/review")
public class ReviewController {

    @Autowired
    private OrderReviewService reviewService;

    @Autowired
    private UserService userService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private MerchantService merchantService;

    /**
     * 提交订单评价
     */
    @PostMapping
    public R<String> addReview(@RequestBody OrderReview review) {
        Long userId = BaseContext.getThreadLocal();
        review.setUserId(userId);
        review.setStatus(1); // 正常状态

        log.info("用户{}提交订单{}评价", userId, review.getOrderId());

        // 检查是否已评价
        LambdaQueryWrapper<OrderReview> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(OrderReview::getOrderId, review.getOrderId());
        OrderReview existing = reviewService.getOne(queryWrapper);

        if (existing != null) {
            return R.error("该订单已评价");
        }

        reviewService.save(review);
        
        // 更新订单的评价状态
        Orders order = orderService.getById(review.getOrderId());
        if (order != null) {
            order.setReviewStatus(1);
            orderService.updateById(order);
        }
        
        // 更新商家评分
        if (review.getMerchantId() != null && review.getRating() != null) {
            updateMerchantRating(review.getMerchantId());
        }
        
        return R.success("评价成功");
    }
    
    /**
     * 更新商家平均评分
     */
    private void updateMerchantRating(Long merchantId) {
        try {
            // 查询该商家的所有评价
            LambdaQueryWrapper<OrderReview> query = new LambdaQueryWrapper<>();
            query.eq(OrderReview::getMerchantId, merchantId);
            query.eq(OrderReview::getStatus, 1);
            
            List<OrderReview> reviews = reviewService.list(query);
            
            if (!reviews.isEmpty()) {
                // 计算平均评分
                double avgRating = reviews.stream()
                    .mapToInt(OrderReview::getRating)
                    .average()
                    .orElse(5.0);
                
                // 更新商家表
                Merchant merchant = merchantService.getById(merchantId);
                if (merchant != null) {
                    merchant.setRating(new BigDecimal(avgRating).setScale(1, RoundingMode.HALF_UP));
                    merchant.setTotalReviews(reviews.size());
                    merchantService.updateById(merchant);
                }
            }
        } catch (Exception e) {
            log.error("更新商家评分失败", e);
        }
    }

    /**
     * 修改评价
     */
    @PutMapping
    public R<String> updateReview(@RequestBody OrderReview review) {
        Long userId = BaseContext.getThreadLocal();
        log.info("用户{}修改评价: {}", userId, review.getId());

        // 验证是否是本人的评价
        OrderReview existing = reviewService.getById(review.getId());
        if (existing == null || !existing.getUserId().equals(userId)) {
            return R.error("无权修改此评价");
        }

        reviewService.updateById(review);
        return R.success("修改成功");
    }

    /**
     * 删除评价（软删除）
     */
    @DeleteMapping("/{id}")
    public R<String> deleteReview(@PathVariable Long id) {
        Long userId = BaseContext.getThreadLocal();
        log.info("用户{}删除评价: {}", userId, id);

        OrderReview review = reviewService.getById(id);
        if (review == null || !review.getUserId().equals(userId)) {
            return R.error("无权删除此评价");
        }

        review.setStatus(0); // 软删除
        reviewService.updateById(review);
        return R.success("删除成功");
    }

    /**
     * 查询订单的评价
     */
    @GetMapping("/order/{orderId}")
    public R<OrderReview> getReviewByOrder(@PathVariable Long orderId) {
        log.info("查询订单{}的评价", orderId);

        LambdaQueryWrapper<OrderReview> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(OrderReview::getOrderId, orderId);
        queryWrapper.eq(OrderReview::getStatus, 1);

        OrderReview review = reviewService.getOne(queryWrapper);
        
        if (review != null && review.getIsAnonymous() == 0) {
            // 填充用户信息（非匿名评价）
            User user = userService.getById(review.getUserId());
            if (user != null) {
                review.setUserName(user.getName());
                review.setUserAvatar(user.getAvatar());
            }
        }

        return R.success(review);
    }

    /**
     * 分页查询商家的评价列表
     */
    @GetMapping("/merchant/{merchantId}/page")
    public R<Page<OrderReview>> getMerchantReviews(
            @PathVariable Long merchantId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        
        log.info("分页查询商家{}的评价, page={}, pageSize={}", merchantId, page, pageSize);

        Page<OrderReview> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<OrderReview> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(OrderReview::getMerchantId, merchantId);
        queryWrapper.eq(OrderReview::getStatus, 1);
        queryWrapper.orderByDesc(OrderReview::getCreateTime);

        reviewService.page(pageInfo, queryWrapper);

        // 填充用户信息
        pageInfo.getRecords().forEach(review -> {
            if (review.getIsAnonymous() == 0) {
                User user = userService.getById(review.getUserId());
                if (user != null) {
                    review.setUserName(user.getName());
                    review.setUserAvatar(user.getAvatar());
                }
            } else {
                review.setUserName("匿名用户");
            }
        });

        return R.success(pageInfo);
    }

    /**
     * 查询用户的评价列表
     */
    @GetMapping("/my/list")
    public R<List<OrderReview>> getMyReviews() {
        Long userId = BaseContext.getThreadLocal();
        log.info("查询用户{}的评价列表", userId);

        LambdaQueryWrapper<OrderReview> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(OrderReview::getUserId, userId);
        queryWrapper.eq(OrderReview::getStatus, 1);
        queryWrapper.orderByDesc(OrderReview::getCreateTime);

        List<OrderReview> reviews = reviewService.list(queryWrapper);
        return R.success(reviews);
    }

    /**
     * 商家回复评价
     */
    @PostMapping("/reply")
    public R<String> replyReview(@RequestBody Map<String, Object> params) {
        Long reviewId = Long.parseLong(params.get("reviewId").toString());
        String reply = params.get("reply").toString();
        
        log.info("商家回复评价：reviewId={}, reply={}", reviewId, reply);
        
        OrderReview review = reviewService.getById(reviewId);
        if (review == null) {
            return R.error("评价不存在");
        }
        
        review.setMerchantReply(reply);
        review.setMerchantReplyTime(java.time.LocalDateTime.now());
        reviewService.updateById(review);
        
        return R.success("回复成功");
    }
    
    /**
     * 获取商家评价列表（分页）
     */
    @GetMapping("/merchant/page")
    public R<Page<OrderReview>> getMerchantReviews(
            @RequestParam Integer page,
            @RequestParam Integer pageSize,
            @RequestParam Long merchantId,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) Integer maxRating,
            @RequestParam(required = false) Integer hasReply) {
        
        log.info("查询商家{}的评价列表", merchantId);
        
        Page<OrderReview> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<OrderReview> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OrderReview::getMerchantId, merchantId);
        wrapper.eq(OrderReview::getStatus, 1); // 只查询显示的评价
        
        if (rating != null) {
            wrapper.eq(OrderReview::getRating, rating);
        }
        
        if (maxRating != null) {
            wrapper.le(OrderReview::getRating, maxRating);
        }
        
        if (hasReply != null) {
            if (hasReply == 0) {
                wrapper.isNull(OrderReview::getMerchantReply);
            } else {
                wrapper.isNotNull(OrderReview::getMerchantReply);
            }
        }
        
        wrapper.orderByDesc(OrderReview::getCreateTime);
        
        reviewService.page(pageInfo, wrapper);
        
        // 填充订单号和用户信息
        pageInfo.getRecords().forEach(review -> {
            // 填充订单号
            Orders order = orderService.getById(review.getOrderId());
            if (order != null) {
                review.setOrderNumber(order.getNumber());
            }
            
            // 填充用户信息
            if (review.getIsAnonymous() == 0) {
                User user = userService.getById(review.getUserId());
                if (user != null) {
                    review.setUserName(user.getName());
                }
            } else {
                review.setUserName("匿名用户");
            }
        });
        
        return R.success(pageInfo);
    }

    /**
     * 获取商家的评分统计
     */
    @GetMapping("/merchant/{merchantId}/stats")
    public R<Object> getMerchantRatingStats(@PathVariable Long merchantId) {
        log.info("查询商家{}的评分统计", merchantId);

        LambdaQueryWrapper<OrderReview> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(OrderReview::getMerchantId, merchantId);
        queryWrapper.eq(OrderReview::getStatus, 1);

        List<OrderReview> reviews = reviewService.list(queryWrapper);

        if (reviews.isEmpty()) {
            return R.success(null);
        }

        // 计算平均分
        double avgRating = reviews.stream()
                .mapToInt(OrderReview::getRating)
                .average()
                .orElse(0.0);

        double avgTaste = reviews.stream()
                .filter(r -> r.getTasteRating() != null)
                .mapToInt(OrderReview::getTasteRating)
                .average()
                .orElse(0.0);

        double avgService = reviews.stream()
                .filter(r -> r.getServiceRating() != null)
                .mapToInt(OrderReview::getServiceRating)
                .average()
                .orElse(0.0);

        double avgSpeed = reviews.stream()
                .filter(r -> r.getSpeedRating() != null)
                .mapToInt(OrderReview::getSpeedRating)
                .average()
                .orElse(0.0);

        // 统计各星级数量
        long star5 = reviews.stream().filter(r -> r.getRating() == 5).count();
        long star4 = reviews.stream().filter(r -> r.getRating() == 4).count();
        long star3 = reviews.stream().filter(r -> r.getRating() == 3).count();
        long star2 = reviews.stream().filter(r -> r.getRating() == 2).count();
        long star1 = reviews.stream().filter(r -> r.getRating() == 1).count();

        Map<String, Object> stats = new HashMap<>();
        stats.put("avgRating", Math.round(avgRating * 10) / 10.0);
        stats.put("avgTaste", Math.round(avgTaste * 10) / 10.0);
        stats.put("avgService", Math.round(avgService * 10) / 10.0);
        stats.put("avgSpeed", Math.round(avgSpeed * 10) / 10.0);
        stats.put("totalReviews", reviews.size());
        stats.put("star5Count", star5);
        stats.put("star4Count", star4);
        stats.put("star3Count", star3);
        stats.put("star2Count", star2);
        stats.put("star1Count", star1);
        
        return R.success(stats);
    }
}

