#!/bin/bash

echo "🎯 最终 Canvas 指纹测试"
echo "===================="

echo "🧹 清理编译缓存..."
rm -rf dist/

echo ""
echo "🏗️  重新编译..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败，请检查代码"
    exit 1
fi

echo ""
echo "🚀 启动最终测试..."
echo ""
echo "📋 测试重点："
echo "  1. 观察控制台中的 Canvas 注入日志"
echo "  2. 每次 toDataURL 调用应显示不同的噪声值"
echo "  3. Canvas 注入效果测试应显示 '可能正在工作'"
echo "  4. 最重要：BrowserLeaks 的 Signature 应该每次重启都不同"
echo ""
echo "🔍 控制台日志重点关注："
echo "  - [Canvas] 🎨 开始 Canvas 指纹注入"
echo "  - [Canvas] 🔄 toDataURL 被调用"
echo "  - [Canvas] 生成噪声: XXXXX (每次应该不同)"
echo "  - [Canvas-Test] ✅ Canvas 注入可能正在工作"
echo ""

NODE_ENV=production electron dist/main/index.js
