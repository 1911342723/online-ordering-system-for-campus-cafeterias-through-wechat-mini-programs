package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.Message;
import com.java_project.reggie.entity.Note;
import com.java_project.reggie.entity.User;
import com.java_project.reggie.service.MessageService;
import com.java_project.reggie.service.NoteService;
import com.java_project.reggie.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    @GetMapping("/list")
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
