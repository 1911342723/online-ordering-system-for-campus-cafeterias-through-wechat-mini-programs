package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Message;
import com.java_project.reggie.entity.Merchant;
import com.java_project.reggie.entity.Note;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.MessageService;
import com.java_project.reggie.service.MerchantService;
import com.java_project.reggie.service.NoteService;
import com.java_project.reggie.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 消息Controller
 */
@Slf4j
@RestController
@RequestMapping("/message")
public class MessageController {

    @Autowired
    private MessageService messageService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private NoteService noteService;

    @Autowired
    private MerchantService merchantService;

    private Long resolveMerchantEmployeeId(Long merchantId) {
        if (merchantId == null) {
            return BaseContext.getThreadLocal();
        }
        Merchant merchant = merchantService.getById(merchantId);
        if (merchant == null) {
            return null;
        }
        return merchant.getEmployeeId();
    }

    private Set<Long> resolveMerchantActorIds(Long merchantId) {
        Set<Long> ids = new HashSet<>();
        if (merchantId != null) {
            ids.add(merchantId);
        }
        Long employeeId = resolveMerchantEmployeeId(merchantId);
        if (employeeId != null) {
            ids.add(employeeId);
        }
        return ids;
    }

    private LambdaQueryWrapper<Message> buildImScopeWrapper(Set<Long> merchantActorIds) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.in(Message::getUserId, merchantActorIds)
                .or()
                .in(Message::getFromUserId, merchantActorIds));
        // Only keep merchant chat messages; tolerate old rows with null type.
        wrapper.and(w -> w.eq(Message::getType, "merchant_chat").or().isNull(Message::getType));
        return wrapper;
    }

    /**
     * IM重构：会话列表
     */
    @GetMapping("/im/conversations")
    public R<List<Map<String, Object>>> imConversations(@RequestParam Long merchantId) {
        Long merchantEmployeeId = resolveMerchantEmployeeId(merchantId);
        if (merchantEmployeeId == null) {
            return R.error("商家信息不存在");
        }

        Set<Long> merchantActorIds = resolveMerchantActorIds(merchantId);
        LambdaQueryWrapper<Message> queryWrapper = buildImScopeWrapper(merchantActorIds);
        queryWrapper.orderByDesc(Message::getCreateTime);

        List<Message> rows = messageService.list(queryWrapper);
        if (rows == null || rows.isEmpty()) {
            return R.success(java.util.Collections.emptyList());
        }

        Set<Long> userIds = new HashSet<>();
        for (Message msg : rows) {
            Long peerId = merchantActorIds.contains(msg.getFromUserId()) ? msg.getUserId() : msg.getFromUserId();
            if (peerId != null && !merchantActorIds.contains(peerId)) {
                userIds.add(peerId);
            }
        }

        Map<Long, User> userMap = new HashMap<>();
        if (!userIds.isEmpty()) {
            userMap = userService.listByIds(userIds).stream()
                    .collect(Collectors.toMap(User::getId, u -> u, (a, b) -> a));
        }

        Map<Long, Map<String, Object>> convoMap = new HashMap<>();
        for (Message msg : rows) {
            Long peerId = merchantActorIds.contains(msg.getFromUserId()) ? msg.getUserId() : msg.getFromUserId();
            if (peerId == null || merchantActorIds.contains(peerId)) {
                continue;
            }

            Map<String, Object> item = convoMap.get(peerId);
            if (item == null) {
                User u = userMap.get(peerId);
                item = new HashMap<>();
                item.put("id", String.valueOf(peerId));
                item.put("userId", String.valueOf(peerId));
                item.put("userName", u != null ? u.getName() : ("用户" + peerId));
                item.put("lastMessage", msg.getContent());
                item.put("lastMessageTime", msg.getCreateTime());
                item.put("unreadCount", 0);
                convoMap.put(peerId, item);
            }

            if (merchantActorIds.contains(msg.getUserId())
                    && !merchantActorIds.contains(msg.getFromUserId())
                    && msg.getIsRead() != null
                    && msg.getIsRead() == 0) {
                item.put("unreadCount", ((Integer) item.get("unreadCount")) + 1);
            }
        }

        List<Map<String, Object>> result = convoMap.values().stream()
                .sorted((a, b) -> {
                    Object ta = a.get("lastMessageTime");
                    Object tb = b.get("lastMessageTime");
                    if (ta == null && tb == null) return 0;
                    if (ta == null) return 1;
                    if (tb == null) return -1;
                    return ((java.time.LocalDateTime) tb).compareTo((java.time.LocalDateTime) ta);
                })
                .collect(Collectors.toList());

        return R.success(result);
    }

    /**
     * IM重构：聊天消息
     */
    @GetMapping("/im/thread")
    public R<List<Map<String, Object>>> imThread(@RequestParam Long merchantId,
                                                 @RequestParam(required = false) Long userId) {
        Long currentUserId = BaseContext.getThreadLocal();
        if (currentUserId == null) {
            return R.error("请先登录");
        }

        Long merchantEmployeeId = resolveMerchantEmployeeId(merchantId);
        if (merchantEmployeeId == null) {
            return R.error("商家信息不存在");
        }

        Long peerUserId = currentUserId.equals(merchantEmployeeId) ? userId : currentUserId;
        if (peerUserId == null) {
            return R.error("userId不能为空");
        }

        Set<Long> merchantActorIds = resolveMerchantActorIds(merchantId);
        LambdaQueryWrapper<Message> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.and(w -> w
                .and(x -> x.in(Message::getFromUserId, merchantActorIds).eq(Message::getUserId, peerUserId))
                .or()
                .and(x -> x.eq(Message::getFromUserId, peerUserId).in(Message::getUserId, merchantActorIds))
        );
        queryWrapper.and(w -> w.eq(Message::getType, "merchant_chat").or().isNull(Message::getType));
        queryWrapper.orderByAsc(Message::getCreateTime);

        List<Message> list = messageService.list(queryWrapper);
        List<Map<String, Object>> result = list.stream().map(msg -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", String.valueOf(msg.getId()));
            item.put("content", msg.getContent());
            item.put("createTime", msg.getCreateTime());
            item.put("fromMerchant", merchantActorIds.contains(msg.getFromUserId()));
            return item;
        }).collect(Collectors.toList());

        return R.success(result);
    }

    /**
     * IM重构：发送消息
     */
    @PostMapping("/im/send")
    public R<String> imSend(@RequestBody Map<String, Object> body) {
        Object merchantIdObj = body.get("merchantId");
        Object userIdObj = body.get("userId");
        String content = body.get("content") == null ? null : String.valueOf(body.get("content")).trim();
        boolean fromMerchant = body.get("fromMerchant") != null
                && Boolean.parseBoolean(String.valueOf(body.get("fromMerchant")));

        Long currentUserId = BaseContext.getThreadLocal();
        if (currentUserId == null) {
            return R.error("请先登录");
        }
        if (merchantIdObj == null || !StringUtils.hasText(content)) {
            return R.error("参数不完整");
        }

        Long merchantId = Long.valueOf(String.valueOf(merchantIdObj));
        Long merchantEmployeeId = resolveMerchantEmployeeId(merchantId);
        if (merchantEmployeeId == null) {
            return R.error("商家信息不存在");
        }

        Long fromUserId;
        Long receiveUserId;
        if (fromMerchant) {
            if (!currentUserId.equals(merchantEmployeeId)) {
                return R.error("无权以商家身份发送消息");
            }
            if (userIdObj == null) {
                return R.error("userId不能为空");
            }
            fromUserId = merchantId;
            receiveUserId = Long.valueOf(String.valueOf(userIdObj));
        } else {
            fromUserId = currentUserId;
            receiveUserId = merchantId;
        }

        Message message = new Message();
        message.setUserId(receiveUserId);
        message.setFromUserId(fromUserId);
        message.setType(null);
        message.setContent(content);
        message.setIsRead(0);
        message.setCreateTime(java.time.LocalDateTime.now());
        
        try {
            boolean saved = messageService.save(message);
            if (!saved) {
                return R.error("数据库影响行数为0");
            }
            return R.success("发送成功");
        } catch (Exception e) {
            e.printStackTrace();
            return R.error("保存抛出异常：" + e.getMessage());
        }
    }

    /**
     * IM重构：标记会话已读
     */
    @PutMapping("/im/read")
    public R<String> imRead(@RequestBody Map<String, Object> body) {
        Object merchantIdObj = body.get("merchantId");
        Object userIdObj = body.get("userId");
        if (merchantIdObj == null) {
            return R.error("merchantId不能为空");
        }

        Long currentUserId = BaseContext.getThreadLocal();
        if (currentUserId == null) {
            return R.error("请先登录");
        }

        Long merchantId = Long.valueOf(String.valueOf(merchantIdObj));
        Long merchantEmployeeId = resolveMerchantEmployeeId(merchantId);
        if (merchantEmployeeId == null) {
            return R.error("商家信息不存在");
        }

        LambdaUpdateWrapper<Message> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Message::getIsRead, 0)
                .and(w -> w.eq(Message::getType, "merchant_chat").or().isNull(Message::getType));

        if (currentUserId.equals(merchantEmployeeId)) {
            // 商户读取用户的消息 (userId应该是在商户端，fromUserId是发消息的用户)
            updateWrapper.in(Message::getUserId, resolveMerchantActorIds(merchantId));
            if (userIdObj != null) {
                updateWrapper.eq(Message::getFromUserId, Long.valueOf(String.valueOf(userIdObj)));
            }
        } else {
            // 用户读取商户的消息
            updateWrapper.eq(Message::getUserId, currentUserId);
            updateWrapper.in(Message::getFromUserId, resolveMerchantActorIds(merchantId));
        }

        updateWrapper.set(Message::getIsRead, 1);
        messageService.update(updateWrapper);

        return R.success("已标记为已读");
    }


    /**
     * 获取未读消息数量
     */
    @GetMapping("/unread/count")
    public R<Integer> getUnreadCount() {
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.success(0);
        }
        
        LambdaQueryWrapper<Message> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Message::getUserId, userId);
        queryWrapper.eq(Message::getIsRead, 0);
        
        int count = messageService.count(queryWrapper);
        
        return R.success(count);
    }

    /**
     * 获取未读消息详细数量（按类型）
     */
    @GetMapping("/unread/detail")
    public R<Map<String, Integer>> getUnreadDetail() {
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            Map<String, Integer> result = new HashMap<>();
            result.put("total", 0);
            result.put("like", 0);
            result.put("comment", 0);
            result.put("system", 0);
            return R.success(result);
        }
        
        Map<String, Integer> result = new HashMap<>();
        
        // 总未读数
        LambdaQueryWrapper<Message> totalWrapper = new LambdaQueryWrapper<>();
        totalWrapper.eq(Message::getUserId, userId).eq(Message::getIsRead, 0);
        result.put("total", messageService.count(totalWrapper));
        
        // 点赞未读数
        LambdaQueryWrapper<Message> likeWrapper = new LambdaQueryWrapper<>();
        likeWrapper.eq(Message::getUserId, userId).eq(Message::getIsRead, 0).eq(Message::getType, "like");
        result.put("like", messageService.count(likeWrapper));
        
        // 评论未读数
        LambdaQueryWrapper<Message> commentWrapper = new LambdaQueryWrapper<>();
        commentWrapper.eq(Message::getUserId, userId).eq(Message::getIsRead, 0).eq(Message::getType, "comment");
        result.put("comment", messageService.count(commentWrapper));
        
        // 系统未读数
        LambdaQueryWrapper<Message> systemWrapper = new LambdaQueryWrapper<>();
        systemWrapper.eq(Message::getUserId, userId).eq(Message::getIsRead, 0).eq(Message::getType, "system");
        result.put("system", messageService.count(systemWrapper));
        
        return R.success(result);
    }

    /**
     * 获取消息列表
     */
    @GetMapping(value = "/list", params = {"!merchantId", "!userId"})
    public R<Page<Message>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String type) {
        
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        Page<Message> pageInfo = new Page<>(page, pageSize);
        
        LambdaQueryWrapper<Message> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Message::getUserId, userId);
        
        if (StringUtils.hasText(type)) {
            queryWrapper.eq(Message::getType, type);
        }
        
        queryWrapper.orderByDesc(Message::getCreateTime);
        
        messageService.page(pageInfo, queryWrapper);
        
        // 填充发送者信息和笔记信息
        for (Message message : pageInfo.getRecords()) {
            // 填充发送者信息
            if (message.getFromUserId() != null) {
                User fromUser = userService.getById(message.getFromUserId());
                if (fromUser != null) {
                    message.setFromUserName(fromUser.getName());
                    message.setFromUserAvatar(fromUser.getAvatar());
                }
            }
            
            // 填充笔记标题
            if (message.getNoteId() != null) {
                Note note = noteService.getById(message.getNoteId());
                if (note != null) {
                    message.setNoteTitle(note.getTitle());
                }
            }
        }
        
        return R.success(pageInfo);
    }

    /**
     * 标记单条消息为已读
     */
    @PostMapping("/read/{id}")
    public R<String> markAsRead(@PathVariable Long id) {
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        LambdaUpdateWrapper<Message> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Message::getId, id);
        updateWrapper.eq(Message::getUserId, userId);
        updateWrapper.set(Message::getIsRead, 1);
        
        messageService.update(updateWrapper);
        
        return R.success("已标记为已读");
    }

    /**
     * 标记所有消息为已读
     */
    @PostMapping("/read/all")
    public R<String> markAllAsRead() {
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        LambdaUpdateWrapper<Message> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Message::getUserId, userId);
        updateWrapper.eq(Message::getIsRead, 0);
        updateWrapper.set(Message::getIsRead, 1);
        
        messageService.update(updateWrapper);
        
        return R.success("已全部标记为已读");
    }
}
