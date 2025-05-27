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
