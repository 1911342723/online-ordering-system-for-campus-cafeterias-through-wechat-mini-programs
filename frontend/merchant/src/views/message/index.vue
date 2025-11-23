<template>
  <div class="app-container">
    <el-card shadow="never" class="main-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <div class="page-title">消息中心</div>
          </div>
          <div class="header-right">
            <!-- 可以添加一些消息相关的操作 -->
          </div>
        </div>
      </template>

      <div class="chat-layout">
        <!-- 对话列表 -->
        <div class="conversation-sidebar">
          <div class="sidebar-header">
            <span class="title">消息列表</span>
            <el-badge :value="unreadCount" :hidden="unreadCount === 0" type="danger" />
          </div>
          
          <div class="conversation-scroll">
            <div 
              v-for="conv in conversations" 
              :key="conv.id"
              class="conversation-item"
              :class="{ active: currentConversation?.id === conv.id }"
              @click="selectConversation(conv)"
            >
              <el-avatar :size="48" class="avatar">
                {{ conv.userName?.charAt(0) || 'U' }}
              </el-avatar>
              <div class="conversation-info">
                <div class="conversation-top">
                  <span class="user-name">{{ conv.userName }}</span>
                  <span class="time">{{ formatTime(conv.lastMessageTime) }}</span>
                </div>
                <div class="last-message">
                  {{ conv.lastMessage }}
                </div>
              </div>
              <el-badge v-if="conv.unreadCount > 0" :value="conv.unreadCount" class="unread-badge" />
            </div>
            
            <el-empty v-if="conversations.length === 0" description="暂无消息" :image-size="100" />
          </div>
        </div>

        <!-- 聊天区域 -->
        <div class="chat-main">
          <template v-if="currentConversation">
            <div class="chat-header">
              <div class="chat-user">
                <el-avatar :size="40">{{ currentConversation.userName?.charAt(0) }}</el-avatar>
                <div class="user-info">
                  <span class="name">{{ currentConversation.userName }}</span>
                  <span class="status">在线</span>
                </div>
              </div>
            </div>
            
            <div class="chat-content">
              <!-- 消息列表 -->
              <div ref="messageListRef" class="message-list">
                <div 
                  v-for="msg in messages" 
                  :key="msg.id"
                  class="message-item"
                  :class="msg.fromMerchant ? 'message-right' : 'message-left'"
                >
                  <el-avatar :size="36" class="message-avatar" v-if="!msg.fromMerchant">
                    {{ currentConversation.userName?.charAt(0) || 'U' }}
                  </el-avatar>
                  <div class="message-content">
                    <div class="message-bubble">
                      {{ msg.content }}
                    </div>
                    <div class="message-time">{{ formatTime(msg.createTime) }}</div>
                  </div>
                  <el-avatar :size="36" class="message-avatar" v-if="msg.fromMerchant">
                    商
                  </el-avatar>
                </div>
                
                <el-empty v-if="messages.length === 0" description="暂无消息" :image-size="100" />
              </div>

              <!-- 输入框 -->
              <div class="message-input">
                <el-input
                  v-model="inputMessage"
                  type="textarea"
                  :rows="3"
                  placeholder="输入消息..."
                  resize="none"
                  @keyup.enter.ctrl="handleSend"
                />
                <div class="input-actions">
                  <el-text type="info" size="small">Ctrl + Enter 发送</el-text>
                  <el-button type="primary" @click="handleSend" :loading="sending">发送</el-button>
                </div>
              </div>
            </div>
          </template>
          
          <div v-else class="empty-chat">
            <el-empty description="请选择一个对话开始聊天" />
          </div>
        </div>
      </div>
    </el-card>
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
.app-container {
  padding: 20px;
  height: calc(100vh - 84px);
  box-sizing: border-box;
}

.main-card {
  height: 100%;
  display: flex;
  flex-direction: column;
  border-radius: 8px;
  
  :deep(.el-card__header) {
    padding: 16px 20px;
    border-bottom: 1px solid #ebeef5;
    flex-shrink: 0;
  }
  
  :deep(.el-card__body) {
    padding: 0;
    flex: 1;
    overflow: hidden;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .header-left {
    .page-title {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
      position: relative;
      padding-left: 12px;
      
      &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 4px;
        height: 16px;
        background: var(--primary-color);
        border-radius: 2px;
      }
    }
  }
}

.chat-layout {
  display: flex;
  height: 100%;
  
  .conversation-sidebar {
    width: 320px;
    border-right: 1px solid #ebeef5;
    display: flex;
    flex-direction: column;
    background: #fff;
    
    .sidebar-header {
      padding: 16px 20px;
      border-bottom: 1px solid #f5f7fa;
      display: flex;
      align-items: center;
      justify-content: space-between;
      
      .title {
        font-weight: 600;
        color: #303133;
      }
    }
    
    .conversation-scroll {
      flex: 1;
      overflow-y: auto;
      
      &::-webkit-scrollbar {
        width: 4px;
      }
    }
    
    .conversation-item {
      padding: 16px 20px;
      display: flex;
      align-items: center;
      cursor: pointer;
      transition: all 0.2s;
      position: relative;
      
      &:hover {
        background-color: #f5f7fa;
      }
      
      &.active {
        background-color: #f0f9ff;
        border-right: 3px solid var(--primary-color);
        
        .user-name {
          color: var(--primary-color);
        }
      }
      
      .avatar {
        flex-shrink: 0;
        margin-right: 12px;
        background: linear-gradient(135deg, #818cf8 0%, #4f46e5 100%);
        font-size: 18px;
        font-weight: 600;
      }
      
      .conversation-info {
        flex: 1;
        min-width: 0;
        
        .conversation-top {
          display: flex;
          justify-content: space-between;
          margin-bottom: 6px;
          
          .user-name {
            font-weight: 600;
            color: #303133;
            font-size: 15px;
          }
          
          .time {
            font-size: 12px;
            color: #909399;
          }
        }
        
        .last-message {
          font-size: 13px;
          color: #909399;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
      }
      
      .unread-badge {
        position: absolute;
        right: 16px;
        top: 50%;
        transform: translateY(-50%);
      }
    }
  }
  
  .chat-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    background-color: #fff;
    
    .empty-chat {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: #f9fafb;
    }
    
    .chat-header {
      padding: 16px 24px;
      border-bottom: 1px solid #ebeef5;
      background: #fff;
      
      .chat-user {
        display: flex;
        align-items: center;
        
        .user-info {
          margin-left: 12px;
          display: flex;
          flex-direction: column;
          
          .name {
            font-weight: 600;
            font-size: 16px;
            color: #303133;
          }
          
          .status {
            font-size: 12px;
            color: #67c23a;
            margin-top: 2px;
          }
        }
      }
    }
    
    .chat-content {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      
      .message-list {
        flex: 1;
        overflow-y: auto;
        padding: 24px;
        background-color: #f9fafb;
        
        .message-item {
          display: flex;
          margin-bottom: 24px;
          
          &.message-left {
            .message-content {
              align-items: flex-start;
              
              .message-bubble {
                background: #fff;
                color: #303133;
                border-bottom-left-radius: 4px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
              }
            }
          }
          
          &.message-right {
            flex-direction: row-reverse;
            
            .message-content {
              align-items: flex-end;
              
              .message-bubble {
                background: var(--primary-color);
                color: #fff;
                border-bottom-right-radius: 4px;
                box-shadow: 0 2px 4px rgba(79, 70, 229, 0.2);
              }
            }
            
            .message-avatar {
              margin-left: 12px;
              margin-right: 0;
              background-color: var(--primary-color);
            }
          }
          
          .message-avatar {
            flex-shrink: 0;
            margin-right: 12px;
            margin-top: 4px;
          }
          
          .message-content {
            display: flex;
            flex-direction: column;
            max-width: 70%;
            
            .message-bubble {
              padding: 12px 16px;
              border-radius: 12px;
              font-size: 14px;
              line-height: 1.6;
              word-break: break-word;
            }
            
            .message-time {
              font-size: 12px;
              color: #9ca3af;
              margin-top: 6px;
              padding: 0 4px;
            }
          }
        }
      }
      
      .message-input {
        padding: 20px 24px;
        border-top: 1px solid #ebeef5;
        background: #fff;
        
        :deep(.el-textarea__inner) {
          border: none;
          padding: 0;
          box-shadow: none;
          resize: none;
          background: transparent;
          
          &:focus {
            box-shadow: none;
          }
        }
        
        .input-actions {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-top: 12px;
          padding-top: 12px;
          border-top: 1px solid #f5f7fa;
        }
      }
    }
  }
}
</style>

