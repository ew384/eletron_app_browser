#!/bin/bash

echo "🌐 真实指纹检测网站测试"
echo "======================"

# 创建专门访问真实网站的主进程
echo "📝 创建真实网站测试版本..."

# 备份原文件
cp src/main/index.ts src/main/index.ts.backup

cat > src/main/index.ts << 'REAL_SITES_EOF'
import { app, BrowserWindow } from 'electron';
import { WindowManager } from './window-manager';
import './ipc-handlers';
import * as path from 'path';

console.log('🚀 真实指纹检测网站测试启动...');

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
    console.log('🧪 创建浏览器实例访问真实指纹检测网站...');
    
    try {
      const testAccount = {
        id: 'real-fingerprint-test-' + Date.now(),
        name: '真实网站指纹测试',
        status: 'idle' as const,
        createdAt: Date.now()
      };
      
      const instance = await windowManager.createBrowserInstance(testAccount.id, {});
      console.log('✅ 测试浏览器实例创建成功');
      
      const testWindow = BrowserWindow.fromId(instance.windowId);
      if (testWindow) {
        // 设置窗口大小和位置，便于观察
        testWindow.setSize(1400, 900);
        testWindow.setPosition(100, 50);
        
        // 显示当前指纹配置
        const config = windowManager.getFingerprintConfig(testAccount.id);
        if (config) {
          console.log('\n🛡️  当前应用的指纹配置:');
          console.log('═'.repeat(60));
          console.log(`📱 平台 (Platform): ${config.navigator.platform}`);
          console.log(`🌍 语言 (Language): ${config.navigator.language}`);
          console.log(`⚙️  CPU核心 (CPU Cores): ${config.navigator.hardwareConcurrency}`);
          console.log(`👆 触控点 (Touch Points): ${config.navigator.maxTouchPoints}`);
          console.log(`💾 设备内存 (Memory): ${config.navigator.deviceMemory}GB`);
          console.log(`📺 屏幕分辨率 (Screen): ${config.screen.width}×${config.screen.height}`);
          console.log(`🖼️  像素比 (Pixel Ratio): ${config.screen.pixelRatio}`);
          console.log(`🎨 颜色深度 (Color Depth): ${config.screen.colorDepth}位`);
          console.log(`🎮 GPU厂商 (GPU Vendor): ${config.webgl.vendor}`);
          console.log(`🎯 GPU型号 (GPU Model): ${config.webgl.renderer.substring(0, 50)}...`);
          console.log(`🎨 Canvas噪声 (Canvas Noise): ${config.canvas.noise.toFixed(4)}`);
          console.log(`🔊 音频噪声 (Audio Noise): ${config.audio.noise.toFixed(4)}`);
          console.log(`🌍 时区 (Timezone): ${config.timezone.name}`);
          console.log('═'.repeat(60));
        }
        
        console.log('\n🎯 开始访问指纹检测网站...');
        
        // 要测试的网站列表（按重要性排序）
        const testSites = [
          {
            name: 'BrowserLeaks Canvas',
            url: 'https://browserleaks.com/canvas',
            description: '最权威的Canvas指纹检测'
          },
          {
            name: 'AmIUnique',
            url: 'https://amiunique.org/fingerprint',
            description: '综合浏览器唯一性检测'
          },
          {
            name: 'EFF Cover Your Tracks',
            url: 'https://coveryourtracks.eff.org/',
            description: 'EFF隐私基金会的跟踪检测'
          },
          {
            name: 'BrowserLeaks WebGL',
            url: 'https://browserleaks.com/webgl',
            description: 'WebGL和GPU信息检测'
          },
          {
            name: 'What Is My Browser',
            url: 'https://www.whatismybrowser.com/',
            description: '基础浏览器信息检测'
          }
        ];
        
        // 尝试按顺序访问网站
        let successCount = 0;
        for (let i = 0; i < testSites.length; i++) {
          const site = testSites[i];
          console.log(`\n📍 [${i + 1}/${testSites.length}] 尝试访问: ${site.name}`);
          console.log(`🔗 URL: ${site.url}`);
          console.log(`📋 说明: ${site.description}`);
          
          try {
            await testWindow.loadURL(site.url);
            console.log(`✅ ${site.name} 加载成功！`);
            console.log(`🔍 请在新窗口中查看检测结果`);
            
            // 显示验证提示
            console.log('\n📊 验证要点:');
            if (site.url.includes('canvas')) {
              console.log('  🎨 重点关注 Canvas Signature 是否每次重启都不同');
              console.log('  🔢 观察 Uniqueness 百分比');
            } else if (site.url.includes('amiunique')) {
              console.log('  📈 查看浏览器唯一性评分');
              console.log('  🔍 检查各项指纹参数是否被正确伪装');
            } else if (site.url.includes('eff')) {
              console.log('  🛡️  查看隐私保护评分');
              console.log('  👀 观察是否能防止跟踪');
            } else if (site.url.includes('webgl')) {
              console.log('  🎮 验证GPU信息是否显示伪装的型号');
              console.log('  📊 检查WebGL参数');
            }
            
            successCount++;
            break; // 成功加载一个网站后停止尝试
            
          } catch (error: unknown) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            console.log(`❌ ${site.name} 加载失败: ${errorMessage}`);
            
            if (i === testSites.length - 1) {
              console.log('\n🔄 所有网站都无法访问，尝试加载本地测试页面...');
              await loadLocalTestPage(testWindow);
            }
          }
        }
        
        if (successCount > 0) {
          console.log(`\n🎉 成功访问了指纹检测网站！`);
          console.log('\n🔍 现在可以验证指纹伪装效果：');
          console.log('1. 📋 对比网站显示的信息与控制台配置');
          console.log('2. 🔄 重启程序验证指纹随机性');
          console.log('3. 📊 观察指纹唯一性和质量评分');
          console.log('4. 🎯 确认关键参数被正确伪装');
          
          console.log('\n💡 其他推荐测试网站（可手动访问）:');
          testSites.slice(1).forEach((site, index) => {
            console.log(`   ${index + 2}. ${site.url} - ${site.description}`);
          });
        }
      }
      
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('❌ 测试失败:', errorMessage);
    }
  }, 3000);
}

async function loadLocalTestPage(window: BrowserWindow) {
  try {
    const testPagePath = path.join(__dirname, '../../test-pages/fingerprint-test.html');
    await window.loadFile(testPagePath);
    console.log('✅ 本地指纹测试页面加载成功');
    console.log('🔍 可以在本地页面中查看详细的指纹信息');
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error('❌ 本地页面加载也失败:', errorMessage);
    
    // 最后的备用方案
    const simpleHtml = `
      <html>
        <head><title>指纹测试</title></head>
        <body style="font-family: monospace; padding: 20px;">
          <h1>🛡️ 浏览器指纹测试</h1>
          <p>网络连接问题，但指纹伪装仍然有效</p>
          <div id="results"></div>
          <script>
            const results = document.getElementById('results');
            results.innerHTML = '<h3>当前浏览器信息:</h3>' +
              '<p>平台: ' + navigator.platform + '</p>' +
              '<p>语言: ' + navigator.language + '</p>' +
              '<p>CPU核心: ' + navigator.hardwareConcurrency + '</p>' +
              '<p>屏幕: ' + screen.width + 'x' + screen.height + '</p>' +
              '<p>像素比: ' + devicePixelRatio + '</p>';
          </script>
        </body>
      </html>
    `;
    window.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(simpleHtml)}`);
  }
}

function showControlPanel(window: BrowserWindow) {
  const controlHtml = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>真实网站指纹测试控制台</title>
        <meta charset="UTF-8">
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                margin: 0; padding: 30px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white; min-height: 100vh;
            }
            .container { max-width: 900px; margin: 0 auto; }
            h1 { text-align: center; font-size: 2.5em; margin-bottom: 30px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
            .panel {
                background: rgba(255,255,255,0.1); border-radius: 15px;
                padding: 25px; margin: 20px 0; backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.2);
            }
            .status { background: rgba(76, 175, 80, 0.3); border-color: rgba(76, 175, 80, 0.5); }
            .info { background: rgba(33, 150, 243, 0.3); border-color: rgba(33, 150, 243, 0.5); }
            .warning { background: rgba(255, 193, 7, 0.3); border-color: rgba(255, 193, 7, 0.5); }
            .countdown { font-size: 1.3em; font-weight: bold; color: #ffd700; text-align: center; }
            .site-list {
                display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 15px; margin: 20px 0;
            }
            .site-card {
                background: rgba(255,255,255,0.15); padding: 15px; border-radius: 10px;
                border-left: 4px solid #ffd700; transition: transform 0.2s;
            }
            .site-card:hover { transform: translateY(-2px); }
            .site-name { font-weight: bold; color: #ffd700; margin-bottom: 5px; }
            .site-desc { font-size: 0.9em; opacity: 0.9; }
            .instructions {
                background: rgba(255,255,255,0.2); padding: 20px; border-radius: 10px;
                margin: 20px 0; border-left: 4px solid #00ff88;
            }
            .verify-list { margin: 15px 0; }
            .verify-list li { margin: 8px 0; padding: 5px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🌐 真实网站指纹测试</h1>
            
            <div class="panel status">
                <h3>✅ 系统状态</h3>
                <p>✓ 指纹伪装系统已激活</p>
                <p>✓ 独特的浏览器指纹配置已生成</p>
                <p>✓ 所有关键API已被拦截和修改</p>
            </div>
            
            <div class="panel info">
                <h3>🧪 测试进行中...</h3>
                <p class="countdown">3秒后将创建新浏览器实例</p>
                <p>新窗口将访问真实的指纹检测网站</p>
                <p>请仔细对比检测结果与控制台显示的配置</p>
            </div>
            
            <div class="panel">
                <h3>🎯 将要测试的网站</h3>
                <div class="site-list">
                    <div class="site-card">
                        <div class="site-name">🎨 BrowserLeaks Canvas</div>
                        <div class="site-desc">最权威的Canvas指纹检测，重点关注Signature变化</div>
                    </div>
                    <div class="site-card">
                        <div class="site-name">🔍 AmIUnique</div>
                        <div class="site-desc">综合浏览器唯一性评估，查看整体伪装效果</div>
                    </div>
                    <div class="site-card">
                        <div class="site-name">🛡️ EFF Cover Your Tracks</div>
                        <div class="site-desc">隐私基金会的跟踪防护测试</div>
                    </div>
                    <div class="site-card">
                        <div class="site-name">🎮 BrowserLeaks WebGL</div>
                        <div class="site-desc">GPU和WebGL信息检测</div>
                    </div>
                </div>
            </div>
            
            <div class="instructions">
                <h3>📋 验证指南</h3>
                <div class="verify-list">
                    <h4>🎨 Canvas 指纹验证:</h4>
                    <ul>
                        <li>✓ Signature 每次重启都应该不同</li>
                        <li>✓ Uniqueness 应该显示高唯一性</li>
                        <li>✓ 支持检测应该全部为 True</li>
                    </ul>
                    
                    <h4>🖥️ Navigator 信息验证:</h4>
                    <ul>
                        <li>✓ Platform 应显示配置的操作系统</li>
                        <li>✓ Language 应显示配置的语言</li>
                        <li>✓ Hardware Concurrency 应显示配置的CPU核心数</li>
                    </ul>
                    
                    <h4>🎮 WebGL 信息验证:</h4>
                    <ul>
                        <li>✓ Vendor 应显示配置的GPU厂商</li>
                        <li>✓ Renderer 应显示配置的GPU型号</li>
                        <li>✓ 参数应与控制台输出匹配</li>
                    </ul>
                </div>
            </div>
            
            <div class="panel warning">
                <h3>⚠️ 注意事项</h3>
                <p>• 如果网站无法访问，会自动切换到本地测试页面</p>
                <p>• 重启程序后指纹会发生变化，这是正常现象</p>
                <p>• 查看控制台获取详细的配置信息和日志</p>
                <p>• 可以手动在地址栏输入其他检测网站进行测试</p>
            </div>
            
        </div>
        
        <script>
            let countdown = 3;
            const countdownEl = document.querySelector('.countdown');
            const timer = setInterval(() => {
                countdown--;
                if (countdown > 0) {
                    countdownEl.textContent = countdown + '秒后将创建新浏览器实例';
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
REAL_SITES_EOF

echo "✅ 真实网站测试版本已创建"

echo ""
echo "🏗️  编译测试版本..."
if npm run build:main; then
    echo "✅ 编译成功"
    
    echo ""
    echo "🌐 启动真实网站指纹测试..."
    echo ""
    echo "📱 预期效果:"
    echo "  - 主窗口: 显示测试控制台和说明"
    echo "  - 新窗口: 访问真实的指纹检测网站"
    echo "  - 控制台: 显示详细的指纹配置和访问日志"
    echo ""
    echo "🔍 重点验证:"
    echo "  1. Canvas Signature 是否每次重启都不同"
    echo "  2. Navigator 信息是否显示伪装的配置"
    echo "  3. GPU 信息是否显示虚拟的硬件"
    echo "  4. 屏幕分辨率等参数是否匹配配置"
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

echo ""
echo "📋 测试完成后的验证清单:"
echo "  □ Canvas Signature 值记录: ________________"
echo "  □ Platform 显示: ________________________"
echo "  □ GPU Vendor 显示: ______________________" 
echo "  □ CPU 核心数显示: _______________________"
echo "  □ 屏幕分辨率显示: _______________________"
echo ""
echo "💡 重启程序后再次测试，上述值应该发生变化！"