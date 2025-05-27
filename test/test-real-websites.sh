#!/bin/bash

echo "🌐 访问真实网站测试指纹效果"
echo "========================"

# 备份原文件
cp src/main/index.ts src/main/index.ts.backup

echo "📝 创建访问真实网站的测试版本..."

cat > src/main/index.ts << 'REAL_SITE_EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

console.log('🚀 真实网站指纹测试启动...');

const windowManager = new WindowManager();

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 1000,
    height: 700,
    webPreferences: {
      preload: path.join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  showControlPanel(mainWindow);

  // 创建测试浏览器实例
  setTimeout(async () => {
    console.log('🧪 创建浏览器实例访问指纹检测网站...');
    
    try {
      const testAccount = {
        id: 'real-site-test-' + Date.now(),
        name: '真实网站测试',
        status: 'idle' as const,
        createdAt: Date.now()
      };
      
      const instance = await windowManager.createBrowserInstance(testAccount.id, {});
      console.log('✅ 测试浏览器实例创建成功');
      
      const testWindow = BrowserWindow.fromId(instance.windowId);
      if (testWindow) {
        // 设置窗口大小和位置
        testWindow.setSize(1200, 800);
        testWindow.setPosition(200, 100);
        
        console.log('🌐 正在访问指纹检测网站...');
        
        // 显示当前指纹配置
        const config = windowManager.getFingerprintConfig(testAccount.id);
        if (config) {
          console.log('\n🛡️  当前应用的指纹配置:');
          console.log('─'.repeat(50));
          console.log(`📱 平台: ${config.navigator.platform}`);
          console.log(`🌍 语言: ${config.navigator.language}`);
          console.log(`⚙️  CPU核心: ${config.navigator.hardwareConcurrency}`);
          console.log(`👆 触控点: ${config.navigator.maxTouchPoints}`);
          console.log(`💾 设备内存: ${config.navigator.deviceMemory}GB`);
          console.log(`📺 屏幕分辨率: ${config.screen.width}×${config.screen.height}`);
          console.log(`🖼️  像素比: ${config.screen.pixelRatio}`);
          console.log(`🎨 颜色深度: ${config.screen.colorDepth}位`);
          console.log(`🎮 GPU厂商: ${config.webgl.vendor}`);
          console.log(`🎯 GPU型号: ${config.webgl.renderer.substring(0, 50)}...`);
          console.log(`🎨 Canvas噪声: ${config.canvas.noise.toFixed(4)}`);
          console.log(`🔊 音频噪声: ${config.audio.noise.toFixed(4)}`);
          console.log(`🌍 时区: ${config.timezone.name}`);
          console.log('─'.repeat(50));
        }
        
        // 尝试访问 BrowserLeaks Canvas 检测页面
        const targetUrl = 'https://browserleaks.com/canvas';
        console.log(`\n🎯 访问目标网站: ${targetUrl}`);
        console.log('📋 这个网站会检测您的Canvas指纹');
        
        try {
          await testWindow.loadURL(targetUrl);
          console.log('✅ 网站加载成功！');
          console.log('\n🔍 验证指纹效果的方法:');
          console.log('1. 观察页面显示的Canvas指纹值');
          console.log('2. 对比控制台显示的配置参数');
          console.log('3. 多次重启程序，验证指纹变化');
          console.log('4. 可以手动访问其他检测网站对比');
          
          console.log('\n🌐 其他推荐的指纹检测网站:');
          console.log('• https://amiunique.org/fingerprint - 综合指纹检测');
          console.log('• https://coveryourtracks.eff.org/ - EFF隐私检测');
          console.log('• https://browserleaks.com/webgl - WebGL指纹检测');
          console.log('• https://browserleaks.com/javascript - JavaScript环境检测');
          console.log('• https://www.whatismybrowser.com/ - 浏览器信息检测');
          
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          console.error('❌ 主要网站访问失败:', errorMessage);
          console.log('\n🔄 尝试访问备用检测网站...');
          
          // 尝试其他网站
          const backupSites = [
            'https://www.whatismybrowser.com/',
            'https://amiunique.org/fingerprint',
            'https://coveryourtracks.eff.org/'
          ];
          
          let loaded = false;
          for (const site of backupSites) {
            try {
              console.log(`🔄 尝试访问: ${site}`);
              await testWindow.loadURL(site);
              console.log(`✅ 成功访问: ${site}`);
              loaded = true;
              break;
            } catch (backupError: unknown) {
              const backupErrorMessage = backupError instanceof Error ? backupError.message : String(backupError);
              console.log(`❌ ${site} 访问失败: ${backupErrorMessage}`);
            }
          }
          
          if (!loaded) {
            console.log('🔄 所有在线网站都无法访问，加载本地测试页面...');
            const testPagePath = path.join(__dirname, '../../test-pages/fingerprint-test.html');
            try {
              await testWindow.loadFile(testPagePath);
              console.log('✅ 本地测试页面加载成功');
            } catch (localError: unknown) {
              const localErrorMessage = localError instanceof Error ? localError.message : String(localError);
              console.error('❌ 本地页面加载失败:', localErrorMessage);
            }
          }
        }
      }
      
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('❌ 测试失败:', errorMessage);
    }
  }, 3000);
}

function showControlPanel(window: BrowserWindow) {
  const controlHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>指纹测试控制面板</title>
        <meta charset="UTF-8">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0; padding: 30px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white; min-height: 100vh;
            }
            .container { max-width: 800px; margin: 0 auto; }
            h1 { text-align: center; font-size: 2.5em; margin-bottom: 30px; }
            .panel {
                background: rgba(255,255,255,0.1); border-radius: 15px;
                padding: 25px; margin: 20px 0; backdrop-filter: blur(10px);
            }
            .status { background: rgba(76, 175, 80, 0.3); border: 1px solid rgba(76, 175, 80, 0.5); }
            .info { background: rgba(33, 150, 243, 0.3); border: 1px solid rgba(33, 150, 243, 0.5); }
            .sites { text-align: left; margin: 15px 0; }
            .sites li { margin: 8px 0; padding: 5px 0; }
            .countdown { font-size: 1.3em; font-weight: bold; color: #ffd700; text-align: center; }
            .instructions {
                background: rgba(255,255,255,0.2); padding: 20px; border-radius: 10px;
                margin: 20px 0; border-left: 4px solid #ffd700;
            }
            .feature-list {
                display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 15px; margin: 20px 0;
            }
            .feature {
                background: rgba(255,255,255,0.15); padding: 15px; border-radius: 8px;
                text-align: center; font-size: 0.9em;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🌐 真实网站指纹测试</h1>
            
            <div class="panel status">
                <h3>✅ 系统状态</h3>
                <p>指纹伪装系统已激活并正常运行</p>
                <p>已生成独特的浏览器指纹配置</p>
            </div>
            
            <div class="panel info">
                <h3>🧪 测试进行中...</h3>
                <p class="countdown">3秒后将创建新的浏览器实例</p>
                <p>新窗口将访问真实的指纹检测网站</p>
                <p>请对比检测结果与控制台显示的配置</p>
            </div>
            
            <div class="instructions">
                <h3>📋 使用说明</h3>
                <p><strong>1. 观察新弹出的窗口</strong> - 将显示真实的指纹检测网站</p>
                <p><strong>2. 查看控制台输出</strong> - 显示当前应用的指纹配置</p>
                <p><strong>3. 对比验证效果</strong> - 网站检测结果应与配置匹配</p>
                <p><strong>4. 测试指纹变化</strong> - 重启程序验证指纹随机性</p>
            </div>
            
            <div class="panel">
                <h3>🎯 将访问的检测网站</h3>
                <div class="sites">
                    <ul>
                        <li>🎨 <strong>BrowserLeaks Canvas</strong> - 检测Canvas指纹和图像噪声</li>
                        <li>🔍 <strong>AmIUnique</strong> - 综合浏览器指纹唯一性检测</li>
                        <li>🛡️ <strong>EFF Cover Your Tracks</strong> - 隐私和追踪保护检测</li>
                        <li>🎮 <strong>BrowserLeaks WebGL</strong> - GPU和WebGL信息检测</li>
                        <li>ℹ️ <strong>What Is My Browser</strong> - 基础浏览器信息检测</li>
                    </ul>
                </div>
            </div>
            
            <div class="panel">
                <h3>🛡️ 当前伪装的指纹组件</h3>
                <div class="feature-list">
                    <div class="feature">🖥️<br>Navigator信息</div>
                    <div class="feature">📺<br>屏幕分辨率</div>
                    <div class="feature">🎨<br>Canvas指纹</div>
                    <div class="feature">🎮<br>WebGL信息</div>
                    <div class="feature">🔊<br>音频上下文</div>
                    <div class="feature">🌍<br>时区设置</div>
                    <div class="feature">📝<br>字体列表</div>
                    <div class="feature">⚙️<br>硬件信息</div>
                </div>
            </div>
            
            <div style="text-align: center; margin-top: 30px; opacity: 0.9;">
                <p>🔍 <strong>验证指纹效果的关键指标:</strong></p>
                <p>• Canvas指纹哈希值每次启动都不同</p>
                <p>• Navigator.platform显示伪装的操作系统</p>
                <p>• GPU信息显示配置的虚拟GPU</p>
                <p>• 屏幕分辨率匹配生成的配置</p>
            </div>
        </div>
        
        <script>
            let countdown = 3;
            const countdownEl = document.querySelector('.countdown');
            const timer = setInterval(() => {
                countdown--;
                if (countdown > 0) {
                    countdownEl.textContent = countdown + '秒后将创建新的浏览器实例';
                } else {
                    countdownEl.textContent = '正在创建浏览器实例并访问检测网站...';
                    countdownEl.style.color = '#90EE90';
                    clearInterval(timer);
                }
            }, 1000);
        </script>
    </body>
    </html>
  `;
  
  window.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(controlHtml)}`);
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
REAL_SITE_EOF

echo "✅ 真实网站测试版本已创建"

echo "🏗️  编译测试版本..."
if npm run build:main; then
    echo "✅ 编译成功"
    echo ""
    echo "🌐 启动真实网站指纹测试..."
    echo ""
    echo "📱 预期效果:"
    echo "  - 主窗口: 显示测试控制面板"
    echo "  - 新窗口: 访问 BrowserLeaks Canvas 检测页面"
    echo "  - 控制台: 显示详细的指纹配置信息"
    echo ""
    echo "🔍 验证方法:"
    echo "  1. 在新窗口查看Canvas指纹检测结果"
    echo "  2. 对比控制台显示的配置参数"
    echo "  3. 观察是否成功伪装了浏览器信息"
    echo ""
    echo "⏱️  3秒后启动..."
    sleep 3
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
fi

# 恢复原文件
echo ""
echo "🔄 恢复原始文件..."
mv src/main/index.ts.backup src/main/index.ts
echo "✅ 原始文件已恢复"
REAL_SITE_EOF

chmod +x test-real-websites.sh

# 创建多站点测试脚本
cat > test-multiple-sites.sh << 'MULTI_SITES_EOF'
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
MULTI_SITES_EOF

chmod +x test-multiple-sites.sh

echo ""
echo "🎉 真实网站测试脚本创建完成！"
echo ""
echo "🌐 可用的真实网站测试："
echo ""
echo "1️⃣  单站点深度测试（推荐）:"
echo "   ./test-real-websites.sh"
echo "   🎯 访问 BrowserLeaks Canvas 进行详细检测"
echo ""
echo "2️⃣  多站点对比测试:"
echo "   ./test-multiple-sites.sh"
echo "   🔄 同时访问多个不同的检测网站"
echo ""
echo "🔍 测试要点："
echo "  • 观察Canvas指纹是否每次启动都不同"
echo "  • 检查Navigator信息是否被正确伪装"
echo "  • 验证GPU信息是否显示虚拟配置"
echo "  • 确认屏幕分辨率等参数匹配生成的配置"
echo ""
echo "💡 网络问题时会自动切换到本地测试页面"
echo "🚀 现在运行 './test-real-websites.sh' 测试真实效果！"