# AutoHotkey 实用脚本集

[![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2.0-brightgreen.svg)](https://www.autohotkey.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build and Release](https://github.com/xgp46ginpo/AutoHotkey/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/xgp46ginpo/AutoHotkey/actions/workflows/build-and-release.yml)

这是一个包含多个实用 AutoHotkey (AHK) v2 脚本的集合，旨在通过简化常见任务来提高您的工作效率。

## ✨ 功能亮点

- **智能 F3**：一个按键，多种用途。自动识别选中文本是链接、商品ID还是普通文本，并执行相应操作（打开、搜索等）。
- **剪贴板增强**：自动清理剪贴板内容，粘贴时去除首尾多余的空格。

---

## 🚀 快速开始

您可以通过两种方式使用这些脚本：

### 方式一：直接运行 (推荐给已安装 AHK 的用户)

1.  确保您已经安装了 [AutoHotkey v2](https://www.autohotkey.com/) 或更高版本。
2.  克隆或下载本项目到您的电脑。
    ```bash
    git clone https://github.com/xgp46ginpo/AutoHotkey.git
    ```
3.  进入项目目录，双击运行您需要的 `.ahk` 脚本文件。

### 方式二：使用编译好的程序 (推荐给未安装 AHK 的用户)

1.  前往本项目的 [**Releases**](https://github.com/xgp46ginpo/AutoHotkey/releases) 页面。
2.  下载最新版本的 `.zip` 压缩包。
3.  解压后，直接运行其中的 `.exe` 文件，无需安装 AutoHotkey 环境。

---

## 🛠️ 脚本详情

| 脚本名称 | 目录 | 热键 | 功能描述 |
| :--- | :--- | :--- | :--- |
| **智能 F3** | `智能F3/` | `F3` | 1. **打开链接**: 选中文本为 URL 时，在浏览器中打开。<br>2. **打开商品**: 选中文本为 Coupang 商品ID时，打开商品页。<br>3. **网页搜索**: 其他情况，在 Coupang 网站上搜索选中的文本。 |
| **粘贴去空格** | `剪贴板工具/` | `Ctrl`+`Alt`+`V` | 粘贴时，自动去除剪贴板内容首尾的空格。 |

---

## 🤝 贡献指南

欢迎您为这个项目做出贡献！如果您有任何改进建议、新功能想法或发现了bug，请随时提交 Pull Request 或创建 Issue。

## 📄 许可证

本项目采用 [MIT](https://opensource.org/licenses/MIT) 许可证。
