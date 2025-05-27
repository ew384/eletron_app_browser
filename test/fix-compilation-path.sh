#!/bin/bash

echo "🔧 修复编译路径问题"
echo "=================="

# 1. 检查当前编译输出结构
echo "📁 检查当前编译输出..."
if [ -d "dist" ]; then
    echo "当前 dist 目录结构:"
    find dist -name "*.js" 2>/dev/null | head -10
else
    echo "❌ dist 目录不存在"
fi

# 2. 检查 tsconfig.main.json 的输出路径
echo "📝 检查 TypeScript 配置..."
if [ -f "tsconfig.main.json" ]; then
    echo "当前 tsconfig.main.json 配置:"
    grep -A 5 -B 5 "outDir\|rootDir" tsconfig.main.json
fi

# 3. 修复 tsconfig.main.json
echo "🔧 修复 TypeScript 编译配置..."

cat > tsconfig.main.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020", "DOM"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true,
    "sourceMap": true
  },
  "include": [
    "src/main/**/*", 
    "src/shared/**/*", 
    "src/preload/**/*"
  ],
  "exclude": [
    "node_modules", 
    "dist",
    "src/renderer"
  ]
}
EOF

echo "✅ tsconfig.main.json 已修复（outDir: ./dist, rootDir: ./src）"

# 4. 清理并重新编译测试
echo "🏗️  清理并重新编译..."
rm -rf dist/

if npx tsc -p tsconfig.main.json; then
    echo "✅ 编译成功"
    echo "📁 编译后的文件结构:"
    find dist -name "*.js" 2>/dev/null | head -10
    
    # 检查入口文件是否存在
    if [ -f "dist/main/index.js" ]; then
        echo "✅ 主入口文件存在: dist/main/index.js"
    else
        echo "❌ 主入口文件不存在，检查其他位置:"
        find dist -name "index.js" 2>/dev/null
    fi
else
    echo "❌ 编译失败"
    exit 1
fi

# 5. 修复启动脚本
echo "📝 修复启动脚本..."

# 检查实际的编译输出位置
MAIN_JS_PATH=""
if [ -f "dist/main/index.js" ]; then
    MAIN_JS_PATH="dist/main/index.js"
elif [ -f "dist/index.js" ]; then
    MAIN_JS_PATH="dist/index.js"
else
    # 查找第一个 index.js 文件
    MAIN_JS_PATH=$(find dist -name "index.js" | head -1)
fi

if [ -n "$MAIN_JS_PATH" ]; then
    echo "✅ 找到主入口文件: $MAIN_JS_PATH"
else
    echo "❌ 找不到主入口文件"
    exit 1
fi

# 创建修复后的启动脚本
cat > start-dev-fixed.sh << EOF
#!/bin/bash

echo "🚀 启动修复后的开发环境"
echo "======================"

# 清理和编译
rm -rf dist/
echo "🏗️  编译主进程..."

if npm run build:main; then
    echo "✅ 主进程编译成功"
    
    # 检查编译结果
    if [ -f "$MAIN_JS_PATH" ]; then
        echo "✅ 入口文件存在: $MAIN_JS_PATH"
    else
        echo "❌ 入口文件不存在，查找..."
        MAIN_JS_PATH=\$(find dist -name "index.js" | head -1)
        if [ -n "\$MAIN_JS_PATH" ]; then
            echo "✅ 找到入口文件: \$MAIN_JS_PATH"
        else
            echo "❌ 无法找到入口文件"
            exit 1
        fi
    fi
    
    echo "🔄 同时启动 Electron 和 Vite..."
    
    # 使用实际的文件路径启动
    npx concurrently \\
        --names "ELECTRON,VITE" \\
        --prefix-colors "cyan,magenta" \\
        "sleep 3 && NODE_ENV=development electron \$MAIN_JS_PATH" \\
        "vite --config vite.config.ts --port 3000"
else
    echo "❌ 编译失败"
    exit 1
fi
EOF

chmod +x start-dev-fixed.sh
echo "✅ 修复后的启动脚本已创建: start-dev-fixed.sh"

# 6. 创建简单的测试脚本
cat > test-simple.sh << EOF
#!/bin/bash

echo "🧪 简单测试脚本"
echo "=============="

# 清理和编译
rm -rf dist/
echo "🏗️  编译..."

if npm run build:main; then
    echo "✅ 编译成功"
    
    # 查找入口文件
    ENTRY_FILE=\$(find dist -name "index.js" | head -1)
    
    if [ -n "\$ENTRY_FILE" ]; then
        echo "✅ 找到入口文件: \$ENTRY_FILE"
        echo "🚀 启动 Electron..."
        
        NODE_ENV=production electron "\$ENTRY_FILE"
    else
        echo "❌ 找不到入口文件"
        echo "📁 dist 目录内容:"
        find dist -type f | head -10
    fi
else
    echo "❌ 编译失败"
fi
EOF

chmod +x test-simple.sh
echo "✅ 简单测试脚本已创建: test-simple.sh"

# 7. 创建调试脚本
cat > debug-compilation.sh << 'EOF'
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
EOF

chmod +x debug-compilation.sh
echo "✅ 调试脚本已创建: debug-compilation.sh"

# 8. 更新 package.json 的 main 字段
echo "📝 更新 package.json..."

if [ -f "package.json" ]; then
    # 使用 Node.js 更新 package.json
    node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    
    // 更新 main 字段，指向实际的编译输出
    pkg.main = 'dist/main/index.js';
    
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
    echo "✅ package.json 主入口已更新"
fi

echo ""
echo "🎉 修复完成！"
echo ""
echo "🚀 现在可以尝试以下方式："
echo ""
echo "1️⃣  运行调试脚本（了解编译过程）:"
echo "   ./debug-compilation.sh"
echo ""
echo "2️⃣  简单测试:"
echo "   ./test-simple.sh"
echo ""
echo "3️⃣  修复后的开发环境:"
echo "   ./start-dev-fixed.sh"
echo ""
echo "💡 建议先运行调试脚本查看编译结果！"