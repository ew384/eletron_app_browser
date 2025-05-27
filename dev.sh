#!/bin/bash
echo "🚀 启动Electron开发环境..."

# 清理旧的构建文件
rm -rf dist

# 编译主进程
echo "📦 编译主进程..."
npx tsc -p tsconfig.main.json

# 检查编译是否成功
if [ ! -f "dist/main/index.js" ]; then
    echo "❌ 主进程编译失败"
    exit 1
fi

echo "✅ 主进程编译成功"

# 启动应用
echo "🎯 启动应用..."
concurrently \
    "npx tsc -p tsconfig.main.json --watch" \
    "vite" \
    "wait-on dist/main/index.js && electron dist/main/index.js"
