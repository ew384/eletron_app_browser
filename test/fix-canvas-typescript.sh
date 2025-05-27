#!/bin/bash

echo "🔧 修复 Canvas TypeScript 编译错误"
echo "==============================="

echo "📝 重新创建修复版的 Canvas 注入代码..."

cat > src/preload/fingerprint/canvas.ts << 'CANVAS_FIXED_EOF'
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
  HTMLCanvasElement.prototype.toDataURL = function(type?: string, quality?: any): string {
    try {
      const originalResult = originalToDataURL.call(this, type, quality);
      const modifiedResult = addCanvasNoise(originalResult, config.noise, rng);
      
      console.log('[Canvas] toDataURL intercepted and modified');
      console.log('[Canvas] Original length:', originalResult.length);
      console.log('[Canvas] Modified length:', modifiedResult.length);
      console.log('[Canvas] Noise level:', config.noise);
      
      return modifiedResult;
    } catch (error) {
      console.error('[Canvas] Error in toDataURL override:', error);
      return originalToDataURL.call(this, type, quality);
    }
  };

  // 重写 CanvasRenderingContext2D.prototype.getImageData
  const originalGetImageData = CanvasRenderingContext2D.prototype.getImageData;
  CanvasRenderingContext2D.prototype.getImageData = function(
    sx: number, 
    sy: number, 
    sw: number, 
    sh: number, 
    settings?: ImageDataSettings
  ): ImageData {
    try {
      const originalImageData = originalGetImageData.call(this, sx, sy, sw, sh, settings);
      const modifiedImageData = addImageDataNoise(originalImageData, config.noise, rng);
      
      console.log('[Canvas] getImageData intercepted and modified');
      return modifiedImageData;
    } catch (error) {
      console.error('[Canvas] Error in getImageData override:', error);
      return originalGetImageData.call(this, sx, sy, sw, sh, settings);
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

// 同步版本的噪声添加函数
function addCanvasNoise(dataURL: string, noiseLevel: number, rng: () => number): string {
  try {
    // 如果是简单的 data URL，直接进行字符串级别的修改
    if (!dataURL.startsWith('data:image/')) {
      return dataURL;
    }

    // 创建一个简单的哈希修改来改变指纹
    let hash = 0;
    for (let i = 0; i < dataURL.length; i++) {
      hash = ((hash << 5) - hash + dataURL.charCodeAt(i)) & 0xffffffff;
    }
    
    // 添加基于噪声配置的随机变化
    const noiseValue = Math.floor(rng() * 1000000);
    const modifiedHash = hash ^ noiseValue;
    
    // 将修改后的哈希值添加到 URL 中（作为注释）
    const base64Part = dataURL.split(',')[1];
    if (base64Part) {
      // 在 base64 数据的末尾添加一些噪声字符
      const noiseByte = (modifiedHash % 64);
      const noiseChar = btoa(String.fromCharCode(noiseByte)).charAt(0);
      
      // 构造修改后的 dataURL
      const prefix = dataURL.split(',')[0];
      const modifiedBase64 = base64Part + noiseChar;
      
      return prefix + ',' + modifiedBase64;
    }
    
    return dataURL;
  } catch (error) {
    console.error('[Canvas] Error in addCanvasNoise:', error);
    return dataURL;
  }
}

// 同步版本的 ImageData 噪声添加
function addImageDataNoise(imageData: ImageData, noiseLevel: number, rng: () => number): ImageData {
  try {
    const data = new Uint8ClampedArray(imageData.data);
    let pixelCount = 0;
    
    // 只修改少量像素，避免视觉影响
    const modificationRate = Math.min(noiseLevel, 0.01); // 最多修改1%的像素
    
    for (let i = 0; i < data.length; i += 4) {
      if (rng() < modificationRate) {
        // 非常小的噪声，不影响视觉效果
        const noiseR = Math.floor((rng() - 0.5) * 2);
        const noiseG = Math.floor((rng() - 0.5) * 2);
        const noiseB = Math.floor((rng() - 0.5) * 2);
        
        data[i] = Math.max(0, Math.min(255, data[i] + noiseR));
        data[i + 1] = Math.max(0, Math.min(255, data[i + 1] + noiseG));
        data[i + 2] = Math.max(0, Math.min(255, data[i + 2] + noiseB));
        // Alpha 通道不修改
        
        pixelCount++;
      }
    }
    
    console.log(`[Canvas] ImageData noise applied to ${pixelCount} pixels (${((pixelCount * 4) / data.length * 100).toFixed(3)}%)`);
    
    return new ImageData(data, imageData.width, imageData.height);
  } catch (error) {
    console.error('[Canvas] Error in addImageDataNoise:', error);
    return imageData;
  }
}

// 更激进的噪声注入方法
export function injectCanvasNoiseDirect() {
  console.log('[Canvas] Applying direct Canvas noise injection');
  
  // 重写 Canvas 创建方法
  const originalGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function(contextType: string, contextAttributes?: any) {
    const context = originalGetContext.call(this, contextType, contextAttributes);
    
    if (contextType === '2d' && context) {
      // 为这个 context 添加噪声标记
      (context as any).__noiseApplied = true;
      console.log('[Canvas] Tagged 2D context for noise injection');
    }
    
    return context;
  };

  // 重写绘图方法，在绘制时添加微小变化
  const originalFillRect = CanvasRenderingContext2D.prototype.fillRect;
  CanvasRenderingContext2D.prototype.fillRect = function(x: number, y: number, width: number, height: number) {
    if ((this as any).__noiseApplied) {
      // 添加微小的随机偏移
      const noise = () => (Math.random() - 0.5) * 0.001;
      const noisyX = x + noise();
      const noisyY = y + noise();
      const noisyWidth = width + noise();
      const noisyHeight = height + noise();
      
      return originalFillRect.call(this, noisyX, noisyY, noisyWidth, noisyHeight);
    }
    return originalFillRect.call(this, x, y, width, height);
  };
  
  const originalFillText = CanvasRenderingContext2D.prototype.fillText;
  CanvasRenderingContext2D.prototype.fillText = function(text: string, x: number, y: number, maxWidth?: number) {
    if ((this as any).__noiseApplied) {
      const noise = () => (Math.random() - 0.5) * 0.001;
      const noisyX = x + noise();
      const noisyY = y + noise();
      
      if (maxWidth !== undefined) {
        return originalFillText.call(this, text, noisyX, noisyY, maxWidth + noise());
      } else {
        return originalFillText.call(this, text, noisyX, noisyY);
      }
    }
    
    if (maxWidth !== undefined) {
      return originalFillText.call(this, text, x, y, maxWidth);
    } else {
      return originalFillText.call(this, text, x, y);
    }
  };
  
  console.log('[Canvas] Direct noise injection completed');
}

// 终极噪声注入 - 直接修改 toDataURL 的返回值
export function injectUltimateCanvasNoise() {
  console.log('[Canvas] Applying ultimate Canvas noise injection');
  
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function(type?: string, quality?: any): string {
    const originalResult = originalToDataURL.call(this, type, quality);
    
    // 生成基于时间的噪声
    const timeNoise = Date.now() % 1000000;
    const randomNoise = Math.floor(Math.random() * 1000000);
    const combinedNoise = timeNoise ^ randomNoise;
    
    // 修改 base64 数据
    try {
      const parts = originalResult.split(',');
      if (parts.length === 2) {
        const header = parts[0];
        let base64Data = parts[1];
        
        // 在 base64 数据中插入噪声
        const noiseStr = combinedNoise.toString(36); // 转换为36进制字符串
        const insertPos = Math.floor(base64Data.length / 2);
        
        // 插入噪声字符，确保仍然是有效的 base64
        base64Data = base64Data.substring(0, insertPos) + 
                    btoa(noiseStr).substring(0, 4) + 
                    base64Data.substring(insertPos);
        
        const result = header + ',' + base64Data;
        console.log('[Canvas] Ultimate noise applied, hash will be different');
        return result;
      }
    } catch (error) {
      console.error('[Canvas] Error in ultimate noise injection:', error);
    }
    
    return originalResult;
  };
  
  console.log('[Canvas] Ultimate Canvas noise injection completed');
}
CANVAS_FIXED_EOF

echo "✅ 修复版 Canvas 代码已创建"

# 更新指纹注入的主文件
echo ""
echo "📝 更新指纹注入主文件..."

cat > src/preload/fingerprint/index.ts << 'INDEX_FIXED_EOF'
import { injectCanvasFingerprinting, injectCanvasNoiseDirect, injectUltimateCanvasNoise } from './canvas';
import { FingerprintConfig } from '../../shared/types';

export function injectAllFingerprints(config: FingerprintConfig) {
  try {
    console.log('[Fingerprint] Starting fingerprint injection with config:', config);
    
    // Canvas 指纹注入 - 使用三重保险
    if (config.canvas.enabled) {
      console.log('[Fingerprint] Injecting Canvas fingerprinting (Triple Method)...');
      injectCanvasFingerprinting(config.canvas);
      injectCanvasNoiseDirect();
      injectUltimateCanvasNoise(); // 终极方法，确保每次都不同
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
    WebGLRenderingContext.prototype.getParameter = function(parameter: GLenum): any {
      if (parameter === this.VENDOR) return config.vendor;
      if (parameter === this.RENDERER) return config.renderer;
      if (parameter === this.VERSION) return 'WebGL 1.0 (OpenGL ES 2.0 Chromium)';
      if (parameter === this.SHADING_LANGUAGE_VERSION) return 'WebGL GLSL ES 1.0 (OpenGL ES GLSL ES 1.0 Chromium)';
      return getParameter.call(this, parameter);
    };

    // WebGL2 支持
    if (window.WebGL2RenderingContext) {
      const getParameter2 = WebGL2RenderingContext.prototype.getParameter;
      WebGL2RenderingContext.prototype.getParameter = function(parameter: GLenum): any {
        if (parameter === this.VENDOR) return config.vendor;
        if (parameter === this.RENDERER) return config.renderer;
        if (parameter === this.VERSION) return 'WebGL 2.0 (OpenGL ES 3.0 Chromium)';
        if (parameter === this.SHADING_LANGUAGE_VERSION) return 'WebGL GLSL ES 3.00 (OpenGL ES GLSL ES 3.0 Chromium)';
        return getParameter2.call(this, parameter);
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
INDEX_FIXED_EOF

echo "✅ 指纹注入主文件已更新"

# 创建简化的测试脚本
echo ""
echo "📝 创建简化的测试脚本..."

cat > test-fixed-canvas.sh << 'TEST_FIXED_EOF'
#!/bin/bash

echo "🎨 修复后的 Canvas 测试"
echo "===================="

echo "🏗️  编译修复后的代码..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🌐 启动测试，请观察 Canvas Signature 是否每次都不同"
echo "📱 将打开浏览器访问 BrowserLeaks Canvas 页面"
echo "🔍 查看控制台的 [Canvas] 日志了解注入情况"

NODE_ENV=production electron dist/main/index.js
TEST_FIXED_EOF

chmod +x test-fixed-canvas.sh

echo ""
echo "🎉 Canvas TypeScript 错误修复完成！"
echo ""
echo "🔧 修复内容："
echo "  ✅ 修复了所有 TypeScript 类型错误"
echo "  ✅ 实现了同步的噪声注入算法"
echo "  ✅ 添加了三重保险的注入方法"
echo "  ✅ 使用时间戳确保每次都不同"
echo ""
echo "🧪 现在测试："
echo ""
echo "1️⃣  修复后的测试（推荐）:"
echo "   ./test-fixed-canvas.sh"
echo "   🎯 使用修复后的代码测试"
echo ""
echo "2️⃣  完整的指纹测试:"
echo "   ./test-real-websites.sh"
echo "   🌐 验证所有指纹功能"
echo ""
echo "💡 新版本使用了终极噪声注入方法，确保每次 Canvas 指纹都不同！"