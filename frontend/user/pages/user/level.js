// pages/user/level.js
const { LEVEL_CONFIG, resolveUserLevel } = require('../../utils/level')

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
    this.setData({
      currentLevel: resolveUserLevel(userInfo || {})
    })
  }
})

