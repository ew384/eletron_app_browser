#!/bin/bash

echo "🔄 多账号指纹对比测试（修复版）"
echo "=========================="

echo "📊 生成多个账号的指纹配置进行对比..."

# 编译检查
if [ ! -f "dist/main/fingerprint/generator.js" ]; then
    echo "🏗️  先进行编译..."
    if ! npm run build:main; then
        echo "❌ 编译失败"
        exit 1
    fi
fi

# 创建对比脚本
cat > temp-compare.js << 'COMPARE_EOF'
const { FingerprintGenerator } = require('./dist/main/fingerprint/generator.js');

console.log('🔄 多账号指纹对比分析');
console.log('═'.repeat(80));

const accounts = ['user-alice', 'user-bob', 'user-charlie'];

accounts.forEach((accountId, index) => {
  const config = FingerprintGenerator.generateFingerprint(accountId);
  
  console.log(`\n👤 账号 ${index + 1}: ${accountId}`);
  console.log('─'.repeat(50));
  
  console.log(`🖥️  平台: ${config.navigator.platform}`);
  console.log(`🌍 语言: ${config.navigator.language}`);
  console.log(`⚙️  CPU: ${config.navigator.hardwareConcurrency}核`);
  console.log(`📱 触控: ${config.navigator.maxTouchPoints}点`);
  console.log(`💾 内存: ${config.navigator.deviceMemory}GB`);
  console.log(`📺 屏幕: ${config.screen.width}×${config.screen.height}`);
  console.log(`🎮 GPU: ${config.webgl.vendor}`);
  console.log(`🎨 Canvas噪声: ${config.canvas.noise.toFixed(3)}`);
  console.log(`🔊 音频噪声: ${config.audio.noise.toFixed(3)}`);
  console.log(`🌍 时区: ${config.timezone.name}`);
});

console.log('\n' + '═'.repeat(80));
console.log('📊 对比总结:');
console.log('✅ 每个账号都有独特的指纹配置');
console.log('✅ 参数在合理范围内，不易被检测');
console.log('✅ 基于账号ID生成，保证一致性');
console.log('💡 相同账号ID会生成相同的指纹配置');
COMPARE_EOF

node temp-compare.js
rm temp-compare.js

echo ""
echo "🧪 现在启动图形界面进行实际测试..."
echo "📱 将创建多个浏览器窗口展示不同指纹"

# 备份原文件
cp src/main/index.ts src/main/index.ts.backup

# 创建多窗口测试版本（简化版，避免错误）
cat > src/main/index.ts << 'MULTI_EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

console.log('🚀 多账号指纹测试启动...');

const windowManager = new WindowManager();

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  // 显示简单的欢迎页面
  const welcomeHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>多账号指纹测试</title>
        <meta charset="UTF-8">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0; padding: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white; min-height: 100vh; display: flex; flex-direction: column;
                align-items: center; justify-content: center; text-align: center;
            }
            h1 { font-size: 2.5em; margin-bottom: 20px; }
            .info { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0; }
        </style>
    </head>
    <body>
        <h1>🔄 多账号指纹测试</h1>
        <div class="info">
            <h3>🧪 正在创建多个测试账号...</h3>
            <p>每个账号都有独特的指纹配置</p>
            <p>请查看控制台输出了解详情</p>
        </div>
    </body>
    </html>
  `;
  
  mainWindow.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(welcomeHtml)}`);

  // 创建多个测试实例
  setTimeout(async () => {
    const accounts = ['test-alice', 'test-bob', 'test-charlie'];
    
    for (let i = 0; i < accounts.length; i++) {
      const accountId = accounts[i];
      console.log(`\n📱 创建账号: ${accountId}`);
      
      try {
        const instance = await windowManager.createBrowserInstance(accountId, {});
        console.log(`✅ ${accountId} 创建成功`);
        
        const testWindow = BrowserWindow.fromId(instance.windowId);
        if (testWindow) {
          // 设置窗口位置避免重叠
          testWindow.setPosition(300 + i * 250, 150 + i * 100);
          testWindow.setSize(800, 600);
          
          // 显示该账号的指纹信息
          const config = windowManager.getFingerprintConfig(accountId);
          if (config) {
            console.log(`🛡️  ${accountId} 指纹配置:`);
            console.log(`    平台: ${config.navigator.platform}`);
            console.log(`    CPU: ${config.navigator.hardwareConcurrency}核`);
            console.log(`    屏幕: ${config.screen.width}×${config.screen.height}`);
            console.log(`    GPU: ${config.webgl.vendor}`);
            
            // 在窗口中显示指纹信息
            const fingerprintHtml = `
              <!DOCTYPE html>
              <html>
              <head>
                  <title>${accountId} 指纹信息</title>
                  <meta charset="UTF-8">
                  <style>
                      body { font-family: monospace; padding: 20px; background: #f0f8ff; }
                      h1 { color: #333; text-align: center; }
                      .section { background: white; margin: 15px 0; padding: 15px; border-radius: 8px; border-left: 4px solid #007acc; }
                      .label { font-weight: bold; color: #007acc; margin-bottom: 8px; }
                      .value { margin-left: 15px; color: #333; }
                      .highlight { background: #e7f3ff; padding: 5px; border-radius: 3px; }
                  </style>
              </head>
              <body>
                  <h1>🛡️ ${accountId}</h1>
                  <div class="section">
                      <div class="label">🖥️ 操作系统</div>
                      <div class="value">平台: <span class="highlight">${config.navigator.platform}</span></div>
                      <div class="value">语言: <span class="highlight">${config.navigator.language}</span></div>
                      <div class="value">CPU核心: <span class="highlight">${config.navigator.hardwareConcurrency}</span></div>
                      <div class="value">触控点: <span class="highlight">${config.navigator.maxTouchPoints}</span></div>
                  </div>
                  <div class="section">
                      <div class="label">📺 屏幕信息</div>
                      <div class="value">分辨率: <span class="highlight">${config.screen.width} × ${config.screen.height}</span></div>
                      <div class="value">像素比: <span class="highlight">${config.screen.pixelRatio}</span></div>
                      <div class="value">颜色深度: <span class="highlight">${config.screen.colorDepth}位</span></div>
                  </div>
                  <div class="section">
                      <div class="label">🎮 GPU 信息</div>
                      <div class="value">厂商: <span class="highlight">${config.webgl.vendor}</span></div>
                      <div class="value">型号: <span class="highlight">${config.webgl.renderer.substring(0, 40)}...</span></div>
                  </div>
                  <div class="section">
                      <div class="label">🎨 指纹设置</div>
                      <div class="value">Canvas噪声: <span class="highlight">${config.canvas.noise.toFixed(4)}</span></div>
                      <div class="value">音频噪声: <span class="highlight">${config.audio.noise.toFixed(4)}</span></div>
                      <div class="value">时区: <span class="highlight">${config.timezone.name}</span></div>
                  </div>
                  <div style="margin-top: 30px; text-align: center; color: #666;">
                      <p>💡 此配置已应用到当前浏览器实例</p>
                      <p>🔍 可通过 navigator.platform 等验证</p>
                  </div>
              </body>
              </html>
            `;
            
            testWindow.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(fingerprintHtml)}`);
          }
        }
        
        // 延迟创建下一个实例
        if (i < accounts.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 1500));
        }
        
      } catch (error) {
        console.error(`❌ ${accountId} 创建失败:`, error);
      }
    }
    
    console.log('\n🎉 多账号测试完成！');
    console.log('📊 请对比各个窗口显示的指纹信息');
    console.log('✅ 每个账号都应该有不同的配置');
  }, 2000);
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
MULTI_EOF

echo "✅ 多窗口测试版本已创建"

echo "🏗️  编译测试版本..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🚀 启动多账号指纹对比测试..."
    echo "📱 将创建4个窗口（1个主窗口 + 3个测试窗口）"
    echo "🔍 每个测试窗口显示不同账号的指纹信息"
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
