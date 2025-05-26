#!/usr/bin/env node

/**
 * 文件分割脚本 - 自动解析包含多个文件的文本并创建对应的文件结构
 * 
 * 使用方法:
 * 1. 将Claude生成的完整代码保存为 project-files.txt
 * 2. 运行: node split-files.js project-files.txt
 * 3. 脚本会自动创建所有文件和目录结构
 */

const fs = require('fs');
const path = require('path');
const process = require('process');

class FileSplitter {
  constructor() {
    this.separator = '---FILE_SEPARATOR---';
    this.createdFiles = [];
    this.createdDirs = [];
  }

  /**
   * 主要处理函数
   */
  async processFile(inputFile) {
    try {
      console.log(`📁 开始处理文件: ${inputFile}`);
      
      // 读取输入文件
      const content = fs.readFileSync(inputFile, 'utf8');
      
      // 分割文件内容
      const sections = this.splitContent(content);
      
      // 处理每个文件段
      for (const section of sections) {
        await this.processSection(section);
      }
      
      // 显示结果
      this.showResults();
      
    } catch (error) {
      console.error('❌ 处理失败:', error.message);
      process.exit(1);
    }
  }

  /**
   * 分割文件内容
   */
  splitContent(content) {
    const sections = content.split(this.separator);
    const result = [];

    for (let i = 0; i < sections.length; i++) {
      const section = sections[i].trim();
      if (!section) continue;

      // 查找文件名注释
      const lines = section.split('\n');
      let fileName = null;
      let fileContent = '';
      let contentStartIndex = 0;

      // 查找文件名 (支持多种格式)
      for (let j = 0; j < Math.min(5, lines.length); j++) {
        const line = lines[j].trim();
        
        // 匹配各种文件名格式
        const patterns = [
          /^\/\/\s*(.+)$/,           // // filename
          /^#\s*(.+)$/,             // # filename  
          /^\/\*\s*(.+?)\s*\*\/$/,  // /* filename */
          /^<!--\s*(.+?)\s*-->$/,   // <!-- filename -->
          /^"([^"]+)":\s*{/,        // JSON开始 (package.json)
        ];

        for (const pattern of patterns) {
          const match = line.match(pattern);
          if (match) {
            fileName = match[1].trim();
            contentStartIndex = j + 1;
            break;
          }
        }

        if (fileName) break;
      }

      // 如果没找到文件名，跳过或使用默认名称
      if (!fileName) {
        if (section.includes('package.json') || section.startsWith('{')) {
          fileName = 'package.json';
          contentStartIndex = 0;
        } else {
          console.warn(`⚠️  未找到文件名，跳过段落: ${section.substring(0, 50)}...`);
          continue;
        }
      }

      // 提取文件内容
      fileContent = lines.slice(contentStartIndex).join('\n').trim();

      if (fileContent) {
        result.push({
          fileName: fileName,
          content: fileContent
        });
      }
    }

    return result;
  }

  /**
   * 处理单个文件段
   */
  async processSection(section) {
    const { fileName, content } = section;
    
    try {
      // 确保目录存在
      const dirName = path.dirname(fileName);
      if (dirName !== '.' && !fs.existsSync(dirName)) {
        fs.mkdirSync(dirName, { recursive: true });
        this.createdDirs.push(dirName);
        console.log(`📂 创建目录: ${dirName}`);
      }

      // 写入文件
      fs.writeFileSync(fileName, content, 'utf8');
      this.createdFiles.push(fileName);
      console.log(`📄 创建文件: ${fileName}`);

      // 特殊处理：给脚本文件添加执行权限
      if (fileName.endsWith('.sh') || fileName.includes('bin/')) {
        try {
          fs.chmodSync(fileName, 0o755);
        } catch (e) {
          // 忽略权限设置错误 (Windows)
        }
      }

    } catch (error) {
      console.error(`❌ 创建文件失败 ${fileName}:`, error.message);
      throw error;
    }
  }

  /**
   * 显示处理结果
   */
  showResults() {
    console.log('\n✅ 文件处理完成！');
    console.log(`📊 统计信息:`);
    console.log(`   - 创建目录: ${this.createdDirs.length} 个`);
    console.log(`   - 创建文件: ${this.createdFiles.length} 个`);
    
    if (this.createdDirs.length > 0) {
      console.log('\n📂 创建的目录:');
      this.createdDirs.forEach(dir => console.log(`   ${dir}`));
    }

    console.log('\n📄 创建的文件:');
    this.createdFiles.forEach(file => console.log(`   ${file}`));

    // 检查是否有package.json，给出下一步提示
    if (this.createdFiles.includes('package.json')) {
      console.log('\n🚀 下一步操作:');
      console.log('   1. npm install     # 安装依赖');
      console.log('   2. npm run dev     # 启动开发环境');
      console.log('   3. npm run build   # 构建项目');
    }
  }

  /**
   * 验证项目结构
   */
  validateProject() {
    const requiredFiles = [
      'package.json',
      'tsconfig.json',
      'vite.config.ts',
      'src/main/index.ts',
      'src/renderer/App.tsx'
    ];

    const missingFiles = requiredFiles.filter(file => !fs.existsSync(file));
    
    if (missingFiles.length > 0) {
      console.warn('\n⚠️  以下关键文件缺失:');
      missingFiles.forEach(file => console.warn(`   ${file}`));
    } else {
      console.log('\n✅ 项目结构验证通过！');
    }
  }

  /**
   * 清理功能 - 删除创建的文件（用于测试）
   */
  cleanup() {
    console.log('\n🧹 清理创建的文件...');
    
    // 删除文件
    this.createdFiles.forEach(file => {
      try {
        if (fs.existsSync(file)) {
          fs.unlinkSync(file);
          console.log(`🗑️  删除文件: ${file}`);
        }
      } catch (error) {
        console.error(`❌ 删除文件失败 ${file}:`, error.message);
      }
    });

    // 删除目录 (从深层开始)
    const sortedDirs = this.createdDirs.sort((a, b) => b.length - a.length);
    sortedDirs.forEach(dir => {
      try {
        if (fs.existsSync(dir) && fs.readdirSync(dir).length === 0) {
          fs.rmdirSync(dir);
          console.log(`🗑️  删除目录: ${dir}`);
        }
      } catch (error) {
        console.error(`❌ 删除目录失败 ${dir}:`, error.message);
      }
    });
  }
}

/**
 * 主函数
 */
async function main() {
  const args = process.argv.slice(2);
  
  // 显示帮助信息
  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`
📁 文件分割脚本

用法:
  node split-files.js <输入文件> [选项]

选项:
  --help, -h        显示帮助信息
  --cleanup         清理模式 (删除创建的文件)
  --validate        验证项目结构

示例:
  node split-files.js project-files.txt
  node split-files.js project-files.txt --validate
  node split-files.js project-files.txt --cleanup

支持的文件名格式:
  // src/main/index.ts
  # package.json
  /* vite.config.ts */
  <!-- README.md -->
    `);
    process.exit(0);
  }

  const inputFile = args[0];
  const isCleanup = args.includes('--cleanup');
  const shouldValidate = args.includes('--validate');

  // 检查输入文件是否存在
  if (!fs.existsSync(inputFile)) {
    console.error(`❌ 输入文件不存在: ${inputFile}`);
    process.exit(1);
  }

  const splitter = new FileSplitter();

  try {
    if (isCleanup) {
      // 清理模式：先处理文件以获取文件列表，然后清理
      await splitter.processFile(inputFile);
      splitter.cleanup();
    } else {
      // 正常模式：处理文件
      await splitter.processFile(inputFile);
      
      if (shouldValidate) {
        splitter.validateProject();
      }
    }

  } catch (error) {
    console.error('❌ 脚本执行失败:', error.message);
    process.exit(1);
  }
}

// 运行主函数
if (require.main === module) {
  main();
}

module.exports = FileSplitter;
