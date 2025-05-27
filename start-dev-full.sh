#!/bin/bash

echo "🚀 启动完整开发环境"
echo "=================="

# 清理旧的编译文件
echo "🗑️  清理编译缓存..."
rm -rf dist/

# 编译主进程
echo "🏗️  编译主进程..."
if npm run build:main; then
    echo "✅ 主进程编译成功"
else
    echo "❌ 主进程编译失败"
    exit 1
fi

echo "🔄 同时启动 Electron 和 Vite 开发服务器..."

# 使用 concurrently 同时启动
npx concurrently \
    --names "ELECTRON,VITE" \
    --prefix-colors "cyan,magenta" \
    "sleep 2 && NODE_ENV=development electron dist/main/index.js --dev" \
    "vite --config vite.config.ts --port 3000"
