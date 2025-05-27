#!/bin/bash

echo "🔍 调试编译过程"
echo "=============="

echo "📋 检查源文件结构:"
echo "主进程文件:"
find src/main -name "*.ts" 2>/dev/null

echo ""
echo "预加载文件:"
find src/preload -name "*.ts" 2>/dev/null

echo ""
echo "共享文件:"
find src/shared -name "*.ts" 2>/dev/null

echo ""
echo "🏗️  开始编译（详细输出）..."
rm -rf dist/

# 详细编译过程
npx tsc -p tsconfig.main.json --listFiles --pretty

echo ""
echo "📁 编译后的结构:"
if [ -d "dist" ]; then
    find dist -type f | sort
else
    echo "❌ dist 目录不存在"
fi

echo ""
echo "🔍 查找所有 JavaScript 文件:"
find dist -name "*.js" 2>/dev/null

echo ""
echo "📝 检查 package.json 主入口:"
if [ -f "package.json" ]; then
    grep -A 1 -B 1 '"main"' package.json
fi
