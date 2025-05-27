#!/bin/bash

echo "🚀 启动修复后的开发环境"
echo "======================"

# 清理和编译
rm -rf dist/
echo "🏗️  编译主进程..."

if npm run build:main; then
    echo "✅ 主进程编译成功"
    
    # 检查编译结果
    if [ -f "dist/main/index.js" ]; then
        echo "✅ 入口文件存在: dist/main/index.js"
    else
        echo "❌ 入口文件不存在，查找..."
        MAIN_JS_PATH=$(find dist -name "index.js" | head -1)
        if [ -n "$MAIN_JS_PATH" ]; then
            echo "✅ 找到入口文件: $MAIN_JS_PATH"
        else
            echo "❌ 无法找到入口文件"
            exit 1
        fi
    fi
    
    echo "🔄 同时启动 Electron 和 Vite..."
    
    # 使用实际的文件路径启动
    npx concurrently \
        --names "ELECTRON,VITE" \
        --prefix-colors "cyan,magenta" \
        "sleep 3 && NODE_ENV=development electron $MAIN_JS_PATH" \
        "vite --config vite.config.ts --port 3000"
else
    echo "❌ 编译失败"
    exit 1
fi
