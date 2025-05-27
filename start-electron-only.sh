#!/bin/bash

echo "🚀 仅启动 Electron（独立模式）"
echo "=========================="

# 清理和编译
rm -rf dist/
echo "🏗️  编译主进程..."

if npm run build:main; then
    echo "✅ 主进程编译成功"
    echo "🚀 启动 Electron（独立模式）..."
    
    # 设置环境变量，不尝试连接 Vite
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
    exit 1
fi
