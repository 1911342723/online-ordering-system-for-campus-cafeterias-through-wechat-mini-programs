package com.java_project.reggie.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.java_project.reggie.entity.NoteComment;
import org.apache.ibatis.annotations.Mapper;

/**
 * 笔记评论Mapper
 */
@Mapper
public interface NoteCommentMapper extends BaseMapper<NoteComment> {
}

