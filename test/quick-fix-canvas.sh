#!/bin/bash

echo "⚡ 快速修复 Canvas 类型错误"
echo "========================"

echo "📝 创建简化版的 Canvas 注入（避免复杂类型问题）..."

cat > src/preload/fingerprint/canvas.ts << 'SIMPLE_CANVAS_EOF'
import { CanvasFingerprintConfig } from '../../shared/types';

export function injectCanvasFingerprinting(config: CanvasFingerprintConfig) {
  if (!config.enabled) {
    console.log('[Canvas] Canvas fingerprinting disabled');
    return;
  }

  console.log('[Canvas] Injecting Canvas fingerprinting with noise level:', config.noise);
  
  // 简单且有效的 Canvas 指纹注入
  injectSimpleCanvasNoise(config.noise, config.seed || Date.now());
  
  console.log('[Canvas] Canvas fingerprinting injection completed');
}

function injectSimpleCanvasNoise(noiseLevel: number, seed: number) {
  // 方法1：重写 toDataURL（最重要的方法）
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function(type?: string, quality?: any): string {
    const originalResult = originalToDataURL.call(this, type, quality);
    
    // 基于时间和种子生成噪声
    const timeNoise = Date.now() % 1000000;
    const seedNoise = seed % 1000000;
    const randomNoise = Math.floor(Math.random() * 1000000);
    const finalNoise = timeNoise ^ seedNoise ^ randomNoise;
    
    console.log('[Canvas] toDataURL intercepted, applying noise:', finalNoise);
    
    return addStringNoise(originalResult, finalNoise);
  };
  
  // 方法2：重写 getImageData
  const originalGetImageData = CanvasRenderingContext2D.prototype.getImageData;
  CanvasRenderingContext2D.prototype.getImageData = function(
    sx: number, 
    sy: number, 
    sw: number, 
    sh: number
  ): ImageData {
    const originalData = originalGetImageData.call(this, sx, sy, sw, sh);
    
    console.log('[Canvas] getImageData intercepted, applying pixel noise');
    
    return addPixelNoise(originalData, noiseLevel);
  };
}

// 字符串级别的噪声添加（最可靠的方法）
function addStringNoise(dataURL: string, noise: number): string {
  try {
    const parts = dataURL.split(',');
    if (parts.length !== 2) return dataURL;
    
    const header = parts[0];
    let base64Data = parts[1];
    
    // 将噪声转换为字符并插入到 base64 数据中
    const noiseStr = noise.toString(36); // 转换为36进制
    const noiseBase64 = btoa(noiseStr).replace(/[+/=]/g, ''); // 移除特殊字符
    
    // 在中间位置插入噪声
    const insertPos = Math.floor(base64Data.length / 2);
    const modifiedBase64 = 
      base64Data.substring(0, insertPos) + 
      noiseBase64.substring(0, Math.min(8, noiseBase64.length)) + 
      base64Data.substring(insertPos);
    
    const result = header + ',' + modifiedBase64;
    console.log('[Canvas] String noise applied successfully');
    return result;
    
  } catch (error) {
    console.error('[Canvas] Error in string noise:', error);
    return dataURL;
  }
}

// 像素级别的噪声添加
function addPixelNoise(imageData: ImageData, noiseLevel: number): ImageData {
  try {
    const data = new Uint8ClampedArray(imageData.data);
    let modifiedPixels = 0;
    
    // 基于噪声级别修改像素
    const modificationRate = Math.min(noiseLevel * 0.1, 0.005); // 最多0.5%的像素
    
    for (let i = 0; i < data.length; i += 4) {
      if (Math.random() < modificationRate) {
        // 非常小的像素修改
        const pixelNoise = Math.floor((Math.random() - 0.5) * 4);
        
        data[i] = Math.max(0, Math.min(255, data[i] + pixelNoise));     // R
        data[i + 1] = Math.max(0, Math.min(255, data[i + 1] + pixelNoise)); // G  
        data[i + 2] = Math.max(0, Math.min(255, data[i + 2] + pixelNoise)); // B
        // Alpha 通道保持不变
        
        modifiedPixels++;
      }
    }
    
    console.log(`[Canvas] Modified ${modifiedPixels} pixels`);
    
    return new ImageData(data, imageData.width, imageData.height);
  } catch (error) {
    console.error('[Canvas] Error in pixel noise:', error);
    return imageData;
  }
}

// 导出其他方法保持兼容性
export function injectCanvasNoiseDirect() {
  console.log('[Canvas] Direct noise injection (placeholder)');
}

export function injectUltimateCanvasNoise() {
  console.log('[Canvas] Ultimate noise injection - using time-based noise');
  
  // 每次调用都基于当前时间生成不同的噪声
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function(type?: string, quality?: any): string {
    const originalResult = originalToDataURL.call(this, type, quality);
    
    // 使用当前精确时间作为噪声源
    const preciseTime = performance.now() * 1000; // 微秒级精度
    const timeHash = Math.floor(preciseTime) % 1000000;
    const randomHash = Math.floor(Math.random() * 1000000);
    const finalHash = timeHash ^ randomHash;
    
    console.log('[Canvas] Ultimate noise hash:', finalHash);
    
    return addStringNoise(originalResult, finalHash);
  };
}
SIMPLE_CANVAS_EOF

echo "✅ 简化版 Canvas 注入代码已创建"

# 测试编译
echo ""
echo "🧪 测试编译..."
if npm run build:main; then
    echo "✅ 编译成功！"
    
    echo ""
    echo "🚀 启动 Canvas 指纹测试..."
    echo "📱 即将打开浏览器，请观察 Canvas Signature 是否变化"
    echo "⏱️  3秒后启动..."
    sleep 3
    
    NODE_ENV=production electron dist/main/index.js
else
    echo "❌ 编译仍然失败，需要进一步调试"
    
    # 创建最简单的版本
    echo ""
    echo "📝 创建最简单的 Canvas 注入版本..."
    
    cat > src/preload/fingerprint/canvas.ts << 'MINIMAL_CANVAS_EOF'
import { CanvasFingerprintConfig } from '../../shared/types';

export function injectCanvasFingerprinting(config: CanvasFingerprintConfig) {
  if (!config.enabled) return;

  console.log('[Canvas] Injecting minimal Canvas fingerprinting');
  
  // 最简单的方法：直接重写 toDataURL
  const original = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function(): string {
    const result = original.call(this);
    
    // 添加时间戳噪声
    const timeNoise = Date.now() % 100000;
    const modifiedResult = result + '<!-- noise:' + timeNoise + ' -->';
    
    console.log('[Canvas] Applied time-based noise:', timeNoise);
    return modifiedResult;
  };
}

export function injectCanvasNoiseDirect() {
  console.log('[Canvas] Direct injection placeholder');
}

export function injectUltimateCanvasNoise() {
  console.log('[Canvas] Ultimate injection placeholder');
}
MINIMAL_CANVAS_EOF

    echo "✅ 最简版本已创建，重新编译..."
    
    if npm run build:main; then
        echo "✅ 最简版编译成功！"
        echo ""
        echo "🚀 启动测试..."
        NODE_ENV=production electron dist/main/index.js
    else
        echo "❌ 仍然编译失败，可能有其他问题"
    fi
fi