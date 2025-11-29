package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.Note;
import com.java_project.reggie.mapper.NoteMapper;
import com.java_project.reggie.service.NoteService;
import org.springframework.stereotype.Service;

/**
 * 笔记Service实现类
 */
@Service
public class NoteServiceImpl extends ServiceImpl<NoteMapper, Note> implements NoteService {
}

