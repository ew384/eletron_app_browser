#!/bin/bash

echo "🎯 简单 Canvas 指纹测试"
echo "===================="

echo "🏗️  编译简单版本..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🚀 启动简单测试..."
echo ""
echo "📋 请观察控制台输出："
echo "  - [Canvas-Simple] 开头的日志"
echo "  - toDataURL 被调用时的噪声值"
echo "  - Canvas 注入效果测试结果"
echo ""
echo "🎯 关键验证点："
echo "  1. 每次 toDataURL 调用都应该显示不同的噪声值"
echo "  2. Canvas 注入效果测试应该返回 '可能有效'"
echo "  3. BrowserLeaks 的 Canvas Signature 应该每次重启都不同"
echo ""

NODE_ENV=production electron dist/main/index.js
