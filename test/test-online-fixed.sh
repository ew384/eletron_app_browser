#!/bin/bash

echo "🌐 修复版在线指纹检测测试"
echo "======================="

# 备份原文件
cp src/main/index.ts src/main/index.ts.backup

echo "📝 创建修复版的在线测试主进程..."

cat > src/main/index.ts << 'FIXED_EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

console.log('🚀 在线指纹检测测试启动...');

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

  // 创建测试浏览器实例
  setTimeout(async () => {
    console.log('🧪 创建浏览器实例访问在线指纹检测网站...');
    
    try {
      const testAccount = {
        id: 'fingerprint-test',
        name: '指纹检测测试',
        status: 'idle' as const,
        createdAt: Date.now()
      };
      
      const instance = await windowManager.createBrowserInstance(testAccount.id, {});
      console.log('✅ 测试浏览器实例创建成功');
      
      const testWindow = BrowserWindow.fromId(instance.windowId);
      if (testWindow) {
        console.log('🌐 正在访问在线指纹检测网站...');
        
        // 首先尝试访问 BrowserLeaks
        const targetUrl = 'https://browserleaks.com/canvas';
        console.log(`📱 访问: ${targetUrl}`);
        
        try {
          await testWindow.loadURL(targetUrl);
          console.log('✅ 网站加载成功');
          console.log('🔍 在新窗口中查看 Canvas 指纹检测结果');
          
          // 显示当前指纹配置
          const config = windowManager.getFingerprintConfig(testAccount.id);
          if (config) {
            console.log('\n🛡️  当前应用的指纹配置:');
            console.log(`    平台: ${config.navigator.platform}`);
            console.log(`    语言: ${config.navigator.language}`);
            console.log(`    CPU核心: ${config.navigator.hardwareConcurrency}`);
            console.log(`    屏幕分辨率: ${config.screen.width}x${config.screen.height}`);
            console.log(`    像素比: ${config.screen.pixelRatio}`);
            console.log(`    GPU厂商: ${config.webgl.vendor}`);
            console.log(`    GPU型号: ${config.webgl.renderer}`);
            console.log(`    Canvas噪声强度: ${config.canvas.noise.toFixed(3)}`);
            console.log(`    音频噪声强度: ${config.audio.noise.toFixed(3)}`);
          }
          
          console.log('\n📋 其他推荐测试网站:');
          const otherSites = [
            'https://amiunique.org/fingerprint',
            'https://coveryourtracks.eff.org/',
            'https://browserleaks.com/webgl',
            'https://browserleaks.com/javascript'
          ];
          otherSites.forEach((site, index) => {
            console.log(`    ${index + 1}. ${site}`);
          });
          console.log('💡 可以在新窗口地址栏中手动访问这些网站');
          
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          console.error('❌ 网站访问失败:', errorMessage);
          console.log('🔄 切换到本地指纹测试页面...');
          
          // 加载本地测试页面作为备用
          const testPagePath = path.join(__dirname, '../../test-pages/fingerprint-test.html');
          try {
            await testWindow.loadFile(testPagePath);
            console.log('✅ 已切换到本地指纹测试页面');
          } catch (localError: unknown) {
            const localErrorMessage = localError instanceof Error ? localError.message : String(localError);
            console.error('❌ 本地页面加载也失败:', localErrorMessage);
            console.log('🔄 显示简单的指纹信息页面...');
            showSimpleFingerprint(testWindow, config);
          }
        }
      }
      
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('❌ 测试失败:', errorMessage);
    }
  }, 3000);
}

function showWelcomePage(window: BrowserWindow) {
  const welcomeHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>在线指纹检测测试</title>
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
            .container { text-align: center; max-width: 700px; }
            h1 { font-size: 2.5em; margin-bottom: 20px; }
            .status {
                background: rgba(255,255,255,0.1); border-radius: 10px;
                padding: 20px; margin: 20px 0; backdrop-filter: blur(10px);
            }
            .info { background: rgba(33, 150, 243, 0.3); border: 1px solid rgba(33, 150, 243, 0.5); }
            .sites { text-align: left; margin: 15px 0; }
            .sites li { margin: 8px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🌐 在线指纹检测测试</h1>
            <div class="status info">
                <h3>🧪 准备访问在线检测网站...</h3>
                <p>3秒后将创建浏览器实例并访问指纹检测网站</p>
                <div class="sites">
                    <h4>📋 主要测试网站:</h4>
                    <ul>
                        <li>🎨 BrowserLeaks Canvas - 检测Canvas指纹</li>
                        <li>🔍 AmIUnique - 综合指纹检测</li>
                        <li>🛡️ EFF Cover Your Tracks - 隐私检测</li>
                    </ul>
                </div>
                <p><strong>💡 使用提示:</strong></p>
                <p>• 观察检测结果与控制台显示的配置是否匹配</p>
                <p>• 每次重启程序，指纹都会发生变化</p>
                <p>• 如果网络访问失败，会自动显示本地测试页面</p>
            </div>
        </div>
    </body>
    </html>
  `;
  window.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(welcomeHtml)}`);
}

function showSimpleFingerprint(window: BrowserWindow, config: any) {
  const fingerprintHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>指纹配置显示</title>
        <meta charset="UTF-8">
        <style>
            body { font-family: monospace; padding: 20px; background: #f5f5f5; }
            h1 { color: #333; }
            .config { background: white; padding: 20px; border-radius: 8px; margin: 10px 0; }
            .section { margin: 15px 0; }
            .label { font-weight: bold; color: #007acc; }
            .value { margin-left: 20px; }
        </style>
    </head>
    <body>
        <h1>🛡️ 当前指纹配置</h1>
        <div class="config">
            <div class="section">
                <div class="label">🖥️ Navigator 信息:</div>
                <div class="value">平台: ${config?.navigator?.platform || 'N/A'}</div>
                <div class="value">语言: ${config?.navigator?.language || 'N/A'}</div>
                <div class="value">CPU核心: ${config?.navigator?.hardwareConcurrency || 'N/A'}</div>
            </div>
            <div class="section">
                <div class="label">📺 屏幕信息:</div>
                <div class="value">分辨率: ${config?.screen?.width || 'N/A'}x${config?.screen?.height || 'N/A'}</div>
                <div class="value">像素比: ${config?.screen?.pixelRatio || 'N/A'}</div>
            </div>
            <div class="section">
                <div class="label">🎮 GPU 信息:</div>
                <div class="value">厂商: ${config?.webgl?.vendor || 'N/A'}</div>
                <div class="value">型号: ${config?.webgl?.renderer?.substring(0, 50) || 'N/A'}...</div>
            </div>
            <div class="section">
                <div class="label">🎨 指纹设置:</div>
                <div class="value">Canvas噪声: ${config?.canvas?.noise?.toFixed(3) || 'N/A'}</div>
                <div class="value">音频噪声: ${config?.audio?.noise?.toFixed(3) || 'N/A'}</div>
            </div>
        </div>
        <p><strong>💡 提示:</strong> 这些配置已应用到当前浏览器实例中</p>
    </body>
    </html>
  `;
  window.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(fingerprintHtml)}`);
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
FIXED_EOF

echo "✅ 修复版在线测试主进程已创建"

echo "🏗️  编译修复版..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🌐 启动在线指纹检测测试..."
    echo "📱 将尝试访问 BrowserLeaks Canvas 检测页面"
    echo "🔍 如果网络失败，会自动切换到本地页面"
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
