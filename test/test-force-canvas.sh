#!/bin/bash

echo "💪 强制性 Canvas 指纹测试"
echo "======================="

echo "🏗️  编译强制修复版本..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🔍 启动强制测试..."
echo "📱 请特别关注控制台的 [Canvas-Force] 和 [Canvas-Ultimate] 日志"
echo "🎯 每次 toDataURL 调用都应该显示不同的噪声值"
echo ""
echo "⚠️  如果仍然没有效果，说明可能需要更深层的修复"

NODE_ENV=production electron dist/main/index.js
