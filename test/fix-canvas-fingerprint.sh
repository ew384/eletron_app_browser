#!/bin/bash

echo "🔧 修复 Canvas 指纹问题"
echo "====================="

echo "🔍 问题分析:"
echo "  - Canvas 指纹哈希在重启后没有变化"
echo "  - 说明噪声注入可能没有正常工作"
echo "  - 需要检查和修复 Canvas 伪装代码"

# 1. 首先检查当前的 Canvas 注入代码
echo ""
echo "📝 检查当前 Canvas 注入代码..."

if [ -f "src/preload/fingerprint/index.ts" ]; then
    echo "✅ 找到指纹注入文件"
    echo "🔍 检查 Canvas 相关代码..."
    
    # 显示当前 Canvas 相关代码的关键部分
    echo "当前 Canvas 注入逻辑:"
    grep -A 10 -B 5 "injectCanvasFingerprinting\|HTMLCanvasElement\|toDataURL" src/preload/fingerprint/index.ts || echo "❌ 未找到 Canvas 注入代码"
else
    echo "❌ 指纹注入文件不存在"
fi

echo ""
echo "🔧 创建增强版的 Canvas 指纹注入..."

# 2. 创建增强版的 Canvas 指纹注入代码
cat > src/preload/fingerprint/canvas.ts << 'CANVAS_EOF'
import { CanvasFingerprintConfig } from '../../shared/types';

export function injectCanvasFingerprinting(config: CanvasFingerprintConfig) {
  if (!config.enabled) {
    console.log('[Canvas] Canvas fingerprinting disabled');
    return;
  }

  console.log('[Canvas] Injecting Canvas fingerprinting with config:', config);
  
  const rng = createSeededRandom(config.seed || Date.now());

  // 重写 HTMLCanvasElement.prototype.toDataURL
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function(...args: any[]) {
    try {
      const originalResult = originalToDataURL.apply(this, args);
      const modifiedResult = addCanvasNoise(originalResult, config.noise, rng);
      
      console.log('[Canvas] toDataURL intercepted and modified');
      console.log('[Canvas] Original length:', originalResult.length);
      console.log('[Canvas] Modified length:', modifiedResult.length);
      console.log('[Canvas] Noise level:', config.noise);
      
      return modifiedResult;
    } catch (error) {
      console.error('[Canvas] Error in toDataURL override:', error);
      return originalToDataURL.apply(this, args);
    }
  };

  // 重写 CanvasRenderingContext2D.prototype.getImageData
  const originalGetImageData = CanvasRenderingContext2D.prototype.getImageData;
  CanvasRenderingContext2D.prototype.getImageData = function(...args: any[]) {
    try {
      const originalImageData = originalGetImageData.apply(this, args);
      const modifiedImageData = addImageDataNoise(originalImageData, config.noise, rng);
      
      console.log('[Canvas] getImageData intercepted and modified');
      return modifiedImageData;
    } catch (error) {
      console.error('[Canvas] Error in getImageData override:', error);
      return originalGetImageData.apply(this, args);
    }
  };

  console.log('[Canvas] Canvas fingerprinting injection completed');
}

function createSeededRandom(seed: number) {
  let currentSeed = seed;
  return () => {
    currentSeed = (currentSeed * 9301 + 49297) % 233280;
    return currentSeed / 233280;
  };
}

function addCanvasNoise(dataURL: string, noiseLevel: number, rng: () => number): string {
  try {
    // 创建临时 canvas 来处理图像
    const tempCanvas = document.createElement('canvas');
    const tempCtx = tempCanvas.getContext('2d');
    
    if (!tempCtx) {
      console.warn('[Canvas] Cannot get 2D context, returning original');
      return dataURL;
    }

    // 创建图像对象
    const img = new Image();
    
    return new Promise<string>((resolve) => {
      img.onload = () => {
        try {
          tempCanvas.width = img.width || 300;
          tempCanvas.height = img.height || 150;
          
          // 绘制原始图像
          tempCtx.drawImage(img, 0, 0);
          
          // 获取图像数据
          const imageData = tempCtx.getImageData(0, 0, tempCanvas.width, tempCanvas.height);
          const data = imageData.data;
          
          // 添加噪声
          let pixelCount = 0;
          for (let i = 0; i < data.length; i += 4) {
            if (rng() < noiseLevel) {
              // 计算噪声值
              const noiseR = Math.floor((rng() - 0.5) * 6);
              const noiseG = Math.floor((rng() - 0.5) * 6);
              const noiseB = Math.floor((rng() - 0.5) * 6);
              
              // 应用噪声
              data[i] = Math.max(0, Math.min(255, data[i] + noiseR));         // R
              data[i + 1] = Math.max(0, Math.min(255, data[i + 1] + noiseG)); // G
              data[i + 2] = Math.max(0, Math.min(255, data[i + 2] + noiseB)); // B
              // data[i + 3] 是 alpha 通道，不修改
              
              pixelCount++;
            }
          }
          
          console.log(`[Canvas] Applied noise to ${pixelCount} pixels (${(pixelCount/(data.length/4)*100).toFixed(2)}%)`);
          
          // 将修改后的数据放回 canvas
          tempCtx.putImageData(imageData, 0, 0);
          
          // 返回修改后的 dataURL
          resolve(tempCanvas.toDataURL());
        } catch (error) {
          console.error('[Canvas] Error processing image:', error);
          resolve(dataURL);
        }
      };
      
      img.onerror = () => {
        console.error('[Canvas] Error loading image');
        resolve(dataURL);
      };
      
      img.src = dataURL;
    }).then(result => result).catch(() => dataURL);
    
  } catch (error) {
    console.error('[Canvas] Error in addCanvasNoise:', error);
    return dataURL;
  }
}

// 同步版本的噪声添加（用于 getImageData）
function addImageDataNoise(imageData: ImageData, noiseLevel: number, rng: () => number): ImageData {
  try {
    const data = new Uint8ClampedArray(imageData.data);
    let pixelCount = 0;
    
    for (let i = 0; i < data.length; i += 4) {
      if (rng() < noiseLevel) {
        const noiseR = Math.floor((rng() - 0.5) * 4);
        const noiseG = Math.floor((rng() - 0.5) * 4);
        const noiseB = Math.floor((rng() - 0.5) * 4);
        
        data[i] = Math.max(0, Math.min(255, data[i] + noiseR));
        data[i + 1] = Math.max(0, Math.min(255, data[i + 1] + noiseG));
        data[i + 2] = Math.max(0, Math.min(255, data[i + 2] + noiseB));
        
        pixelCount++;
      }
    }
    
    console.log(`[Canvas] ImageData noise applied to ${pixelCount} pixels`);
    
    return new ImageData(data, imageData.width, imageData.height);
  } catch (error) {
    console.error('[Canvas] Error in addImageDataNoise:', error);
    return imageData;
  }
}

// 直接修改 Canvas 实例方法的替代方案
export function injectCanvasNoiseDirect() {
  console.log('[Canvas] Applying direct Canvas noise injection');
  
  // 生成随机噪声函数
  const generateNoise = () => Math.random() * 0.0001 - 0.00005;
  
  // 重写关键的 Canvas 方法
  const originalFillRect = CanvasRenderingContext2D.prototype.fillRect;
  CanvasRenderingContext2D.prototype.fillRect = function(x, y, width, height) {
    // 添加微小的随机偏移
    const noiseX = x + generateNoise();
    const noiseY = y + generateNoise();
    const noiseWidth = width + generateNoise();
    const noiseHeight = height + generateNoise();
    
    return originalFillRect.call(this, noiseX, noiseY, noiseWidth, noiseHeight);
  };
  
  const originalFillText = CanvasRenderingContext2D.prototype.fillText;
  CanvasRenderingContext2D.prototype.fillText = function(text, x, y, maxWidth) {
    // 添加微小的随机偏移
    const noiseX = x + generateNoise();
    const noiseY = y + generateNoise();
    
    if (maxWidth !== undefined) {
      return originalFillText.call(this, text, noiseX, noiseY, maxWidth + generateNoise());
    } else {
      return originalFillText.call(this, text, noiseX, noiseY);
    }
  };
  
  console.log('[Canvas] Direct noise injection completed');
}
CANVAS_EOF

echo "✅ 增强版 Canvas 注入代码已创建"

# 3. 更新主要的指纹注入文件
echo ""
echo "📝 更新主要指纹注入文件..."

cat > src/preload/fingerprint/index.ts << 'FINGERPRINT_INDEX_EOF'
import { injectCanvasFingerprinting, injectCanvasNoiseDirect } from './canvas';
import { FingerprintConfig } from '../../shared/types';

export function injectAllFingerprints(config: FingerprintConfig) {
  try {
    console.log('[Fingerprint] Starting fingerprint injection with config:', config);
    
    // Canvas 指纹注入 - 使用两种方法确保有效
    if (config.canvas.enabled) {
      console.log('[Fingerprint] Injecting Canvas fingerprinting...');
      injectCanvasFingerprinting(config.canvas);
      injectCanvasNoiseDirect(); // 额外的直接注入方法
    }

    // Navigator 指纹注入
    if (config.navigator.enabled) {
      console.log('[Fingerprint] Injecting Navigator fingerprinting...');
      injectNavigatorFingerprinting(config.navigator);
    }

    // WebGL 指纹注入
    if (config.webgl.enabled) {
      console.log('[Fingerprint] Injecting WebGL fingerprinting...');
      injectWebGLFingerprinting(config.webgl);
    }

    // Screen 指纹注入
    if (config.screen.enabled) {
      console.log('[Fingerprint] Injecting Screen fingerprinting...');
      injectScreenFingerprinting(config.screen);
    }

    console.log('[Fingerprint] All fingerprint injections completed successfully');
  } catch (error) {
    console.error('[Fingerprint] Error injecting fingerprints:', error);
  }
}

function injectNavigatorFingerprinting(config: any) {
  try {
    console.log('[Navigator] Injecting Navigator fingerprinting...');
    
    Object.defineProperties(navigator, {
      platform: { value: config.platform, writable: false, enumerable: true, configurable: true },
      language: { value: config.language, writable: false, enumerable: true, configurable: true },
      languages: { value: Object.freeze([...config.languages]), writable: false, enumerable: true, configurable: true },
      hardwareConcurrency: { value: config.hardwareConcurrency, writable: false, enumerable: true, configurable: true },
      maxTouchPoints: { value: config.maxTouchPoints, writable: false, enumerable: true, configurable: true }
    });
    
    if (config.deviceMemory !== undefined) {
      Object.defineProperty(navigator, 'deviceMemory', {
        value: config.deviceMemory,
        writable: false,
        enumerable: true,
        configurable: true
      });
    }
    
    console.log('[Navigator] Navigator fingerprinting injection completed');
  } catch (error) {
    console.error('[Navigator] Error in Navigator injection:', error);
  }
}

function injectWebGLFingerprinting(config: any) {
  try {
    console.log('[WebGL] Injecting WebGL fingerprinting...');
    
    const getParameter = WebGLRenderingContext.prototype.getParameter;
    WebGLRenderingContext.prototype.getParameter = function(parameter) {
      if (parameter === this.VENDOR) return config.vendor;
      if (parameter === this.RENDERER) return config.renderer;
      if (parameter === this.VERSION) return 'WebGL 1.0 (OpenGL ES 2.0 Chromium)';
      if (parameter === this.SHADING_LANGUAGE_VERSION) return 'WebGL GLSL ES 1.0 (OpenGL ES GLSL ES 1.0 Chromium)';
      return getParameter.apply(this, arguments as any);
    };

    // WebGL2 支持
    if (window.WebGL2RenderingContext) {
      const getParameter2 = WebGL2RenderingContext.prototype.getParameter;
      WebGL2RenderingContext.prototype.getParameter = function(parameter) {
        if (parameter === this.VENDOR) return config.vendor;
        if (parameter === this.RENDERER) return config.renderer;
        if (parameter === this.VERSION) return 'WebGL 2.0 (OpenGL ES 3.0 Chromium)';
        if (parameter === this.SHADING_LANGUAGE_VERSION) return 'WebGL GLSL ES 3.00 (OpenGL ES GLSL ES 3.0 Chromium)';
        return getParameter2.apply(this, arguments as any);
      };
    }
    
    console.log('[WebGL] WebGL fingerprinting injection completed');
  } catch (error) {
    console.error('[WebGL] Error in WebGL injection:', error);
  }
}

function injectScreenFingerprinting(config: any) {
  try {
    console.log('[Screen] Injecting Screen fingerprinting...');
    
    Object.defineProperties(screen, {
      width: { value: config.width, writable: false, enumerable: true, configurable: true },
      height: { value: config.height, writable: false, enumerable: true, configurable: true },
      availWidth: { value: config.width, writable: false, enumerable: true, configurable: true },
      availHeight: { value: config.height - 40, writable: false, enumerable: true, configurable: true },
      colorDepth: { value: config.colorDepth, writable: false, enumerable: true, configurable: true },
      pixelDepth: { value: config.colorDepth, writable: false, enumerable: true, configurable: true }
    });

    Object.defineProperty(window, 'devicePixelRatio', {
      get: () => config.pixelRatio,
      set: () => {},
      enumerable: true,
      configurable: true
    });
    
    console.log('[Screen] Screen fingerprinting injection completed');
  } catch (error) {
    console.error('[Screen] Error in Screen injection:', error);
  }
}

let injected = false;
export function ensureInjected(config: FingerprintConfig) {
  if (!injected) {
    console.log('[Fingerprint] First time injection, applying all fingerprints');
    injectAllFingerprints(config);
    injected = true;
  } else {
    console.log('[Fingerprint] Already injected, skipping');
  }
}
FINGERPRINT_INDEX_EOF

echo "✅ 主要指纹注入文件已更新"

# 4. 创建测试脚本来验证 Canvas 指纹变化
echo ""
echo "📝 创建 Canvas 指纹变化测试脚本..."

cat > test-canvas-change.sh << 'CANVAS_TEST_EOF'
#!/bin/bash

echo "🎨 Canvas 指纹变化测试"
echo "===================="

echo "📋 此测试将："
echo "  1. 编译更新后的代码"
echo "  2. 启动浏览器访问 BrowserLeaks"
echo "  3. 记录第一次的 Canvas 指纹"
echo "  4. 重启程序"
echo "  5. 再次访问并对比指纹变化"

# 编译
echo ""
echo "🏗️  编译更新后的代码..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🎯 第一次测试 - 记录初始指纹"
echo "请访问 BrowserLeaks Canvas 页面并记录 Signature 值"
echo "按任意键启动第一次测试..."
read -n 1

NODE_ENV=production electron dist/main/index.js &
ELECTRON_PID=$!

echo ""
echo "⏱️  请在新窗口中查看并记录 Canvas Signature"
echo "记录完成后，按任意键继续..."
read -n 1

# 结束第一次测试
kill $ELECTRON_PID 2>/dev/null
sleep 2

echo ""
echo "🔄 第二次测试 - 验证指纹变化"
echo "现在重新启动程序，Canvas 指纹应该不同"
echo "按任意键启动第二次测试..."
read -n 1

NODE_ENV=production electron dist/main/index.js &
ELECTRON_PID=$!

echo ""
echo "🔍 请对比新的 Canvas Signature 是否与第一次不同"
echo "如果不同，说明 Canvas 指纹伪装工作正常！"
echo "测试完成后，按任意键结束..."
read -n 1

kill $ELECTRON_PID 2>/dev/null

echo ""
echo "📊 测试完成！"
echo "✅ 如果两次的 Signature 不同，Canvas 指纹伪装成功"
echo "❌ 如果两次的 Signature 相同，需要进一步调试"
CANVAS_TEST_EOF

chmod +x test-canvas-change.sh

# 5. 创建调试版本的测试脚本
cat > debug-canvas.sh << 'DEBUG_EOF'
#!/bin/bash

echo "🔍 Canvas 指纹调试"
echo "=================="

echo "🏗️  编译调试版本..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🚀 启动调试模式..."
echo "📱 请打开开发者工具查看详细的 Console 日志"
echo "🔍 特别关注以 [Canvas] 开头的日志信息"

NODE_ENV=development electron dist/main/index.js --inspect
DEBUG_EOF

chmod +x debug-canvas.sh

echo ""
echo "🎉 Canvas 指纹修复完成！"
echo ""
echo "🔧 修复内容："
echo "  ✅ 重写了 Canvas 指纹注入逻辑"
echo "  ✅ 添加了详细的调试日志"
echo "  ✅ 实现了双重噪声注入方法"
echo "  ✅ 改进了随机数生成算法"
echo ""
echo "🧪 现在可以测试："
echo ""
echo "1️⃣  Canvas 指纹变化测试（推荐）:"
echo "   ./test-canvas-change.sh"
echo "   🎯 专门测试 Canvas 指纹是否每次都变化"
echo ""
echo "2️⃣  调试模式测试:"
echo "   ./debug-canvas.sh"
echo "   🔍 查看详细的 Canvas 注入日志"
echo ""
echo "3️⃣  重新运行完整测试:"
echo "   ./test-real-websites.sh"
echo "   🌐 验证修复后的效果"
echo ""
echo "💡 如果 Signature 仍然不变，请运行调试模式查看详细日志！"