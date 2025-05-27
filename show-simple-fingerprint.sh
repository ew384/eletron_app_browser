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
