package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.Message;
import com.java_project.reggie.mapper.MessageMapper;
import com.java_project.reggie.service.MessageService;
import org.springframework.stereotype.Service;

/**
 * 消息ServiceImpl
 */
@Service
public class MessageServiceImpl extends ServiceImpl<MessageMapper, Message> implements MessageService {
}

