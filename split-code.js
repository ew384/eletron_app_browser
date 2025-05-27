#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * 代码文件自动拆分脚本
 * 用于将合并的代码文件按照 // ===== 文件路径 ===== 标记拆分成独立文件
 */

class CodeSplitter {
    constructor(inputFile, outputDir = './src') {
        this.inputFile = inputFile;
        this.outputDir = outputDir;
        this.fileMarkerRegex = /^\/\/ ===== (.+?) (?:完整更新 )?=====$/;
    }

    /**
     * 主要拆分逻辑
     */
    async splitCode() {
        try {
            console.log('🚀 开始拆分代码文件...');

            // 读取输入文件
            const content = await this.readFile(this.inputFile);

            // 解析文件块
            const fileBlocks = this.parseFileBlocks(content);

            // 创建文件并写入内容
            await this.createFiles(fileBlocks);

            console.log('✅ 代码拆分完成！');
            console.log(`📁 总共处理了 ${fileBlocks.length} 个文件`);

        } catch (error) {
            console.error('❌ 拆分过程中出现错误:', error.message);
            process.exit(1);
        }
    }

    /**
     * 读取文件内容
     */
    async readFile(filePath) {
        try {
            return fs.readFileSync(filePath, 'utf8');
        } catch (error) {
            throw new Error(`无法读取文件 ${filePath}: ${error.message}`);
        }
    }

    /**
     * 解析文件块
     */
    parseFileBlocks(content) {
        const lines = content.split('\n');
        const fileBlocks = [];
        let currentFile = null;
        let currentContent = [];

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const match = line.match(this.fileMarkerRegex);

            if (match) {
                // 保存上一个文件的内容
                if (currentFile) {
                    fileBlocks.push({
                        path: currentFile,
                        content: this.cleanContent(currentContent.join('\n'))
                    });
                }

                // 开始新文件
                currentFile = match[1].trim();
                currentContent = [];
                console.log(`📄 发现文件: ${currentFile}`);
            } else if (currentFile) {
                // 收集当前文件的内容
                currentContent.push(line);
            }
        }

        // 保存最后一个文件
        if (currentFile && currentContent.length > 0) {
            fileBlocks.push({
                path: currentFile,
                content: this.cleanContent(currentContent.join('\n'))
            });
        }

        return fileBlocks;
    }

    /**
     * 清理文件内容
     */
    cleanContent(content) {
        // 移除开头和结尾的空行
        return content.trim();
    }

    /**
     * 创建文件并写入内容
     */
    async createFiles(fileBlocks) {
        for (const block of fileBlocks) {
            try {
                await this.createSingleFile(block.path, block.content);
            } catch (error) {
                console.error(`❌ 创建文件 ${block.path} 失败:`, error.message);
            }
        }
    }

    /**
     * 创建单个文件
     */
    async createSingleFile(filePath, content) {
        // 标准化文件路径
        const normalizedPath = this.normalizePath(filePath);
        const fullPath = path.join(this.outputDir, normalizedPath);

        // 确保目录存在
        const dir = path.dirname(fullPath);
        await this.ensureDir(dir);

        // 写入文件
        fs.writeFileSync(fullPath, content, 'utf8');
        console.log(`✅ 已创建: ${fullPath}`);
    }

    /**
     * 标准化文件路径
     */
    normalizePath(filePath) {
        // 移除开头的路径分隔符
        let normalized = filePath.replace(/^[\/\\]+/, '');

        // 处理特殊路径格式
        const pathMappings = {
            'shared/types.ts 扩展': 'shared/types.ts',
            'shared/types.ts 完整更新': 'shared/types.ts',
            'preload/index.ts 更新': 'preload/index.ts',
            'preload/index.ts 完整更新': 'preload/index.ts',
            'main/window-manager.ts 更新': 'main/window-manager.ts',
            'main/ipc-handlers.ts 更新': 'main/ipc-handlers.ts',
            'main/ipc-handlers.ts 完整更新': 'main/ipc-handlers.ts',
            'renderer/components/FingerprintConfig.tsx': 'renderer/components/FingerprintConfig.tsx'
        };

        // 应用路径映射
        if (pathMappings[normalized]) {
            normalized = pathMappings[normalized];
        }

        // 确保使用正确的路径分隔符
        return normalized.replace(/\\/g, '/');
    }

    /**
     * 确保目录存在
     */
    async ensureDir(dirPath) {
        try {
            await fs.promises.mkdir(dirPath, { recursive: true });
        } catch (error) {
            if (error.code !== 'EEXIST') {
                throw error;
            }
        }
    }
}

/**
 * 命令行接口
 */
class CLI {
    static async run() {
        const args = process.argv.slice(2);

        if (args.length === 0) {
            this.showHelp();
            return;
        }

        const inputFile = args[0];
        const outputDir = args[1] || './src';

        // 检查输入文件是否存在
        if (!fs.existsSync(inputFile)) {
            console.error(`❌ 输入文件不存在: ${inputFile}`);
            process.exit(1);
        }

        // 创建拆分器并执行
        const splitter = new CodeSplitter(inputFile, outputDir);
        await splitter.splitCode();
    }

    static showHelp() {
        console.log(`
📦 代码文件自动拆分工具

用法:
  node split-code.js <输入文件> [输出目录]

参数:
  输入文件    包含合并代码的文件路径
  输出目录    拆分后文件的输出目录 (默认: ./src)

示例:
  node split-code.js merged-code.txt
  node split-code.js merged-code.txt ./my-project/src

说明:
  - 脚本会自动识别 // ===== 文件路径 ===== 标记
  - 自动创建必要的目录结构
  - 支持 TypeScript 和 JavaScript 文件
  - 会清理多余的空行和格式
`);
    }
}

/**
 * 增强版代码拆分器 - 支持更多功能
 */
class AdvancedCodeSplitter extends CodeSplitter {
    constructor(inputFile, outputDir = './src', options = {}) {
        super(inputFile, outputDir);
        this.options = {
            backup: options.backup || false,
            dryRun: options.dryRun || false,
            verbose: options.verbose || false,
            ...options
        };
    }

    /**
     * 创建备份
     */
    async createBackup() {
        if (!this.options.backup) return;

        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const backupDir = `${this.outputDir}_backup_${timestamp}`;

        try {
            await this.copyDirectory(this.outputDir, backupDir);
            console.log(`📋 已创建备份: ${backupDir}`);
        } catch (error) {
            console.warn(`⚠️ 备份创建失败: ${error.message}`);
        }
    }

    /**
     * 复制目录
     */
    async copyDirectory(src, dest) {
        if (!fs.existsSync(src)) return;

        await fs.promises.mkdir(dest, { recursive: true });
        const entries = await fs.promises.readdir(src, { withFileTypes: true });

        for (const entry of entries) {
            const srcPath = path.join(src, entry.name);
            const destPath = path.join(dest, entry.name);

            if (entry.isDirectory()) {
                await this.copyDirectory(srcPath, destPath);
            } else {
                await fs.promises.copyFile(srcPath, destPath);
            }
        }
    }

    /**
     * 干运行模式
     */
    async dryRun(fileBlocks) {
        console.log('🔍 干运行模式 - 不会实际创建文件');
        console.log('将要创建的文件:');

        for (const block of fileBlocks) {
            const normalizedPath = this.normalizePath(block.path);
            const fullPath = path.join(this.outputDir, normalizedPath);
            console.log(`  📄 ${fullPath} (${block.content.length} 字符)`);
        }
    }

    /**
     * 增强的拆分逻辑
     */
    async splitCode() {
        try {
            console.log('🚀 开始增强版代码拆分...');

            // 创建备份
            await this.createBackup();

            // 读取和解析
            const content = await this.readFile(this.inputFile);
            const fileBlocks = this.parseFileBlocks(content);

            // 干运行检查
            if (this.options.dryRun) {
                await this.dryRun(fileBlocks);
                return;
            }

            // 创建文件
            await this.createFiles(fileBlocks);

            // 生成报告
            await this.generateReport(fileBlocks);

            console.log('✅ 增强版代码拆分完成！');

        } catch (error) {
            console.error('❌ 拆分过程中出现错误:', error.message);
            process.exit(1);
        }
    }

    /**
     * 生成报告
     */
    async generateReport(fileBlocks) {
        const report = {
            timestamp: new Date().toISOString(),
            totalFiles: fileBlocks.length,
            files: fileBlocks.map(block => ({
                path: this.normalizePath(block.path),
                size: block.content.length,
                lines: block.content.split('\n').length
            }))
        };

        const reportPath = path.join(this.outputDir, 'split-report.json');
        fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
        console.log(`📊 报告已生成: ${reportPath}`);
    }
}

// 主程序入口
if (require.main === module) {
    CLI.run().catch(console.error);
}

module.exports = {
    CodeSplitter,
    AdvancedCodeSplitter,
    CLI
};