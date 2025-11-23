<template>
  <div class="dashboard-container">
    <!-- Welcome Section -->
    <div class="welcome-section">
      <div class="welcome-text">
        <h2>早安，{{ userInfo.name }} 👋</h2>
        <p>祝你今天工作愉快！这里是今日的运营概览。</p>
      </div>
    </div>
    
    <!-- Statistics Cards -->
    <el-row :gutter="24" class="stat-cards" v-loading="loading">
      <el-col :span="6" v-for="(stat, index) in stats" :key="index">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" :style="{ background: stat.bg }">
            <el-icon :color="stat.color"><component :is="stat.icon" /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">{{ stat.label }}</div>
            <div class="stat-value">
              {{ stat.value }}
              <span class="stat-trend" :class="stat.trend >= 0 ? 'up' : 'down'">
                {{ Math.abs(stat.trend) }}%
                <el-icon><component :is="stat.trend >= 0 ? 'ArrowUp' : 'ArrowDown'" /></el-icon>
              </span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Charts Section -->
    <el-row :gutter="24" class="charts-row">
      <el-col :span="16">
        <el-card shadow="hover" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>营收趋势</span>
              <el-radio-group v-model="chartPeriod" size="small">
                <el-radio-button label="week">本周</el-radio-button>
                <el-radio-button label="month">本月</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="revenueChartRef" style="height: 350px;"></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>热门菜品 Top 5</span>
            </div>
          </template>
          <div ref="pieChartRef" style="height: 350px;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'
import request from '@/api/request'

const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
const chartPeriod = ref('week')
const revenueChartRef = ref(null)
const pieChartRef = ref(null)
let revenueChart = null
let pieChart = null
const loading = ref(false)

// 统计数据
const stats = ref([
  { label: '今日订单', value: '0', trend: 0, icon: 'List', color: '#4f46e5', bg: '#e0e7ff' },
  { label: '今日营业额', value: '¥0.00', trend: 0, icon: 'Money', color: '#059669', bg: '#d1fae5' },
  { label: '待处理', value: '0', trend: 0, icon: 'Bell', color: '#d97706', bg: '#fef3c7' },
  { label: '总用户数', value: '0', trend: 0, icon: 'User', color: '#2563eb', bg: '#dbeafe' },
])

// 获取统计数据
const fetchStatistics = async () => {
  loading.value = true
  try {
    const res = await request({
      url: '/statistics/merchant/overview',
      method: 'get',
      params: { period: chartPeriod.value }
    })
    
    if (res.code === 1 && res.data) {
      const data = res.data
      
      // 更新统计卡片
      stats.value[0].value = String(data.todayOrders || 0)
      stats.value[0].trend = data.todayOrdersTrend || 0
      
      stats.value[1].value = `¥${((data.todayRevenue || 0) / 100).toFixed(2)}`
      stats.value[1].trend = data.todayRevenueTrend || 0
      
      stats.value[2].value = String(data.pendingOrders || 0)
      stats.value[2].trend = data.pendingOrdersTrend || 0
      
      stats.value[3].value = String(data.totalUsers || 0)
      stats.value[3].trend = data.totalUsersTrend || 0
      
      // 更新图表
      updateCharts(data)
    }
  } catch (err) {
    console.error('获取统计数据失败:', err)
    ElMessage.error('获取统计数据失败')
  } finally {
    loading.value = false
  }
}

const initCharts = () => {
  // Revenue Chart
  if (revenueChartRef.value) {
    revenueChart = echarts.init(revenueChartRef.value)
  }

  // Pie Chart
  if (pieChartRef.value) {
    pieChart = echarts.init(pieChartRef.value)
  }
}

const updateCharts = (data) => {
  // Update Revenue Chart
  if (revenueChart && data.revenueTrend) {
    const dates = data.revenueTrend.map(item => item.date)
    const revenues = data.revenueTrend.map(item => item.revenue)
    
    revenueChart.setOption({
      tooltip: { 
        trigger: 'axis',
        formatter: (params) => {
          const param = params[0]
          return `${param.name}<br/>营业额: ¥${param.value}`
        }
      },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: dates,
        axisLine: { lineStyle: { color: '#9ca3af' } }
      },
      yAxis: {
        type: 'value',
        axisLine: { show: false },
        axisTick: { show: false },
        splitLine: { lineStyle: { type: 'dashed', color: '#e5e7eb' } }
      },
      series: [
        {
          name: '营业额',
          type: 'line',
          smooth: true,
          itemStyle: { color: '#4f46e5' },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: 'rgba(79, 70, 229, 0.3)' },
              { offset: 1, color: 'rgba(79, 70, 229, 0)' }
            ])
          },
          data: revenues
        }
      ]
    })
  }

  // Update Pie Chart
  if (pieChart && data.topDishes) {
    const pieData = data.topDishes.map(item => ({
      value: item.count,
      name: item.name
    }))
    
    pieChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '0%', left: 'center' },
      series: [
        {
          name: '销量',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: {
            borderRadius: 10,
            borderColor: '#fff',
            borderWidth: 2
          },
          label: { show: false, position: 'center' },
          emphasis: {
            label: { show: true, fontSize: 20, fontWeight: 'bold' }
          },
          data: pieData.length > 0 ? pieData : [{ value: 0, name: '暂无数据' }]
        }
      ]
    })
  }
}

const handleResize = () => {
  revenueChart?.resize()
  pieChart?.resize()
}

// 监听时间段变化
watch(chartPeriod, () => {
  fetchStatistics()
})

onMounted(() => {
  initCharts()
  fetchStatistics()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  revenueChart?.dispose()
  pieChart?.dispose()
})
</script>

<style scoped lang="scss">
.dashboard-container {
  .welcome-section {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;

    .welcome-text {
      h2 { margin: 0 0 5px 0; font-size: 24px; color: #111827; }
      p { margin: 0; color: #6b7280; }
    }
  }

  .stat-cards {
    margin-bottom: 24px;

    .stat-card {
      border: none;
      border-radius: 12px;
      transition: transform 0.2s;
      
      &:hover { transform: translateY(-5px); }

      :deep(.el-card__body) {
        display: flex;
        align-items: center;
        padding: 20px;
      }

      .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 16px;
        font-size: 24px;
      }

      .stat-info {
        flex: 1;
        .stat-label { font-size: 14px; color: #6b7280; margin-bottom: 4px; }
        .stat-value {
          font-size: 24px;
          font-weight: bold;
          color: #111827;
          display: flex;
          align-items: baseline;
          
          .stat-trend {
            font-size: 12px;
            margin-left: 8px;
            display: flex;
            align-items: center;
            padding: 2px 6px;
            border-radius: 10px;

            &.up { color: #059669; background: #d1fae5; }
            &.down { color: #dc2626; background: #fee2e2; }
          }
        }
      }
    }
  }

  .charts-row {
    .chart-card {
      border: none;
      border-radius: 12px;

      .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-weight: 600;
      }
    }
  }
}
</style>
