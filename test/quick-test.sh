#!/bin/bash

echo "⚡ 一键快速测试"
echo "============="

echo "📋 将执行以下测试："
echo "  1. 编译项目"
echo "  2. 显示指纹配置"
echo "  3. 启动图形界面测试"
echo ""

# 步骤1：编译
echo "🏗️  步骤1：编译项目..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 步骤2：显示配置
echo ""
echo "📊 步骤2：显示示例指纹配置..."
./show-simple-fingerprint.sh

# 步骤3：启动测试
echo ""
echo "🚀 步骤3：启动图形界面测试..."
echo "📱 即将打开两个窗口："
echo "  - 主窗口：欢迎界面"
echo "  - 新窗口：指纹测试页面"
echo ""
echo "⏱️  3秒后启动..."
sleep 3

NODE_ENV=production electron dist/main/index.js
