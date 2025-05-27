#!/bin/bash

echo "🧪 测试指纹功能"
echo "=============="

echo "📋 测试将执行以下步骤："
echo "1. 编译项目"
echo "2. 启动 Electron"
echo "3. 自动创建测试浏览器实例"
echo "4. 在新窗口中加载测试页面"
echo "5. 验证指纹伪装效果"

echo ""
echo "🏗️  编译项目..."

if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🚀 启动测试..."
    echo "📱 主窗口将显示欢迎页面"
    echo "🌐 3秒后将弹出新的浏览器窗口"
    echo "🔍 新窗口将访问百度，请在开发者工具中验证指纹"
    echo ""
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败，请检查代码"
fi
