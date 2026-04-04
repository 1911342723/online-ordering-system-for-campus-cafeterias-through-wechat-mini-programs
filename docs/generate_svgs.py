import urllib.request
import zlib
import base64
import string
import os

def encode_plantuml(text):
    z = zlib.compress(text.encode('utf-8'))
    b = base64.b64encode(z[2:-4]).decode('utf-8')
    t = str.maketrans('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
                      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_')
    return b.translate(t)

def generate_svg(puml_content, filename):
    encoded = encode_plantuml(puml_content)
    url = f"http://www.plantuml.com/plantuml/svg/{encoded}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req) as response:
            svg = response.read().decode('utf-8')
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(svg)
            print(f"Generated academic style {filename}")
    except Exception as e:
        print(f"Failed to generate {filename}: {e}")

os.makedirs('f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures', exist_ok=True)

arch_puml = """
@startuml
!theme plain
skinparam defaultFontName "Arial, sans-serif"
skinparam shadowing false
skinparam roundcorner 4
skinparam defaultFontSize 14
skinparam linetype ortho

skinparam node {
    BackgroundColor #F4F6F7
    BorderColor #2C3E50
    BorderThickness 1.5
    FontColor #2C3E50
}

skinparam component {
    BackgroundColor #FFFFFF
    BorderColor #34495E
    BorderThickness 1.5
    FontColor #2C3E50
}

skinparam database {
    BackgroundColor #EBF5FB
    BorderColor #2471A3
    BorderThickness 1.5
    FontColor #154360
}

skinparam arrow {
    Color #34495E
    Thickness 1.2
}

node "客户端交互层" {
  [微信小程序 (用户端)] as user_app
  [Vue3 Web (商家后台)] as merchant_app
  [Vue3 Web (运营大盘)] as admin_app
}

node "边缘网关与安全控制层" {
  [Nginx 负载分发节点] as nginx
  [JWT鉴权过滤器] as jwt
  [AOP统一异常处理切面] as exception_handler
}

node "微服务业务内核 (Spring Boot)" {
  [多租户用户与权限模块] as user_service
  [菜品分类与库存调度引擎] as dish_service
  [高并发交易与购物车流转] as order_service
  [多维数据审计与统计层] as data_service
  [AI大模型语义重塑网关] as ai_service
}

database "持久化底座与隔离缓存层" {
  [MySQL 5.7+ ACID 核心集群] as mysql
}

node "外部集成协议层" {
  [第三方安全支付通道] as pay_api
  [大语言模型推理接口 (LLM)] as llm_api
}

user_app --> nginx : HTTPS
merchant_app --> nginx : HTTPS
admin_app --> nginx : HTTPS

nginx --> jwt
jwt --> exception_handler : 非法签名/越权拦截
jwt --> user_service
jwt --> dish_service
jwt --> order_service
jwt --> data_service
jwt --> ai_service

user_service --> mysql
dish_service --> mysql
order_service --> mysql
data_service --> mysql

ai_service --> llm_api : RPC / REST (上下文约束)
order_service --> pay_api : 唤醒收银台
@enduml
"""

func_puml = """
@startuml
!theme plain
skinparam defaultFontName "Arial, sans-serif"
skinparam shadowing false
skinparam roundcorner 6
skinparam linetype poly

skinparam actor {
    BackgroundColor #FFFFFF
    BorderColor #2C3E50
    FontColor #2C3E50
}

skinparam usecase {
    BackgroundColor #F9EBEA
    BorderColor #922B21
    BorderThickness 1.2
    FontColor #641E16
}

skinparam rectangle {
    BackgroundColor #FDFEFE
    BorderColor #7F8C8D
    BorderThickness 1.5
    FontColor #2C3E50
}

skinparam arrow {
    Color #7F8C8D
    Thickness 1.2
}

left to right direction
actor "在校师生终端" as user
actor "驻场商户终端" as merchant
actor "系统超级超管" as admin

rectangle "校园智慧餐饮核心系统功能矩阵" {
  usecase "结构化菜品瀑布流检索" as UC1
  usecase "非结构语义 AI 辅助点餐" as UC2
  usecase "一致性购物车与并单结算" as UC3
  usecase "资金流水记录与逆向追溯" as UC4
  usecase "全周期履约快照与满意度回传" as UC5
  
  usecase "商户域数字立面维护与闭店" as MC1
  usecase "多模态 SKU 树规格动态插拔" as MC2
  usecase "WebSocket 双工即时订单播报" as MC3
  usecase "客诉工单反馈与负面舆情处理" as MC4
  usecase "时序业务量度量与 ECharts 导出" as MC5
  
  usecase "入驻商户生命周期一票否决" as AD1
  usecase "平台全频段广播消息分发" as AD2
  usecase "宏观用户活跃度数据观测盘" as AD3
  usecase "高细粒度 RBAC 运营越权干预" as AD4
}

user --> UC1
user --> UC2
user --> UC3
user --> UC4
user --> UC5

merchant --> MC1
merchant --> MC2
merchant --> MC3
merchant --> MC4
merchant --> MC5

admin --> AD1
admin --> AD2
admin --> AD3
admin --> AD4
@enduml
"""

er_puml = """
@startuml
!theme plain
skinparam defaultFontName "Arial, sans-serif"
skinparam shadowing false
skinparam roundcorner 4
hide circle
hide empty members

skinparam class {
    BackgroundColor #FFFFFF
    HeaderBackgroundColor #EBEDEF
    BorderColor #2C3E50
    BorderThickness 1.2
    ArrowColor #2C3E50
    FontColor #2C3E50
}

entity "用户域聚合基表 (User)" as user {
  * id : BIGINT
  --
  phone : VARCHAR(11) [唯一约束]
  name : VARCHAR(255)
  balance : DECIMAL(10,2) [财务极]
  status : INT [软删除标识]
}

entity "虚拟租户映射锚点 (Merchant)" as merchant {
  * id : BIGINT
  --
  canteen_id : BIGINT [弱挂接源]
  name : VARCHAR(100)
  contact : VARCHAR(50)
  rating : DECIMAL(3,2) [动态均值]
}

entity "商品标准化基底 (Dish)" as dish {
  * id : BIGINT
  --
  name : VARCHAR(64)
  merchant_id : BIGINT
  category_id : BIGINT [类目隔离阈]
  price : DECIMAL(10,2)
  stock : INT [乐观锁检测限]
}

entity "非结构化多维属性簇 (Dish_Flavor)" as flavor {
  * id : BIGINT
  --
  dish_id : BIGINT
  name : VARCHAR(64) [变长特征索引]
  value : VARCHAR(500) [JSON长文本]
}

entity "一致性交易主生命线 (Orders)" as orders {
  * id : BIGINT
  --
  number : VARCHAR(50) [对账幂等键]
  user_id : BIGINT
  merchant_id : BIGINT
  amount : DECIMAL(10,2)
  status : INT [有限状态机]
  order_time : DATETIME
}

entity "履约标的快照留痕谱 (Order_Detail)" as detail {
  * id : BIGINT
  --
  order_id : BIGINT
  dish_id : BIGINT
  number : INT
  amount : DECIMAL(10,2) [截断历史底价]
  dish_flavor : VARCHAR(50) [固化离线偏好]
}

user ||--o{ orders : "激发交易流水"
merchant ||--o{ dish : "产权界定"
merchant ||--o{ orders : "履约承接"
dish ||--o{ flavor : "无限裂变衍生"
orders ||--o{ detail : "物理聚合包裹"
dish ||--o{ detail : "时间断层快照定格"

@enduml
"""

generate_svg(arch_puml, 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures/architecture.svg')
generate_svg(func_puml, 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures/functions.svg')
generate_svg(er_puml, 'f:/开发项目/接单/CM/Online-Catering-System-main/docs/figures/er_diagram.svg')
