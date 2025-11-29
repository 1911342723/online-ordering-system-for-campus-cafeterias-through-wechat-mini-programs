// pages/user/level.js
const LEVEL_CONFIG = [
  { level: 1, title: '美食小白', icon: '🌱', minExp: 0, maxExp: 100 },
  { level: 2, title: '美食学徒', icon: '🌿', minExp: 100, maxExp: 300 },
  { level: 3, title: '美食达人', icon: '🌳', minExp: 300, maxExp: 600 },
  { level: 4, title: '美食专家', icon: '⭐', minExp: 600, maxExp: 1000 },
  { level: 5, title: '美食大师', icon: '🏆', minExp: 1000, maxExp: 2000 },
  { level: 6, title: '美食之神', icon: '👑', minExp: 2000, maxExp: 999999 }
]

Page({
  data: {
    currentLevel: {
      level: 1,
      title: '美食小白',
      icon: '🌱',
      currentExp: 0,
      nextExp: 100,
      progress: 0
    },
    levelList: LEVEL_CONFIG
  },

  onLoad() {
    this.loadUserLevel()
  },

  loadUserLevel() {
    const userInfo = wx.getStorageSync('userInfo')
    const exp = userInfo?.exp || 150 // 模拟经验值
    
    let currentLevel = LEVEL_CONFIG[0]
    for (let i = LEVEL_CONFIG.length - 1; i >= 0; i--) {
      if (exp >= LEVEL_CONFIG[i].minExp) {
        currentLevel = LEVEL_CONFIG[i]
        break
      }
    }
    
    const expInLevel = exp - currentLevel.minExp
    const expNeeded = currentLevel.maxExp - currentLevel.minExp
    const progress = Math.min(100, Math.round((expInLevel / expNeeded) * 100))
    
    this.setData({
      currentLevel: {
        ...currentLevel,
        currentExp: exp,
        nextExp: currentLevel.maxExp,
        progress: progress
      }
    })
  }
})

