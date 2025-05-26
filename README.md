# Electron多浏览器管理应用

一个基于Electron + React + TypeScript的极简多浏览器实例管理应用，支持账号隔离和扩展配置。

## ✨ 特性

- 🚀 **现代化技术栈**: Electron 27+ + React 18 + TypeScript + Vite
- 🎨 **美观界面**: Tailwind CSS + 深色主题
- 📦 **轻量状态管理**: Zustand
- 🔒 **数据隔离**: 每个账号独立的浏览器会话
- 🔧 **易于扩展**: 策略模式设计，预留指纹伪装等扩展接口
- ⚡ **快速开发**: 热更新 + TypeScript严格模式

## 🏗️ 项目结构

```
src/
├── main/                 # 主进程
│   ├── index.ts         # 应用入口
│   ├── window-manager.ts # 窗口管理器
│   └── ipc-handlers.ts  # IPC处理器
├── renderer/            # 渲染进程
│   ├── App.tsx         # 主组件
│   ├── components/     # UI组件
│   └── stores/         # 状态管理
├── shared/             # 共享代码
│   ├── types.ts       # 类型定义
│   └── constants.ts   # 常量配置
└── preload/           # 预加载脚本
    └── index.ts
```

## 🚀 快速开始

### 安装依赖
```bash
npm install
```

### 开发模式
```bash
npm run dev
```

### 构建应用
```bash
npm run build
```

### 打包应用
```bash
# 全平台
npm run package

# Windows
npm run package:win

# macOS  
npm run package:mac

# Linux
npm run package:linux
```

## 🎯 核心功能

### 1. 账号管理
- ✅ 创建/删除账号
- ✅ 账号状态管理 (空闲/运行中/错误)
- ✅ 账号列表展示

### 2. 浏览器实例管理  
- ✅ 独立浏览器窗口创建
- ✅ 数据隔离 (使用partition)
- ✅ 实例启动/停止控制

### 3. 扩展接口 (预留)
- 🔄 指纹伪装配置
- 🔄 代理配置
- 🔄 自动化行为脚本
- 🔄 AI集成接口

## 🔧 配置说明

### 类型定义
所有核心类型定义在 `src/shared/types.ts`，包含：
- `BrowserAccount`: 账号基础信息
- `AccountConfig`: 账号配置选项 
- `FingerprintConfig`: 指纹配置 (预留)
- `BehaviorConfig`: 行为配置 (预留)

### 常量配置
应用配置在 `src/shared/constants.ts`，包含：
- 窗口尺寸配置
- IPC通信频道
- 默认User-Agent列表

## 🏛️ 架构设计

### 策略模式
- 窗口管理器使用策略模式，支持不同的浏览器配置策略
- 预留指纹注入、代理配置等扩展点

### 状态管理
- 使用Zustand进行轻量级状态管理
- 集中管理账号状态和实例控制逻辑

### IPC通信
- 安全的主进程-渲染进程通信
- 类型安全的API设计

## 🔒 安全特性

- Context Isolation启用
- Node Integration禁用  
- 安全的preload脚本
- 数据隔离 (partition)

## 📈 扩展计划

### Phase 1 (当前)
- ✅ 基础架构搭建
- ✅ 账号管理界面
- ✅ 浏览器实例创建

### Phase 2 (下一步)
- 🔄 指纹伪装配置界面
- 🔄 代理配置功能
- 🔄 用户行为录制/回放

### Phase 3 (未来)
- 🔄 AI自动化集成
- 🔄 批量操作功能
- 🔄 数据导入/导出

## 🛠️ 开发指南

### 添加新功能
1. 在 `shared/types.ts` 中定义相关类型
2. 在 `main/` 中实现主进程逻辑
3. 在 `renderer/` 中实现UI组件
4. 通过IPC进行通信

### 扩展配置
1. 修改 `AccountConfig` 接口
2. 在 `WindowManager` 中实现配置应用逻辑
3. 在UI中添加相应的配置选项

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交Issue和Pull Request！

---

**验收标准**:
- ✅ `npm run dev` 启动开发环境
- ✅ 显示主界面，有"创建账号"按钮  
- ✅ 点击按钮能弹出基础的浏览器窗口
- ✅ 代码结构清晰，易于理解和修改