#!/bin/bash

echo "🔧 修复 TypeScript 错误并创建简化测试"
echo "======================================="

# 1. 先运行基础的指纹验证测试
echo "🧪 运行基础指纹验证测试（无需修复）..."

cat > run-basic-test.sh << 'EOF'
#!/bin/bash

echo "🔍 基础指纹验证测试"
echo "=================="

echo "🏗️  编译项目..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🚀 启动指纹验证测试..."
    echo "📱 将显示："
    echo "  - 主窗口：欢迎页面"
    echo "  - 新窗口：详细的指纹测试页面"
    echo "  - 控制台：指纹配置信息"
    echo ""
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
    exit 1
fi
EOF

chmod +x run-basic-test.sh

echo "✅ 基础测试脚本已创建: run-basic-test.sh"

# 2. 创建修复版的在线测试脚本
echo "📝 创建修复版的在线测试脚本..."

cat > test-online-fixed.sh << 'EOF'
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
EOF

chmod +x test-online-fixed.sh

# 3. 创建简单的指纹配置显示脚本
echo "📝 创建简单的指纹配置显示脚本..."

cat > show-simple-fingerprint.sh << 'EOF'
#!/bin/bash

echo "📊 简单指纹配置显示"
echo "=================="

# 创建临时测试文件
cat > temp-show-fingerprint.js << 'TEMP_EOF'
// 检查是否存在编译后的文件
const fs = require('fs');
const path = require('path');

const generatorPath = path.join(__dirname, 'dist/main/fingerprint/generator.js');

if (!fs.existsSync(generatorPath)) {
  console.log('❌ 编译文件不存在，请先运行编译');
  console.log('🏗️  运行命令: npm run build:main');
  process.exit(1);
}

const { FingerprintGenerator } = require('./dist/main/fingerprint/generator.js');

console.log('🎲 生成指纹配置示例\n');

// 生成一个示例指纹
const testAccountId = 'demo-account-' + Date.now();
const config = FingerprintGenerator.generateFingerprint(testAccountId);

console.log('🆔 账号ID:', testAccountId);
console.log('─'.repeat(50));

console.log('🖥️  操作系统信息:');
console.log(`   平台: ${config.navigator.platform}`);
console.log(`   语言: ${config.navigator.language}`);
console.log(`   CPU核心: ${config.navigator.hardwareConcurrency}`);
console.log(`   触控点: ${config.navigator.maxTouchPoints}`);
console.log(`   内存: ${config.navigator.deviceMemory}GB`);

console.log('\n📺 屏幕信息:');
console.log(`   分辨率: ${config.screen.width} × ${config.screen.height}`);
console.log(`   像素比: ${config.screen.pixelRatio}`);
console.log(`   颜色深度: ${config.screen.colorDepth}位`);

console.log('\n🎮 图形信息:');
console.log(`   GPU厂商: ${config.webgl.vendor}`);
console.log(`   GPU型号: ${config.webgl.renderer}`);

console.log('\n🎨 指纹噪声:');
console.log(`   Canvas噪声: ${config.canvas.noise.toFixed(4)}`);
console.log(`   Canvas算法: ${config.canvas.algorithm}`);
console.log(`   音频噪声: ${config.audio.noise.toFixed(4)}`);

console.log('\n🌍 地理信息:');
console.log(`   时区: ${config.timezone.name}`);
console.log(`   UTC偏移: ${config.timezone.offset}分钟`);

console.log('\n📝 字体信息:');
console.log(`   可用字体数: ${config.fonts.available.length}`);
console.log(`   前5个字体: ${config.fonts.available.slice(0, 5).join(', ')}`);

console.log('\n✅ 指纹配置生成完成!');
console.log('💡 每次运行都会生成不同的配置');
TEMP_EOF

echo "🏗️  检查编译状态..."
if [ -f "dist/main/fingerprint/generator.js" ]; then
    echo "✅ 编译文件存在，显示指纹配置..."
    node temp-show-fingerprint.js
else
    echo "⚠️  编译文件不存在，先进行编译..."
    if npm run build:main; then
        echo "✅ 编译成功，显示指纹配置..."
        node temp-show-fingerprint.js
    else
        echo "❌ 编译失败"
        exit 1
    fi
fi

# 清理临时文件
rm -f temp-show-fingerprint.js
EOF

chmod +x show-simple-fingerprint.sh

# 4. 创建一键测试脚本
cat > quick-test.sh << 'EOF'
#!/bin/bash

echo "⚡ 一键快速测试"
echo "============="

echo "📋 将执行以下测试："
echo "  1. 编译项目"
echo "  2. 显示指纹配置"
echo "  3. 启动图形界面测试"
echo ""

# 步骤1：编译
echo "🏗️  步骤1：编译项目..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 步骤2：显示配置
echo ""
echo "📊 步骤2：显示示例指纹配置..."
./show-simple-fingerprint.sh

# 步骤3：启动测试
echo ""
echo "🚀 步骤3：启动图形界面测试..."
echo "📱 即将打开两个窗口："
echo "  - 主窗口：欢迎界面"
echo "  - 新窗口：指纹测试页面"
echo ""
echo "⏱️  3秒后启动..."
sleep 3

NODE_ENV=production electron dist/main/index.js
EOF

chmod +x quick-test.sh

echo ""
echo "🎉 修复和测试脚本创建完成！"
echo ""
echo "🚀 推荐的测试顺序："
echo ""
echo "1️⃣  一键快速测试（推荐）:"
echo "   ./quick-test.sh"
echo "   📱 包含编译、配置显示、图形测试"
echo ""
echo "2️⃣  基础测试:"
echo "   ./run-basic-test.sh"
echo "   🔍 本地指纹验证页面"
echo ""
echo "3️⃣  查看指纹配置:"
echo "   ./show-simple-fingerprint.sh"
echo "   📊 控制台显示配置详情"
echo ""
echo "4️⃣  在线测试（修复版）:"
echo "   ./test-online-fixed.sh"
echo "   🌐 访问真实指纹检测网站"
echo ""
echo "💡 建议先运行 './quick-test.sh' 进行完整测试！"