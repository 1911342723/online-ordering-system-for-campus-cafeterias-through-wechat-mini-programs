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

seq_puml = """
@startuml
!theme plain
skinparam defaultFontName "Arial, sans-serif"
skinparam shadowing false
skinparam roundcorner 4
skinparam sequence {
    LifeLineBorderColor #2C3E50
    LifeLineBackgroundColor #F4F6F7
    ParticipantBorderColor #2C3E50
    ParticipantBackgroundColor #FFFFFF
    ParticipantFontColor #2C3E50
    ArrowColor #34495E
}

actor User as "终端发起方\\n(小程序侧)"
participant Gateway as "负载分发网关\\n(Nginx Edge)"
participant JWT as "切面鉴权中枢\\n(Interceptor)"
participant AI as "业务内聚集成服务\\n(Spring Boot)"
participant DB as "数据持久核\\n(MySQL 5.7+)"
participant LLM as "外部大模型推理池\\n(LLM API)"

User -> Gateway: 发起非结构请求 (如"要热汤面")
Gateway -> JWT: 指令下发并附带 Token
activate JWT
JWT -> JWT: HAMC 算法比对摘要防伪
JWT --> Gateway: 签发授权，注入本地线程空间
deactivate JWT

Gateway -> AI: REST流投递至智能路由
activate AI
AI -> DB: 高速过滤获取时域在线 SKU
activate DB
DB --> AI: 主键级可用菜单字典 JSON
deactivate DB

AI -> LLM: 组配 Prompt 沙盒并异步桥接外发
activate LLM
LLM -> LLM: 构建生成式注意力矩阵演算
LLM --> AI: 返回降维 JSON 结构化过滤序列
deactivate LLM

AI -> DB: 携反编译序列对靶向库存校验
activate DB
DB --> AI: 输出高精度关联历史快照
deactivate DB

AI --> User: 回传并渲染响应决策卡面
deactivate AI
@enduml
"""

deploy_puml = """
@startuml
!theme plain
skinparam defaultFontName "Arial, sans-serif"
skinparam shadowing false
skinparam roundcorner 4
skinparam linetype ortho

skinparam node {
    BackgroundColor #FFFFFF
    BorderColor #2C3E50
    BorderThickness 1.5
    FontColor #2C3E50
}

skinparam component {
    BackgroundColor #F4F6F7
    BorderColor #34495E
    FontColor #2C3E50
}

skinparam cloud {
    BackgroundColor #EBF5FB
    BorderColor #2471A3
    FontColor #154360
}

node "客户端拓扑域" {
    component "微信小程序运行内存栈" as wx
    component "Web 端宿主 DOM 树" as web
}

cloud "WAN 广域网链路层 (HTTPS/WSS)" as int

node "高防与引流边缘" {
    node "Nginx 调度总栈" {
        component "L7 正则应用层防火墙" as waf
        component "静态物料剥离分离器" as static
    }
}

node "应用集群计算域 (Core Cluster)" {
    node "Spring Boot 实例池" {
        component "JWT 无状态验证容器" as jwt_cmp
        component "悲观锁排他处理队列" as lock_cmp
        component "WebSocket 双工协议池" as ws_cmp
    }
}

node "底层主备隔离区 (Data Layer)" {
    database "MySQL 5.7+ 阵列" as mysql
}

wx --> int
web --> int
int --> waf
waf --> static
static --> jwt_cmp : 剥离转发动态调用
jwt_cmp --> lock_cmp
jwt_cmp --> ws_cmp
lock_cmp --> mysql
ws_cmp --> mysql
@enduml
"""

flow_puml = """
@startuml
!theme plain
skinparam defaultFontName "Arial, sans-serif"
skinparam shadowing false
skinparam roundcorner 4

skinparam activity {
    BackgroundColor #F4F6F7
    BorderColor #2C3E50
    BorderThickness 1.2
    FontColor #2C3E50
    DiamondBackgroundColor #FFFFFF
    DiamondBorderColor #C0392B
}

skinparam arrow {
    Color #34495E
    Thickness 1.2
}

start
:通过解密域下发 Token 静默认证;
if (是否新终端地址?) then (是)
  :激活缺省地址模块注册;
else (否)
endif

fork
  :结构化树遍历检索;
fork again
  :抛送诉求至大模型 (NLP Engine);
  :异步拆解意图隔离非法请求;
end fork

:靶向 SKU 展现输出;
:ThreadLocal 暂存;
:拉起高危交易结算;

if (竞争 InnoDB 行锁结果?) then (成功执行)
  :第三方资金强代扣;
  :事务提交 (DB Commit);
  :发射 WebSocket 轰鸣提醒;
else (受阻滞 - 防超卖熔断)
  :触发 AOP 热力隔离;
  :截断外连并销毁线程;
  :反抛友好异常告警提示;
  stop
endif

:消费者物理提餐核销;
:评价留痕;
stop
@enduml
"""

generate_svg_kroki(seq_puml, 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures/sequence_diagram.svg')
generate_svg_kroki(deploy_puml, 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures/deployment.svg')
generate_svg_kroki(flow_puml, 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures/user_flow.svg')
