#!/bin/bash

echo "🔍 Canvas 指纹调试"
echo "=================="

echo "🏗️  编译调试版本..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🚀 启动调试模式..."
echo "📱 请打开开发者工具查看详细的 Console 日志"
echo "🔍 特别关注以 [Canvas] 开头的日志信息"

NODE_ENV=development electron dist/main/index.js --inspect
