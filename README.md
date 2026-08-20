# TuneScope

> 基于 MoonBit 与 WebAssembly 的离线歌单解析、清洗与音乐偏好分析工具。

TuneScope 希望帮助用户将不同音乐平台导出的歌单数据，转换为结构统一、便于统计和比较的音乐资料库，并在浏览器本地生成直观的听歌偏好报告。


## 为什么开发 TuneScope？

音乐平台通常可以保存大量收藏，但用户很难直接回答这些问题：

- 我的歌单中哪位歌手出现得最多？
- 合作歌曲应该如何归属给不同艺人？
- 是否存在重复歌曲、缺失信息或格式异常？
- 我的音乐偏好集中在少数歌手，还是相对多样？
- 两个时期的歌单发生了什么变化？

现有工具往往依赖特定平台或需要上传个人数据。TuneScope 计划提供一个可复用的 MoonBit 分析核心，并通过 WebAssembly 在浏览器本地完成处理，尽量减少数据离开设备的需要。

## 计划功能

- 导入 CSV、JSON 和简单文本格式的歌单数据
- 统一歌曲名、艺人名、专辑名等元数据
- 识别并拆分合作艺人
- 检测重复歌曲、缺失字段和异常记录
- 统计歌手、专辑和歌曲数量排行
- 计算歌单集中度与多样性指标
- 比较两个歌单快照之间的变化
- 导出清洗后的数据和分析报告
- 提供基于 WebAssembly 的浏览器本地演示页面

## 当前进度

目前已经完成：

- [√] 创建 MoonBit 项目及公共 GitHub 仓库
- [√] 定义基础 `Track` 数据结构
- [√] 实现按歌手统计歌曲数量的核心函数
- [√] 添加首个 MoonBit 单元测试
- [√] 创建可运行的命令行示例
- [ ] 实现歌单文本解析
- [ ] 实现数据清洗与标准化
- [ ] 实现排行和偏好分析
- [ ] 实现歌单快照比较
- [ ] 构建 WebAssembly 浏览器演示
- [ ] 完善测试、文档与持续集成
- [ ] 发布 Mooncakes 包

## 项目结构

```text
TuneScope/
├── cmd/main/              # 命令行演示程序
├── tunescope.mbt          # TuneScope 核心库
├── tunescope_test.mbt     # 黑盒测试
├── tunescope_wbtest.mbt   # 白盒测试
├── moon.mod               # MoonBit 模块配置
├── moon.pkg               # MoonBit 包配置
└── LICENSE                # 开源许可证
```

## 快速开始

### 环境要求

请先安装 MoonBit 稳定版工具链。

### 获取并运行

```bash
git clone https://github.com/youyong5/tunescope.git
cd tunescope
moon check
moon test
moon run cmd/main
```

当前示例输出：

```text
TuneScope demo
王菲：2 首
```

## 技术方案

TuneScope 计划分为三个部分：

1. **MoonBit 核心库**  
   负责歌单解析、数据清洗、统计分析和快照比较。

2. **命令行演示程序**  
   用于快速验证核心功能，并为开发者提供调用示例。

3. **WebAssembly 浏览器应用**  
   在浏览器本地读取和分析歌单文件，展示可交互的统计结果。

## 项目目标

TuneScope 是一个可以复用和扩展的音乐数据分析工具。项目将优先保证：

- MoonBit 承担主要数据处理逻辑
- 核心算法具有自动化测试
- 输入、输出格式清晰且可复用
- 浏览器演示可以直接运行
- 用户的歌单数据尽量只在本地处理

## 开发者

由 [youyong5](https://github.com/youyong5) 独立开发。

## 许可证

本项目采用仓库 `LICENSE` 文件中所示的开源许可证。