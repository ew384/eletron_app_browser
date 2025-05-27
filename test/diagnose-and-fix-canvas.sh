#!/bin/bash

echo "🔍 诊断并修复 Canvas 指纹问题"
echo "============================"

echo "❌ 问题确认: Canvas 指纹没有生效"
echo "  - 两次测试的 Signature 完全相同"
echo "  - 说明 Canvas 噪声注入没有工作"
echo "  - 需要彻底重新设计注入方式"

echo ""
echo "🔧 创建强制性 Canvas 指纹注入..."

# 创建最直接的 Canvas 注入方法
cat > src/preload/fingerprint/canvas-force.ts << 'FORCE_CANVAS_EOF'
import { CanvasFingerprintConfig } from '../../shared/types';

// 强制性 Canvas 指纹注入
export function forceInjectCanvasFingerprint(config: CanvasFingerprintConfig) {
  if (!config.enabled) return;

  console.log('[Canvas-Force] 开始强制性 Canvas 指纹注入');
  console.log('[Canvas-Force] 配置:', config);

  // 方法1: 重写 toDataURL - 直接修改返回值
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function(type?: string, quality?: any): string {
    const original = originalToDataURL.call(this, type, quality);
    
    // 生成基于时间的强制噪声
    const timestamp = Date.now();
    const random = Math.random();
    const forceNoise = Math.floor(timestamp * random) % 1000000;
    
    console.log('[Canvas-Force] toDataURL 被调用，注入噪声:', forceNoise);
    
    // 直接修改 base64 数据
    return modifyBase64Data(original, forceNoise);
  };

  // 方法2: 重写 getContext - 在获取上下文时就开始注入
  const originalGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function(contextType: string, contextAttributes?: any): RenderingContext | null {
    const context = originalGetContext.call(this, contextType, contextAttributes);
    
    if (contextType === '2d' && context) {
      console.log('[Canvas-Force] 2D Context 创建，准备注入噪声');
      injectInto2DContext(context as CanvasRenderingContext2D);
    }
    
    return context;
  };

  // 方法3: 重写关键绘图方法
  injectDrawingMethods();
  
  console.log('[Canvas-Force] 强制性注入完成');
}

function modifyBase64Data(dataURL: string, noise: number): string {
  try {
    if (!dataURL.includes(',')) return dataURL;
    
    const [header, base64] = dataURL.split(',');
    
    // 方法1: 在 base64 中间插入噪声
    const noiseHex = noise.toString(16).padStart(8, '0');
    const noiseBase64 = btoa(noiseHex);
    
    const mid = Math.floor(base64.length / 2);
    const modifiedBase64 = base64.substring(0, mid) + noiseBase64 + base64.substring(mid + noiseBase64.length);
    
    console.log('[Canvas-Force] Base64 修改完成，长度变化:', base64.length, '->', modifiedBase64.length);
    
    return header + ',' + modifiedBase64;
  } catch (error) {
    console.error('[Canvas-Force] Base64 修改失败:', error);
    
    // 备用方法: 简单地在末尾添加噪声标记
    return dataURL + '<!-- noise:' + noise + ' -->';
  }
}

function injectInto2DContext(ctx: CanvasRenderingContext2D) {
  // 标记这个 context 已被处理
  (ctx as any).__fingerprint_injected = true;
  
  // 重写 fillText 方法
  const originalFillText = ctx.fillText;
  ctx.fillText = function(text: string, x: number, y: number, maxWidth?: number) {
    console.log('[Canvas-Force] fillText 被调用，添加位置噪声');
    
    // 添加微小的位置噪声
    const noiseX = x + (Math.random() - 0.5) * 0.1;
    const noiseY = y + (Math.random() - 0.5) * 0.1;
    
    if (maxWidth !== undefined) {
      return originalFillText.call(this, text, noiseX, noiseY, maxWidth);
    } else {
      return originalFillText.call(this, text, noiseX, noiseY);
    }
  };
  
  // 重写 fillRect 方法
  const originalFillRect = ctx.fillRect;
  ctx.fillRect = function(x: number, y: number, width: number, height: number) {
    console.log('[Canvas-Force] fillRect 被调用，添加尺寸噪声');
    
    const noiseX = x + (Math.random() - 0.5) * 0.01;
    const noiseY = y + (Math.random() - 0.5) * 0.01;
    const noiseW = width + (Math.random() - 0.5) * 0.01;
    const noiseH = height + (Math.random() - 0.5) * 0.01;
    
    return originalFillRect.call(this, noiseX, noiseY, noiseW, noiseH);
  };
}

function injectDrawingMethods() {
  console.log('[Canvas-Force] 注入绘图方法噪声');
  
  // 重写全局的 fillText 方法
  const originalFillText = CanvasRenderingContext2D.prototype.fillText;
  CanvasRenderingContext2D.prototype.fillText = function(text: string, x: number, y: number, maxWidth?: number) {
    if (!(this as any).__fingerprint_injected) {
      console.log('[Canvas-Force] fillText 全局拦截，添加文本噪声');
      
      // 在文本末尾添加不可见字符
      const noisyText = text + String.fromCharCode(8203); // 零宽度空格
      
      if (maxWidth !== undefined) {
        return originalFillText.call(this, noisyText, x, y, maxWidth);
      } else {
        return originalFillText.call(this, noisyText, x, y);
      }
    }
    
    if (maxWidth !== undefined) {
      return originalFillText.call(this, text, x, y, maxWidth);
    } else {
      return originalFillText.call(this, text, x, y);
    }
  };
}

// 终极方法：直接修改 Canvas 原型链
export function ultimateCanvasHijack() {
  console.log('[Canvas-Ultimate] 启动终极 Canvas 劫持');
  
  // 创建一个全局的噪声生成器
  const globalNoise = () => Date.now() + Math.floor(Math.random() * 1000000);
  
  // 完全重写 toDataURL
  Object.defineProperty(HTMLCanvasElement.prototype, 'toDataURL', {
    value: function(type?: string, quality?: any): string {
      // 获取原始方法
      const canvas = this as HTMLCanvasElement;
      const ctx = canvas.getContext('2d');
      
      if (!ctx) {
        console.log('[Canvas-Ultimate] 无法获取 2D context');
        return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
      }
      
      // 在 canvas 上绘制一个不可见的噪声像素
      const noise = globalNoise();
      const originalFillStyle = ctx.fillStyle;
      
      // 保存当前状态
      ctx.save();
      
      // 在随机位置绘制一个几乎透明的像素
      const x = noise % canvas.width;
      const y = Math.floor(noise / canvas.width) % canvas.height;
      ctx.fillStyle = `rgba(${noise % 255}, ${(noise >> 8) % 255}, ${(noise >> 16) % 255}, 0.003)`;
      ctx.fillRect(x, y, 1, 1);
      
      // 恢复状态
      ctx.restore();
      ctx.fillStyle = originalFillStyle;
      
      // 调用原始的 toDataURL
      const originalToDataURL = Object.getPrototypeOf(Object.getPrototypeOf(canvas)).toDataURL;
      const result = originalToDataURL.call(canvas, type, quality);
      
      console.log('[Canvas-Ultimate] 终极劫持成功，注入噪声:', noise);
      
      return result;
    },
    writable: false,
    enumerable: false,
    configurable: true
  });
  
  console.log('[Canvas-Ultimate] 终极劫持完成');
}

// 检测当前注入状态
export function detectCanvasInjection() {
  console.log('[Canvas-Detect] 检测当前 Canvas 注入状态');
  
  // 创建测试 canvas
  const testCanvas = document.createElement('canvas');
  testCanvas.width = 100;
  testCanvas.height = 100;
  
  const ctx = testCanvas.getContext('2d');
  if (!ctx) {
    console.log('[Canvas-Detect] 无法创建测试 Canvas');
    return false;
  }
  
  // 绘制测试内容
  ctx.fillStyle = 'red';
  ctx.fillRect(10, 10, 50, 50);
  ctx.fillStyle = 'blue';
  ctx.font = '16px Arial';
  ctx.fillText('Test', 20, 30);
  
  // 获取两次 dataURL
  const url1 = testCanvas.toDataURL();
  const url2 = testCanvas.toDataURL();
  
  console.log('[Canvas-Detect] 第一次 URL 长度:', url1.length);
  console.log('[Canvas-Detect] 第二次 URL 长度:', url2.length);
  console.log('[Canvas-Detect] 两次结果相同:', url1 === url2);
  
  // 等待一毫秒后再次测试
  setTimeout(() => {
    const url3 = testCanvas.toDataURL();
    console.log('[Canvas-Detect] 延迟测试 URL 长度:', url3.length);
    console.log('[Canvas-Detect] 与第一次相同:', url1 === url3);
  }, 1);
  
  return url1 !== url2;
}
FORCE_CANVAS_EOF

echo "✅ 强制性 Canvas 注入代码已创建"

# 更新主要的指纹注入文件
echo ""
echo "📝 更新主要指纹注入文件..."

cat > src/preload/fingerprint/index.ts << 'MAIN_INJECT_EOF'
import { forceInjectCanvasFingerprint, ultimateCanvasHijack, detectCanvasInjection } from './canvas-force';
import { FingerprintConfig } from '../../shared/types';

export function injectAllFingerprints(config: FingerprintConfig) {
  try {
    console.log('[Fingerprint] 开始强制性指纹注入');
    console.log('[Fingerprint] 配置:', config);
    
    // 首先检测当前状态
    console.log('[Fingerprint] 检测当前 Canvas 状态...');
    const isWorking = detectCanvasInjection();
    console.log('[Fingerprint] Canvas 注入检测结果:', isWorking ? '可能有效' : '需要修复');

    // Canvas 指纹注入 - 使用强制方法
    if (config.canvas.enabled) {
      console.log('[Fingerprint] 启动强制性 Canvas 指纹注入...');
      forceInjectCanvasFingerprint(config.canvas);
      ultimateCanvasHijack(); // 终极方法
      
      // 再次检测
      setTimeout(() => {
        console.log('[Fingerprint] 注入后检测...');
        detectCanvasInjection();
      }, 100);
    }

    // Navigator 指纹注入
    if (config.navigator.enabled) {
      console.log('[Fingerprint] 注入 Navigator 指纹...');
      injectNavigatorFingerprinting(config.navigator);
    }

    // WebGL 指纹注入
    if (config.webgl.enabled) {
      console.log('[Fingerprint] 注入 WebGL 指纹...');
      injectWebGLFingerprinting(config.webgl);
    }

    // Screen 指纹注入
    if (config.screen.enabled) {
      console.log('[Fingerprint] 注入 Screen 指纹...');
      injectScreenFingerprinting(config.screen);
    }

    console.log('[Fingerprint] 所有指纹注入完成');
  } catch (error) {
    console.error('[Fingerprint] 指纹注入出错:', error);
  }
}

function injectNavigatorFingerprinting(config: any) {
  try {
    console.log('[Navigator] 注入 Navigator 指纹...');
    
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
    
    console.log('[Navigator] Navigator 注入完成');
  } catch (error) {
    console.error('[Navigator] Navigator 注入失败:', error);
  }
}

function injectWebGLFingerprinting(config: any) {
  try {
    console.log('[WebGL] 注入 WebGL 指纹...');
    
    const getParameter = WebGLRenderingContext.prototype.getParameter;
    WebGLRenderingContext.prototype.getParameter = function(parameter: GLenum): any {
      if (parameter === this.VENDOR) return config.vendor;
      if (parameter === this.RENDERER) return config.renderer;
      return getParameter.call(this, parameter);
    };

    if (window.WebGL2RenderingContext) {
      const getParameter2 = WebGL2RenderingContext.prototype.getParameter;
      WebGL2RenderingContext.prototype.getParameter = function(parameter: GLenum): any {
        if (parameter === this.VENDOR) return config.vendor;
        if (parameter === this.RENDERER) return config.renderer;
        return getParameter2.call(this, parameter);
      };
    }
    
    console.log('[WebGL] WebGL 注入完成');
  } catch (error) {
    console.error('[WebGL] WebGL 注入失败:', error);
  }
}

function injectScreenFingerprinting(config: any) {
  try {
    console.log('[Screen] 注入 Screen 指纹...');
    
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
    
    console.log('[Screen] Screen 注入完成');
  } catch (error) {
    console.error('[Screen] Screen 注入失败:', error);
  }
}

let injected = false;
export function ensureInjected(config: FingerprintConfig) {
  if (!injected) {
    console.log('[Fingerprint] 首次注入，启动所有指纹伪装');
    injectAllFingerprints(config);
    injected = true;
  } else {
    console.log('[Fingerprint] 已注入，跳过重复注入');
  }
}
MAIN_INJECT_EOF

echo "✅ 主要指纹注入文件已更新"

# 创建强制测试脚本
echo ""
echo "📝 创建强制测试脚本..."

cat > test-force-canvas.sh << 'FORCE_TEST_EOF'
#!/bin/bash

echo "💪 强制性 Canvas 指纹测试"
echo "======================="

echo "🏗️  编译强制修复版本..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🔍 启动强制测试..."
echo "📱 请特别关注控制台的 [Canvas-Force] 和 [Canvas-Ultimate] 日志"
echo "🎯 每次 toDataURL 调用都应该显示不同的噪声值"
echo ""
echo "⚠️  如果仍然没有效果，说明可能需要更深层的修复"

NODE_ENV=production electron dist/main/index.js
FORCE_TEST_EOF

chmod +x test-force-canvas.sh

echo ""
echo "🎉 强制性修复完成！"
echo ""
echo "🔧 修复内容："
echo "  ✅ 完全重写了 Canvas 注入方法"
echo "  ✅ 使用多重保险的注入策略"
echo "  ✅ 添加了实时检测和验证"
echo "  ✅ 实现了终极劫持方法"
echo ""
echo "🧪 现在测试："
echo ""
echo "1️⃣  强制性测试（推荐）:"
echo "   ./test-force-canvas.sh"
echo "   💪 使用最激进的修复方法"
echo ""
echo "2️⃣  然后访问真实网站验证:"
echo "   ./test-real-fingerprint-sites.sh"
echo "   🌐 检查 BrowserLeaks 的结果"
echo ""
echo "🔍 关键检查点："
echo "  - 控制台应显示: [Canvas-Force] toDataURL 被调用，注入噪声: XXXXX"
echo "  - 每次调用都应该有不同的噪声值"
echo "  - Canvas Signature 应该每次重启都不同"
echo ""
echo "💡 如果这次修复仍然无效，可能需要从更底层的角度解决问题"