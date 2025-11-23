<template>
  <div class="app-container">
    <!-- 时间筛选 -->
    <div class="filter-section">
      <el-card shadow="never">
        <el-form :inline="true">
          <el-form-item label="时间范围">
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              style="width: 280px"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="fetchStatistics">查询</el-button>
            <el-button @click="handleExport">导出报表</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>

    <!-- 核心指标卡片 -->
    <el-row :gutter="24" class="stat-cards">
      <el-col :span="6" v-for="(stat, index) in coreStats" :key="index">
        <el-card shadow="hover" class="stat-card">
          <el-statistic 
            :title="stat.label" 
            :value="stat.value"
            :prefix="stat.prefix"
            :suffix="stat.suffix"
          >
            <template #prefix>
              <el-icon :color="stat.color" :size="24">
                <component :is="stat.icon" />
              </el-icon>
            </template>
          </el-statistic>
          <div class="stat-extra">
            <span :class="stat.trend >= 0 ? 'trend-up' : 'trend-down'">
              {{ stat.trend >= 0 ? '↑' : '↓' }} {{ Math.abs(stat.trend) }}%
            </span>
            <span class="stat-desc">较上期</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="24" class="charts-section">
      <!-- 订单趋势 -->
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>订单趋势</span>
              <el-radio-group v-model="orderPeriod" size="small">
                <el-radio-button label="day">日</el-radio-button>
                <el-radio-button label="week">周</el-radio-button>
                <el-radio-button label="month">月</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="orderChartRef" style="height: 300px;"></div>
        </el-card>
      </el-col>

      <!-- 营收趋势 -->
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>营收趋势</span>
            </div>
          </template>
          <div ref="revenueChartRef" style="height: 300px;"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="24" class="charts-section">
      <!-- 各食堂营收对比 -->
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>各食堂营收对比</span>
            </div>
          </template>
          <div ref="canteenChartRef" style="height: 350px;"></div>
        </el-card>
      </el-col>

      <!-- 高峰期流量分析 -->
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>高峰期流量分析（24小时）</span>
            </div>
          </template>
          <div ref="peakChartRef" style="height: 350px;"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 热门菜品排行 -->
    <el-row :gutter="24" class="charts-section">
      <el-col :span="24">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>热门菜品 Top 10</span>
            </div>
          </template>
          <div ref="dishRankRef" style="height: 400px;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import { ElMessage } from 'element-plus'

const dateRange = ref([])
const orderPeriod = ref('day')

const orderChartRef = ref(null)
const revenueChartRef = ref(null)
const canteenChartRef = ref(null)
const peakChartRef = ref(null)
const dishRankRef = ref(null)

let orderChart = null
let revenueChart = null
let canteenChart = null
let peakChart = null
let dishRankChart = null

// 核心统计数据（模拟数据）
const coreStats = ref([
  { label: '日活用户数', value: 1234, trend: 12.5, icon: 'User', color: '#409eff' },
  { label: '总订单量', value: 5678, trend: 8.3, icon: 'List', color: '#67c23a' },
  { label: '总营业额', value: 28960, prefix: '¥', trend: 15.2, icon: 'Money', color: '#f56c6c' },
  { label: '平均客单价', value: 25.8, prefix: '¥', trend: -2.1, icon: 'TrendCharts', color: '#e6a23c' }
])

// 初始化图表
const initCharts = () => {
  // 订单趋势图
  if (orderChartRef.value) {
    orderChart = echarts.init(orderChartRef.value)
    orderChart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
        axisLine: { lineStyle: { color: '#9ca3af' } }
      },
      yAxis: {
        type: 'value',
        axisLine: { show: false },
        splitLine: { lineStyle: { type: 'dashed', color: '#e5e7eb' } }
      },
      series: [{
        name: '订单数',
        type: 'line',
        smooth: true,
        itemStyle: { color: '#4f46e5' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(79, 70, 229, 0.3)' },
            { offset: 1, color: 'rgba(79, 70, 229, 0)' }
          ])
        },
        data: [320, 410, 380, 450, 520, 680, 590]
      }]
    })
  }

  // 营收趋势图
  if (revenueChartRef.value) {
    revenueChart = echarts.init(revenueChartRef.value)
    revenueChart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
      },
      yAxis: { type: 'value' },
      series: [{
        name: '营业额',
        type: 'bar',
        itemStyle: { color: '#67c23a' },
        data: [8200, 9500, 8800, 11200, 13800, 18900, 15600]
      }]
    })
  }

  // 各食堂营收对比
  if (canteenChartRef.value) {
    canteenChart = echarts.init(canteenChartRef.value)
    canteenChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '0%' },
      series: [{
        name: '营收',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: { show: false },
        emphasis: {
          label: { show: true, fontSize: 16, fontWeight: 'bold' }
        },
        data: [
          { value: 35000, name: '第一食堂' },
          { value: 28000, name: '第二食堂' },
          { value: 22000, name: '第三食堂' },
          { value: 18000, name: '清真食堂' },
          { value: 15000, name: '教工食堂' }
        ]
      }]
    })
  }

  // 高峰期流量分析
  if (peakChartRef.value) {
    peakChart = echarts.init(peakChartRef.value)
    const hours = Array.from({ length: 24 }, (_, i) => `${i}:00`)
    const orderData = [2, 1, 0, 0, 0, 3, 15, 45, 68, 52, 98, 185, 156, 88, 72, 58, 125, 198, 165, 95, 52, 28, 15, 8]
    
    peakChart.setOption({
      tooltip: { trigger: 'axis' },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: {
        type: 'category',
        data: hours
      },
      yAxis: {
        type: 'value',
        name: '订单数'
      },
      series: [{
        name: '订单数',
        type: 'line',
        smooth: true,
        itemStyle: { color: '#f56c6c' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(245, 108, 108, 0.3)' },
            { offset: 1, color: 'rgba(245, 108, 108, 0)' }
          ])
        },
        data: orderData,
        markLine: {
          data: [
            { name: '午高峰', xAxis: 11 },
            { name: '晚高峰', xAxis: 17 }
          ]
        }
      }]
    })
  }

  // 热门菜品排行
  if (dishRankRef.value) {
    dishRankChart = echarts.init(dishRankRef.value)
    dishRankChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'value' },
      yAxis: {
        type: 'category',
        data: ['牛肉拉面', '扬州炒饭', '宫保鸡丁', '麻婆豆腐', '红烧肉', '西红柿炒蛋', '糖醋里脊', '鱼香肉丝', '青椒肉丝', '香辣鸡腿堡'].reverse()
      },
      series: [{
        name: '销量',
        type: 'bar',
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
            { offset: 0, color: '#83bff6' },
            { offset: 1, color: '#188df0' }
          ])
        },
        data: [520, 580, 620, 680, 720, 780, 850, 920, 1050, 1180].reverse()
      }]
    })
  }
}

const handleResize = () => {
  orderChart?.resize()
  revenueChart?.resize()
  canteenChart?.resize()
  peakChart?.resize()
  dishRankChart?.resize()
}

const fetchStatistics = () => {
  ElMessage.success('数据已刷新')
  // 实际项目中这里调用API获取数据
}

const handleExport = () => {
  ElMessage.info('导出功能开发中')
}

onMounted(() => {
  initCharts()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  orderChart?.dispose()
  revenueChart?.dispose()
  canteenChart?.dispose()
  peakChart?.dispose()
  dishRankChart?.dispose()
})
</script>

<style scoped lang="scss">
.app-container {
  padding: 0;
}

.filter-section {
  margin-bottom: 24px;
}

.stat-cards {
  margin-bottom: 24px;

  .stat-card {
    border: none;
    border-radius: 12px;
    
    :deep(.el-card__body) {
      padding: 24px;
    }

    .stat-extra {
      margin-top: 12px;
      font-size: 14px;
      
      .trend-up {
        color: #67c23a;
        margin-right: 8px;
      }
      
      .trend-down {
        color: #f56c6c;
        margin-right: 8px;
      }
      
      .stat-desc {
        color: #909399;
      }
    }
  }
}

.charts-section {
  margin-bottom: 24px;

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
</style>

