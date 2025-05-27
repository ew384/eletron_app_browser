#!/bin/bash

echo "🔧 修复入口点问题"
echo "================"

# 1. 检查当前编译输出
echo "📁 检查当前编译输出结构..."
if [ -d "dist" ]; then
    echo "当前 dist 目录结构:"
    find dist -name "*.js" | sort
    echo ""
    
    echo "🔍 查找主进程入口文件..."
    if [ -f "dist/main/index.js" ]; then
        echo "✅ 找到正确的主进程入口: dist/main/index.js"
        MAIN_ENTRY="dist/main/index.js"
    else
        echo "❌ 未找到 dist/main/index.js"
        echo "查找其他可能的主进程文件..."
        
        # 查找包含 'app.whenReady' 的文件
        MAIN_CANDIDATES=$(grep -l "app\.whenReady\|BrowserWindow" dist/**/*.js 2>/dev/null || true)
        if [ -n "$MAIN_CANDIDATES" ]; then
            echo "找到可能的主进程文件:"
            echo "$MAIN_CANDIDATES"
            MAIN_ENTRY=$(echo "$MAIN_CANDIDATES" | head -1)
        else
            echo "❌ 找不到主进程文件"
        fi
    fi
else
    echo "❌ dist 目录不存在，需要先编译"
    exit 1
fi

# 2. 检查源文件结构
echo ""
echo "📋 检查源文件结构..."
echo "主进程源文件:"
find src/main -name "*.ts" 2>/dev/null | sort

echo ""
echo "预加载源文件:"
find src/preload -name "*.ts" 2>/dev/null | sort

# 3. 确保主进程入口文件存在且正确
echo ""
echo "📝 检查/修复主进程入口文件..."

if [ ! -f "src/main/index.ts" ]; then
    echo "❌ src/main/index.ts 不存在，创建它..."
    
    mkdir -p src/main
    cat > src/main/index.ts << 'EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

console.log('🚀 主进程启动...');

const windowManager = new WindowManager();

function createWindow() {
  console.log('📱 创建主窗口...');
  
  const mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  // 检查是否是开发环境
  const isDev = process.env.NODE_ENV === 'development' || process.argv.includes('--dev');
  
  if (isDev) {
    console.log('🔧 开发模式：尝试连接 Vite 服务器...');
    // 开发环境：尝试连接 Vite 服务器，如果失败则显示本地页面
    mainWindow.loadURL('http://localhost:3000').catch((error) => {
      console.log('⚠️  Vite 服务器未运行，显示本地欢迎页面');
      console.log('错误详情:', error.message);
      showWelcomePage(mainWindow);
    });
    mainWindow.webContents.openDevTools();
  } else {
    console.log('🏭 生产模式：显示本地页面');
    showWelcomePage(mainWindow);
  }

  // 测试创建账号和浏览器实例
  setTimeout(async () => {
    try {
      console.log('🧪 测试创建浏览器实例...');
      const testAccount = {
        id: 'test-001',
        name: '测试账号',
        status: 'idle' as const,
        createdAt: Date.now()
      };
      
      const instance = await windowManager.createBrowserInstance(testAccount.id, {});
      console.log('✅ 测试浏览器实例创建成功:', instance);
      
      // 加载测试页面
      const testWindow = BrowserWindow.fromId(instance.windowId);
      if (testWindow) {
        console.log('📱 正在加载测试页面...');
        await testWindow.loadURL('https://www.baidu.com');
        console.log('🎉 测试页面加载成功！新窗口已应用指纹伪装');
        
        // 显示指纹信息
        console.log('🔍 指纹配置信息:');
        const fingerprintConfig = windowManager.getFingerprintConfig(testAccount.id);
        if (fingerprintConfig) {
          console.log('  - 平台:', fingerprintConfig.navigator.platform);
          console.log('  - 语言:', fingerprintConfig.navigator.language);
          console.log('  - CPU核心:', fingerprintConfig.navigator.hardwareConcurrency);
          console.log('  - 屏幕分辨率:', `${fingerprintConfig.screen.width}x${fingerprintConfig.screen.height}`);
          console.log('  - GPU:', fingerprintConfig.webgl.vendor);
        }
      }
    } catch (error) {
      console.error('❌ 测试失败:', error);
    }
  }, 3000);
}

function showWelcomePage(window: BrowserWindow) {
  console.log('🎨 显示欢迎页面...');
  
  // 显示内置的欢迎页面
  const welcomeHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>防关联浏览器</title>
        <meta charset="UTF-8">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0;
                padding: 40px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
            }
            .container {
                text-align: center;
                max-width: 600px;
            }
            h1 {
                font-size: 3em;
                margin-bottom: 20px;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
            .status {
                background: rgba(255,255,255,0.1);
                border-radius: 10px;
                padding: 20px;
                margin: 20px 0;
                backdrop-filter: blur(10px);
            }
            .success {
                background: rgba(76, 175, 80, 0.3);
                border: 1px solid rgba(76, 175, 80, 0.5);
            }
            .info {
                background: rgba(33, 150, 243, 0.3);
                border: 1px solid rgba(33, 150, 243, 0.5);
            }
            .feature {
                display: inline-block;
                margin: 10px;
                padding: 10px 20px;
                background: rgba(255,255,255,0.2);
                border-radius: 20px;
                font-size: 14px;
            }
            .countdown {
                font-size: 1.2em;
                font-weight: bold;
                color: #ffd700;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 防关联浏览器</h1>
            
            <div class="status success">
                <h3>✅ 系统启动成功</h3>
                <p>指纹伪装系统已激活</p>
            </div>
            
            <div class="status info">
                <h3>🧪 自动测试中...</h3>
                <p class="countdown">3秒后将自动创建测试浏览器实例</p>
                <p>新窗口将访问百度，并应用独特的浏览器指纹</p>
            </div>
            
            <div>
                <h3>🛡️ 核心功能</h3>
                <div class="feature">Canvas 指纹伪装</div>
                <div class="feature">WebGL 指纹伪装</div>
                <div class="feature">Navigator 信息伪装</div>
                <div class="feature">屏幕分辨率伪装</div>
                <div class="feature">字体指纹伪装</div>
                <div class="feature">时区伪装</div>
            </div>
            
            <div style="margin-top: 40px; opacity: 0.8;">
                <p>📱 查看控制台输出了解测试进度</p>
                <p>🌐 新的浏览器窗口即将出现...</p>
                <p>🔍 可在新窗口开发者工具中验证指纹效果</p>
            </div>
        </div>
        
        <script>
            let countdown = 3;
            const countdownEl = document.querySelector('.countdown');
            const timer = setInterval(() => {
                countdown--;
                if (countdown > 0) {
                    countdownEl.textContent = countdown + '秒后将自动创建测试浏览器实例';
                } else {
                    countdownEl.textContent = '正在创建测试浏览器实例...';
                    countdownEl.style.color = '#90EE90';
                    clearInterval(timer);
                }
            }, 1000);
        </script>
    </body>
    </html>
  `;
  
  window.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(welcomeHtml)}`);
}

app.whenReady().then(() => {
  console.log('⚡ Electron 应用就绪');
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  console.log('🚪 所有窗口已关闭');
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

console.log('📋 主进程入口文件加载完成');
EOF

    echo "✅ src/main/index.ts 已创建"
else
    echo "✅ src/main/index.ts 已存在"
fi

# 4. 重新编译
echo ""
echo "🏗️  重新编译..."
rm -rf dist/

if npm run build:main; then
    echo "✅ 编译成功"
    
    echo ""
    echo "📁 新的编译结果:"
    find dist -name "*.js" | sort
    
    # 验证主进程入口文件
    if [ -f "dist/main/index.js" ]; then
        echo "✅ 主进程入口文件正确: dist/main/index.js"
        MAIN_ENTRY="dist/main/index.js"
    else
        echo "❌ 主进程入口文件仍然不存在"
        exit 1
    fi
else
    echo "❌ 编译失败"
    exit 1
fi

# 5. 创建正确的测试脚本
echo ""
echo "📝 创建正确的测试脚本..."

cat > test-correct.sh << EOF
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
EOF

chmod +x test-correct.sh

# 6. 创建开发模式脚本
cat > dev-correct.sh << 'EOF'
#!/bin/bash

echo "🚀 正确的开发模式"
echo "================"

# 编译
echo "🏗️  编译主进程..."
if npm run build:main; then
    echo "✅ 编译成功"
    
    echo "🔄 启动开发环境..."
    echo "📋 将同时启动:"
    echo "  - Vite 开发服务器 (端口 3000)"
    echo "  - Electron 主进程"
    echo ""
    
    # 使用 concurrently 同时启动
    npx concurrently \
        --names "VITE,ELECTRON" \
        --prefix-colors "magenta,cyan" \
        "vite --config vite.config.ts --port 3000" \
        "sleep 3 && NODE_ENV=development electron dist/main/index.js --dev"
else
    echo "❌ 编译失败"
    exit 1
fi
EOF

chmod +x dev-correct.sh

echo ""
echo "🎉 修复完成！"
echo ""
echo "🚀 现在可以使用正确的脚本："
echo ""
echo "1️⃣  测试模式（推荐先试这个）:"
echo "   ./test-correct.sh"
echo ""
echo "2️⃣  开发模式（包含 React 界面）:"
echo "   ./dev-correct.sh"
echo ""
echo "📋 主要修复内容:"
echo "  ✅ 确保 src/main/index.ts 存在且正确"
echo "  ✅ 脚本使用正确的主进程入口文件"
echo "  ✅ 添加详细的日志输出"
echo "  ✅ 修复入口文件检测逻辑"
echo ""
echo "💡 运行 ./test-correct.sh 应该能看到指纹测试效果！"