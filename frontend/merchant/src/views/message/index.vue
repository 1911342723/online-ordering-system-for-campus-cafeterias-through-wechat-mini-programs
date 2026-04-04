<template>
  <div class="message-center-container">
    <el-card class="chat-card" :body-style="{ padding: 0 }">
      <div class="chat-layout">
        <!-- Sidebar -->
        <div class="sidebar">
          <div class="sidebar-header">
            <h3>消息中心</h3>
            <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="total-unread" type="danger" />
          </div>
          <div class="conversation-list">
            <template v-if="conversations.length > 0">
              <div 
                v-for="conv in conversations" 
                :key="conv.id"
                class="conversation-item"
                :class="{ active: currentConversation?.id === conv.id }"
                @click="selectConversation(conv)"
              >
                <el-avatar :size="48" class="conv-avatar">
                  {{ conv.userName?.charAt(0) || '用' }}
                </el-avatar>
                <div class="conv-content">
                  <div class="conv-top">
                    <span class="conv-name">{{ conv.userName }}</span>
                    <span class="conv-time">{{ formatTimeShort(conv.lastMessageTime) }}</span>
                  </div>
                  <div class="conv-bottom">
                    <span class="conv-last-msg">{{ conv.lastMessage }}</span>
                    <el-badge :value="conv.unreadCount" :max="99" :hidden="!conv.unreadCount" class="conv-unread" />
                  </div>
                </div>
              </div>
            </template>
            <div v-else class="empty-conversations">
              <el-empty description="暂无消息" :image-size="80" />
            </div>
          </div>
        </div>

        <!-- Main Chat Area -->
        <div class="main-chat">
          <template v-if="currentConversation">
            <div class="chat-header">
              <div class="chat-title">{{ currentConversation.userName }}</div>
            </div>
            
            <div class="chat-messages" ref="messageListRef">
              <div class="messages-container">
                <template v-if="processedMessages.length > 0">
                  <div 
                    v-for="msg in processedMessages" 
                    :key="msg.id"
                    class="message-row"
                    :class="{ 'mine': msg.fromMerchant, 'theirs': !msg.fromMerchant }"
                  >
                    <div class="time-divider" v-if="msg.showTime">
                      <span>{{ formatTimeFull(msg.createTime) }}</span>
                    </div>
                    <div class="message-wrapper">
                      <el-avatar :size="40" class="msg-avatar">
                        {{ msg.fromMerchant ? '商' : (currentConversation.userName?.charAt(0) || '用') }}
                      </el-avatar>
                      <div class="msg-content-wrapper">
                        <div class="msg-bubble" :class="{ 'sending': msg.sending }">
                          {{ msg.content }}
                        </div>
                      </div>
                    </div>
                  </div>
                </template>
                <div v-else class="empty-messages">
                  <el-empty description="暂无历史消息，快打个招呼吧" :image-size="100" />
                </div>
              </div>
            </div>

            <div class="chat-input-area">
              <el-input
                v-model="inputMessage"
                type="textarea"
                :rows="4"
                placeholder="输入消息，按 Ctrl + Enter 发送..."
                resize="none"
                @keydown.ctrl.enter.prevent="handleSend"
                class="message-input"
              />
              <div class="input-toolbar">
                <span class="hint-text">Ctrl + Enter 快捷发送</span>
                <el-button type="primary" :disabled="!inputMessage.trim()" @click="handleSend" :loading="sending">
                  发送消息
                </el-button>
              </div>
            </div>
          </template>
          
          <div v-else class="empty-chat-state">
            <el-empty description="请从左侧选择任意会话开始聊天" />
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/api/request'
import { getMerchantByEmployeeId } from '@/api/merchant'

const conversations = ref([])
const currentConversation = ref(null)
const messages = ref([])
const inputMessage = ref('')
const sending = ref(false)
const messageListRef = ref(null)
const currentMerchantId = ref(null)
const unreadCount = ref(0)
let pollTimer = null

// 时间处理
const safeDate = (time) => {
  if (!time) return new Date()
  if (Array.isArray(time)) {
    const [y, m, d, h = 0, mm = 0, s = 0] = time
    return new Date(y, (m || 1) - 1, d || 1, h, mm, s)
  }
  if (typeof time === 'string' && time.includes(' ') && !time.includes('T')) {
    return new Date(time.replace(' ', 'T'))
  }
  return new Date(time)
}

const formatTimeShort = (time) => {
  if (!time) return ''
  const date = safeDate(time)
  const now = new Date()
  const diff = now - date

  if (diff < 60000) return '刚刚'
  if (date.toDateString() === now.toDateString()) {
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
  }
  return `${date.getMonth() + 1}月${date.getDate()}日`
}

const formatTimeFull = (time) => {
  if (!time) return ''
  const date = safeDate(time)
  const now = new Date()
  const timeStr = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
  if (date.toDateString() === now.toDateString()) {
    return timeStr
  }
  return `${date.getMonth() + 1}月${date.getDate()}日 ${timeStr}`
}

// 消息处理，组合时间显示和排序
const processedMessages = computed(() => {
  let lastTime = 0
  return [...messages.value].map(msg => {
    const msgTime = safeDate(msg.createTime).getTime()
    let showTime = false
    if (msgTime - lastTime > 5 * 60 * 1000) {
      showTime = true
      lastTime = msgTime
    }
    return { ...msg, showTime }
  })
})

const fetchConversations = async () => {
  if (!currentMerchantId.value) return
  try {
    const res = await request({
      url: '/message/im/conversations',
      method: 'get',
      params: { merchantId: currentMerchantId.value }
    })
    
    if (res.code === 1) {
      const rawList = Array.isArray(res.data) ? res.data : []
      conversations.value = rawList.map(conv => ({
        ...conv,
        id: String(conv.userId || conv.id),
        userId: String(conv.userId || conv.id),
        userName: conv.userName || `用户${conv.userId || conv.id}`,
        lastMessage: conv.lastMessage || '',
        lastMessageTime: conv.lastMessageTime || conv.createTime,
        unreadCount: Number(conv.unreadCount || 0)
      }))

      unreadCount.value = conversations.value.reduce((sum, conv) => sum + conv.unreadCount, 0)

      if (currentConversation.value) {
        const latest = conversations.value.find(c => c.id === currentConversation.value.id)
        if (latest) currentConversation.value = latest
      }
    }
  } catch (error) {
    console.error('获取会话失败:', error)
  }
}

const selectConversation = async (conv) => {
  if (currentConversation.value?.id === conv.id) return
  currentConversation.value = conv
  messages.value = [] // 立即清空，避免闪烁
  await fetchMessages(conv.id, true)
  
  if (conv.unreadCount > 0) {
    await markAsRead(conv.id)
  }
}

const fetchMessages = async (userId, shouldScroll = false) => {
  if (!userId) return
  try {
    const res = await request({
      url: '/message/im/thread',
      method: 'get',
      params: {
        merchantId: currentMerchantId.value,
        userId: String(userId)
      }
    })
    
    if (res.code === 1) {
      const rawList = Array.isArray(res.data) ? res.data : []
      const oldLen = messages.value.length
      
      messages.value = rawList.map(msg => ({
        ...msg,
        id: String(msg.id),
        fromMerchant: !!msg.fromMerchant,
        createTime: msg.createTime || msg.time,
        sending: false
      }))
      
      const newLen = messages.value.length
      
      // 只有在新增消息或初次加载时才强行滚动到底部，避免打扰用户往上翻阅
      if (shouldScroll || newLen > oldLen) {
        scrollToBottom()
      }
    }
  } catch (error) {
    console.error('加载消息失败:', error)
  }
}

const handleSend = async () => {
  const content = inputMessage.value.trim()
  if (!content || sending.value) return
  if (!currentConversation.value) return ElMessage.warning('请选择对话')
  
  // 乐观更新（Optimistic Update）
  const tempId = `local_${Date.now()}`
  messages.value.push({
    id: tempId,
    content: content,
    createTime: new Date().toISOString(),
    fromMerchant: true,
    sending: true
  })
  
  inputMessage.value = ''
  scrollToBottom()
  sending.value = true
  
  try {
    const res = await request({
      url: '/message/im/send',
      method: 'post',
      data: {
        merchantId: currentMerchantId.value,
        userId: currentConversation.value.id,
        content: content,
        fromMerchant: true
      }
    })
    
    if (res.code === 1) {
      await fetchMessages(currentConversation.value.id)
      await fetchConversations()
    } else {
      ElMessage.error(res.msg || '发送失败')
      // 回退
      messages.value = messages.value.filter(m => m.id !== tempId)
    }
  } catch (error) {
    ElMessage.error('发送请求失败')
    messages.value = messages.value.filter(m => m.id !== tempId)
  } finally {
    sending.value = false
  }
}

const markAsRead = async (userId) => {
  if (!userId) return
  try {
    await request({
      url: '/message/im/read',
      method: 'put',
      data: {
        merchantId: currentMerchantId.value,
        userId: String(userId)
      }
    })
    // 本地即时消除小红点
    const conv = conversations.value.find(c => c.id === userId)
    if (conv) conv.unreadCount = 0
    unreadCount.value = conversations.value.reduce((sum, c) => sum + c.unreadCount, 0)
  } catch (error) {
    console.error('标记已读失败', error)
  }
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messageListRef.value) {
      const el = messageListRef.value
      // setTimeout to ensure DOM render is fully flushed
      setTimeout(() => {
        el.scrollTop = el.scrollHeight
      }, 50)
    }
  })
}

let polling = false;

const startPolling = () => {
  pollTimer = setInterval(async () => {
    if (polling) return;
    polling = true;
    try {
      await fetchConversations()
      if (currentConversation.value) {
        await fetchMessages(currentConversation.value.id, false)
      }
    } finally {
      polling = false;
    }
  }, 3000)
}

onMounted(async () => {
  try {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    if (userInfo.id) {
      const res = await getMerchantByEmployeeId(userInfo.id)
      if (res.code === 1 && res.data) {
        currentMerchantId.value = res.data.id
        await fetchConversations()
        startPolling()
      }
    }
  } catch (error) {
    console.error('初始化失败:', error)
  }
})

onUnmounted(() => {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
})
</script>

<style scoped lang="scss">
.message-center-container {
  padding: 16px;
  height: calc(100vh - 120px);
  min-height: 500px;
  box-sizing: border-box;

  .chat-card {
    height: 100%;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);

    :deep(.el-card__body) {
      height: 100%;
    }
  }
}

.chat-layout {
  display: flex;
  height: 100%;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
}

/* Sidebar */
.sidebar {
  width: 320px;
  border-right: 1px solid #ebeef5;
  display: flex;
  flex-direction: column;
  background-color: #fafbfc;
  flex-shrink: 0;

  .sidebar-header {
    height: 64px;
    padding: 0 20px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid #ebeef5;
    background-color: #fff;
    
    h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: #303133;
    }
    
    .total-unread {
      margin-left: 8px;
    }
  }

  .conversation-list {
    flex: 1;
    overflow-y: auto;
    
    &::-webkit-scrollbar {
      width: 6px;
    }
    &::-webkit-scrollbar-thumb {
      background: #dcdee2;
      border-radius: 3px;
    }

    .empty-conversations {
      height: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .conversation-item {
      display: flex;
      padding: 16px 20px;
      cursor: pointer;
      transition: background-color 0.2s;
      border-bottom: 1px solid #f2f3f5;

      &:hover {
        background-color: #f2f6fc;
      }

      &.active {
        background-color: #e6f1fc;
        position: relative;
        
        &::before {
          content: '';
          position: absolute;
          left: 0;
          top: 0;
          bottom: 0;
          width: 4px;
          background-color: #409eff;
        }
      }

      .conv-avatar {
        background: linear-gradient(135deg, #1890ff, #36cfc9);
        color: #fff;
        font-weight: bold;
        flex-shrink: 0;
        margin-right: 12px;
      }

      .conv-content {
        flex: 1;
        min-width: 0;
        display: flex;
        flex-direction: column;
        justify-content: center;

        .conv-top {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 6px;

          .conv-name {
            font-size: 15px;
            font-weight: 500;
            color: #303133;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          .conv-time {
            font-size: 12px;
            color: #909399;
            flex-shrink: 0;
            margin-left: 8px;
          }
        }

        .conv-bottom {
          display: flex;
          justify-content: space-between;
          align-items: center;

          .conv-last-msg {
            font-size: 13px;
            color: #909399;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding-right: 12px;
          }
        }
      }
    }
  }
}

/* Main Chat Area */
.main-chat {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #fff;
  min-width: 0;

  .empty-chat-state {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #f5f7fa;
  }

  .chat-header {
    height: 64px;
    padding: 0 24px;
    border-bottom: 1px solid #ebeef5;
    display: flex;
    align-items: center;

    .chat-title {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
    }
  }

  .chat-messages {
    flex: 1;
    padding: 24px;
    overflow-y: auto;
    background-color: #f9fafc;

    &::-webkit-scrollbar {
      width: 6px;
    }
    &::-webkit-scrollbar-thumb {
      background: #dcdfe6;
      border-radius: 3px;
    }

    .messages-container {
      display: flex;
      flex-direction: column;
      
      .empty-messages {
        margin-top: 100px;
      }
    }

    .message-row {
      display: flex;
      flex-direction: column;
      margin-bottom: 30px;

      .time-divider {
        text-align: center;
        margin-bottom: 16px;
        
        span {
          display: inline-block;
          background-color: #ebedf0;
          color: #909399;
          font-size: 12px;
          padding: 4px 12px;
          border-radius: 12px;
        }
      }

      .message-wrapper {
        display: flex;
        max-width: 70%;
      }

      &.theirs .message-wrapper {
        align-self: flex-start;
        flex-direction: row;

        .msg-avatar {
          background-color: #c0c4cc;
          margin-right: 12px;
        }

        .msg-bubble {
          background-color: #fff;
          color: #303133;
          border: 1px solid #ebeef5;
          border-top-left-radius: 4px;
        }
      }

      &.mine .message-wrapper {
        align-self: flex-end;
        flex-direction: row-reverse;

        .msg-avatar {
          background-color: #409eff;
          margin-left: 12px;
        }

        .msg-bubble {
          background-color: #409eff;
          color: #fff;
          border-top-right-radius: 4px;
          box-shadow: 0 4px 12px rgba(64,158,255,0.2);
        }
        
        .msg-content-wrapper {
          align-items: flex-end;
        }
      }
      
      .msg-content-wrapper {
        display: flex;
        flex-direction: column;
      }

      .msg-bubble {
        padding: 12px 16px;
        border-radius: 12px;
        font-size: 14px;
        line-height: 1.6;
        word-break: break-word;
        transition: opacity 0.3s;
        
        &.sending {
          opacity: 0.6;
        }
      }
    }
  }

  .chat-input-area {
    height: auto;
    border-top: 1px solid #ebeef5;
    padding: 16px 24px;
    background-color: #fff;
    display: flex;
    flex-direction: column;

    :deep(.el-textarea__inner) {
      border: none;
      box-shadow: none;
      padding: 0;
      background: transparent;
      
      &:focus {
        box-shadow: none;
      }
    }

    .input-toolbar {
      display: flex;
      justify-content: flex-end;
      align-items: center;
      margin-top: 12px;
      
      .hint-text {
        font-size: 13px;
        color: #909399;
        margin-right: 16px;
      }
    }
  }
}
</style>
