#!/bin/bash

echo "🔧 修复 TypeScript 配置问题"
echo "========================="

# 1. 修复 tsconfig.main.json - 调整 rootDir
echo "📝 修复 tsconfig.main.json..."

cat > tsconfig.main.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020", "DOM"],
    "outDir": "./dist/main",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true
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

echo "✅ tsconfig.main.json 已修复"

# 2. 创建 shared/constants.ts（如果不存在）
echo "📝 检查 shared/constants.ts..."

if [ ! -f "src/shared/constants.ts" ]; then
    cat > src/shared/constants.ts << 'EOF'
// 应用常量配置
export const APP_CONFIG = {
  NAME: 'Electron Browser Manager',
  VERSION: '1.0.0'
};

// 指纹配置常量
export const FINGERPRINT_CONSTANTS = {
  DEFAULT_CANVAS_NOISE: 0.2,
  DEFAULT_AUDIO_NOISE: 0.1,
  MIN_ENTROPY_SCORE: 50,
  DEFAULT_SCREEN_RESOLUTIONS: [
    { width: 1920, height: 1080 },
    { width: 1366, height: 768 },
    { width: 1536, height: 864 }
  ]
};

// IPC 通道名称
export const IPC_CHANNELS = {
  CREATE_ACCOUNT: 'create-account',
  GET_ACCOUNTS: 'get-accounts',
  DELETE_ACCOUNT: 'delete-account',
  CREATE_BROWSER_INSTANCE: 'create-browser-instance',
  CLOSE_BROWSER_INSTANCE: 'close-browser-instance',
  GET_FINGERPRINT_CONFIG: 'get-fingerprint-config',
  UPDATE_FINGERPRINT_CONFIG: 'update-fingerprint-config'
};
EOF
    echo "✅ shared/constants.ts 已创建"
else
    echo "✅ shared/constants.ts 已存在"
fi

# 3. 更新 package.json 脚本，使用正确的编译方式
echo "📝 更新 package.json 脚本..."

# 读取现有的 package.json
if [ -f "package.json" ]; then
    # 备份原文件
    cp package.json package.json.backup
    
    # 使用 Node.js 来更新 package.json
    node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    
    pkg.scripts = {
      ...pkg.scripts,
      'dev': 'concurrently \"npm run dev:main\" \"npm run dev:renderer\"',
      'dev:main': 'npm run build:main && electron dist/main/index.js',
      'dev:renderer': 'vite',
      'build': 'npm run build:main && npm run build:renderer',
      'build:main': 'tsc -p tsconfig.main.json',
      'build:renderer': 'vite build',
      'start': 'electron dist/main/index.js',
      'watch:main': 'tsc -p tsconfig.main.json --watch'
    };
    
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
    
    echo "✅ package.json 脚本已更新"
fi

# 4. 创建单独的预编译脚本
echo "📝 创建预编译脚本..."

cat > compile-and-run.sh << 'EOF'
#!/bin/bash

echo "🏗️  编译主进程..."

# 编译主进程和预加载脚本
if npx tsc -p tsconfig.main.json; then
    echo "✅ 主进程编译成功"
    
    echo "🚀 启动 Electron..."
    # 启动 Electron
    npx electron dist/main/index.js
else
    echo "❌ 主进程编译失败"
    exit 1
fi
EOF

chmod +x compile-and-run.sh

echo "✅ 预编译脚本已创建: compile-and-run.sh"

# 5. 创建开发模式脚本
cat > dev-mode.sh << 'EOF'
#!/bin/bash

echo "🔄 开发模式启动..."

# 清理旧的编译文件
rm -rf dist/

echo "🏗️  编译主进程..."
if npm run build:main; then
    echo "✅ 主进程编译成功"
    
    echo "🚀 启动开发模式..."
    # 同时启动 Electron 和 Vite 开发服务器
    concurrently \
        "electron dist/main/index.js" \
        "vite --config vite.config.ts"
else
    echo "❌ 编译失败，请检查代码"
fi
EOF

chmod +x dev-mode.sh

echo "✅ 开发模式脚本已创建: dev-mode.sh"

# 6. 检查文件结构
echo "📁 检查当前文件结构..."

echo "主进程文件:"
find src/main -name "*.ts" 2>/dev/null | head -10

echo "预加载文件:"
find src/preload -name "*.ts" 2>/dev/null | head -5

echo "共享文件:"
find src/shared -name "*.ts" 2>/dev/null | head -5

echo ""
echo "🎉 TypeScript 配置修复完成！"
echo ""
echo "🚀 现在可以使用以下方式运行："
echo ""
echo "方式1 - 简单编译运行:"
echo "  ./compile-and-run.sh"
echo ""
echo "方式2 - 开发模式:"
echo "  ./dev-mode.sh"
echo ""
echo "方式3 - 手动分步："
echo "  npm run build:main"
echo "  npm run start"
echo ""
echo "方式4 - 原来的方式（应该现在能工作）："
echo "  npm run dev"
echo ""
echo "💡 推荐使用方式1进行快速测试！"