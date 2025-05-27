#!/bin/bash

echo "🧪 可靠的指纹测试"
echo "================"

echo "🏗️  编译项目..."
if npm run build:main; then
    echo "✅ 编译成功"
    
    echo ""
    echo "📊 显示生成的指纹配置:"
    echo "─────────────────────────────────"
    
    # 创建临时显示脚本
    cat > temp-display.js << 'DISPLAY_EOF'
const { FingerprintGenerator } = require('./dist/main/fingerprint/generator.js');

const accountId = 'test-account-' + Date.now();
const config = FingerprintGenerator.generateFingerprint(accountId);

console.log('🆔 测试账号:', accountId);
console.log('');
console.log('🖥️  Navigator 伪装:');
console.log(`    平台: ${config.navigator.platform}`);
console.log(`    语言: ${config.navigator.language}`);
console.log(`    CPU核心: ${config.navigator.hardwareConcurrency}`);
console.log(`    触控点数: ${config.navigator.maxTouchPoints}`);
console.log(`    设备内存: ${config.navigator.deviceMemory}GB`);
console.log('');
console.log('📺 屏幕伪装:');
console.log(`    分辨率: ${config.screen.width} × ${config.screen.height}`);
console.log(`    像素比: ${config.screen.pixelRatio}`);
console.log(`    颜色深度: ${config.screen.colorDepth}位`);
console.log('');
console.log('🎮 WebGL 伪装:');
console.log(`    GPU厂商: ${config.webgl.vendor}`);
console.log(`    GPU型号: ${config.webgl.renderer.substring(0, 60)}...`);
console.log('');
console.log('🎨 Canvas 伪装:');
console.log(`    噪声强度: ${config.canvas.noise.toFixed(4)}`);
console.log(`    噪声算法: ${config.canvas.algorithm}`);
console.log(`    随机种子: ${config.canvas.seed}`);
console.log('');
console.log('🔊 音频伪装:');
console.log(`    噪声强度: ${config.audio.noise.toFixed(4)}`);
console.log(`    随机种子: ${config.audio.seed}`);
console.log('');
console.log('🌍 时区伪装:');
console.log(`    时区名称: ${config.timezone.name}`);
console.log(`    UTC偏移: ${config.timezone.offset}分钟`);
console.log('');
console.log('📝 字体伪装:');
console.log(`    字体数量: ${config.fonts.available.length}`);
console.log(`    字体示例: ${config.fonts.available.slice(0, 3).join(', ')}...`);
DISPLAY_EOF
    
    node temp-display.js
    rm temp-display.js
    
    echo ""
    echo "─────────────────────────────────"
    echo "🚀 启动图形界面测试..."
    echo "📱 即将显示两个窗口:"
    echo "  - 主窗口: 欢迎页面"
    echo "  - 新窗口: 本地指纹测试页面"
    echo "⏱️  3秒后启动..."
    sleep 3
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译失败"
    exit 1
fi
