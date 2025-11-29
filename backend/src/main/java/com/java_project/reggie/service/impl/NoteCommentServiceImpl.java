package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.NoteComment;
import com.java_project.reggie.mapper.NoteCommentMapper;
import com.java_project.reggie.service.NoteCommentService;
import org.springframework.stereotype.Service;

/**
 * 笔记评论Service实现类
 */
@Service
public class NoteCommentServiceImpl extends ServiceImpl<NoteCommentMapper, NoteComment> implements NoteCommentService {
}

