# 基于微信小程序的校园智慧餐饮系统的设计与实现

**曹敏**

## 摘  要

在高等教育信息化建设不断深化的背景下，传统校园餐饮后勤服务因高度依赖密集型人力与经验主导的粗放管理模式，逐渐无法适应庞大且快速增长的师生群体在订餐体验、饮食结构和时效性上的多维需求。尤其在用餐高峰时段，物理空间的集中式挤兑不仅造成后勤资源的严重内耗，亦导致食品采购预估困难与系统性浪费的出现。为解决上述架构性和服务体验的瓶颈，本研究系统性地设计并实现了一套基于微信小程序的校园智慧餐饮信息管理平台。

该系统在底层架构构建上遵循微服务化和前后端分离的设计范式。服务端基于 Spring Boot 2.4.5 框架搭建具有高度可扩展性的 RESTful API 业务网关，并依托 MyBatis Plus 3.4.2 实现复杂关系型模型在 MySQL 5.7+ 数据库中的高效持久化。针对多租户特型的认证体系，系统运用了基于加密摘要算法的 JWT（JSON Web Token）无状态鉴权安全机制，极大提升了分布式场景下的会话并发承载力。在展现层，师生端采用原生的微信小程序架构实现轻量化跨平台订餐闭环，而系统管理员与驻场商家端则由 Vue 3 结合 Element Plus 构建，通过引入 Vite 引擎确保了数据大屏的响应式渲染与即时数据交互。

此外，本研究跳出了传统“基于销量的被动式菜品筛选”困境，在业务架构的核心流程中创新性地引入了外部大语言模型（基于豆包 LLM API 等自然语言大模型底座）。通过在后端构建严密的语义隔离上下文环境配置（Context Parameter Injection），系统使得原本冷冰冰的筛选页面演化成了具备自然语义意图识别能力的智能点餐客服枢纽。用户可通过非结构化自然语言表达用餐诉求，大模型则利用强大的通识推理泛化能力将其精准映射至本地库表内的结构化菜品数据集，最终通过 JSON 序列化组件动态装配投放到前端页面。

在系统测试阶段，采用自动化黑盒功能回归测试与基于 Apache JMeter 驱动的并发链路探测证实了体系的健壮性：在单机容器节点模拟 500 QPS 的极限读写冲突下，通过 InnoDB 引擎内置锁行隔离与声明式事务（@Transactional）精准阻断了高频“超卖”雪崩效应，并利用 WebSocket 全双工协议实现了无延迟的商户端订单推送响应。该平台不仅显著降低了校园餐饮体系的网络交易摩擦成本，同时也为传统 O2O（Online To Offline）校园后勤服务与 AIGC（人工智能生成内容）相关技术的深度融合提供了可靠的工程级实践思路。

**关键词**：微信小程序；智慧餐饮；Spring Boot；无状态鉴权(JWT)；自然语言大模型(LLM)；高并发事务

---

## Abstract

In the context of deepening the informatization construction of higher education, traditional campus catering logistics services, which highly rely on intensive human resources and experience-oriented extensive management models, are gradually unable to adapt to the multi-dimensional needs of the large and fast-growing group of teachers and students in terms of ordering experience, dietary structure, and timeliness. Especially during peak dining periods, the centralized run on physical space not only causes severe internal friction of logistical resources but also leads to difficulties in food procurement estimation and systematic waste. To address the above-mentioned structural and service experience bottlenecks, this study systematically designed and implemented a campus smart catering information management platform based on the WeChat mini-program.

The underlying architecture of the system follows the design paradigm of microservices and the separation of front and back ends. The server side establishes a highly scalable RESTful API business gateway based on the Spring Boot 2.4.5 framework and relies on MyBatis Plus 3.4.2 to achieve efficient persistence of complex relational models in the MySQL 5.7+ database. For the multi-tenant authentication system, the system utilizes the JWT (JSON Web Token) stateless authentication security mechanism based on cryptographic digest algorithms, greatly enhancing the concurrent session carrying capacity in distributed scenarios. In the presentation layer, the teacher-student terminal adopts the native WeChat mini-program architecture to achieve a lightweight cross-platform ordering closed loop, while the system administrator and resident merchant terminals are constructed tightly by Vue 3 combined with Element Plus, utilizing the Vite engine to ensure responsive rendering and real-time data interaction of the data dashboard.

Furthermore, jumping out of the traditional "passive dish filtering based on sales volume" dilemma, this research innovatively incorporates an external large language model (based on NLP models like Doubao LLM API) into the core flow of the business architecture. By building a strict contextual parameter injection environment on the backend, the system evolves the formerly rigid filtering page into an intelligent ordering customer service hub with natural semantic intent recognition capabilities. Users can express their dining appeals via unstructured natural language, and the large model utilizes its powerful general-knowledge generalization and reasoning capabilities to accurately map them to the structured dish dataset within the local database tables, ultimately assembling and releasing them to the front-end page dynamically via JSON serialization components.

During the system testing phase, automated black-box functional regression testing and concurrent link probing driven by Apache JMeter confirmed the robustness of the architecture: under simulated 500 QPS extreme read-write conflicts on a single-machine container node, the high-frequency "oversold" avalanche effect was precisely blocked through the internal row-level locks of the InnoDB engine and declarative transactions (@Transactional), and a real-time merchant order push response without delay was accomplished via the WebSocket full-duplex protocol. This platform not only significantly reduces the network transaction friction costs of the campus catering system but also provides a reliable engineering-level practical idea for the deep integration of traditional O2O (Online To Offline) campus logistics services with AIGC (Artificial Intelligence Generated Content) related technologies.

**Keywords**: WeChat Mini-Program; Smart Catering; Spring Boot; Stateless Authentication (JWT); Large Language Model (LLM); High Concurrency Transaction

---

## 第1章 绪论

### 1.1 研究的宏观背景与现实意义探讨

信息化社会的迭代已深刻影响了社会各垂直服务领域的运作机制。高等院校作为前沿技术的实验田与发源地，其在“智慧校园”信息化方面的建设程度从侧面映射了整个院校的综合治理水平。然而，长期以来，校园后勤管理——尤以占据校园师生绝大多数活动体量的餐饮服务——仍处在信息化建设的薄弱真空地带。
现阶段，我国大多数高校食堂的管理与服务依然采取高度传统的“物理展台挑选、序列排队取餐、一卡通终端扣费”交互模式。该模式在数据时效性和资源配置上存在以下结构性弊病：
第一，**时空资源分配的极度不均衡**。校园特殊的作息制度决定了每日必定存在数个极其陡峭的就餐波峰段（例如 11:45 至 12:30）。在高峰区间内，瞬时聚集的客流大幅超过物理窗口的服务吞吐阈值，造成了师生时间的大量无效空耗。
第二，**数据真空导致的后勤资源粗放损耗**。由于缺乏线上预约及大数据沉淀系统，独立运营的各个食堂档口（商户）只能依赖厨师或管理者主观经验进行粗略的食材估量。当偏差发生时，不是导致菜品过早售罄造成用户满意度锐减，就是造成了大量餐后厨余倾倒，有悖于新时代绿色校园的发展导向。
第三，**信息孤岛现象扼杀了服务体验的升级空间**。面对多达数十级的类目和几百种菜品，学生无法基于精准的过敏原、热量和即时身体状况进行有效筛选。传统的食堂展示面板使得消费者与售卖者长期处于信息不对称的被动关系之中。

在此背景下，利用移动互联网、微服务及大规模并发处理技术，搭建一套全链路的校园智慧餐饮系统，具有十分关键的理论应用价值与工程实践意义。本系统依托于国民级社交软件微信所衍生的“小程序”生态容器，极大地降低了端侧流量的获客成本并免除了复杂安装依赖。该系统不仅解构并将点餐行为前置到了用户的碎片化时间中去消化，更意图在后端重构一张精确到每一次交易流水与评价的数据捕获网。尤其是项目中针对性地嵌入了大语言模型进行自然语言交互式的辅助点餐系统，彻底模糊了以往代码机械检索与人类沟通语境之间的界限。长远来看，本项目为高校数字化后勤管理提供了一套高内聚、低耦合的标准参考解决范式。

### 1.2 国内外行业演进现状

纵观全球智慧高校及机构内餐饮的信息化沿革，不难发现不同地域所采取的技术演进曲线并不尽相同。

在发达国家的高等教育学府（如哈佛大学、麻省理工学院等），基于庞大的后勤运维预算支撑，他们的餐饮信息化起步极早并高度统一。其大多通过外包引入 Aramark（爱玛客）或是 Sodexo（索迪斯）等跨国企业级的全生命周期管理软件，且在物理终端配套了带有高精度图像识别及多维传感器的结算闸机，甚至开始覆盖自动驾驶机器人进行校内固定点餐食投递。但由于当地极其注重个人敏感数据流的合规（如 GDPR ），这类系统的后台往往局限于被动的统一核算，其算法对个体用户喜好的纵深挖掘及深度智能化的交互体系拓展上反而显得步履蹒跚。并且，高昂的商业闭源系统授权费以及高昂的硬件配套门槛，导致其系统对于其他中等规模的高校并不具备普适下沉的能力。

回到国内，伴随由“美团”、“饿了么”主导的商业 O2O 餐饮革命，极大倒逼了校园局部餐饮的信息化意识觉醒。大量高校引入了诸如“扫码点餐”、“智慧餐盘结算”等碎片化子系统。但从系统工程学角度审视目前国内的开源案例及商业竞品，仍普遍暴露以下底层缺陷：
1. **架构老旧导致的瞬时承压脆弱性。** 大多流通于市面的系统仍拘泥于单体结构，过度依赖对单一关系型数据库裸数据流的锁定。一旦面临下课瞬时数千人的脉冲式访问流量冲击，往往触发大量脏读或者抛出连接池满载等应用层异常崩溃（Downtime）。
2. **算法僵硬造成的“伪智能”痛点。** 现有的所谓的“推荐模块”几乎呈现出一种机械式的数据堆砌——要么全量进行 `order by sales DESC` 以静态销量展示，要么引入如协同过滤算法（Collaborative Filtering）但因为长期面临严重的数据稀疏性冷启动问题，导致计算得出的推荐列表经常毫无逻辑性且运算代价过大。这使得“智能系统”徒具其表。

综上所述，利用具备横向拓展能力的 Spring Boot 框架、具备隔离鉴权特性的 JWT 机制，以及最为关键的——降维引入大语言模型自然语言理解能力从而彻底剥离自建高维护成本推荐算法的做法，成为本项目最为核心的研发驱动力与行业突围方法论。

### 1.3 论文主要内容结构

本论文共分为七个核心章节，分别从系统的背景构想、技术架构解析、严密的需求工程构建、底层详细设计、核心机制与并发解决方案落实现、至系统高稳定承压测试闭环，旨在完整反映一名软件工程开发者对大型应用系统的全生命周期把控能力。具体划分如下：
1. **第1章 绪论**：探究研究初衷与时代宏观动因，对比多方竞品并引出本课题设计的合理性与开创价值。
2. **第2章 基础支撑技术体系原理论证**：从计算机工程视角深层剖析 Spring Boot、MyBatis Plus、Vue3、JWT 及核心 AI 框架底座为何能匹配当前业务诉求。
3. **第3章 双边需求建模与用例推演**：采用软件过程工程学标准详细解剖三端（用户、商家、管理）用例需求与其关键性非功能指标约束。
4. **第4章 系统网络拓扑架构与精密数据库设计**：提供系统级高并发网关路由分离模型以及高度遵循业务第三范式的数据库实体抽象（ER 视图）与外键解耦设计逻辑。
5. **第5章 核心业务模块算法与代码级设计**：重点论述 JWT 的加密攻防逻辑、库存锁防控策略（基于特定行粒度的 InnoDB 引擎操作），以及结合大语言模型构建的语义对话中枢的具体实现源码思路。
6. **第6章 容错与并发极限测试与分析**：详述利用 JMeter 对该应用微服务环境进行高吞吐压测的结果，以及面对非法输入数据的安全拦截响应分析。
7. **第7章 总结与后续远景规划展望**。

---

## 第2章 基础支撑技术体系原理论证与深度剖析

现代工程化软硬件系统的搭建切忌凭借经验或盲目追高的主观技术堆叠。任何一行底层框架的引入都必须基于该框架能否消除特定业务链条上的高耗阻力来进行科学权衡。本项目横跨了移动端、前后端分离 Web 页面、复杂的关系型数据落地以及第三方的接口泛化集成体系。

### 2.1 基于控制反转容器的核心骨架：Spring Boot 2.4.5 运作机理

面对餐饮系统所特有的极其复杂的订单状态流转（例如待付款、退款中、驳回、已派送）、多样的数据验证隔离，传统 Spring 框架的繁冗 XML 声明周期管理（如手动装配 Bean 的注册和数据池映射）极大拖慢了开发周期的敏捷性。

故本项目核心层彻底采用了 **Spring Boot 2.4.5**，借其核心特性“约定优于配置（Convention Over Configuration）”实现组件的按需动态加载。
在程序启动时，启动器上的 `@SpringBootApplication` 注解将作为一个复合型注解去触发 `@EnableAutoConfiguration`。底层的 `SpringFactoriesLoader` 机制将迅速扫描 `META-INF/spring.factories` 配置文件内的第三方依赖。这一步对于本项目至关重要：它能够根据当前的 Classpath 环境内是否存在特定库，自动实例化（Instantiate）出诸如 `TomcatWebServerFactoryCustomizer` 等大量的底层配置对象，这抹除了开发者维护 Tomcat 生命周期等低层次通信模块所需消耗的精力。同时，Spring Framework 内核特带的 IoC（控制反转）和 DI（依赖注入）极大程度减少了例如 `OrderServiceImpl` 对 `DishMapper` 及其他服务的强硬编码依赖。其统一被上下文接管的方式，让针对业务接口做单体集成热插拔和隔离级别的自动测试成为了轻而易举的可能。

### 2.2 彻底重塑关系映射生态：MyBatis Plus 3.4.2的编译期优化

为了从后台拉取商品列表并进行极其苛刻的多维度（包含多口味标签、逻辑删除识别和库存条件）复杂组合式搜索，传统的 JDBC 防护机制过于孱弱，且直接由拼接字符串（`"` + "AND" + `"`）带来的开发体验无异于刀尖起舞，存在大量隐性被攻击风险（如著名的 SQL Injection 漏洞）。虽然原生的 MyBatis 做到了 SQL 与代码的文本割裂，但也要求极高维护成本的手动 Mapper XML 文件映射。

故持久层架构采用了 **MyBatis Plus 3.4.2**（MP）。它的精妙之处在于不侵入原生 MyBatis 的 `SqlSessionFactory` 核心构建器，而是在系统运行时借助底层的 Java 反射机制以及拦截器动态推导并拼接 SQL 预编译语句。
在开发中应用最深的便是其引入的 `LambdaQueryWrapper<T>` 数据结构体系。通过严格保证类型安全的 Lambda 方法引用（如 `Wrapper.eq(Dish::getStatus, 1)`），直接将字段绑定的硬编码错误消除在了 IDE 的前端编译阶段。而在向数据库提交 SQL 更新事件（如下单后对存量餐品的物理库削减）时，MP 本身内部重写的批量增删改和乐观锁插件同样大大夯实了底层的可靠防线。

### 2.3 无状态防护壁垒与分布式信任：JSON Web Token（JWT）加密模型

在传统的 Web 服务交互里，服务端需要通过维持一张巨大的 `HttpSession` 对照表去映射客户端请求捎带过来的 `SessionID` Cookie。当并发数来到高峰且前端应用场景为原生微信小程序时，由于微信客户端 HTTP 请求体天生不包含 Cookie 自动化携带规范，导致了传统维持状态标识的失效。同时一旦后续扩容至微服务或多前置节点进行轮询派发，就将不可避免地面临 Redis 等 Session 集中式共享存储的高可用灾难风险。

为了彻底实现前后台基于“完全零信任”原则的系统剥离，我们全面引入并对接了 **JJWT 库**，采用基于行业统一标准的 RFC 7519 JWT 协议模型作为所有交易及资料修改操作的接口大门凭证。
本系统对身份签发模块的改造如下：
- **第一环，签发态（Sign Phase）：** 客户端正确携带授权认证（如加密手机号验证通过或账密核实）请求登陆端点后，服务器摒弃建立任何 Session。它仅仅抽取出用户数据表的内部身份自增器 ID （即 User_id 等抽象标识），装填进入 JWT 的第二部分（Payload）。紧接着，服务器根据其潜藏在配置代码中的最核心签名秘钥（Salt Secret），使用成熟不可逆的 **HMAC-SHA256（HS256）** 将请求头（Header）与载荷压制成不可破译的哈希密文拼接在第三段（Signature）。这样生成的三段式字符串（以 `.` 分隔）完整下发出应用端，彻底释放自身的内存负荷保存压力。
- **第二环，验权态（Verify Phase）：** 该方案下，所有的后续如提交订单 `POST /order/submit` 等动作都被限定在 Spring HTTP 层配置了全局的拦截器 `HandlerInterceptor` 内阻断。拦截器每次均用内部同一套算法针对拦截到的 Token 重建一次 HS256 ，若生成的摘要与用户传过来的相符，且载具未过时间期效（Expiration），则准予执行。否则即判定数据被恶劣破坏抛出非法请求，系统这种彻底无状态的设计，换取了网络资源上的极高开销比。

### 2.4 异步数据响应与单页面渲染树构建：基于 Vue3 的 Composition API

考虑到针对大体量及高结构维度的信息（包含店铺财务可视化图形、复杂菜品多图上传管理及菜单层级树操作），这部分运营监控管理平台需要向后端执行大量极速的异步（AJAX）网络交互读取，系统的前置框架运用了 **Vue 3**。

相比于过去由 `Options API` 所带来的跨行找方法逻辑分裂问题，系统在后台编码时深度遵循了全新的 `Composition API （组合式 API）`设计。开发者得以使用 `<script setup>` 这种极度声明且轻量化的组件封装技术，令例如“监听后端 WebSocket 数据广播挂载方法”与“调用获取统计订单折线图 `echarts` 重绘画的响应逻辑”实现了真正的低耦合高内聚管理。搭配新型基于 ESBuild 本机扩展库构建的 **Vite 编译器**，不仅开发环境不再像过去 Webpack 般需要耗费大量分秒进行打包热重载（HMR），且它能极小化生产阶段在打包时的体积并内置原生的依赖树拆解分割方法以实现代码级的首刷秒开。

### 2.5 打破固定检索匹配：大模型（LLM）的智能解构重塑意愿

系统如何利用其“高大上”的科技身份去区别大量陈旧同质系统？它引入了一套被“伪装”并封装良好的 LLM 通信对接适配层（其基于主流通用接口协议对接以实现例如字节豆包等大预训练智能体 API）。

传统的 SQL 查询逻辑只容许极其严格的确切匹配。如果想做复杂的协同个性化推荐，不仅需要耗费大量数据去描绘离线计算的用户特征工程（Feature Engineering），而其长达多日的批量式处理与时效特性根本无法面对类似用户突然的一句：“发热喉咙痒推荐个没有海鲜元素的软饭”这种口语且蕴含着重重隐式排斥因子的请求。
大语言模型具有对基于自然语言建立的高阶向量重映射泛化解构能力。系统内配置的代码片段如下：不搭建成本昂贵的私有深度学习机群，而是采用了极度精细化并被工程界验证可行的提示工程注入（Prompt Engineering Context Injection）。我们将数据库中符合时空条件（当期开店、非缺货）所有包含标签规格组合及主键 ID 的轻量级 JSON 文本串作为 `System Context Parameter` 绑定进入 HTTP 或 REST 请求通道抛送给云端。令模型在一个绝对限制在当前菜单封闭域的情景（Zero-Shot 或 Few-Shot 标准下）进行约束式的思考回答。如此极大限度剥离了前端繁复的树形展开结构以及无休止的被动筛选搜索消耗，在工程层将智能化这一指标彻底夯实。
