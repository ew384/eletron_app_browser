#!/bin/bash

echo "🧪 正确的测试脚本"
echo "================"

# 编译
echo "🏗️  编译主进程..."
if npm run build:main; then
    echo "✅ 编译成功"
    
    # 使用正确的主进程入口
    if [ -f "dist/main/index.js" ]; then
        echo "✅ 使用正确的主进程入口: dist/main/index.js"
        echo "🚀 启动 Electron..."
        echo ""
        echo "📋 预期效果:"
        echo "  1. 主窗口显示欢迎页面"
        echo "  2. 控制台显示详细日志"
        echo "  3. 3秒后弹出新浏览器窗口"
        echo "  4. 新窗口访问百度并应用指纹伪装"
        echo ""
        
        NODE_ENV=production electron "dist/main/index.js"
    else
        echo "❌ 主进程入口文件不存在"
        exit 1
    fi
else
    echo "❌ 编译失败"
    exit 1
fi
