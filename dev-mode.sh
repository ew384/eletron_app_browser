#!/bin/bash

echo "🔄 开发模式启动..."

# 清理旧的编译文件
rm -rf dist/

echo "🏗️  编译主进程..."
if npm run build:main; then
    echo "✅ 主进程编译成功"
    
    echo "🚀 启动开发模式..."
    # 同时启动 Electron 和 Vite 开发服务器
    concurrently \
        "electron dist/main/index.js" \
        "vite --config vite.config.ts"
else
    echo "❌ 编译失败，请检查代码"
fi
