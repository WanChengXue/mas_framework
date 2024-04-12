---
title: model_test
language_tabs:
  - shell: Shell
  - http: HTTP
  - javascript: JavaScript
  - ruby: Ruby
  - python: Python
  - php: PHP
  - java: Java
  - go: Go
toc_footers: []
includes: []
search: true
code_clipboard: true
highlight_theme: darkula
headingLevel: 2
generator: "@tarslib/widdershins v4.0.23"

---

# model_test

Base URLs:

* <a href="http://test-cn.your-api-server.com">测试环境: http://test-cn.your-api-server.com</a>

# Authentication

# Default

## GET /

GET /

> 返回示例

> 成功

```json
{
  "operation": [
    "new",
    "load",
    "exit"
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|成功|Inline|

### 返回数据结构

## GET /new

GET /new

> 返回示例

> 成功

```json
{
  "conversation_cache": [],
  "game_id": "ArTydPKePg6wESLkPYlO9Q=="
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|成功|Inline|

### 返回数据结构

## GET /get_game_observation

GET /get_game_observation

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|game_id|query|string| 否 |none|

> 返回示例

> 成功

```json
{
  "conversation_cache": [
    "test_question_actor: 你是一只小猫咪",
    "test_answer_actor: 你吃了没",
    "test_critic_actor: 基于你们的QA问答，我总结的到以下几点: 1. xxx \n 2. xxx \n 3.xxx",
    "test_question_actor: 你是一只小猫咪",
    "test_answer_actor: 太累了，睡觉",
    "test_critic_actor: 基于你们的QA问答，我总结的到以下几点: 1. xxx \n 2. xxx \n 3.xxx",
    "test_question_actor: 你是一只小猫咪",
    "test_answer_actor: 我想要放假",
    "test_critic_actor: 基于你们的QA问答，我总结的到以下几点: 1. xxx \n 2. xxx \n 3.xxx"
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|成功|Inline|

### 返回数据结构

## GET /new_actor

GET /new_actor

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|game_id|query|string| 否 |none|
|actor_type|query|string| 否 |none|
|actor_name|query|string| 否 |none|

> 返回示例

> 成功

```json
{
  "actor_name": "test_question_actor"
}
```

```json
{
  "actor_name": "test_answer_actor"
}
```

```json
{
  "actor_name": "test_critic_actor"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|成功|Inline|

### 返回数据结构

## GET /question

GET /question

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|game_id|query|string| 否 |none|
|actor_name|query|string| 否 |none|
|question|query|string| 否 |none|

> 返回示例

> 500 Response

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器错误|Inline|

### 返回数据结构

# 数据模型

