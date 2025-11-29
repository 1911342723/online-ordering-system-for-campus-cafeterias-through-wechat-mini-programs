package com.java_project.reggie.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.java_project.reggie.entity.NoteCollect;
import com.java_project.reggie.mapper.NoteCollectMapper;
import com.java_project.reggie.service.NoteCollectService;
import org.springframework.stereotype.Service;

/**
 * 笔记收藏Service实现类
 */
@Service
public class NoteCollectServiceImpl extends ServiceImpl<NoteCollectMapper, NoteCollect> implements NoteCollectService {
}

