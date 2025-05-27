import { CanvasFingerprintConfig } from '../../shared/types';

export function injectCanvasFingerprinting(config: CanvasFingerprintConfig) {
  if (!config.enabled) {
    console.log('[Canvas] Canvas 指纹注入已禁用');
    return;
  }

  console.log('[Canvas] 🎨 开始 Canvas 指纹注入');
  console.log('[Canvas] 噪声级别:', config.noise);
  console.log('[Canvas] 种子值:', config.seed);

  // 保存原始方法
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;

  // 重写 toDataURL 方法
  HTMLCanvasElement.prototype.toDataURL = function (type?: string, quality?: any): string {
    const context = this.getContext('2d');
    if (context) {
      applyRealPixelNoise(context, this.width, this.height, config.noise);
    }

    const result = originalToDataURL.call(this, type, quality);
    console.log('[Canvas] 🔄 toDataURL 被调用，已注入像素级噪声');
    return result;
  };

  // 注入绘图函数的微扰噪声
  injectDrawingNoise();

  console.log('[Canvas] ✅ Canvas 指纹注入设置完成');
}

// 真正修改像素数据的函数
function applyRealPixelNoise(ctx: CanvasRenderingContext2D, width: number, height: number, intensity: number) {
  try {
    const imageData = ctx.getImageData(0, 0, width, height);
    const data = imageData.data;
    const noiseLevel = intensity || 1; // 噪声强度

    for (let i = 0; i < data.length; i += 4) {
      // 在每个像素的 R 分量注入微小扰动
      const noise = (Math.random() - 0.5) * noiseLevel;
      data[i] = Math.min(255, Math.max(0, data[i] + noise));
    }

    ctx.putImageData(imageData, 0, 0);
    console.log('[Canvas] 🧬 像素级噪声注入完成');
  } catch (error) {
    console.warn('[Canvas] 像素注入失败:', error);
  }
}

// 可选额外：修改 fillText、fillRect 等函数，加入扰动
function injectDrawingNoise() {
  console.log('[Canvas] 🖌️ 注入绘图函数噪声');

  const originalFillText = CanvasRenderingContext2D.prototype.fillText;
  CanvasRenderingContext2D.prototype.fillText = function (text: string, x: number, y: number, maxWidth?: number) {
    const dx = (Math.random() - 0.5) * 0.1;
    const dy = (Math.random() - 0.5) * 0.1;
    const noisyX = x + dx;
    const noisyY = y + dy;

    if (maxWidth !== undefined) {
      return originalFillText.call(this, text, noisyX, noisyY, maxWidth);
    } else {
      return originalFillText.call(this, text, noisyX, noisyY);
    }
  };

  const originalFillRect = CanvasRenderingContext2D.prototype.fillRect;
  CanvasRenderingContext2D.prototype.fillRect = function (x: number, y: number, width: number, height: number) {
    const microOffset = () => (Math.random() - 0.5) * 0.1;
    const noisyX = x + microOffset();
    const noisyY = y + microOffset();
    const noisyWidth = width + microOffset();
    const noisyHeight = height + microOffset();

    return originalFillRect.call(this, noisyX, noisyY, noisyWidth, noisyHeight);
  };
}

// 测试函数
export function testCanvasInjection(): void {
  console.log('[Canvas-Test] 🧪 开始测试 Canvas 注入效果');

  try {
    const testCanvas = document.createElement('canvas');
    testCanvas.width = 200;
    testCanvas.height = 100;

    const ctx = testCanvas.getContext('2d');
    if (!ctx) return;

    ctx.fillStyle = '#FF0000';
    ctx.fillRect(10, 10, 50, 30);
    ctx.fillStyle = '#0000FF';
    ctx.font = '16px Arial';
    ctx.fillText('Canvas Test', 20, 60);

    const results: string[] = [];
    for (let i = 0; i < 3; i++) {
      const dataURL = testCanvas.toDataURL();
      results.push(dataURL);
      console.log(`[Canvas-Test] 第 ${i + 1} 次 dataURL 长度:`, dataURL.length);
    }

    const allSame = results.every(url => url === results[0]);
    console.log('[Canvas-Test] 三次结果是否相同:', allSame);

    if (!allSame) {
      console.log('[Canvas-Test] ✅ Canvas 注入成功，指纹已变异');
    } else {
      console.log('[Canvas-Test] ⚠️ Canvas 注入失败，结果一致');
    }
  } catch (error) {
    console.error('[Canvas-Test] ❌ 测试出错:', error);
  }
}
