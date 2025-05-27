import { CanvasFingerprintConfig } from '../../shared/types';

export function injectCanvasFingerprinting(config: CanvasFingerprintConfig) {
  if (!config.enabled) {
    console.log('[Canvas] Canvas 指纹注入已禁用');
    return;
  }

  console.log('[Canvas] 🎨 开始 Canvas 指纹注入');
  console.log('[Canvas] 噪声级别:', config.noise);
  console.log('[Canvas] 种子值:', config.seed);

  // 核心方法：重写 toDataURL
  const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
  HTMLCanvasElement.prototype.toDataURL = function(type?: string, quality?: any): string {
    // 获取原始结果
    const originalResult = originalToDataURL.call(this, type, quality);
    
    // 生成基于时间的噪声（确保每次都不同）
    const timestamp = performance.now(); // 高精度时间戳
    const random = Math.random() * 1000000;
    const noise = Math.floor(timestamp + random) % 1000000;
    
    console.log('[Canvas] 🔄 toDataURL 被调用');
    console.log('[Canvas] 生成噪声:', noise);
    
    // 修改结果
    const modifiedResult = addNoiseToCanvasData(originalResult, noise);
    
    console.log('[Canvas] 原始数据长度:', originalResult.length);
    console.log('[Canvas] 修改后长度:', modifiedResult.length);
    console.log('[Canvas] ✅ Canvas 噪声注入完成');
    
    return modifiedResult;
  };

  // 额外的绘图方法注入
  injectDrawingNoise();
  
  console.log('[Canvas] 🎨 Canvas 指纹注入设置完成');
}

function addNoiseToCanvasData(dataURL: string, noise: number): string {
  try {
    // 检查数据格式
    if (!dataURL.includes('data:') || !dataURL.includes(',')) {
      console.log('[Canvas] 数据格式异常，使用简单方法');
      return dataURL + '?t=' + noise;
    }

    // 分离头部和 base64 数据
    const parts = dataURL.split(',');
    const header = parts[0];
    const base64Data = parts[1];

    // 创建噪声字符串
    const noiseStr = noise.toString(36); // 36进制
    const paddedNoiseStr = noiseStr.padStart(6, '0');
    
    // 将噪声转换为 base64 兼容格式
    const noiseBytes = paddedNoiseStr.split('').map(c => c.charCodeAt(0));
    const noiseBinary = String.fromCharCode(...noiseBytes);
    const noiseBase64 = btoa(noiseBinary).replace(/[+/=]/g, match => {
      switch (match) {
        case '+': return 'A';
        case '/': return 'B'; 
        case '=': return 'C';
        default: return match;
      }
    });

    // 在 base64 数据中间插入噪声
    const insertPosition = Math.floor(base64Data.length / 2);
    const noiseLength = Math.min(8, noiseBase64.length);
    
    const modifiedBase64 = 
      base64Data.substring(0, insertPosition) + 
      noiseBase64.substring(0, noiseLength) + 
      base64Data.substring(insertPosition);

    const result = header + ',' + modifiedBase64;
    
    console.log('[Canvas] Base64 噪声注入成功');
    return result;

  } catch (error) {
    console.error('[Canvas] Base64 处理失败:', error);
    
    // 最简单的备用方法
    const timestamp = Date.now();
    const fallbackResult = dataURL + '<!-- noise:' + noise + ':' + timestamp + ' -->';
    console.log('[Canvas] 使用备用方法添加噪声');
    return fallbackResult;
  }
}

function injectDrawingNoise() {
  console.log('[Canvas] 🖌️  注入绘图方法噪声');

  // 重写 fillText 方法
  const originalFillText = CanvasRenderingContext2D.prototype.fillText;
  CanvasRenderingContext2D.prototype.fillText = function(text: string, x: number, y: number, maxWidth?: number) {
    // 在文本中添加不可见的噪声字符
    const invisibleChars = [
      String.fromCharCode(8203), // 零宽度空格
      String.fromCharCode(8204), // 零宽度非断行空格
      String.fromCharCode(8205)  // 零宽度连接符
    ];
    
    const randomChar = invisibleChars[Math.floor(Math.random() * invisibleChars.length)];
    const noiseText = text + randomChar;
    
    console.log('[Canvas] 📝 fillText 添加文本噪声');
    
    if (maxWidth !== undefined) {
      return originalFillText.call(this, noiseText, x, y, maxWidth);
    } else {
      return originalFillText.call(this, noiseText, x, y);
    }
  };

  // 重写 fillRect 方法
  const originalFillRect = CanvasRenderingContext2D.prototype.fillRect;
  CanvasRenderingContext2D.prototype.fillRect = function(x: number, y: number, width: number, height: number) {
    // 添加微小的随机偏移（不影响视觉效果）
    const microOffset = () => (Math.random() - 0.5) * 0.001;
    
    const noisyX = x + microOffset();
    const noisyY = y + microOffset();
    const noisyWidth = width + microOffset();
    const noisyHeight = height + microOffset();
    
    console.log('[Canvas] 🔲 fillRect 添加位置噪声');
    
    return originalFillRect.call(this, noisyX, noisyY, noisyWidth, noisyHeight);
  };
}

// 测试 Canvas 注入是否工作
export function testCanvasInjection(): void {
  console.log('[Canvas-Test] 🧪 开始测试 Canvas 注入效果');
  
  try {
    // 创建测试 canvas
    const testCanvas = document.createElement('canvas');
    testCanvas.width = 200;
    testCanvas.height = 100;
    
    const ctx = testCanvas.getContext('2d');
    if (!ctx) {
      console.log('[Canvas-Test] ❌ 无法创建 2D context');
      return;
    }

    // 绘制测试内容
    ctx.fillStyle = '#FF0000';
    ctx.fillRect(10, 10, 50, 30);
    ctx.fillStyle = '#0000FF';
    ctx.font = '16px Arial';
    ctx.fillText('Canvas Test', 20, 60);

    // 多次获取 dataURL 进行对比
    const results: string[] = [];
    for (let i = 0; i < 3; i++) {
      const dataURL = testCanvas.toDataURL();
      results.push(dataURL);
      console.log(`[Canvas-Test] 第 ${i + 1} 次 dataURL 长度:`, dataURL.length);
    }

    // 检查结果差异
    const allSame = results.every(url => url === results[0]);
    const hasDifferences = !allSame;

    console.log('[Canvas-Test] 三次结果是否相同:', allSame);
    console.log('[Canvas-Test] 检测到差异:', hasDifferences);
    
    if (hasDifferences) {
      console.log('[Canvas-Test] ✅ Canvas 注入可能正在工作');
    } else {
      console.log('[Canvas-Test] ⚠️  Canvas 注入可能未生效');
    }

    // 额外测试：时间间隔测试
    setTimeout(() => {
      const delayedURL = testCanvas.toDataURL();
      const isDifferent = delayedURL !== results[0];
      console.log('[Canvas-Test] 延迟测试结果不同:', isDifferent);
      
      if (isDifferent) {
        console.log('[Canvas-Test] ✅ 时间间隔测试通过，噪声注入有效');
      } else {
        console.log('[Canvas-Test] ⚠️  时间间隔测试未通过');
      }
    }, 50);

  } catch (error) {
    console.error('[Canvas-Test] ❌ 测试过程出错:', error);
  }
}

// 导出兼容性方法
export function injectCanvasNoiseDirect() {
  console.log('[Canvas] 🔧 直接噪声注入（兼容性方法）');
}

export function injectUltimateCanvasNoise() {
  console.log('[Canvas] 🚀 终极噪声注入（兼容性方法）');
}
