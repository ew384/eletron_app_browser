#!/bin/bash

echo "🔄 多账号指纹对比测试"
echo "===================="

echo "📝 创建多账号测试版本的主进程..."

# 备份原文件
cp src/main/index.ts src/main/index.ts.backup

# 创建多账号测试版本
cat > src/main/index.ts << 'MULTI_EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

console.log('🚀 多账号指纹对比测试启动...');

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

  showWelcomePage(mainWindow);

  // 创建多个测试账号
  setTimeout(async () => {
    console.log('🧪 创建多个测试账号进行指纹对比...');
    
    const accounts = [
      { id: 'account-001', name: '账号1' },
      { id: 'account-002', name: '账号2' },
      { id: 'account-003', name: '账号3' }
    ];

    for (let i = 0; i < accounts.length; i++) {
      const account = accounts[i];
      console.log(`\n📱 创建 ${account.name} (${account.id})...`);
      
      try {
        const instance = await windowManager.createBrowserInstance(account.id, {});
        console.log(`✅ ${account.name} 创建成功`);
        
        const testWindow = BrowserWindow.fromId(instance.windowId);
        if (testWindow) {
          // 设置窗口位置，避免重叠
          testWindow.setPosition(200 + i * 300, 100 + i * 100);
          
          const testPagePath = path.join(__dirname, '../../test-pages/fingerprint-test.html');
          await testWindow.loadFile(testPagePath);
          
          // 输出该账号的指纹配置
          const config = windowManager.getFingerprintConfig(account.id);
          if (config) {
            console.log(`🛡️  ${account.name} 指纹配置:`);
            console.log(`    平台: ${config.navigator.platform}`);
            console.log(`    语言: ${config.navigator.language}`);
            console.log(`    CPU: ${config.navigator.hardwareConcurrency}核`);
            console.log(`    屏幕: ${config.screen.width}x${config.screen.height}`);
            console.log(`    GPU: ${config.webgl.vendor}`);
            console.log(`    Canvas噪声: ${config.canvas.noise.toFixed(3)}`);
            console.log(`    音频噪声: ${config.audio.noise.toFixed(3)}`);
          }
        }
        
        // 延迟创建下一个窗口
        if (i < accounts.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 2000));
        }
        
      } catch (error) {
        console.error(`❌ ${account.name} 创建失败:`, error);
      }
    }
    
    console.log('\n🎉 多账号指纹对比测试完成！');
    console.log('📊 对比各个窗口中显示的指纹信息，验证每个账号的指纹都不相同');
    
  }, 3000);
}

function showWelcomePage(window: BrowserWindow) {
  const welcomeHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>多账号指纹对比测试</title>
        <meta charset="UTF-8">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0; padding: 40px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white; min-height: 100vh;
                display: flex; flex-direction: column;
                align-items: center; justify-content: center;
            }
            .container { text-align: center; max-width: 600px; }
            h1 { font-size: 3em; margin-bottom: 20px; }
            .status {
                background: rgba(255,255,255,0.1); border-radius: 10px;
                padding: 20px; margin: 20px 0; backdrop-filter: blur(10px);
            }
            .info { background: rgba(33, 150, 243, 0.3); border: 1px solid rgba(33, 150, 243, 0.5); }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔄 多账号指纹对比测试</h1>
            <div class="status info">
                <h3>🧪 测试进行中...</h3>
                <p>3秒后将依次创建3个测试账号</p>
                <p>每个账号都有独特的指纹配置</p>
                <p>查看控制台输出对比指纹差异</p>
            </div>
        </div>
    </body>
    </html>
  `;
  window.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(welcomeHtml)}`);
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
MULTI_EOF

echo "✅ 多账号测试版本已创建"

echo "🏗️  编译多账号测试版本..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🚀 启动多账号指纹对比测试..."
    echo "📱 将创建3个窗口，每个都有不同的指纹"
    echo "📊 对比各窗口的指纹信息验证差异性"
    echo ""
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
fi

# 恢复原文件
echo ""
echo "🔄 恢复原始主进程文件..."
mv src/main/index.ts.backup src/main/index.ts
echo "✅ 原始文件已恢复"
