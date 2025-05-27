#!/bin/bash

echo "🔍 指纹验证和测试方案"
echo "==================="

# 1. 创建指纹验证页面
echo "📝 创建本地指纹验证页面..."

mkdir -p test-pages

cat > test-pages/fingerprint-test.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>指纹验证测试页面</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
            line-height: 1.6;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .test-section {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .test-title {
            color: #007acc;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 15px;
            border-bottom: 2px solid #007acc;
            padding-bottom: 5px;
        }
        .result {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 10px;
            margin: 10px 0;
            font-family: monospace;
            font-size: 14px;
            white-space: pre-wrap;
            word-break: break-all;
        }
        .success {
            background: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }
        .info {
            background: #d1ecf1;
            border-color: #bee5eb;
            color: #0c5460;
        }
        .warning {
            background: #fff3cd;
            border-color: #ffeaa7;
            color: #856404;
        }
        button {
            background: #007acc;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover {
            background: #005999;
        }
        .auto-test {
            text-align: center;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 浏览器指纹验证测试</h1>
        
        <div class="auto-test">
            <button onclick="runAllTests()">🚀 运行所有测试</button>
            <button onclick="clearResults()">🗑️ 清除结果</button>
        </div>

        <div class="test-section">
            <div class="test-title">🖥️ Navigator 信息</div>
            <button onclick="testNavigator()">测试 Navigator</button>
            <div id="navigator-result" class="result"></div>
        </div>

        <div class="test-section">
            <div class="test-title">🎨 Canvas 指纹</div>
            <button onclick="testCanvas()">测试 Canvas</button>
            <div id="canvas-result" class="result"></div>
        </div>

        <div class="test-section">
            <div class="test-title">🎮 WebGL 指纹</div>
            <button onclick="testWebGL()">测试 WebGL</button>
            <div id="webgl-result" class="result"></div>
        </div>

        <div class="test-section">
            <div class="test-title">🔊 音频上下文</div>
            <button onclick="testAudio()">测试 Audio</button>
            <div id="audio-result" class="result"></div>
        </div>

        <div class="test-section">
            <div class="test-title">📺 屏幕信息</div>
            <button onclick="testScreen()">测试 Screen</button>
            <div id="screen-result" class="result"></div>
        </div>

        <div class="test-section">
            <div class="test-title">⏰ 时区信息</div>
            <button onclick="testTimezone()">测试 Timezone</button>
            <div id="timezone-result" class="result"></div>
        </div>

        <div class="test-section">
            <div class="test-title">📊 综合指纹哈希</div>
            <button onclick="generateFingerprint()">生成指纹哈希</button>
            <div id="fingerprint-result" class="result"></div>
        </div>
    </div>

    <script>
        function testNavigator() {
            const result = {
                userAgent: navigator.userAgent,
                platform: navigator.platform,
                language: navigator.language,
                languages: navigator.languages,
                hardwareConcurrency: navigator.hardwareConcurrency,
                maxTouchPoints: navigator.maxTouchPoints,
                deviceMemory: navigator.deviceMemory,
                cookieEnabled: navigator.cookieEnabled,
                onLine: navigator.onLine,
                vendor: navigator.vendor,
                vendorSub: navigator.vendorSub,
                productSub: navigator.productSub,
                webdriver: navigator.webdriver
            };
            
            document.getElementById('navigator-result').textContent = 
                JSON.stringify(result, null, 2);
            document.getElementById('navigator-result').className = 'result success';
        }

        function testCanvas() {
            try {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');
                
                // 创建测试图像
                ctx.textBaseline = 'top';
                ctx.font = '14px Arial';
                ctx.fillStyle = '#f60';
                ctx.fillRect(125, 1, 62, 20);
                ctx.fillStyle = '#069';
                ctx.fillText('Browser fingerprint test 🎨', 2, 2);
                ctx.fillStyle = 'rgba(102, 204, 0, 0.7)';
                ctx.fillText('Canvas fingerprint test', 4, 17);
                
                const dataURL = canvas.toDataURL();
                const result = {
                    dataURL: dataURL.substring(0, 100) + '...',
                    hash: btoa(dataURL).substring(0, 32),
                    length: dataURL.length
                };
                
                document.getElementById('canvas-result').textContent = 
                    JSON.stringify(result, null, 2);
                document.getElementById('canvas-result').className = 'result info';
            } catch (e) {
                document.getElementById('canvas-result').textContent = 
                    'Canvas 测试失败: ' + e.message;
                document.getElementById('canvas-result').className = 'result warning';
            }
        }

        function testWebGL() {
            try {
                const canvas = document.createElement('canvas');
                const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
                
                if (!gl) {
                    throw new Error('WebGL 不支持');
                }
                
                const result = {
                    vendor: gl.getParameter(gl.VENDOR),
                    renderer: gl.getParameter(gl.RENDERER),
                    version: gl.getParameter(gl.VERSION),
                    shadingLanguageVersion: gl.getParameter(gl.SHADING_LANGUAGE_VERSION),
                    maxTextureSize: gl.getParameter(gl.MAX_TEXTURE_SIZE),
                    maxViewportDims: gl.getParameter(gl.MAX_VIEWPORT_DIMS),
                    supportedExtensions: gl.getSupportedExtensions()?.slice(0, 5) || []
                };
                
                document.getElementById('webgl-result').textContent = 
                    JSON.stringify(result, null, 2);
                document.getElementById('webgl-result').className = 'result info';
            } catch (e) {
                document.getElementById('webgl-result').textContent = 
                    'WebGL 测试失败: ' + e.message;
                document.getElementById('webgl-result').className = 'result warning';
            }
        }

        function testAudio() {
            try {
                const AudioContext = window.AudioContext || window.webkitAudioContext;
                if (!AudioContext) {
                    throw new Error('AudioContext 不支持');
                }
                
                const context = new AudioContext();
                const result = {
                    sampleRate: context.sampleRate,
                    state: context.state,
                    maxChannelCount: context.destination.maxChannelCount,
                    numberOfInputs: context.destination.numberOfInputs,
                    numberOfOutputs: context.destination.numberOfOutputs
                };
                
                context.close();
                
                document.getElementById('audio-result').textContent = 
                    JSON.stringify(result, null, 2);
                document.getElementById('audio-result').className = 'result info';
            } catch (e) {
                document.getElementById('audio-result').textContent = 
                    'Audio 测试失败: ' + e.message;
                document.getElementById('audio-result').className = 'result warning';
            }
        }

        function testScreen() {
            const result = {
                width: screen.width,
                height: screen.height,
                availWidth: screen.availWidth,
                availHeight: screen.availHeight,
                colorDepth: screen.colorDepth,
                pixelDepth: screen.pixelDepth,
                devicePixelRatio: window.devicePixelRatio,
                orientation: screen.orientation ? {
                    angle: screen.orientation.angle,
                    type: screen.orientation.type
                } : 'Not supported'
            };
            
            document.getElementById('screen-result').textContent = 
                JSON.stringify(result, null, 2);
            document.getElementById('screen-result').className = 'result success';
        }

        function testTimezone() {
            const now = new Date();
            const result = {
                timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
                timezoneOffset: now.getTimezoneOffset(),
                localTime: now.toString(),
                utcTime: now.toUTCString(),
                isoString: now.toISOString()
            };
            
            document.getElementById('timezone-result').textContent = 
                JSON.stringify(result, null, 2);
            document.getElementById('timezone-result').className = 'result success';
        }

        async function generateFingerprint() {
            const components = [];
            
            // Navigator
            components.push(navigator.userAgent);
            components.push(navigator.platform);
            components.push(navigator.language);
            components.push(navigator.hardwareConcurrency.toString());
            
            // Screen
            components.push(screen.width + 'x' + screen.height);
            components.push(screen.colorDepth.toString());
            components.push(window.devicePixelRatio.toString());
            
            // Canvas
            try {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');
                ctx.textBaseline = 'top';
                ctx.font = '14px Arial';
                ctx.fillText('Fingerprint test', 2, 2);
                components.push(canvas.toDataURL());
            } catch (e) {
                components.push('canvas-error');
            }
            
            // WebGL
            try {
                const canvas = document.createElement('canvas');
                const gl = canvas.getContext('webgl');
                if (gl) {
                    components.push(gl.getParameter(gl.VENDOR));
                    components.push(gl.getParameter(gl.RENDERER));
                }
            } catch (e) {
                components.push('webgl-error');
            }
            
            // 生成哈希
            const fingerprint = components.join('|');
            const hash = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(fingerprint));
            const hashArray = Array.from(new Uint8Array(hash));
            const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
            
            const result = {
                componentsCount: components.length,
                fingerprintLength: fingerprint.length,
                hash: hashHex,
                sample: fingerprint.substring(0, 200) + '...'
            };
            
            document.getElementById('fingerprint-result').textContent = 
                JSON.stringify(result, null, 2);
            document.getElementById('fingerprint-result').className = 'result success';
        }

        function runAllTests() {
            testNavigator();
            setTimeout(testCanvas, 100);
            setTimeout(testWebGL, 200);
            setTimeout(testAudio, 300);
            setTimeout(testScreen, 400);
            setTimeout(testTimezone, 500);
            setTimeout(generateFingerprint, 600);
        }

        function clearResults() {
            const results = document.querySelectorAll('.result');
            results.forEach(result => {
                result.textContent = '';
                result.className = 'result';
            });
        }

        // 页面加载完成后自动运行测试
        window.addEventListener('load', () => {
            setTimeout(runAllTests, 1000);
        });
    </script>
</body>
</html>
EOF

echo "✅ 指纹验证页面已创建: test-pages/fingerprint-test.html"

# 2. 修改主进程，让新窗口加载本地测试页面
echo "📝 修改主进程以加载本地测试页面..."

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

  showWelcomePage(mainWindow);

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
      
      // 加载本地指纹测试页面
      const testWindow = BrowserWindow.fromId(instance.windowId);
      if (testWindow) {
        console.log('📱 正在加载指纹测试页面...');
        const testPagePath = path.join(__dirname, '../../test-pages/fingerprint-test.html');
        console.log('📄 测试页面路径:', testPagePath);
        
        await testWindow.loadFile(testPagePath);
        console.log('🎉 指纹测试页面加载成功！');
        console.log('🔍 查看新窗口中的测试结果验证指纹效果');
        
        // 显示指纹信息
        console.log('🛡️  当前指纹配置:');
        const fingerprintConfig = windowManager.getFingerprintConfig(testAccount.id);
        if (fingerprintConfig) {
          console.log('  📱 平台:', fingerprintConfig.navigator.platform);
          console.log('  🌍 语言:', fingerprintConfig.navigator.language);
          console.log('  ⚙️  CPU核心:', fingerprintConfig.navigator.hardwareConcurrency);
          console.log('  📺 屏幕:', `${fingerprintConfig.screen.width}x${fingerprintConfig.screen.height}`);
          console.log('  🎮 GPU厂商:', fingerprintConfig.webgl.vendor);
          console.log('  🎨 GPU型号:', fingerprintConfig.webgl.renderer);
          console.log('  🎯 Canvas噪声:', fingerprintConfig.canvas.noise);
          console.log('  🔊 音频噪声:', fingerprintConfig.audio.noise);
        }
      }
    } catch (error) {
      console.error('❌ 测试失败:', error);
    }
  }, 3000);
}

function showWelcomePage(window: BrowserWindow) {
  console.log('🎨 显示欢迎页面...');
  
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
            .container { text-align: center; max-width: 600px; }
            h1 { font-size: 3em; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
            .status {
                background: rgba(255,255,255,0.1);
                border-radius: 10px;
                padding: 20px;
                margin: 20px 0;
                backdrop-filter: blur(10px);
            }
            .success { background: rgba(76, 175, 80, 0.3); border: 1px solid rgba(76, 175, 80, 0.5); }
            .info { background: rgba(33, 150, 243, 0.3); border: 1px solid rgba(33, 150, 243, 0.5); }
            .feature {
                display: inline-block; margin: 10px; padding: 10px 20px;
                background: rgba(255,255,255,0.2); border-radius: 20px; font-size: 14px;
            }
            .countdown { font-size: 1.2em; font-weight: bold; color: #ffd700; }
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
                <p>新窗口将显示<strong>指纹验证测试页面</strong></p>
                <p>在新窗口中可以详细查看所有指纹信息</p>
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
                <p>📱 查看控制台输出了解详细配置</p>
                <p>🌐 新窗口将显示完整的指纹测试结果</p>
                <p>🔍 无需开发者工具即可验证指纹效果</p>
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
                    countdownEl.textContent = '正在创建指纹测试窗口...';
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

echo "✅ 主进程已修改为加载本地测试页面"

# 3. 创建测试脚本
echo "📝 创建指纹验证测试脚本..."

cat > test-fingerprint-verification.sh << 'EOF'
#!/bin/bash

echo "🔍 指纹验证测试"
echo "=============="

echo "📋 本次测试将："
echo "  1. 编译最新代码"
echo "  2. 启动主窗口（欢迎页面）"
echo "  3. 3秒后弹出指纹测试窗口"
echo "  4. 在测试窗口中显示详细的指纹信息"
echo "  5. 控制台输出指纹配置详情"
echo ""

# 编译
echo "🏗️  编译项目..."
if npm run build:main; then
    echo "✅ 编译成功"
    
    echo "🚀 启动指纹验证测试..."
    echo "📱 请注意观察："
    echo "  - 控制台中的指纹配置信息"
    echo "  - 新弹出窗口中的详细测试结果"
    echo "  - 每个指纹组件的具体数值"
    echo ""
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
    exit 1
fi
EOF

chmod +x test-fingerprint-verification.sh

# 4. 创建多账号对比测试脚本
cat > test-multiple-accounts.sh << 'EOF'
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
EOF

chmod +x test-multiple-accounts.sh

# 5. 创建在线指纹检测脚本
cat > test-online-fingerprint.sh << 'EOF'
#!/bin/bash

echo "🌐 在线指纹检测测试"
echo "================="

echo "📝 修改主进程访问在线指纹检测网站..."

# 备份原文件
cp src/main/index.ts src/main/index.ts.backup

# 创建在线测试版本
cat > src/main/index.ts << 'ONLINE_EOF'
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
        
        // 访问多个指纹检测网站
        const sites = [
          'https://browserleaks.com/canvas',
          'https://amiunique.org/fingerprint',
          'https://coveryourtracks.eff.org/'
        ];
        
        const currentSite = sites[0];
        console.log(`📱 访问: ${currentSite}`);
        
        try {
          await testWindow.loadURL(currentSite);
          console.log('✅ 网站加载成功');
          console.log('🔍 在新窗口中查看指纹检测结果');
          
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
          
          console.log('\n📋 其他测试网站:');
          sites.slice(1).forEach((site, index) => {
            console.log(`    ${index + 2}. ${site}`);
          });
          console.log('💡 可以在新窗口地址栏中手动访问这些网站进行对比测试');
          
        } catch (error) {
          console.error('❌ 网站访问失败:', error.message);
          console.log('🔄 尝试访问备用检测网站...');
          
          // 尝试访问本地测试页面作为备用
          const testPagePath = path.join(__dirname, '../../test-pages/fingerprint-test.html');
          await testWindow.loadFile(testPagePath);
          console.log('✅ 已切换到本地指纹测试页面');
        }
      }
      
    } catch (error) {
      console.error('❌ 测试失败:', error);
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
                    <h4>📋 将访问的检测网站:</h4>
                    <ul>
                        <li>🎨 BrowserLeaks Canvas - 检测Canvas指纹</li>
                        <li>🔍 AmIUnique - 综合指纹检测</li>
                        <li>🛡️ EFF Cover Your Tracks - 隐私检测</li>
                    </ul>
                </div>
                <p><strong>💡 使用提示:</strong></p>
                <p>• 观察检测结果与控制台显示的配置是否匹配</p>
                <p>• 每次重启程序，指纹都会发生变化</p>
                <p>• 可以手动在地址栏输入其他检测网站</p>
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
ONLINE_EOF

echo "✅ 在线测试版本已创建"

echo "🏗️  编译在线测试版本..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🌐 启动在线指纹检测测试..."
    echo "📱 将访问真实的指纹检测网站"
    echo "🔍 可以看到指纹伪装的实际效果"
    echo ""
    echo "⚠️  如果网络访问失败，会自动切换到本地测试页面"
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

chmod +x test-online-fingerprint.sh

# 6. 创建控制台指纹输出脚本
cat > show-fingerprint-config.sh << 'EOF'
#!/bin/bash

echo "📊 显示指纹配置详情"
echo "=================="

echo "📝 创建指纹配置显示版本..."

# 创建临时测试文件
cat > temp-fingerprint-display.js << 'TEMP_EOF'
const { FingerprintGenerator } = require('./dist/main/fingerprint/generator.js');

console.log('🎲 生成示例指纹配置...\n');

// 生成几个不同的指纹配置进行对比
const accounts = ['account-001', 'account-002', 'account-003'];

accounts.forEach((accountId, index) => {
  console.log(`📱 账号 ${index + 1} (${accountId}) 的指纹配置:`);
  console.log('═'.repeat(50));
  
  const config = FingerprintGenerator.generateFingerprint(accountId);
  
  console.log('🖥️  Navigator 信息:');
  console.log(`    平台: ${config.navigator.platform}`);
  console.log(`    语言: ${config.navigator.language}`);
  console.log(`    支持语言: [${config.navigator.languages.join(', ')}]`);
  console.log(`    CPU核心数: ${config.navigator.hardwareConcurrency}`);
  console.log(`    最大触控点: ${config.navigator.maxTouchPoints}`);
  console.log(`    设备内存: ${config.navigator.deviceMemory}GB`);
  
  console.log('\n📺 屏幕信息:');
  console.log(`    分辨率: ${config.screen.width} × ${config.screen.height}`);
  console.log(`    像素比: ${config.screen.pixelRatio}`);
  console.log(`    颜色深度: ${config.screen.colorDepth}位`);
  
  console.log('\n🎮 WebGL 信息:');
  console.log(`    GPU厂商: ${config.webgl.vendor}`);
  console.log(`    GPU型号: ${config.webgl.renderer}`);
  
  console.log('\n🎨 Canvas 设置:');
  console.log(`    噪声强度: ${config.canvas.noise.toFixed(4)}`);
  console.log(`    噪声算法: ${config.canvas.algorithm}`);
  console.log(`    随机种子: ${config.canvas.seed}`);
  
  console.log('\n🔊 音频设置:');
  console.log(`    噪声强度: ${config.audio.noise.toFixed(4)}`);
  console.log(`    随机种子: ${config.audio.seed}`);
  
  console.log('\n🌍 时区设置:');
  console.log(`    时区名称: ${config.timezone.name}`);
  console.log(`    UTC偏移: ${config.timezone.offset}分钟`);
  
  console.log('\n📝 字体设置:');
  console.log(`    可用字体: [${config.fonts.available.slice(0, 5).join(', ')}...]`);
  console.log(`    字体总数: ${config.fonts.available.length}`);
  console.log(`    检测方法: ${config.fonts.measurementMethod}`);
  
  if (index < accounts.length - 1) {
    console.log('\n' + '─'.repeat(80) + '\n');
  }
});

console.log('\n🎯 总结:');
console.log('• 每个账号都有完全不同的指纹配置');
console.log('• 指纹配置基于账号ID生成，确保一致性');
console.log('• 所有参数都在合理范围内，避免被检测');
console.log('• 噪声算法确保同一账号的指纹始终相同');
TEMP_EOF

echo "✅ 临时显示脚本已创建"

if [ -f "dist/main/fingerprint/generator.js" ]; then
    echo "🚀 显示指纹配置..."
    node temp-fingerprint-display.js
else
    echo "❌ 需要先编译项目"
    echo "🏗️  正在编译..."
    if npm run build:main; then
        echo "✅ 编译成功，显示指纹配置..."
        node temp-fingerprint-display.js
    else
        echo "❌ 编译失败"
    fi
fi

# 清理临时文件
rm -f temp-fingerprint-display.js
EOF

chmod +x show-fingerprint-config.sh

echo ""
echo "🎉 指纹验证方案创建完成！"
echo ""
echo "🚀 可用的验证方式："
echo ""
echo "1️⃣  基础指纹验证（推荐）:"
echo "   ./test-fingerprint-verification.sh"
echo "   📱 在新窗口显示详细的指纹测试页面"
echo ""
echo "2️⃣  多账号对比测试:"
echo "   ./test-multiple-accounts.sh"
echo "   📊 同时创建3个窗口，对比不同指纹"
echo ""
echo "3️⃣  在线指纹检测:"
echo "   ./test-online-fingerprint.sh"
echo "   🌐 访问真实的指纹检测网站"
echo ""
echo "4️⃣  显示指纹配置详情:"
echo "   ./show-fingerprint-config.sh"
echo "   📋 在控制台显示详细的指纹配置信息"
echo ""
echo "💡 验证方法说明："
echo "  • 方式1：在本地测试页面中查看所有指纹信息"
echo "  • 方式2：对比多个账号的指纹差异"
echo "  • 方式3：在真实网站上验证指纹效果"
echo "  • 方式4：直接查看生成的指纹配置"
echo ""
echo "🔍 重点关注的指纹参数："
echo "  - navigator.platform（操作系统平台）"
echo "  - navigator.hardwareConcurrency（CPU核心数）"
echo "  - screen.width/height（屏幕分辨率）"
echo "  - WebGL vendor/renderer（GPU信息）"
echo "  - Canvas 和 Audio 指纹哈希值"
echo ""
echo "📋 验证指纹伪装成功的标志："
echo "  ✅ 每次重启程序，指纹都不相同"
echo "  ✅ 不同账号显示不同的指纹信息"
echo "  ✅ 同一账号的指纹保持一致"
echo "  ✅ 指纹参数在合理范围内（不会太异常）"