#!/bin/bash

echo "✅ 指纹功能验证"
echo "=============="

echo "🔍 快速验证指纹生成功能..."

# 编译检查
if [ ! -f "dist/main/fingerprint/generator.js" ]; then
    echo "🏗️  编译项目..."
    if ! npm run build:main; then
        echo "❌ 编译失败"
        exit 1
    fi
fi

echo "✅ 编译检查通过"

# 验证指纹生成
echo ""
echo "🎲 测试指纹生成功能..."

cat > temp-verify.js << 'VERIFY_EOF'
const { FingerprintGenerator } = require('./dist/main/fingerprint/generator.js');
const { FingerprintValidator } = require('./dist/main/fingerprint/validator.js');

console.log('🧪 指纹生成测试:');

// 测试1：生成指纹
const config1 = FingerprintGenerator.generateFingerprint('test-001');
console.log('✅ 指纹生成成功');

// 测试2：验证指纹质量
const quality = FingerprintValidator.validateFingerprint(config1);
console.log(`✅ 指纹质量评分: ${quality.score}/100`);

// 测试3：一致性测试
const config2 = FingerprintGenerator.generateFingerprint('test-001');
const isConsistent = JSON.stringify(config1) === JSON.stringify(config2);
console.log(`✅ 一致性测试: ${isConsistent ? '通过' : '失败'}`);

// 测试4：唯一性测试
const config3 = FingerprintGenerator.generateFingerprint('test-002');
const isDifferent = JSON.stringify(config1) !== JSON.stringify(config3);
console.log(`✅ 唯一性测试: ${isDifferent ? '通过' : '失败'}`);

console.log('\n📊 示例指纹配置:');
console.log(`   平台: ${config1.navigator.platform}`);
console.log(`   语言: ${config1.navigator.language}`);
console.log(`   CPU: ${config1.navigator.hardwareConcurrency}核`);
console.log(`   屏幕: ${config1.screen.width}×${config1.screen.height}`);
console.log(`   GPU: ${config1.webgl.vendor}`);

if (quality.issues.length > 0) {
  console.log('\n⚠️  质量问题:');
  quality.issues.forEach(issue => console.log(`   - ${issue}`));
} else {
  console.log('\n🎉 指纹配置完美！');
}
VERIFY_EOF

node temp-verify.js
rm temp-verify.js

echo ""
echo "🚀 启动图形界面验证..."
echo "📱 将显示指纹测试页面"

NODE_ENV=production electron dist/main/index.js
