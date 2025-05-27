import { injectCanvasFingerprinting, testCanvasInjection } from './canvas';
import { FingerprintConfig } from '../../shared/types';

export function injectAllFingerprints(config: FingerprintConfig) {
  console.log('[Fingerprint] 🚀 开始指纹注入流程');
  console.log('[Fingerprint] 配置摘要:', {
    canvas: config.canvas.enabled,
    webgl: config.webgl.enabled,
    navigator: config.navigator.enabled,
    screen: config.screen.enabled
  });

  try {
    // Canvas 指纹注入
    if (config.canvas.enabled) {
      console.log('[Fingerprint] === Canvas 指纹注入 ===');
      injectCanvasFingerprinting(config.canvas);
      
      // 延迟测试效果
      setTimeout(() => {
        testCanvasInjection();
      }, 200);
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

    console.log('[Fingerprint] ✅ 所有指纹注入完成');

  } catch (error) {
    console.error('[Fingerprint] ❌ 注入过程中出错:', error);
  }
}

function injectNavigatorFingerprinting(config: any) {
  console.log('[Navigator] 🧭 开始 Navigator 注入');
  console.log('[Navigator] 目标平台:', config.platform);

  try {
    Object.defineProperties(navigator, {
      platform: { 
        value: config.platform, 
        writable: false, 
        enumerable: true, 
        configurable: true 
      },
      language: { 
        value: config.language, 
        writable: false, 
        enumerable: true, 
        configurable: true 
      },
      languages: { 
        value: Object.freeze([...config.languages]), 
        writable: false, 
        enumerable: true, 
        configurable: true 
      },
      hardwareConcurrency: { 
        value: config.hardwareConcurrency, 
        writable: false, 
        enumerable: true, 
        configurable: true 
      },
      maxTouchPoints: { 
        value: config.maxTouchPoints, 
        writable: false, 
        enumerable: true, 
        configurable: true 
      }
    });

    if (config.deviceMemory !== undefined) {
      Object.defineProperty(navigator, 'deviceMemory', {
        value: config.deviceMemory,
        writable: false,
        enumerable: true,
        configurable: true
      });
    }

    console.log('[Navigator] ✅ Navigator 注入完成');
    console.log('[Navigator] 验证 - 平台:', navigator.platform);
    console.log('[Navigator] 验证 - 语言:', navigator.language);
    console.log('[Navigator] 验证 - CPU:', navigator.hardwareConcurrency);

  } catch (error) {
    console.error('[Navigator] ❌ Navigator 注入失败:', error);
  }
}

function injectWebGLFingerprinting(config: any) {
  console.log('[WebGL] 🎮 开始 WebGL 注入');
  console.log('[WebGL] 目标厂商:', config.vendor);

  try {
    const originalGetParameter = WebGLRenderingContext.prototype.getParameter;
    WebGLRenderingContext.prototype.getParameter = function(parameter: GLenum): any {
      switch (parameter) {
        case this.VENDOR:
          console.log('[WebGL] 🏭 返回伪装厂商:', config.vendor);
          return config.vendor;
        case this.RENDERER:
          console.log('[WebGL] 🖥️  返回伪装渲染器:', config.renderer);
          return config.renderer;
        case this.VERSION:
          return 'WebGL 1.0 (OpenGL ES 2.0 Chromium)';
        case this.SHADING_LANGUAGE_VERSION:
          return 'WebGL GLSL ES 1.0 (OpenGL ES GLSL ES 1.0 Chromium)';
        default:
          return originalGetParameter.call(this, parameter);
      }
    };

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
            return 'WebGL GLSL ES 3.00 (OpenGL ES GLSL ES 3.0 Chromium)';
          default:
            return originalGetParameter2.call(this, parameter);
        }
      };
    }

    console.log('[WebGL] ✅ WebGL 注入完成');

  } catch (error) {
    console.error('[WebGL] ❌ WebGL 注入失败:', error);
  }
}

function injectScreenFingerprinting(config: any) {
  console.log('[Screen] 📺 开始 Screen 注入');
  console.log('[Screen] 目标分辨率:', `${config.width}x${config.height}`);

  try {
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

    console.log('[Screen] ✅ Screen 注入完成');
    console.log('[Screen] 验证 - 宽度:', screen.width);
    console.log('[Screen] 验证 - 高度:', screen.height);
    console.log('[Screen] 验证 - 像素比:', window.devicePixelRatio);

  } catch (error) {
    console.error('[Screen] ❌ Screen 注入失败:', error);
  }
}

let injected = false;
export function ensureInjected(config: FingerprintConfig) {
  if (!injected) {
    console.log('[Fingerprint] 🔄 执行首次指纹注入');
    injectAllFingerprints(config);
    injected = true;
  } else {
    console.log('[Fingerprint] ⏭️  指纹已注入，跳过');
  }
}
