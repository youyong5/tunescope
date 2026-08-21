# TuneScope

> A playlist cleaner and analyzer written in MoonBit.

TuneScope 是一个使用 MoonBit 开发的命令行歌单分析工具。它可以读取 CSV 歌单，检查无效数据，统计歌手和专辑，识别重复歌曲，并导出清洗后的 CSV 文件和 Markdown 分析报告。


## 功能

- 读取真实 CSV 歌单文件
- 支持带引号的 CSV 字段
- 支持字段内部的逗号和转义双引号
- 自动修剪字段首尾空格
- 检查缺少歌曲名或歌手名的无效记录
- 允许专辑字段为空
- 统计总行数、有效歌曲数和无效行数
- 统计不同歌手和已知专辑数量
- 生成歌手歌曲数量排行
- 生成“歌手 + 专辑”排行
- 检测重复歌曲
- 导出清洗后的标准 CSV
- 自动生成 Markdown 分析报告

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/youyong5/tunescope.git
cd tunescope
```

### 2. 检查项目

```bash
moon check
```

### 3. 运行测试

```bash
moon test
```

### 4. 分析示例歌单

```bash
moon run cmd/main -- examples/sample_playlist.csv
```

### 5. 导出清洗结果和 Markdown 报告

```bash
moon run cmd/main -- examples/sample_playlist.csv examples/cleaned_playlist.csv examples/sample_report.md
```

三个命令行参数依次表示：

1. 输入歌单路径
2. 清洗后的 CSV 输出路径（可选）
3. Markdown 报告输出路径（可选）

## 输入格式

CSV 文件第一行为表头，每条歌曲记录包含：

```csv
title,artist,album
```

示例：

```csv
title,artist,album
浮躁,王菲,浮躁
不来也不去,陈奕迅,H3M
无专辑歌曲,测试歌手,
"Song, Part 1",Artist,"Album, Deluxe"
"He said ""Hi""",Artist,Album
```

其中：

- `title`：歌曲名，不能为空
- `artist`：歌手名，不能为空
- `album`：专辑名，可以为空
- 包含逗号的字段需要使用双引号包围
- 字段中的双引号使用两个连续双引号表示

## 运行结果

使用示例歌单运行后，会得到类似输出：

```text
TuneScope playlist report
File: examples/sample_playlist.csv
Total rows: 10
Valid tracks: 8
Invalid rows: 2

Top artists:
1. 王菲: 3

Unique artists: 6
Known albums: 5

Top albums:
1. 浮躁 — 王菲: 3

Duplicate tracks: 1 groups
- 浮躁 — 王菲 (2 copies)
```

如果提供输出路径，程序还会生成：

- [清洗后的示例 CSV](examples/cleaned_playlist.csv)
- [示例 Markdown 分析报告](examples/sample_report.md)

## 数据处理规则

### 无效记录

以下记录会被判定为无效：

- 字段数量不是三个
- 歌曲名为空
- 歌手名为空
- CSV 引号没有正确闭合
- 关闭引号后出现非法字符

### 重复歌曲

当两条记录的“歌曲名 + 歌手名”相同时，会被视为重复歌曲。

比较时会：

- 忽略空格差异
- 忽略英文字母大小写
- 不使用专辑名作为重复判断条件

重复检测只生成报告，不会自动删除歌曲，避免程序擅自修改用户数据。

### 清洗导出

导出的 CSV 会：

- 删除无效记录
- 修剪字段首尾空格
- 保留合法的空专辑字段
- 正确转义逗号和双引号
- 保留检测到的重复歌曲

## 项目结构

```text
TuneScope/
├── cmd/main/                   # 命令行程序入口
│   ├── main.mbt
│   └── moon.pkg
├── examples/                   # 输入、清洗结果和报告示例
│   ├── sample_playlist.csv
│   ├── cleaned_playlist.csv
│   └── sample_report.md
├── tunescope.mbt               # CSV 解析、统计和导出核心逻辑
├── tunescope_wbtest.mbt        # 白盒测试
├── tunescope_test.mbt          # 黑盒测试
├── moon.mod                    # MoonBit 模块配置
└── moon.pkg                    # 根包配置
```

## 核心模块

TuneScope 的核心逻辑包括：

- `parse_track_line`：解析单条 CSV 记录
- `parse_playlist`：解析完整歌单
- `artist_ranking`：生成歌手排行
- `album_ranking`：生成专辑排行
- `duplicate_tracks`：检测重复歌曲
- `tracks_to_csv`：生成清洗后的 CSV
- `generate_markdown_report`：生成 Markdown 报告

## 测试

项目包含针对以下情况的自动化测试：

- 正常歌曲记录
- 缺少字段和多余字段
- 空歌曲名或空歌手名
- 空专辑名
- 字段首尾空格
- 带逗号的引号字段
- CSV 双引号转义
- 未闭合的引号
- 歌手与专辑排行
- 重复歌曲检测
- CSV 清洗导出
- Markdown 报告生成
- 空歌单边界情况

运行：

```bash
moon test
```

## 为什么使用 MoonBit

TuneScope 使用 MoonBit 完成了完整的数据处理流程和界面演示：

```text
CSV 文件
→ 解析与校验
→ 结构化 Track 数据
→ 排行和重复检测
→ CSV 与 Markdown 输出
```

项目使用了 MoonBit 的结构体、模式匹配、数组、Map、包管理、错误处理、文件系统接口和测试工具链。

## 当前限制

- 当前要求每条歌曲记录位于单独一行
- 暂不支持引号字段内部的换行
- 当前输入字段固定为 `title,artist,album`
- 当前提供命令行版本，暂未提供图形界面

## 后续计划

- 增加播放次数等可选字段
- 增加更多歌单多样性统计
- 支持自定义字段映射
- 增加 JSON 报告输出
- 探索基于 WebAssembly 的浏览器版本

## 项目说明

TuneScope 是为 MoonBit 开源活动从零开发的原创项目，并非已有项目的迁移版本。

## License

本项目采用仓库中 `LICENSE` 文件所示的开源许可证。