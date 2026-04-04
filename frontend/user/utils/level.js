// utils/level.js

const LEVEL_CONFIG = [
  { level: 1, title: '美食小白', icon: '🌱', minExp: 0, maxExp: 100, tips: '再发布1篇帖子即可升级' },
  { level: 2, title: '美食学徒', icon: '🌿', minExp: 100, maxExp: 300, tips: '多发帖、评论可以快速升级哦' },
  { level: 3, title: '美食达人', icon: '🌳', minExp: 300, maxExp: 600, tips: '你已经是美食达人啦！' },
  { level: 4, title: '美食专家', icon: '⭐', minExp: 600, maxExp: 1000, tips: '继续加油，即将成为美食大师！' },
  { level: 5, title: '美食大师', icon: '🏆', minExp: 1000, maxExp: 2000, tips: '恭喜成为美食大师！' },
  { level: 6, title: '美食之神', icon: '👑', minExp: 2000, maxExp: 999999, tips: '你已经是传说中的美食之神！' }
]

function toInt(value, fallback = 0) {
  const n = Number(value)
  return Number.isFinite(n) ? Math.max(0, Math.floor(n)) : fallback
}

function getLevelByExp(exp) {
  let current = LEVEL_CONFIG[0]
  for (let i = LEVEL_CONFIG.length - 1; i >= 0; i--) {
    if (exp >= LEVEL_CONFIG[i].minExp) {
      current = LEVEL_CONFIG[i]
      break
    }
  }
  return current
}

// 统一从后端用户对象推导等级信息，兼容 level/exp/points 等不同字段。
function resolveUserLevel(user = {}) {
  const exp = toInt(user.exp, toInt(user.experience, toInt(user.totalExp, toInt(user.points, 0))))

  // 后端若直接返回 level，则优先使用；否则根据经验值计算。
  const levelFromApi = toInt(user.level, 0)
  const levelByExp = getLevelByExp(exp)
  const current = LEVEL_CONFIG.find(item => item.level === levelFromApi) || levelByExp

  const expInLevel = Math.max(0, exp - current.minExp)
  const expNeeded = Math.max(1, current.maxExp - current.minExp)
  const progress = Math.min(100, Math.round((expInLevel / expNeeded) * 100))

  return {
    level: current.level,
    title: current.title,
    icon: current.icon,
    currentExp: exp,
    nextExp: current.maxExp,
    progress,
    tips: current.tips
  }
}

module.exports = {
  LEVEL_CONFIG,
  resolveUserLevel
}
