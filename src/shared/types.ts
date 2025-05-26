/**
 * 核心类型定义 - 简洁设计，预留扩展接口
 */

export interface BrowserAccount {
  id: string;
  name: string;
  status: 'idle' | 'running' | 'error';
  createdAt: number;
  updatedAt?: number;
}

export interface BrowserInstance {
  accountId: string;
  windowId: number;
  status: 'starting' | 'running' | 'stopped';
  url?: string;
}

// 预留扩展接口 - 配置驱动架构
export interface AccountConfig {
  proxy?: ProxyConfig;
  userAgent?: string;
  viewport?: ViewportConfig;
  // 预留指纹配置接口
  fingerprint?: FingerprintConfig;
  // 预留行为配置接口
  behavior?: BehaviorConfig;
}

export interface ProxyConfig {
  type: 'http' | 'https' | 'socks5';
  host: string;
  port: number;
  username?: string;
  password?: string;
}

export interface ViewportConfig {
  width: number;
  height: number;
  deviceScaleFactor?: number;
}

// 预留接口 - 策略模式扩展点
export interface FingerprintConfig {
  canvas?: any;
  webgl?: any;
  audio?: any;
  fonts?: any;
}

export interface BehaviorConfig {
  mouseMovement?: any;
  typingPattern?: any;
  scrollPattern?: any;
}

// IPC 通信类型
export interface IpcResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
}

// 窗口管理器状态
export interface WindowManagerState {
  mainWindow?: Electron.BrowserWindow;
  browserInstances: Map<string, Electron.BrowserWindow>;
}