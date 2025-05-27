#!/bin/bash

echo "🔍 指纹验证测试"
echo "=============="

echo "📋 本次测试将："
echo "  1. 编译最新代码"
echo "  2. 启动主窗口（欢迎页面）"
echo "  3. 3秒后弹出指纹测试窗口"
echo "  4. 在测试窗口中显示详细的指纹信息"
echo "  5. 控制台输出指纹配置详情"
echo ""

# 编译
echo "🏗️  编译项目..."
if npm run build:main; then
    echo "✅ 编译成功"
    
    echo "🚀 启动指纹验证测试..."
    echo "📱 请注意观察："
    echo "  - 控制台中的指纹配置信息"
    echo "  - 新弹出窗口中的详细测试结果"
    echo "  - 每个指纹组件的具体数值"
    echo ""
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
    exit 1
fi
