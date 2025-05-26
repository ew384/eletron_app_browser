/**
 * 主进程入口 - 应用生命周期管理
 */
import { app, BrowserWindow } from 'electron';
import path from 'path';
import { WindowManager } from './window-manager';
import { setupIpcHandlers } from './ipc-handlers';

class App {
  private windowManager: WindowManager;
  private isDev: boolean;

  constructor() {
    this.isDev = process.env.NODE_ENV === 'development';
    this.windowManager = new WindowManager(this.isDev);
    this.init();
  }

  private async init(): Promise<void> {
    // 等待应用就绪
    await app.whenReady();
    
    // 设置IPC处理器
    setupIpcHandlers(this.windowManager);
    
    // 创建主窗口
    await this.windowManager.createMainWindow();
    
    // 开发环境优化
    if (this.isDev) {
      this.setupDevtools();
    }
    
    this.setupAppEventHandlers();
  }

  private setupDevtools(): void {
    // 安装开发者工具扩展
    app.whenReady().then(() => {
      // 可以在这里安装React DevTools等扩展
    });
  }

  private setupAppEventHandlers(): void {
    // 窗口全部关闭时退出应用 (macOS除外)
    app.on('window-all-closed', () => {
      if (process.platform !== 'darwin') {
        app.quit();
      }
    });

    // macOS重新激活时创建窗口
    app.on('activate', async () => {
      if (BrowserWindow.getAllWindows().length === 0) {
        await this.windowManager.createMainWindow();
      }
    });

    // 应用即将退出时清理资源
    app.on('before-quit', () => {
      this.windowManager.cleanup();
    });

    // 安全策略：阻止新窗口创建
    app.on('web-contents-created', (_, contents) => {
      contents.on('new-window', (event) => {
        event.preventDefault();
      });
    });
  }
}

// 启动应用
new App();