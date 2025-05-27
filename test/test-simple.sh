#!/bin/bash

echo "🧪 简单测试脚本"
echo "=============="

# 清理和编译
rm -rf dist/
echo "🏗️  编译..."

if npm run build:main; then
    echo "✅ 编译成功"
    
    # 查找入口文件
    ENTRY_FILE=$(find dist -name "index.js" | head -1)
    
    if [ -n "$ENTRY_FILE" ]; then
        echo "✅ 找到入口文件: $ENTRY_FILE"
        echo "🚀 启动 Electron..."
        
        NODE_ENV=production electron "$ENTRY_FILE"
    else
        echo "❌ 找不到入口文件"
        echo "📁 dist 目录内容:"
        find dist -type f | head -10
    fi
else
    echo "❌ 编译失败"
fi
