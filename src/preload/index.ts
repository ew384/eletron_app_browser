/**
 * 预加载脚本 - 安全的IPC桥接
 */
import { contextBridge, ipcRenderer } from 'electron';
import { IPC_CHANNELS } from '@shared/constants';
import type { BrowserAccount, AccountConfig, IpcResponse } from '@shared/types';

// 定义安全的API接口
const electronAPI = {
  // 账号管理
  createBrowserInstance: (accountId: string, config?: AccountConfig): Promise<IpcResponse> =>
    ipcRenderer.invoke(IPC_CHANNELS.CREATE_BROWSER_INSTANCE, accountId, config),
  
  destroyBrowserInstance: (accountId: string): Promise<IpcResponse> =>
    ipcRenderer.invoke(IPC_CHANNELS.DESTROY_BROWSER_INSTANCE, accountId),
  
  getInstanceStatus: (accountId: string): Promise<IpcResponse<string>> =>
    ipcRenderer.invoke(IPC_CHANNELS.GET_INSTANCE_STATUS, accountId),
  
  // 预留扩展方法
  injectFingerprint: (accountId: string, fingerprint: any): Promise<IpcResponse> =>
    ipcRenderer.invoke(IPC_CHANNELS.INJECT_FINGERPRINT, accountId, fingerprint),
  
  updateProxy: (accountId: string, proxy: any): Promise<IpcResponse> =>
    ipcRenderer.invoke(IPC_CHANNELS.UPDATE_PROXY, accountId, proxy),
  
  executeBehavior: (accountId: string, behavior: any): Promise<IpcResponse> =>
    ipcRenderer.invoke(IPC_CHANNELS.EXECUTE_BEHAVIOR, accountId, behavior),
  
  // 应用信息
  getAppVersion: (): Promise<string> =>
    ipcRenderer.invoke('get-app-version'),
  
  // 窗口控制
  minimizeWindow: (): void =>
    ipcRenderer.send('minimize-window'),
  
  maximizeWindow: (): void =>
    ipcRenderer.send('maximize-window'),
  
  closeWindow: (): void =>
    ipcRenderer.send('close-window')
};

// 类型安全的API暴露
declare global {
  interface Window {
    electronAPI: typeof electronAPI;
  }
}

// 安全暴露API到渲染进程
contextBridge.exposeInMainWorld('electronAPI', electronAPI);