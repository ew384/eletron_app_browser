#!/bin/bash

echo "🌐 多站点指纹对比测试"
echo "==================="

echo "📝 此测试将创建多个浏览器实例，每个访问不同的指纹检测网站"

# 备份原文件
cp src/main/index.ts src/main/index.ts.backup

cat > src/main/index.ts << 'MULTI_SITES_MAIN_EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

console.log('🚀 多站点指纹对比测试启动...');

const windowManager = new WindowManager();

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 900,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  const welcomeHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>多站点指纹测试</title>
        <meta charset="UTF-8">
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 30px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh; text-align: center; }
            h1 { font-size: 2.5em; margin-bottom: 20px; }
            .info { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0; }
            .sites { text-align: left; margin: 15px 0; }
        </style>
    </head>
    <body>
        <h1>🌐 多站点指纹测试</h1>
        <div class="info">
            <h3>🧪 正在创建多个浏览器实例...</h3>
            <p>每个实例将访问不同的指纹检测网站</p>
            <div class="sites">
                <h4>📋 测试网站列表:</h4>
                <ul>
                    <li>🎨 BrowserLeaks Canvas</li>
                    <li>🔍 AmIUnique</li>
                    <li>🎮 BrowserLeaks WebGL</li>
                </ul>
            </div>
            <p>请查看控制台输出了解详情</p>
        </div>
    </body>
    </html>
  `;
  
  mainWindow.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(welcomeHtml)}`);

  // 创建多个测试实例访问不同网站
  setTimeout(async () => {
    const testSites = [
      {
        id: 'canvas-test',
        name: 'Canvas检测',
        url: 'https://browserleaks.com/canvas'
      },
      {
        id: 'unique-test', 
        name: '唯一性检测',
        url: 'https://amiunique.org/fingerprint'
      },
      {
        id: 'webgl-test',
        name: 'WebGL检测', 
        url: 'https://browserleaks.com/webgl'
      }
    ];
    
    for (let i = 0; i < testSites.length; i++) {
      const site = testSites[i];
      console.log(`\n📱 创建实例 ${i + 1}: ${site.name}`);
      
      try {
        const instance = await windowManager.createBrowserInstance(site.id, {});
        console.log(`✅ ${site.name} 实例创建成功`);
        
        const testWindow = BrowserWindow.fromId(instance.windowId);
        if (testWindow) {
          // 设置窗口位置避免重叠
          testWindow.setPosition(100 + i * 350, 100 + i * 150);
          testWindow.setSize(900, 700);
          
          // 显示当前实例的指纹配置
          const config = windowManager.getFingerprintConfig(site.id);
          if (config) {
            console.log(`🛡️  ${site.name} 指纹配置:`);
            console.log(`    平台: ${config.navigator.platform}`);
            console.log(`    语言: ${config.navigator.language}`);
            console.log(`    CPU: ${config.navigator.hardwareConcurrency}核`);
            console.log(`    屏幕: ${config.screen.width}×${config.screen.height}`);
            console.log(`    GPU: ${config.webgl.vendor}`);
            console.log(`    Canvas噪声: ${config.canvas.noise.toFixed(3)}`);
          }
          
          console.log(`🌐 正在访问: ${site.url}`);
          
          try {
            await testWindow.loadURL(site.url);
            console.log(`✅ ${site.name} 页面加载成功`);
          } catch (error: unknown) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            console.log(`❌ ${site.name} 访问失败: ${errorMessage}`);
            console.log(`🔄 为 ${site.name} 加载本地测试页面...`);
            
            // 加载本地测试页面作为备用
            const testPagePath = path.join(__dirname, '../../test-pages/fingerprint-test.html');
            try {
              await testWindow.loadFile(testPagePath);
              console.log(`✅ ${site.name} 本地页面加载成功`);
            } catch (localError: unknown) {
              const localErrorMessage = localError instanceof Error ? localError.message : String(localError);
              console.log(`❌ ${site.name} 本地页面也失败: ${localErrorMessage}`);
            }
          }
        }
        
        // 延迟创建下一个实例
        if (i < testSites.length - 1) {
          console.log('⏱️  等待2秒后创建下一个实例...');
          await new Promise(resolve => setTimeout(resolve, 2000));
        }
        
      } catch (error: unknown) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        console.error(`❌ ${site.name} 实例创建失败:`, errorMessage);
      }
    }
    
    console.log('\n🎉 多站点测试完成！');
    console.log('📊 请对比各个窗口的检测结果');
    console.log('🔍 验证每个实例的指纹都不相同');
    
  }, 3000);
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
MULTI_SITES_MAIN_EOF

echo "✅ 多站点测试版本已创建"

echo "🏗️  编译..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🌐 启动多站点指纹测试..."
    echo "📱 将创建4个窗口（1个主窗口 + 3个测试窗口）"
    echo "🔍 每个测试窗口访问不同的指纹检测网站"
    echo ""
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
fi

# 恢复原文件
echo ""
echo "🔄 恢复原始文件..."
mv src/main/index.ts.backup src/main/index.ts
echo "✅ 原始文件已恢复"
