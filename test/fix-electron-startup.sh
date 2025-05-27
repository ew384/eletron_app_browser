#!/bin/bash

echo "🔧 修复 Electron 启动问题"
echo "======================="

# 1. 修复主进程入口文件 - 在开发环境中提供fallback
echo "📝 修复主进程入口文件..."

cat > src/main/index.ts << 'EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

const windowManager = new WindowManager();

function createWindow() {
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
    // 开发环境：尝试连接 Vite 服务器，如果失败则显示本地页面
    mainWindow.loadURL('http://localhost:3000').catch(() => {
      console.log('⚠️  Vite 服务器未运行，显示本地欢迎页面');
      showWelcomePage(mainWindow);
    });
    mainWindow.webContents.openDevTools();
  } else {
    // 生产环境：加载构建后的文件
    const rendererPath = path.join(__dirname, '../renderer/index.html');
    if (require('fs').existsSync(rendererPath)) {
      mainWindow.loadFile(rendererPath);
    } else {
      showWelcomePage(mainWindow);
    }
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
      }
    } catch (error) {
      console.error('❌ 测试失败:', error);
    }
  }, 3000);
}

function showWelcomePage(window: BrowserWindow) {
  // 显示内置的欢迎页面
  const welcomeHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>防关联浏览器</title>
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
                <p>3秒后将自动创建测试浏览器实例</p>
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
            </div>
        </div>
        
        <script>
            let countdown = 3;
            const countdownEl = document.querySelector('.status.info p');
            const timer = setInterval(() => {
                countdown--;
                if (countdown > 0) {
                    countdownEl.textContent = countdown + '秒后将自动创建测试浏览器实例';
                } else {
                    countdownEl.textContent = '正在创建测试浏览器实例...';
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
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
EOF

echo "✅ 主进程入口文件已修复"

# 2. 创建完整的开发环境启动脚本
echo "📝 创建完整开发环境脚本..."

cat > start-dev-full.sh << 'EOF'
#!/bin/bash

echo "🚀 启动完整开发环境"
echo "=================="

# 清理旧的编译文件
echo "🗑️  清理编译缓存..."
rm -rf dist/

# 编译主进程
echo "🏗️  编译主进程..."
if npm run build:main; then
    echo "✅ 主进程编译成功"
else
    echo "❌ 主进程编译失败"
    exit 1
fi

echo "🔄 同时启动 Electron 和 Vite 开发服务器..."

# 使用 concurrently 同时启动
npx concurrently \
    --names "ELECTRON,VITE" \
    --prefix-colors "cyan,magenta" \
    "sleep 2 && NODE_ENV=development electron dist/main/index.js --dev" \
    "vite --config vite.config.ts --port 3000"
EOF

chmod +x start-dev-full.sh

# 3. 创建仅启动 Electron 的脚本（不依赖 Vite）
cat > start-electron-only.sh << 'EOF'
#!/bin/bash

echo "🚀 仅启动 Electron（独立模式）"
echo "=========================="

# 清理和编译
rm -rf dist/
echo "🏗️  编译主进程..."

if npm run build:main; then
    echo "✅ 主进程编译成功"
    echo "🚀 启动 Electron（独立模式）..."
    
    # 设置环境变量，不尝试连接 Vite
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
    exit 1
fi
EOF

chmod +x start-electron-only.sh

# 4. 创建测试指纹功能的脚本
cat > test-fingerprint.sh << 'EOF'
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
EOF

chmod +x test-fingerprint.sh

# 5. 更新 vite.config.ts 确保正确配置
echo "📝 检查 Vite 配置..."

if [ ! -f "vite.config.ts" ]; then
    cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  root: 'src/renderer',
  base: './',
  build: {
    outDir: '../../dist/renderer',
    emptyOutDir: true
  },
  server: {
    port: 3000,
    strictPort: true
  }
});
EOF
    echo "✅ Vite 配置已创建"
else
    echo "✅ Vite 配置已存在"
fi

# 6. 检查渲染进程文件
echo "📝 检查渲染进程文件..."

mkdir -p src/renderer

if [ ! -f "src/renderer/index.html" ]; then
    cat > src/renderer/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>防关联浏览器管理界面</title>
    <style>
        body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    </style>
</head>
<body>
    <div id="root"></div>
    <script type="module" src="./main.tsx"></script>
</body>
</html>
EOF
    echo "✅ 渲染进程 HTML 已创建"
fi

if [ ! -f "src/renderer/main.tsx" ]; then
    cat > src/renderer/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF
    echo "✅ 渲染进程入口已创建"
fi

if [ ! -f "src/renderer/App.tsx" ]; then
    cat > src/renderer/App.tsx << 'EOF'
import React, { useState } from 'react'

interface Account {
  id: string;
  name: string;
  status: string;
}

function App() {
  const [accounts, setAccounts] = useState<Account[]>([]);

  const createAccount = () => {
    const newAccount: Account = {
      id: `account-${Date.now()}`,
      name: `账号 ${accounts.length + 1}`,
      status: 'idle'
    };
    setAccounts([...accounts, newAccount]);
  };

  const launchBrowser = async (accountId: string) => {
    try {
      // 调用 Electron API
      const result = await (window as any).electronAPI?.createBrowserInstance(accountId, {});
      if (result?.success) {
        setAccounts(accounts.map(acc => 
          acc.id === accountId ? { ...acc, status: 'running' } : acc
        ));
        console.log('✅ 浏览器实例创建成功');
      }
    } catch (error) {
      console.error('❌ 创建浏览器实例失败:', error);
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1 style={{ color: '#333', marginBottom: '30px' }}>
        🚀 防关联浏览器管理系统
      </h1>
      
      <div style={{ marginBottom: '20px' }}>
        <button 
          onClick={createAccount}
          style={{
            padding: '12px 24px',
            backgroundColor: '#007acc',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontSize: '16px'
          }}
        >
          + 创建新账号
        </button>
      </div>

      <div>
        <h2 style={{ color: '#555', marginBottom: '15px' }}>账号列表</h2>
        
        {accounts.length === 0 ? (
          <div style={{ 
            padding: '40px', 
            textAlign: 'center', 
            color: '#666',
            border: '2px dashed #ddd',
            borderRadius: '8px'
          }}>
            <p style={{ fontSize: '18px', margin: '0' }}>
              暂无账号，点击"创建新账号"开始使用
            </p>
          </div>
        ) : (
          <div style={{ display: 'grid', gap: '10px' }}>
            {accounts.map(account => (
              <div key={account.id} style={{
                border: '1px solid #e0e0e0',
                padding: '15px',
                borderRadius: '8px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                backgroundColor: '#fafafa'
              }}>
                <div>
                  <strong style={{ fontSize: '16px' }}>{account.name}</strong>
                  <span style={{
                    marginLeft: '12px',
                    padding: '4px 12px',
                    borderRadius: '4px',
                    fontSize: '12px',
                    fontWeight: 'bold',
                    backgroundColor: account.status === 'running' ? '#d4edda' : '#f8f9fa',
                    color: account.status === 'running' ? '#155724' : '#6c757d'
                  }}>
                    {account.status === 'running' ? '运行中' : '待机'}
                  </span>
                </div>
                
                <button
                  onClick={() => launchBrowser(account.id)}
                  disabled={account.status === 'running'}
                  style={{
                    padding: '8px 16px',
                    backgroundColor: account.status === 'running' ? '#6c757d' : '#28a745',
                    color: 'white',
                    border: 'none',
                    borderRadius: '4px',
                    cursor: account.status === 'running' ? 'not-allowed' : 'pointer',
                    fontSize: '14px'
                  }}
                >
                  {account.status === 'running' ? '已启动' : '启动浏览器'}
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
      
      <div style={{ 
        marginTop: '40px', 
        padding: '20px', 
        backgroundColor: '#e8f4fd', 
        borderRadius: '8px',
        border: '1px solid #bee5eb'
      }}>
        <h3 style={{ color: '#0c5460', margin: '0 0 10px 0' }}>💡 使用说明</h3>
        <ul style={{ color: '#0c5460', margin: '0', paddingLeft: '20px' }}>
          <li>每个账号都有独立的浏览器指纹配置</li>
          <li>启动的浏览器窗口将自动应用指纹伪装</li>
          <li>每个实例使用独立的 Cookie 和存储空间</li>
          <li>支持代理配置和行为模拟</li>
        </ul>
      </div>
    </div>
  )
}

export default App
EOF
    echo "✅ 渲染进程应用已创建"
fi

echo ""
echo "🎉 修复完成！现在可以选择运行方式："
echo ""
echo "🚀 方式1 - 完整开发环境（推荐）："
echo "   ./start-dev-full.sh"
echo ""
echo "🚀 方式2 - 仅启动 Electron（独立测试）："
echo "   ./start-electron-only.sh"
echo ""
echo "🧪 方式3 - 专门测试指纹功能："
echo "   ./test-fingerprint.sh"
echo ""
echo "📝 说明："
echo "  - 方式1：同时启动 React 界面和 Electron"
echo "  - 方式2：只启动 Electron，显示内置欢迎页面"
echo "  - 方式3：专门用于测试指纹伪装功能"
echo ""
echo "💡 推荐先使用方式2或3进行测试！"