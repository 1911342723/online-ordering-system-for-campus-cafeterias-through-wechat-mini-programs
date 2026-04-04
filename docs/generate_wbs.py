import urllib.request
import json
import os

def generate_svg_kroki(puml_content, filename):
    url = "https://kroki.io/plantuml/svg"
    data = {"diagram_source": puml_content}
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as response:
            svg = response.read().decode('utf-8')
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(svg)
            print(f"Generated {filename}")
    except Exception as e:
        print(f"Failed to generate {filename}: {e}")

os.makedirs('f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures', exist_ok=True)

wbs_puml = """
@startwbs
!theme plain
skinparam defaultFontName "Arial, sans-serif"
skinparam shadowing false
skinparam roundcorner 4

<style>
wbsDiagram {
  BackgroundColor #FFFFFF
  BorderColor #2C3E50
  BorderThickness 1.2
  FontColor #2C3E50
  
  .layer_group {
      BackgroundColor #FDFEFE
      BorderColor #808B96
  }
  .frontend_node {
      BackgroundColor #EBF5FB
      BorderColor #2471A3
  }
  .backend_node {
      BackgroundColor #F4F6F7
      BorderColor #34495E
  }
}
</style>

* 基于微信小程序的校园智慧餐饮系统
** 前端表现层 (客户端界面交互) <<layer_group>>
*** 微信小程序端 (消费者终端) <<frontend_node>>
**** 结构化菜单与多维类目检索模块
**** 一致性客户端逻辑与防并发购物车模块
**** 订单全生命周期状态流转展示界面
**** 嵌入式大语言模型(LLM)交互对话组件
**** 本地地址簿与历史票单序列查阅面板
*** Web 工作台端 (商家与管理终端) <<frontend_node>>
**** 可视化店铺物理参数配置模块
**** SKU 级菜品与库存实时交互面板
**** WebSocket 异步接单响铃调度工作台
**** 时序维度的图表(ECharts)可视化报表
**** 平台客诉阻断与网段商户准入审批流视图
** 后端支撑层 (云端核心服务逻辑) <<layer_group>>
*** 核心业务调度与计算
**** 订单强一致性生命周期状态机推进引擎
**** SKU 并发扣减与分布式库存协调算子
**** 基于云存储的图文素材统一归档存储
*** 人工智能与高频异步通信
**** LLM 意图解构与自然语言推荐代理处理器
**** 分布式 WebSocket 平台事件全屏广播信道
*** 风控认证与拦截基座
**** 二次封装 RBAC 细粒度特权矩阵引擎映射
**** JWT 无状态数字令牌鉴权与越权拦截网关
**** 基于控制闸门机制的恶意违规实体熔断器
@endwbs
"""

generate_svg_kroki(wbs_puml, 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures/functional_structure.svg')
