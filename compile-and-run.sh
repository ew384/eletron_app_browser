#!/bin/bash

echo "🏗️  编译主进程..."

# 编译主进程和预加载脚本
if npx tsc -p tsconfig.main.json; then
    echo "✅ 主进程编译成功"
    
    echo "🚀 启动 Electron..."
    # 启动 Electron
    npx electron dist/main/index.js
else
    echo "❌ 主进程编译失败"
    exit 1
fi
