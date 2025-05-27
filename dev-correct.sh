#!/bin/bash

echo "🚀 正确的开发模式"
echo "================"

# 编译
echo "🏗️  编译主进程..."
if npm run build:main; then
    echo "✅ 编译成功"
    
    echo "🔄 启动开发环境..."
    echo "📋 将同时启动:"
    echo "  - Vite 开发服务器 (端口 3000)"
    echo "  - Electron 主进程"
    echo ""
    
    # 使用 concurrently 同时启动
    npx concurrently \
        --names "VITE,ELECTRON" \
        --prefix-colors "magenta,cyan" \
        "vite --config vite.config.ts --port 3000" \
        "sleep 3 && NODE_ENV=development electron dist/main/index.js --dev"
else
    echo "❌ 编译失败"
    exit 1
fi
