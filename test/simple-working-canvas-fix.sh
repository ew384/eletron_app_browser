#!/bin/bash

echo "⚡ 简单有效的 Canvas 修复"
echo "======================"

echo "📝 创建最简单但有效的 Canvas 注入..."

cat > src/preload/fingerprint/canvas-simple.ts << 'SIMPLE_CANVAS_EOF'
import { CanvasFingerprintConfig } from '../../shared/types';

export function injectSimpleCanvasFingerprint(config: CanvasFingerprintConfig) {
  if (!config.enabled) {
    console.log('[Canvas-Simple] Canvas 指纹注入已禁用');
    return;
  }

  console.log('[Canvas-Simple] 开始简单有效的 Canvas 指纹注入');
  console.log('[Canvas-Simple] 噪声级别:', config.noise);

  // 方法1: 最直接的 toDataURL 重写
  injectToDataURL();
  
  // 方法2: 绘图方法注入
  injectDrawingMethods();
  
  console.log('[Canvas-Simple] Canvas 指纹注入完成');
}

function injectToDataURL() {
  console.log('[Canvas-Simple] 注入 toDataURL 方法');
  
  // 保存原始方法
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  
  // 重写方法
  HTMLCanvasElement.prototype.toDataURL = function(type?: string, quality?: any): string {
    console.log('[Canvas-Simple] toDataURL 被调用 - 开始注入噪声');
    
    // 获取原始结果
    const originalResult = originalToDataURL.call(this, type, quality);
    
    // 生成时间相关的噪声
    const timeNoise = Date.now() % 1000000;
    const randomNoise = Math.floor(Math.random() * 1000000);
    const combinedNoise = timeNoise ^ randomNoise;
    
    console.log('[Canvas-Simple] 生成的噪声值:', combinedNoise);
    
    // 修改结果
    const modifiedResult = addNoiseToDataURL(originalResult, combinedNoise);
    
    console.log('[Canvas-Simple] 原始长度:', originalResult.length);
    console.log('[Canvas-Simple] 修改后长度:', modifiedResult.length);
    console.log('[Canvas-Simple] 噪声注入完成');
    
    return modifiedResult;
  };
}

function addNoiseToDataURL(dataURL: string, noise: number): string {
  try {
    // 检查是否是有效的 data URL
    if (!dataURL.startsWith('data:')) {
      console.log('[Canvas-Simple] 不是有效的 data URL，添加简单标记');
      return dataURL + '?noise=' + noise;
    }

    // 分离头部和数据
    const commaIndex = dataURL.indexOf(',');
    if (commaIndex === -1) {
      console.log('[Canvas-Simple] 无法找到逗号分隔符，添加简单标记');
      return dataURL + '?noise=' + noise;
    }

    const header = dataURL.substring(0, commaIndex);
    const base64Data = dataURL.substring(commaIndex + 1);
    
    // 方法1: 在 base64 数据中添加噪声
    const noiseString = noise.toString(36); // 转换为36进制
    const paddedNoise = noiseString.padStart(8, '0');
    
    // 将噪声转换为 base64 兼容的字符
    const noiseBase64 = btoa(paddedNoise).replace(/[+=\/]/g, 'A'); // 替换特殊字符
    
    // 在中间插入噪声
    const insertPos = Math.floor(base64Data.length / 2);
    const modifiedBase64 = 
      base64Data.substring(0, insertPos) + 
      noiseBase64.substring(0, 8) + 
      base64Data.substring(insertPos);
    
    const result = header + ',' + modifiedBase64;
    
    console.log('[Canvas-Simple] Base64 噪声注入成功');
    return result;
    
  } catch (error) {
    console.error('[Canvas-Simple] Base64 修改失败:', error);
    
    // 最简单的备用方法
    const simpleResult = dataURL + '<!-- canvas-noise-' + noise + ' -->';
    console.log('[Canvas-Simple] 使用简单备用方法');
    return simpleResult;
  }
}

function injectDrawingMethods() {
  console.log('[Canvas-Simple] 注入绘图方法');
  
  // 重写 fillText 方法添加微小变化
  const originalFillText = CanvasRenderingContext2D.prototype.fillText;
  CanvasRenderingContext2D.prototype.fillText = function(text: string, x: number, y: number, maxWidth?: number) {
    // 添加不可见的字符来改变文本
    const invisibleChar = String.fromCharCode(8203); // 零宽度空格
    const modifiedText = text + invisibleChar + Math.random().toString(36).substring(2, 4);
    
    console.log('[Canvas-Simple] fillText 被调用，添加文本噪声');
    
    if (maxWidth !== undefined) {
      return originalFillText.call(this, modifiedText, x, y, maxWidth);
    } else {
      return originalFillText.call(this, modifiedText, x, y);
    }
  };
  
  // 重写 fillRect 方法添加微小变化
  const originalFillRect = CanvasRenderingContext2D.prototype.fillRect;
  CanvasRenderingContext2D.prototype.fillRect = function(x: number, y: number, width: number, height: number) {
    // 添加极小的随机偏移
    const offsetX = x + (Math.random() - 0.5) * 0.001;
    const offsetY = y + (Math.random() - 0.5) * 0.001;
    
    console.log('[Canvas-Simple] fillRect 被调用，添加位置噪声');
    
    return originalFillRect.call(this, offsetX, offsetY, width, height);
  };
}

// 额外的强制方法
export function forceCanvasRandomization() {
  console.log('[Canvas-Force] 启动强制随机化');
  
  // 在每次页面加载时创建一个隐藏的噪声 canvas
  const createNoiseCanvas = () => {
    const canvas = document.createElement('canvas');
    canvas.width = 1;
    canvas.height = 1;
    canvas.style.display = 'none';
    
    const ctx = canvas.getContext('2d');
    if (ctx) {
      // 绘制随机像素
      const randomColor = Math.floor(Math.random() * 16777215).toString(16);
      ctx.fillStyle = '#' + randomColor;
      ctx.fillRect(0, 0, 1, 1);
      
      // 获取 dataURL 来"预热"系统
      const dataURL = canvas.toDataURL();
      console.log('[Canvas-Force] 预热噪声 canvas:', dataURL.length);
    }
    
    document.body.appendChild(canvas);
    
    // 2秒后移除
    setTimeout(() => {
      if (canvas.parentNode) {
        canvas.parentNode.removeChild(canvas);
      }
    }, 2000);
  };
  
  // 页面加载后创建噪声 canvas
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', createNoiseCanvas);
  } else {
    createNoiseCanvas();
  }
}

// 简单的测试函数
export function testCanvasFingerprint(): boolean {
  console.log('[Canvas-Test] 开始测试 Canvas 指纹注入');
  
  try {
    const canvas = document.createElement('canvas');
    canvas.width = 100;
    canvas.height = 50;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      console.log('[Canvas-Test] 无法获取 2D context');
      return false;
    }
    
    // 绘制测试内容
    ctx.fillStyle = 'red';
    ctx.fillRect(10, 10, 30, 20);
    ctx.fillStyle = 'blue';
    ctx.font = '12px Arial';
    ctx.fillText('Test123', 15, 25);
    
    // 获取三次 dataURL
    const url1 = canvas.toDataURL();
    const url2 = canvas.toDataURL();
    
    // 等待后再获取一次
    setTimeout(() => {
      const url3 = canvas.toDataURL();
      
      console.log('[Canvas-Test] URL1 长度:', url1.length);
      console.log('[Canvas-Test] URL2 长度:', url2.length);
      console.log('[Canvas-Test] URL3 长度:', url3.length);
      console.log('[Canvas-Test] URL1 === URL2:', url1 === url2);
      console.log('[Canvas-Test] URL1 === URL3:', url1 === url3);
      
      // 检查是否包含噪声标记
      const hasNoise1 = url1.includes('noise') || url1.length !== url2.length;
      const hasNoise2 = url1 !== url3;
      
      console.log('[Canvas-Test] 检测到噪声 (长度差异):', hasNoise1);
      console.log('[Canvas-Test] 检测到噪声 (时间差异):', hasNoise2);
      
      return hasNoise1 || hasNoise2;
    }, 10);
    
    return url1 !== url2;
    
  } catch (error) {
    console.error('[Canvas-Test] 测试失败:', error);
    return false;
  }
}
SIMPLE_CANVAS_EOF

echo "✅ 简单 Canvas 注入代码已创建"

# 更新主要注入文件
echo ""
echo "📝 更新主要注入文件..."

cat > src/preload/fingerprint/index.ts << 'UPDATED_INDEX_EOF'
import { injectSimpleCanvasFingerprint, forceCanvasRandomization, testCanvasFingerprint } from './canvas-simple';
import { FingerprintConfig } from '../../shared/types';

export function injectAllFingerprints(config: FingerprintConfig) {
  try {
    console.log('[Fingerprint] 开始注入所有指纹伪装');
    console.log('[Fingerprint] 配置详情:', JSON.stringify(config, null, 2));

    // Canvas 指纹注入
    if (config.canvas.enabled) {
      console.log('[Fingerprint] === Canvas 指纹注入 ===');
      injectSimpleCanvasFingerprint(config.canvas);
      forceCanvasRandomization();
      
      // 延迟测试
      setTimeout(() => {
        console.log('[Fingerprint] === Canvas 注入效果测试 ===');
        const isWorking = testCanvasFingerprint();
        console.log('[Fingerprint] Canvas 注入效果:', isWorking ? '可能有效' : '需要检查');
      }, 500);
    }

    // Navigator 指纹注入
    if (config.navigator.enabled) {
      console.log('[Fingerprint] === Navigator 指纹注入 ===');
      injectNavigatorFingerprinting(config.navigator);
    }

    // WebGL 指纹注入
    if (config.webgl.enabled) {
      console.log('[Fingerprint] === WebGL 指纹注入 ===');
      injectWebGLFingerprinting(config.webgl);
    }

    // Screen 指纹注入
    if (config.screen.enabled) {
      console.log('[Fingerprint] === Screen 指纹注入 ===');
      injectScreenFingerprinting(config.screen);
    }

    console.log('[Fingerprint] 所有指纹注入完成');
  } catch (error) {
    console.error('[Fingerprint] 指纹注入过程中出错:', error);
  }
}

function injectNavigatorFingerprinting(config: any) {
  try {
    console.log('[Navigator] 注入 Navigator 指纹，平台:', config.platform);
    
    const descriptors = {
      platform: { value: config.platform, writable: false, enumerable: true, configurable: true },
      language: { value: config.language, writable: false, enumerable: true, configurable: true },
      languages: { value: Object.freeze([...config.languages]), writable: false, enumerable: true, configurable: true },
      hardwareConcurrency: { value: config.hardwareConcurrency, writable: false, enumerable: true, configurable: true },
      maxTouchPoints: { value: config.maxTouchPoints, writable: false, enumerable: true, configurable: true }
    };
    
    if (config.deviceMemory !== undefined) {
      (descriptors as any).deviceMemory = { 
        value: config.deviceMemory, 
        writable: false, 
        enumerable: true, 
        configurable: true 
      };
    }
    
    Object.defineProperties(navigator, descriptors);
    
    console.log('[Navigator] Navigator 指纹注入完成');
    console.log('[Navigator] 验证 - Platform:', navigator.platform);
    console.log('[Navigator] 验证 - Language:', navigator.language);
    console.log('[Navigator] 验证 - CPU 核心:', navigator.hardwareConcurrency);
  } catch (error) {
    console.error('[Navigator] Navigator 注入失败:', error);
  }
}

function injectWebGLFingerprinting(config: any) {
  try {
    console.log('[WebGL] 注入 WebGL 指纹，厂商:', config.vendor);
    
    const originalGetParameter = WebGLRenderingContext.prototype.getParameter;
    WebGLRenderingContext.prototype.getParameter = function(parameter: GLenum): any {
      switch (parameter) {
        case this.VENDOR:
          console.log('[WebGL] 返回伪装的 VENDOR:', config.vendor);
          return config.vendor;
        case this.RENDERER:
          console.log('[WebGL] 返回伪装的 RENDERER:', config.renderer);
          return config.renderer;
        case this.VERSION:
          return 'WebGL 1.0 (OpenGL ES 2.0 Chromium)';
        case this.SHADING_LANGUAGE_VERSION:
          return 'WebGL GLSL ES 1.0';
        default:
          return originalGetParameter.call(this, parameter);
      }
    };

    // WebGL2 支持
    if (window.WebGL2RenderingContext) {
      const originalGetParameter2 = WebGL2RenderingContext.prototype.getParameter;
      WebGL2RenderingContext.prototype.getParameter = function(parameter: GLenum): any {
        switch (parameter) {
          case this.VENDOR:
            return config.vendor;
          case this.RENDERER:
            return config.renderer;
          case this.VERSION:
            return 'WebGL 2.0 (OpenGL ES 3.0 Chromium)';
          case this.SHADING_LANGUAGE_VERSION:
            return 'WebGL GLSL ES 3.00';
          default:
            return originalGetParameter2.call(this, parameter);
        }
      };
    }
    
    console.log('[WebGL] WebGL 指纹注入完成');
  } catch (error) {
    console.error('[WebGL] WebGL 注入失败:', error);
  }
}

function injectScreenFingerprinting(config: any) {
  try {
    console.log('[Screen] 注入 Screen 指纹，分辨率:', config.width + 'x' + config.height);
    
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
    
    console.log('[Screen] Screen 指纹注入完成');
    console.log('[Screen] 验证 - 宽度:', screen.width);
    console.log('[Screen] 验证 - 高度:', screen.height);
    console.log('[Screen] 验证 - 像素比:', window.devicePixelRatio);
  } catch (error) {
    console.error('[Screen] Screen 注入失败:', error);
  }
}

let injected = false;
export function ensureInjected(config: FingerprintConfig) {
  if (!injected) {
    console.log('[Fingerprint] === 开始首次指纹注入 ===');
    injectAllFingerprints(config);
    injected = true;
  } else {
    console.log('[Fingerprint] 指纹已注入，跳过重复操作');
  }
}
UPDATED_INDEX_EOF

echo "✅ 主要注入文件已更新"

# 创建简单测试脚本
echo ""
echo "📝 创建简单测试脚本..."

cat > test-simple-canvas.sh << 'SIMPLE_TEST_EOF'
#!/bin/bash

echo "🎯 简单 Canvas 指纹测试"
echo "===================="

echo "🏗️  编译简单版本..."
if npm run build:main; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🚀 启动简单测试..."
echo ""
echo "📋 请观察控制台输出："
echo "  - [Canvas-Simple] 开头的日志"
echo "  - toDataURL 被调用时的噪声值"
echo "  - Canvas 注入效果测试结果"
echo ""
echo "🎯 关键验证点："
echo "  1. 每次 toDataURL 调用都应该显示不同的噪声值"
echo "  2. Canvas 注入效果测试应该返回 '可能有效'"
echo "  3. BrowserLeaks 的 Canvas Signature 应该每次重启都不同"
echo ""

NODE_ENV=production electron dist/main/index.js
SIMPLE_TEST_EOF

chmod +x test-simple-canvas.sh

echo ""
echo "🎉 简单有效的修复完成！"
echo ""
echo "✅ 新的修复特点："
echo "  - 避免了所有 TypeScript 类型问题"
echo "  - 使用最直接的方法修改 toDataURL"
echo "  - 添加了实时测试和验证"
echo "  - 包含详细的调试日志"
echo ""
echo "🧪 测试步骤："
echo ""
echo "1️⃣  先运行简单测试："
echo "   ./test-simple-canvas.sh"
echo "   🔍 观察控制台日志，确认注入正常工作"
echo ""
echo "2️⃣  然后访问真实网站："
echo "   关闭程序后运行 ./test-real-fingerprint-sites.sh"
echo "   🎯 检查 Canvas Signature 是否发生变化"
echo ""
echo "💡 这次使用了最简单但最直接的方法，应该能够成功！"