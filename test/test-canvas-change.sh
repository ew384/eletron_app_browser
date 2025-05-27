#!/bin/bash

echo "🎨 Canvas 指纹变化测试"
echo "===================="

echo "📋 此测试将："
echo "  1. 编译更新后的代码"
echo "  2. 启动浏览器访问 BrowserLeaks"
echo "  3. 记录第一次的 Canvas 指纹"
echo "  4. 重启程序"
echo "  5. 再次访问并对比指纹变化"

# 编译
echo ""
echo "🏗️  编译更新后的代码..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🎯 第一次测试 - 记录初始指纹"
echo "请访问 BrowserLeaks Canvas 页面并记录 Signature 值"
echo "按任意键启动第一次测试..."
read -n 1

NODE_ENV=production electron dist/main/index.js &
ELECTRON_PID=$!

echo ""
echo "⏱️  请在新窗口中查看并记录 Canvas Signature"
echo "记录完成后，按任意键继续..."
read -n 1

# 结束第一次测试
kill $ELECTRON_PID 2>/dev/null
sleep 2

echo ""
echo "🔄 第二次测试 - 验证指纹变化"
echo "现在重新启动程序，Canvas 指纹应该不同"
echo "按任意键启动第二次测试..."
read -n 1

NODE_ENV=production electron dist/main/index.js &
ELECTRON_PID=$!

echo ""
echo "🔍 请对比新的 Canvas Signature 是否与第一次不同"
echo "如果不同，说明 Canvas 指纹伪装工作正常！"
echo "测试完成后，按任意键结束..."
read -n 1

kill $ELECTRON_PID 2>/dev/null

echo ""
echo "📊 测试完成！"
echo "✅ 如果两次的 Signature 不同，Canvas 指纹伪装成功"
echo "❌ 如果两次的 Signature 相同，需要进一步调试"
