#!/bin/bash

echo "🎨 修复后的 Canvas 测试"
echo "===================="

echo "🏗️  编译修复后的代码..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🌐 启动测试，请观察 Canvas Signature 是否每次都不同"
echo "📱 将打开浏览器访问 BrowserLeaks Canvas 页面"
echo "🔍 查看控制台的 [Canvas] 日志了解注入情况"

NODE_ENV=production electron dist/main/index.js
