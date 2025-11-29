package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.Note;
import org.apache.ibatis.annotations.Mapper;

/**
 * 笔记Mapper
 */
@Mapper
public interface NoteMapper extends BaseMapper<Note> {
}

