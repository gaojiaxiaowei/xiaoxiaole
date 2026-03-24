# Block Blast API 接口文档 v1.0

## 概述

本文档定义了 Block Blast 游戏的后端 API 接口规范。

**基础URL**: `https://api.blockblast.game/v1`

**认证方式**: Bearer Token (JWT)

**请求格式**: JSON

**响应格式**: JSON

---

## 通用响应结构

### 成功响应
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

### 错误响应
```json
{
  "code": 4001,
  "message": "错误描述",
  "data": null
}
```

### 错误码定义
| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（token无效或过期） |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 4001 | 用户名已存在 |
| 4002 | 密码错误 |
| 4003 | 用户不存在 |
| 5000 | 服务器内部错误 |

---

## 1. 用户相关接口

### 1.1 用户注册

**POST** `/api/user/register`

**请求参数**:
```json
{
  "username": "player001",
  "password": "SecurePass123!",
  "nickname": "游戏达人",
  "device_id": "uuid-device-id"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 用户名，4-20字符，字母数字下划线 |
| password | string | 是 | 密码，6-32字符 |
| nickname | string | 否 | 昵称，默认为用户名 |
| device_id | string | 是 | 设备唯一标识 |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "user_id": "u_12345678",
    "username": "player001",
    "nickname": "游戏达人",
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "refresh_token_here",
    "expires_at": 1711111111
  }
}
```

---

### 1.2 用户登录

**POST** `/api/user/login`

**请求参数**:
```json
{
  "username": "player001",
  "password": "SecurePass123!",
  "device_id": "uuid-device-id"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |
| device_id | string | 是 | 设备唯一标识 |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "user_id": "u_12345678",
    "username": "player001",
    "nickname": "游戏达人",
    "avatar": "https://cdn.blockblast.game/avatar/default.png",
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "refresh_token_here",
    "expires_at": 1711111111,
    "stats": {
      "total_games": 128,
      "highest_score": 9856,
      "total_score": 125680
    }
  }
}
```

---

### 1.3 获取用户信息

**GET** `/api/user/profile`

**请求头**:
```
Authorization: Bearer {token}
```

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| user_id | string | 否 | 用户ID，不传则获取当前登录用户信息 |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "user_id": "u_12345678",
    "username": "player001",
    "nickname": "游戏达人",
    "avatar": "https://cdn.blockblast.game/avatar/default.png",
    "level": 15,
    "experience": 12500,
    "created_at": "2024-01-15T10:30:00Z",
    "stats": {
      "total_games": 128,
      "highest_score": 9856,
      "total_score": 125680,
      "daily_streak": 7,
      "challenges_completed": 45
    }
  }
}
```

---

## 2. 游戏相关接口

### 2.1 提交分数

**POST** `/api/score/submit`

**请求头**:
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "score": 8856,
  "lines_cleared": 12,
  "blocks_placed": 45,
  "game_mode": "classic",
  "duration_seconds": 180,
  "device_id": "uuid-device-id",
  "timestamp": 1711111111
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| score | int | 是 | 最终得分 |
| lines_cleared | int | 是 | 消除行数 |
| blocks_placed | int | 是 | 放置方块数 |
| game_mode | string | 是 | 游戏模式：classic/challenge |
| duration_seconds | int | 是 | 游戏时长（秒） |
| device_id | string | 是 | 设备ID |
| timestamp | int | 是 | 客户端时间戳 |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "record_id": "r_12345678",
    "score": 8856,
    "rank": 156,
    "is_new_high": true,
    "rewards": {
      "experience": 88,
      "coins": 50
    }
  }
}
```

---

### 2.2 排行榜

**GET** `/api/score/leaderboard`

**请求头**:
```
Authorization: Bearer {token}
```

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| type | string | 否 | global | 排行类型：global/friends/daily |
| page | int | 否 | 1 | 页码 |
| page_size | int | 否 | 20 | 每页数量（1-100） |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "type": "global",
    "page": 1,
    "page_size": 20,
    "total": 10000,
    "my_rank": 156,
    "my_score": 9856,
    "leaderboard": [
      {
        "rank": 1,
        "user_id": "u_001",
        "nickname": "大神玩家",
        "avatar": "https://cdn.blockblast.game/avatar/1.png",
        "score": 25800,
        "updated_at": "2024-03-20T10:00:00Z"
      },
      {
        "rank": 2,
        "user_id": "u_002",
        "nickname": "消消乐达人",
        "avatar": "https://cdn.blockblast.game/avatar/2.png",
        "score": 24350,
        "updated_at": "2024-03-20T09:30:00Z"
      }
    ]
  }
}
```

---

### 2.3 历史记录

**GET** `/api/score/history`

**请求头**:
```
Authorization: Bearer {token}
```

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| user_id | string | 否 | 当前用户 | 用户ID |
| page | int | 否 | 1 | 页码 |
| page_size | int | 否 | 20 | 每页数量 |
| game_mode | string | 否 | - | 筛选模式：classic/challenge |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "page": 1,
    "page_size": 20,
    "total": 128,
    "records": [
      {
        "record_id": "r_12345678",
        "score": 8856,
        "lines_cleared": 12,
        "blocks_placed": 45,
        "game_mode": "classic",
        "duration_seconds": 180,
        "created_at": "2024-03-20T10:30:00Z"
      },
      {
        "record_id": "r_12345677",
        "score": 5620,
        "lines_cleared": 8,
        "blocks_placed": 32,
        "game_mode": "classic",
        "duration_seconds": 120,
        "created_at": "2024-03-19T15:20:00Z"
      }
    ]
  }
}
```

---

## 3. 每日挑战接口

### 3.1 获取今日挑战

**GET** `/api/challenge/today`

**请求头**:
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "challenge_id": "c_20240320",
    "date": "2024-03-20",
    "title": "消除大师",
    "description": "在单局游戏中消除至少15行",
    "target": {
      "type": "lines_cleared",
      "value": 15
    },
    "rewards": {
      "experience": 200,
      "coins": 100,
      "badge": "elimination_master"
    },
    "is_completed": false,
    "progress": {
      "current": 8,
      "target": 15
    },
    "expires_at": "2024-03-21T00:00:00Z"
  }
}
```

---

### 3.2 完成挑战

**POST** `/api/challenge/complete`

**请求头**:
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "challenge_id": "c_20240320",
  "score": 8856,
  "lines_cleared": 15,
  "blocks_placed": 45,
  "duration_seconds": 180,
  "timestamp": 1711111111
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| challenge_id | string | 是 | 挑战ID |
| score | int | 是 | 本局得分 |
| lines_cleared | int | 是 | 消除行数 |
| blocks_placed | int | 是 | 放置方块数 |
| duration_seconds | int | 是 | 游戏时长 |
| timestamp | int | 是 | 客户端时间戳 |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "challenge_id": "c_20240320",
    "completed": true,
    "rewards_claimed": {
      "experience": 200,
      "coins": 100,
      "badge": "elimination_master"
    },
    "new_level": 16,
    "new_experience": 12700
  }
}
```

---

## 4. Token刷新

### 4.1 刷新Token

**POST** `/api/auth/refresh`

**请求参数**:
```json
{
  "refresh_token": "refresh_token_here"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "new_access_token",
    "refresh_token": "new_refresh_token",
    "expires_at": 1711114711
  }
}
```

---

## 5. 离线模式说明

客户端应实现以下离线功能：

1. **本地缓存用户信息** - 使用 SharedPreferences 或 SQLite
2. **离线分数提交** - 网络恢复后自动同步
3. **本地排行榜** - 缓存最近排行榜数据
4. **挑战状态** - 本地记录完成进度

### 离线数据同步机制

```json
{
  "pending_scores": [
    {
      "id": "local_001",
      "score": 8856,
      "timestamp": 1711111111,
      "synced": false
    }
  ]
}
```

---

## 6. Mock实现说明

当前阶段使用Mock数据，不连接真实服务器：
- 所有接口返回预设的模拟数据
- 数据持久化在本地
- 模拟网络延迟（100-500ms）
- 随机模拟成功/失败场景（可选）

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2024-03-20 | 初始版本 |
