<template>
  <div class="message-container">
    <el-row :gutter="20" style="height: 100%;">
      <!-- 对话列表 -->
      <el-col :span="8">
        <el-card shadow="never" class="conversation-list" body-style="padding: 0; height: 100%;">
          <template #header>
            <div class="card-header">
              <span>消息列表</span>
              <el-badge :value="unreadCount" :hidden="unreadCount === 0" />
            </div>
          </template>
          
          <div class="conversation-scroll">
            <div 
              v-for="conv in conversations" 
              :key="conv.id"
              class="conversation-item"
              :class="{ active: currentConversation?.id === conv.id }"
              @click="selectConversation(conv)"
            >
              <el-avatar :size="45" class="avatar">
                {{ conv.userName?.charAt(0) || 'U' }}
              </el-avatar>
              <div class="conversation-info">
                <div class="conversation-header">
                  <span class="user-name">{{ conv.userName }}</span>
                  <span class="time">{{ formatTime(conv.lastMessageTime) }}</span>
                </div>
                <div class="last-message">
                  {{ conv.lastMessage }}
                </div>
              </div>
              <el-badge v-if="conv.unreadCount > 0" :value="conv.unreadCount" class="unread-badge" />
            </div>
            
            <el-empty v-if="conversations.length === 0" description="暂无消息" />
          </div>
        </el-card>
      </el-col>

      <!-- 聊天区域 -->
      <el-col :span="16">
        <el-card shadow="never" class="chat-area" body-style="padding: 0; height: 100%;">
          <template #header v-if="currentConversation">
            <div class="chat-header">
              <el-avatar :size="35">{{ currentConversation.userName?.charAt(0) }}</el-avatar>
              <span style="margin-left: 10px; font-weight: 500;">{{ currentConversation.userName }}</span>
            </div>
          </template>
          
          <div v-if="currentConversation" class="chat-content">
            <!-- 消息列表 -->
            <div ref="messageListRef" class="message-list">
              <div 
                v-for="msg in messages" 
                :key="msg.id"
                class="message-item"
                :class="msg.fromMerchant ? 'message-right' : 'message-left'"
              >
                <el-avatar :size="35" class="message-avatar">
                  {{ msg.fromMerchant ? '商' : (currentConversation.userName?.charAt(0) || 'U') }}
                </el-avatar>
                <div class="message-content">
                  <div class="message-bubble">
                    {{ msg.content }}
                  </div>
                  <div class="message-time">{{ formatTime(msg.createTime) }}</div>
                </div>
              </div>
              
              <el-empty v-if="messages.length === 0" description="暂无消息" />
            </div>

            <!-- 输入框 -->
            <div class="message-input">
              <el-input
                v-model="inputMessage"
                type="textarea"
                :rows="3"
                placeholder="输入消息..."
                @keyup.enter.ctrl="handleSend"
              />
              <div class="input-actions">
                <el-text type="info" size="small">Ctrl + Enter 发送</el-text>
                <el-button type="primary" @click="handleSend" :loading="sending">发送</el-button>
              </div>
            </div>
          </div>
          
          <el-empty v-else description="请选择一个对话" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
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

// 获取对话列表
const fetchConversations = async () => {
  if (!currentMerchantId.value) return
  
  try {
    const res = await request({
      url: '/message/conversations',
      method: 'get',
      params: {
        merchantId: currentMerchantId.value
      }
    })
    
    if (res.code === 1) {
      conversations.value = res.data || []
      unreadCount.value = conversations.value.reduce((sum, conv) => sum + (conv.unreadCount || 0), 0)
    }
  } catch (error) {
    console.error(error)
  }
}

// 选择对话
const selectConversation = async (conv) => {
  currentConversation.value = conv
  await fetchMessages(conv.userId)
  
  // 标记为已读
  if (conv.unreadCount > 0) {
    markAsRead(conv.id)
  }
}

// 获取消息列表
const fetchMessages = async (userId) => {
  try {
    const res = await request({
      url: '/message/list',
      method: 'get',
      params: {
        merchantId: currentMerchantId.value,
        userId: userId
      }
    })
    
    if (res.code === 1) {
      messages.value = res.data || []
      scrollToBottom()
    }
  } catch (error) {
    console.error(error)
  }
}

// 发送消息
const handleSend = async () => {
  if (!inputMessage.value.trim()) {
    return
  }
  
  if (!currentConversation.value) {
    ElMessage.warning('请选择一个对话')
    return
  }
  
  sending.value = true
  try {
    const res = await request({
      url: '/message/send',
      method: 'post',
      data: {
        merchantId: currentMerchantId.value,
        userId: currentConversation.value.userId,
        content: inputMessage.value,
        fromMerchant: true
      }
    })
    
    if (res.code === 1) {
      messages.value.push({
        id: Date.now(),
        content: inputMessage.value,
        fromMerchant: true,
        createTime: new Date().toISOString()
      })
      
      inputMessage.value = ''
      scrollToBottom()
      fetchConversations()
    } else {
      ElMessage.error(res.msg || '发送失败')
    }
  } catch (error) {
    console.error(error)
    ElMessage.error('发送失败')
  } finally {
    sending.value = false
  }
}

// 标记已读
const markAsRead = async (conversationId) => {
  try {
    await request({
      url: '/message/read',
      method: 'put',
      data: {
        conversationId: conversationId
      }
    })
    fetchConversations()
  } catch (error) {
    console.error(error)
  }
}

// 滚动到底部
const scrollToBottom = () => {
  nextTick(() => {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight
    }
  })
}

// 格式化时间
const formatTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now - date
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  
  return date.toLocaleString('zh-CN', { 
    month: '2-digit', 
    day: '2-digit', 
    hour: '2-digit', 
    minute: '2-digit' 
  })
}

// 初始化
const init = async () => {
  try {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    if (userInfo.id) {
      const res = await getMerchantByEmployeeId(userInfo.id)
      if (res.code === 1 && res.data) {
        currentMerchantId.value = res.data.id
        fetchConversations()
        
        // 定时刷新
        setInterval(() => {
          fetchConversations()
          if (currentConversation.value) {
            fetchMessages(currentConversation.value.userId)
          }
        }, 5000)
      }
    }
  } catch (error) {
    console.error(error)
  }
}

onMounted(() => {
  init()
})
</script>

<style scoped lang="scss">
.message-container {
  padding: 20px;
  height: calc(100vh - 140px);
}

.conversation-list,
.chat-area {
  height: 100%;
  
  :deep(.el-card__body) {
    height: calc(100% - 60px);
    overflow: hidden;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.conversation-scroll {
  height: 100%;
  overflow-y: auto;
}

.conversation-item {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
  transition: background 0.2s;
  position: relative;
  
  &:hover {
    background: #f5f7fa;
  }
  
  &.active {
    background: #e6f7ff;
  }
  
  .avatar {
    flex-shrink: 0;
    background: #4f46e5;
  }
  
  .conversation-info {
    flex: 1;
    margin-left: 12px;
    min-width: 0;
    
    .conversation-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 5px;
      
      .user-name {
        font-weight: 500;
        color: #303133;
      }
      
      .time {
        font-size: 12px;
        color: #909399;
      }
    }
    
    .last-message {
      font-size: 13px;
      color: #606266;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }
  
  .unread-badge {
    position: absolute;
    right: 15px;
    top: 50%;
    transform: translateY(-50%);
  }
}

.chat-header {
  display: flex;
  align-items: center;
}

.chat-content {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.message-list {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.message-item {
  display: flex;
  margin-bottom: 20px;
  
  &.message-left {
    .message-bubble {
      background: #f0f0f0;
      color: #303133;
    }
  }
  
  &.message-right {
    flex-direction: row-reverse;
    
    .message-content {
      align-items: flex-end;
    }
    
    .message-avatar {
      margin-left: 10px;
      margin-right: 0;
    }
    
    .message-bubble {
      background: #4f46e5;
      color: #fff;
    }
  }
  
  .message-avatar {
    flex-shrink: 0;
    margin-right: 10px;
    background: #4f46e5;
  }
  
  .message-content {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    max-width: 60%;
  }
  
  .message-bubble {
    padding: 10px 15px;
    border-radius: 8px;
    word-break: break-word;
    line-height: 1.5;
  }
  
  .message-time {
    font-size: 12px;
    color: #909399;
    margin-top: 5px;
  }
}

.message-input {
  padding: 20px;
  border-top: 1px solid #e5e7eb;
  
  .input-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 10px;
  }
}
</style>

