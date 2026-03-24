# Block Blast 消除游戏 - 技术方案

> 状态：待架构师审阅
> 创建时间：2026-03-18
> 创建者：小助理

---

## 一、项目概述

做一个类似 Hungry Studio 家 Block Blast 的消除类益智游戏 App。

### 核心玩法
- 8x8 网格，拖拽放置方块
- 填满行/列消除得分
- 连击加成
- 无尽模式挑战高分

### 功能需求
1. 游戏核心玩法
2. 全球排行榜
3. 地区排行榜（按用户位置）
4. 广告接入（激励视频、插屏）
5. 用户系统（跨设备同步）

---

## 二、整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        用户端 (App)                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Flutter    │  │  游戏      │  │     广告SDK         │ │
│  │  游戏引擎   │  │  核心逻辑   │  │  穿山甲/AdMob       │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│         │                │                    │             │
│         └────────────────┼────────────────────┘             │
└──────────────────────────┼──────────────────────────────────┘
                           │ HTTPS
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      云服务器 (阿里云)                        │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Nginx     │───▶│  Node.js    │───▶│   MySQL     │     │
│  │  反向代理   │    │  API服务    │    │   数据库    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                           │                                 │
│                    ┌──────┴──────┐                         │
│                    │   Redis     │                         │
│                    │  缓存/排行榜 │                         │
│                    └─────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 三、技术选型

| 层级 | 技术 | 理由 |
|------|------|------|
| **前端框架** | Flutter 3.x | 跨平台、性能好、一套代码iOS+Android |
| **游戏渲染** | Flutter Canvas | 消除类游戏够用，不需要复杂引擎 |
| **状态管理** | Riverpod | Flutter官方推荐，简洁高效 |
| **后端语言** | Node.js + Express | 前后端统一语言，团队都能写 |
| **数据库** | MySQL 8.0 | 关系型，排行榜查询方便 |
| **缓存** | Redis | 排行榜实时排名，性能好 |
| **服务器** | 阿里云ECS | 国内访问快，~50元/月 |
| **广告SDK** | 穿山甲（国内）+ AdMob（海外） | 收益高，覆盖广 |

---

## 四、模块拆分

```
BlockBlast/
├── app/                    # Flutter App
│   ├── lib/
│   │   ├── game/          # 游戏核心
│   │   │   ├── grid.dart      # 8x8网格
│   │   │   ├── block.dart     # 方块定义
│   │   │   ├── drag.dart      # 拖拽逻辑
│   │   │   └── clear.dart     # 消除逻辑
│   │   ├── ui/            # 界面
│   │   │   ├── home.dart      # 首页
│   │   │   ├── game.dart      # 游戏页
│   │   │   └── rank.dart      # 排行榜页
│   │   ├── api/           # 接口
│   │   ├── ad/            # 广告
│   │   └── main.dart
│   └── pubspec.yaml
│
└── server/                 # 后端服务
    ├── src/
    │   ├── routes/        # 路由
    │   │   ├── score.js       # 分数相关
    │   │   ├── rank.js        # 排行榜
    │   │   └── user.js        # 用户
    │   ├── models/        # 数据模型
    │   ├── middleware/    # 中间件
    │   └── app.js
    └── package.json
```

---

## 五、数据库设计

```sql
-- 用户表
CREATE TABLE users (
  id VARCHAR(36) PRIMARY KEY,
  device_id VARCHAR(100) UNIQUE NOT NULL,  -- 设备唯一标识
  nickname VARCHAR(50),
  avatar_url VARCHAR(255),
  region VARCHAR(50),          -- 地区（省/市）
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);

-- 分数表
CREATE TABLE scores (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  score INT NOT NULL,
  region VARCHAR(50),
  play_time INT,               -- 游戏时长（秒）
  blocks_placed INT,           -- 放置方块数
  combos INT,                  -- 连击数
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_score (score DESC),
  INDEX idx_region_score (region, score DESC),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 游戏配置表
CREATE TABLE configs (
  `key` VARCHAR(50) PRIMARY KEY,
  value TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 预设配置
INSERT INTO configs VALUES 
('ad_enabled', 'true'),
('ad_interval', '3'),           -- 每3局显示一次插屏广告
('min_score_submit', '1000');   -- 最低提交分数
```

---

## 六、API接口设计

```
基础URL: https://api.blockblast.com/v1

【用户相关】
POST   /user/register        # 设备注册/登录
GET    /user/profile         # 获取用户信息
PUT    /user/profile         # 更新昵称/头像

【分数相关】
POST   /score/submit         # 提交分数
请求: { user_id, score, region, play_time, blocks_placed, combos }
响应: { rank: 1234, is_new_best: true }

【排行榜】
GET    /rank/global          # 全球排行榜
GET    /rank/region          # 地区排行榜
请求: ?region=成都&limit=100
响应: { list: [{rank, nickname, score, region}], my_rank: 1234 }

【配置】
GET    /config               # 获取游戏配置
响应: { ad_enabled, ad_interval, min_version }
```

---

## 七、开发顺序

```
Phase 1: 游戏核心（第1-2周）
├── Day 1-3: 网格渲染 + 方块拖拽
├── Day 4-6: 消除逻辑 + 动画效果
├── Day 7-10: 分数系统 + 游戏结束
└── Day 11-14: UI美化 + 本地存分

Phase 2: 后端搭建（第3周）
├── Day 1-2: 服务器购买 + 环境配置
├── Day 3-4: 数据库 + API基础
├── Day 5-6: 分数上传 + 排行榜
└── Day 7: 联调测试

Phase 3: 广告接入（第4周）
├── Day 1-3: 穿山甲SDK接入
├── Day 4-5: 激励视频 + 插屏广告
└── Day 6-7: 广告配置动态控制

Phase 4: 打包上线（第5周）
├── Day 1-3: 打包APK + 内测
├── Day 4-5: Bug修复 + 优化
└── Day 6-7: 上架商店/分发
```

---

## 八、成本预估

| 项目 | 费用 |
|------|------|
| 服务器（1核2G） | ~50元/月 |
| 域名 | ~50元/年 |
| MySQL | 含在服务器内 |
| Redis | 含在服务器内 |
| 广告SDK | 免费（平台抽成30%） |
| **首年总计** | **~700元** |

---

## 九、风险点

| 风险 | 影响 | 应对 |
|------|------|------|
| **智谱API限流** | 开发进度慢 | 控制并发，串行派活 |
| **iOS打包需Mac** | 无法上架App Store | 先做Android，iOS租Mac或找朋友 |
| **广告审核** | 上架延迟 | 提前准备资质材料 |
| **防作弊** | 分数造假 | 服务端校验 + 设备指纹 |
| **服务器成本** | 预算超支 | 先用最低配，按需升级 |

---

## 十、开发进度

### 2026-03-18
- ✅ 技术方案讨论完成
- ✅ 架构师审核通过
- ✅ Flutter项目结构创建
- ✅ 游戏核心代码框架完成
  - main.dart: 入口文件
  - game/block.dart: 方块定义（15种形状）
  - game/grid.dart: 8x8网格渲染
  - game/drag.dart: 拖拽逻辑
  - game/clear.dart: 消除逻辑
  - ui/game_page.dart: 游戏主页面

### 2026-03-19
- ✅ Flutter环境安装完成（运维哥）
- ✅ 限流问题解决（maxConcurrent: 2）
- ✅ 消息推送体验优化

### 2026-03-19
- ✅ 限流问题解决（maxConcurrent: 4→2）
- ✅ 消息推送体验优化（blockStreamingCoalesce调整）

### 待完成
- [ ] 安装Linux toolchain（需要sudo权限）
- [ ] 运行测试游戏核心
- [ ] 优化UI和动画
- [ ] 后端API开发
- [ ] 广告接入

---

## 十一、待确认事项

- [x] 架构师审阅方案 ✅
- [x] 限流问题解决 ✅
- [ ] 确认服务器购买时机
- [ ] 确认广告平台选择
- [ ] 确认是否需要iOS版本

---

*文档维护：小助理*
*最后更新：2026-03-19 00:08*
