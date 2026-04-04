package com.java_project.reggie.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.java_project.reggie.common.BaseContext;
import com.java_project.reggie.common.R;
import com.java_project.reggie.entity.*;
import com.java_project.reggie.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 社区笔记Controller
 */
@Slf4j
@RestController
@RequestMapping("/note")
public class NoteController {

    @Autowired
    private NoteService noteService;
    
    @Autowired
    private NoteCommentService noteCommentService;
    
    @Autowired
    private NoteLikeService noteLikeService;
    
    @Autowired
    private NoteCollectService noteCollectService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private MerchantService merchantService;

    /**
     * 获取笔记列表（分页）
     */
    @GetMapping("/list")
    public R<Page<Note>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String tag) {
        
        log.info("获取笔记列表: page={}, pageSize={}, keyword={}, tag={}", page, pageSize, keyword, tag);
        
        Page<Note> pageInfo = new Page<>(page, pageSize);
        
        LambdaQueryWrapper<Note> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Note::getStatus, 1); // 只查已发布的
        
        // 关键词搜索
        if (StringUtils.hasText(keyword)) {
            queryWrapper.and(w -> 
                w.like(Note::getTitle, keyword)
                 .or()
                 .like(Note::getContent, keyword)
            );
        }
        
        // 标签筛选
        if (StringUtils.hasText(tag)) {
            queryWrapper.like(Note::getTags, tag);
        }
        
        // 排序：置顶优先，然后按创建时间倒序
        queryWrapper.orderByDesc(Note::getIsTop)
                    .orderByDesc(Note::getCreateTime);
        
        noteService.page(pageInfo, queryWrapper);
        
        // 填充用户信息和其他数据
        Long currentUserId = BaseContext.getThreadLocal();
        for (Note note : pageInfo.getRecords()) {
            fillNoteInfo(note, currentUserId);
        }
        
        return R.success(pageInfo);
    }

    /**
     * 获取笔记详情
     */
    @GetMapping("/{id}")
    public R<Note> getById(@PathVariable Long id) {
        log.info("获取笔记详情: id={}", id);
        
        Note note = noteService.getById(id);
        
        if (note == null || note.getStatus() != 1) {
            return R.error("笔记不存在或已删除");
        }
        
        // 增加浏览量
        note.setViewCount(note.getViewCount() + 1);
        noteService.updateById(note);
        
        // 填充详细信息
        Long currentUserId = BaseContext.getThreadLocal();
        fillNoteInfo(note, currentUserId);
        
        // 加载评论列表
        LambdaQueryWrapper<NoteComment> commentWrapper = new LambdaQueryWrapper<>();
        commentWrapper.eq(NoteComment::getNoteId, id);
        commentWrapper.eq(NoteComment::getStatus, 1);
        commentWrapper.eq(NoteComment::getParentId, 0L); // 只查一级评论
        commentWrapper.orderByDesc(NoteComment::getCreateTime);
        
        List<NoteComment> comments = noteCommentService.list(commentWrapper);
        
        // 填充评论用户信息
        for (NoteComment comment : comments) {
            fillCommentInfo(comment, currentUserId);
            
            // 加载子评论（回复）
            LambdaQueryWrapper<NoteComment> replyWrapper = new LambdaQueryWrapper<>();
            replyWrapper.eq(NoteComment::getParentId, comment.getId());
            replyWrapper.eq(NoteComment::getStatus, 1);
            replyWrapper.orderByAsc(NoteComment::getCreateTime);
            
            List<NoteComment> replies = noteCommentService.list(replyWrapper);
            for (NoteComment reply : replies) {
                fillCommentInfo(reply, currentUserId);
            }
            comment.setReplies(replies);
        }
        
        note.setComments(comments);
        
        return R.success(note);
    }

    /**
     * 发布笔记
     */
    @PostMapping
    public R<String> publish(@RequestBody Note note) {
        log.info("发布笔记: {}", note);
        
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        note.setUserId(userId);
        note.setStatus(1); // 直接发布
        note.setLikeCount(0);
        note.setCollectCount(0);
        note.setCommentCount(0);
        note.setShareCount(0);
        note.setViewCount(0);
        note.setIsTop(0);
        note.setIsFeatured(0);
        
        // 处理图片列表
        if (note.getImageList() != null && !note.getImageList().isEmpty()) {
            note.setImages(String.join(",", note.getImageList()));
            note.setCoverImage(note.getImageList().get(0));
        }
        
        // 处理标签列表
        if (note.getTagList() != null && !note.getTagList().isEmpty()) {
            note.setTags(String.join(",", note.getTagList()));
        }
        
        boolean saved = noteService.save(note);
        
        if (saved) {
            // 任务奖励：发布帖子 +20经验，发帖数+1
            rewardUser(userId, 20, true, false, false);

            // 更新商家的好评/差评计数（用于红黑榜）
            if (note.getMerchantId() != null && StringUtils.hasText(note.getRatingType())) {
                updateMerchantRatingCount(note.getMerchantId(), note.getRatingType());
            }
            return R.success("发布成功");
        }
        
        return R.error("发布失败");
    }
    
    /**
     * 更新商家的好评/差评计数
     */
    private void updateMerchantRatingCount(Long merchantId, String ratingType) {
        Merchant merchant = merchantService.getById(merchantId);
        if (merchant != null) {
            if ("positive".equals(ratingType)) {
                // 好评 +1
                Integer positiveCount = merchant.getPositiveCount();
                merchant.setPositiveCount(positiveCount == null ? 1 : positiveCount + 1);
            } else if ("negative".equals(ratingType)) {
                // 差评 +1
                Integer negativeCount = merchant.getNegativeCount();
                merchant.setNegativeCount(negativeCount == null ? 1 : negativeCount + 1);
            }
            merchantService.updateById(merchant);
            log.info("更新商家评价计数: merchantId={}, ratingType={}", merchantId, ratingType);
        }
    }

    /**
     * 点赞/取消点赞
     */
    @PostMapping("/like/{noteId}")
    public R<Boolean> toggleLike(@PathVariable Long noteId) {
        log.info("点赞/取消点赞: noteId={}", noteId);
        
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        // 检查是否已点赞
        LambdaQueryWrapper<NoteLike> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(NoteLike::getNoteId, noteId);
        queryWrapper.eq(NoteLike::getUserId, userId);
        
        NoteLike existing = noteLikeService.getOne(queryWrapper);
        
        Note note = noteService.getById(noteId);
        if (note == null) {
            return R.error("笔记不存在");
        }
        
        boolean isLiked;
        if (existing != null) {
            // 取消点赞
            noteLikeService.removeById(existing.getId());
            note.setLikeCount(Math.max(0, note.getLikeCount() - 1));
            // 回滚被点赞计数与经验，防止反复点赞刷经验
            if (note.getUserId() != null && !note.getUserId().equals(userId)) {
                rewardUser(note.getUserId(), -2, false, false, true);
            }
            isLiked = false;
        } else {
            // 点赞
            NoteLike like = new NoteLike();
            like.setNoteId(noteId);
            like.setUserId(userId);
            noteLikeService.save(like);
            note.setLikeCount(note.getLikeCount() + 1);
            // 任务奖励：被点赞 +2经验，获赞数+1
            if (note.getUserId() != null && !note.getUserId().equals(userId)) {
                rewardUser(note.getUserId(), 2, false, false, true);
            }
            isLiked = true;
        }
        
        noteService.updateById(note);
        
        return R.success(isLiked);
    }

    /**
     * 收藏/取消收藏
     */
    @PostMapping("/collect/{noteId}")
    public R<Boolean> toggleCollect(@PathVariable Long noteId) {
        log.info("收藏/取消收藏: noteId={}", noteId);
        
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        // 检查是否已收藏
        LambdaQueryWrapper<NoteCollect> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(NoteCollect::getNoteId, noteId);
        queryWrapper.eq(NoteCollect::getUserId, userId);
        
        NoteCollect existing = noteCollectService.getOne(queryWrapper);
        
        Note note = noteService.getById(noteId);
        if (note == null) {
            return R.error("笔记不存在");
        }
        
        boolean isCollected;
        if (existing != null) {
            // 取消收藏
            noteCollectService.removeById(existing.getId());
            note.setCollectCount(Math.max(0, note.getCollectCount() - 1));
            // 回滚被收藏计数与经验，防止反复收藏刷经验
            if (note.getUserId() != null && !note.getUserId().equals(userId)) {
                rewardUser(note.getUserId(), -3, false, true, false);
            }
            isCollected = false;
        } else {
            // 收藏
            NoteCollect collect = new NoteCollect();
            collect.setNoteId(noteId);
            collect.setUserId(userId);
            noteCollectService.save(collect);
            note.setCollectCount(note.getCollectCount() + 1);
            // 任务奖励：被收藏 +3经验，收藏数+1
            if (note.getUserId() != null && !note.getUserId().equals(userId)) {
                rewardUser(note.getUserId(), 3, false, true, false);
            }
            isCollected = true;
        }
        
        noteService.updateById(note);
        
        return R.success(isCollected);
    }

    /**
     * 转发（增加转发数）
     */
    @PostMapping("/share/{noteId}")
    public R<Integer> share(@PathVariable Long noteId) {
        log.info("转发笔记: noteId={}", noteId);
        
        Note note = noteService.getById(noteId);
        if (note == null) {
            return R.error("笔记不存在");
        }
        
        note.setShareCount(note.getShareCount() + 1);
        noteService.updateById(note);
        
        return R.success(note.getShareCount());
    }

    /**
     * 发表评论
     */
    @PostMapping("/comment")
    public R<NoteComment> addComment(@RequestBody NoteComment comment) {
        log.info("发表评论: {}", comment);
        
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        comment.setUserId(userId);
        comment.setLikeCount(0);
        comment.setStatus(1);
        
        if (comment.getParentId() == null) {
            comment.setParentId(0L);
        }
        
        boolean saved = noteCommentService.save(comment);
        
        if (saved) {
            // 任务奖励：评论帖子 +5经验
            rewardUser(userId, 5, false, false, false);

            // 更新笔记评论数
            Note note = noteService.getById(comment.getNoteId());
            if (note != null) {
                note.setCommentCount(note.getCommentCount() + 1);
                noteService.updateById(note);
            }
            
            // 填充用户信息
            fillCommentInfo(comment, userId);
            
            return R.success(comment);
        }
        
        return R.error("评论失败");
    }

    /**
     * 删除评论
     */
    @DeleteMapping("/comment/{commentId}")
    public R<String> deleteComment(@PathVariable Long commentId) {
        log.info("删除评论: commentId={}", commentId);
        
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        NoteComment comment = noteCommentService.getById(commentId);
        if (comment == null) {
            return R.error("评论不存在");
        }
        
        // 只能删除自己的评论
        if (!comment.getUserId().equals(userId)) {
            return R.error("无权删除此评论");
        }
        
        comment.setStatus(0); // 软删除
        noteCommentService.updateById(comment);

        // 回滚评论经验，防止通过发评论/删评论刷经验
        rewardUser(userId, -5, false, false, false);
        
        // 更新笔记评论数
        Note note = noteService.getById(comment.getNoteId());
        if (note != null) {
            note.setCommentCount(Math.max(0, note.getCommentCount() - 1));
            noteService.updateById(note);
        }
        
        return R.success("删除成功");
    }

    /**
     * 评论点赞
     */
    @PostMapping("/comment/like/{commentId}")
    public R<Integer> likeComment(@PathVariable Long commentId) {
        log.info("评论点赞: commentId={}", commentId);
        
        NoteComment comment = noteCommentService.getById(commentId);
        if (comment == null) {
            return R.error("评论不存在");
        }
        
        comment.setLikeCount(comment.getLikeCount() + 1);
        noteCommentService.updateById(comment);
        
        return R.success(comment.getLikeCount());
    }

    /**
     * 获取我的笔记
     */
    @GetMapping("/my")
    public R<List<Note>> getMyNotes() {
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        LambdaQueryWrapper<Note> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Note::getUserId, userId);
        queryWrapper.ne(Note::getStatus, 2); // 排除已删除
        queryWrapper.orderByDesc(Note::getCreateTime);
        
        List<Note> notes = noteService.list(queryWrapper);
        
        for (Note note : notes) {
            fillNoteInfo(note, userId);
        }
        
        return R.success(notes);
    }

    /**
     * 获取我收藏的笔记
     */
    @GetMapping("/my/collected")
    public R<List<Note>> getMyCollectedNotes() {
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        // 获取收藏记录
        LambdaQueryWrapper<NoteCollect> collectWrapper = new LambdaQueryWrapper<>();
        collectWrapper.eq(NoteCollect::getUserId, userId);
        collectWrapper.orderByDesc(NoteCollect::getCreateTime);
        
        List<NoteCollect> collects = noteCollectService.list(collectWrapper);
        
        if (collects.isEmpty()) {
            return R.success(new ArrayList<>());
        }
        
        // 获取笔记
        List<Long> noteIds = collects.stream()
                .map(NoteCollect::getNoteId)
                .collect(Collectors.toList());
        
        LambdaQueryWrapper<Note> noteWrapper = new LambdaQueryWrapper<>();
        noteWrapper.in(Note::getId, noteIds);
        noteWrapper.eq(Note::getStatus, 1);
        
        List<Note> notes = noteService.list(noteWrapper);
        
        for (Note note : notes) {
            fillNoteInfo(note, userId);
        }
        
        return R.success(notes);
    }

    /**
     * 删除笔记
     */
    @DeleteMapping("/{id}")
    public R<String> delete(@PathVariable Long id) {
        log.info("删除笔记: id={}", id);
        
        Long userId = BaseContext.getThreadLocal();
        if (userId == null) {
            return R.error("请先登录");
        }
        
        Note note = noteService.getById(id);
        if (note == null) {
            return R.error("笔记不存在");
        }
        
        // 只能删除自己的笔记
        if (!note.getUserId().equals(userId)) {
            return R.error("无权删除此笔记");
        }
        
        note.setStatus(2); // 软删除
        noteService.updateById(note);

        // 删除帖子时回滚发帖任务奖励
        rewardUser(userId, -20, true, false, false);
        
        return R.success("删除成功");
    }

    /**
     * 用户经验与统计字段奖励/回滚。
     */
    private void rewardUser(Long userId, int expDelta, boolean postDelta, boolean collectDelta, boolean likeDelta) {
        if (userId == null) {
            return;
        }

        User user = userService.getById(userId);
        if (user == null) {
            return;
        }

        int currentExp = user.getExp() == null ? 0 : user.getExp();
        user.setExp(Math.max(0, currentExp + expDelta));

        if (postDelta) {
            int postCount = user.getPostCount() == null ? 0 : user.getPostCount();
            user.setPostCount(Math.max(0, postCount + (expDelta >= 0 ? 1 : -1)));
        }
        if (collectDelta) {
            int collectCount = user.getCollectCount() == null ? 0 : user.getCollectCount();
            user.setCollectCount(Math.max(0, collectCount + (expDelta >= 0 ? 1 : -1)));
        }
        if (likeDelta) {
            int likeCount = user.getLikeCount() == null ? 0 : user.getLikeCount();
            user.setLikeCount(Math.max(0, likeCount + (expDelta >= 0 ? 1 : -1)));
        }

        userService.updateById(user);
    }

    // ========== 辅助方法 ==========

    /**
     * 填充笔记信息
     */
    private void fillNoteInfo(Note note, Long currentUserId) {
        // 填充用户信息
        if (note.getUserId() != null) {
            User user = userService.getById(note.getUserId());
            if (user != null) {
                note.setUserName(user.getName() != null ? user.getName() : "用户" + note.getUserId());
                note.setUserAvatar(user.getAvatar());
            }
        }
        
        // 解析标签
        if (StringUtils.hasText(note.getTags())) {
            note.setTagList(Arrays.asList(note.getTags().split(",")));
        } else {
            note.setTagList(new ArrayList<>());
        }
        
        // 解析图片
        if (StringUtils.hasText(note.getImages())) {
            note.setImageList(Arrays.asList(note.getImages().split(",")));
        } else {
            note.setImageList(new ArrayList<>());
        }
        
        // 检查当前用户是否点赞/收藏
        if (currentUserId != null) {
            LambdaQueryWrapper<NoteLike> likeWrapper = new LambdaQueryWrapper<>();
            likeWrapper.eq(NoteLike::getNoteId, note.getId());
            likeWrapper.eq(NoteLike::getUserId, currentUserId);
            note.setIsLiked(noteLikeService.count(likeWrapper) > 0);
            
            LambdaQueryWrapper<NoteCollect> collectWrapper = new LambdaQueryWrapper<>();
            collectWrapper.eq(NoteCollect::getNoteId, note.getId());
            collectWrapper.eq(NoteCollect::getUserId, currentUserId);
            note.setIsCollected(noteCollectService.count(collectWrapper) > 0);
        } else {
            note.setIsLiked(false);
            note.setIsCollected(false);
        }
    }

    /**
     * 填充评论信息
     */
    private void fillCommentInfo(NoteComment comment, Long currentUserId) {
        // 填充用户信息
        if (comment.getUserId() != null) {
            User user = userService.getById(comment.getUserId());
            if (user != null) {
                comment.setUserName(user.getName() != null ? user.getName() : "用户" + comment.getUserId());
                comment.setUserAvatar(user.getAvatar());
            }
        }
        
        // 填充被回复用户信息
        if (comment.getReplyUserId() != null && comment.getReplyUserId() > 0) {
            User replyUser = userService.getById(comment.getReplyUserId());
            if (replyUser != null) {
                comment.setReplyUserName(replyUser.getName() != null ? replyUser.getName() : "用户" + comment.getReplyUserId());
            }
        }
        
        comment.setIsLiked(false); // 简化处理
    }
}

