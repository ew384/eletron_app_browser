#!/bin/bash

echo "🔍 基础指纹验证测试"
echo "=================="

echo "🏗️  编译项目..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🚀 启动指纹验证测试..."
    echo "📱 将显示："
    echo "  - 主窗口：欢迎页面"
    echo "  - 新窗口：详细的指纹测试页面"
    echo "  - 控制台：指纹配置信息"
    echo ""
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
    exit 1
fi
