# Neovim 快捷键总览

这份文档整理的是当前这套 Neovim 配置里可用的快捷键，包含：

- 全局基础映射
- 插件显式配置的映射
- 仅在特定文件类型、缓冲区或插件窗口中生效的映射
- 少数插件启用后的默认核心映射

## 基础说明

- `Leader` 键是 `<Space>`
- `LocalLeader` 键是 `,`
- `Space` 在普通/可视模式下会触发 `which-key` 提示
- 文中模式缩写：`n` 普通模式，`v` 可视模式，`x` 可视选择模式，`o` operator-pending，`i` 插入模式，`c` 命令行模式

## 全局基础映射

| 按键 | 模式 | 功能 | 来源 |
| --- | --- | --- | --- |
| `<Space>` | `n` | 立即显示 Leader 快捷键帮助，并继续接收后续按键 | `config/keymaps.lua` |
| `<Space>` | `v` | 立即显示可视模式下的 Leader 快捷键帮助 | `config/keymaps.lua` |
| `<Space>` | `o` | 禁用默认行为，作为 Leader 前缀保留 | `config/keymaps.lua` |
| `<C-[>` | `n`,`v`,`i` | 退出到普通模式 | `config/keymaps.lua` |
| `<leader>w` | `n` | 保存文件 | `config/keymaps.lua` |
| `<leader>q` | `n` | 退出窗口 | `config/keymaps.lua` |
| `<leader>?` | `n` | 显示 Leader 快捷键帮助 | `config/keymaps.lua` |
| `<C-n>` | `n` | 取消搜索高亮 | `config/keymaps.lua` |
| `<C-g>` | `n` | 显示参数提示 | `config/keymaps.lua` |
| `j` | `n` | 按视觉行向下移动 | `config/keymaps.lua` |
| `k` | `n` | 按视觉行向上移动 | `config/keymaps.lua` |
| `J` | `n`,`v` | 向下移动 5 行 | `config/keymaps.lua` |
| `K` | `n`,`v` | 向上移动 5 行 | `config/keymaps.lua` |
| `<leader>j` | `n` | 合并当前行和下一行 | `config/keymaps.lua` |
| `H` | `n` | 跳到行首非空白字符 | `config/keymaps.lua` |
| `L` | `n` | 跳到行尾 | `config/keymaps.lua` |
| `<leader>=` | `n` | 均分所有窗口 | `config/keymaps.lua` |
| `<leader>-` | `n` | 减小窗口高度 | `config/keymaps.lua` |
| `<leader>+` | `n` | 增大窗口高度 | `config/keymaps.lua` |
| `<A-H>` | `n` | 减小窗口宽度 5 列 | `config/keymaps.lua` |
| `<A-L>` | `n` | 增大窗口宽度 5 列 | `config/keymaps.lua` |
| `<A-J>` | `n` | 减小窗口高度 5 行 | `config/keymaps.lua` |
| `<A-K>` | `n` | 增大窗口高度 5 行 | `config/keymaps.lua` |
| `Y` | `n` | 复制到行尾 | `config/keymaps.lua` |
| `<` | `v` | 左缩进并保持选中 | `config/keymaps.lua` |
| `>` | `v` | 右缩进并保持选中 | `config/keymaps.lua` |
| `p` | `v` | 替换选区并保留寄存器 | `config/keymaps.lua` |
| `<A-j>` | `v` | 向下移动选中行 | `config/keymaps.lua` |
| `<A-k>` | `v` | 向上移动选中行 | `config/keymaps.lua` |
| `<leader>dd` | `n` | 查看当前诊断详情 | `config/keymaps.lua` |
| `[d` | `n` | 上一个诊断 | `config/keymaps.lua` |
| `]d` | `n` | 下一个诊断 | `config/keymaps.lua` |
| `<leader>dl` | `n` | 打开诊断列表 | `config/keymaps.lua` |

## 全局插件映射

| 按键 | 模式 | 功能 | 插件 |
| --- | --- | --- | --- |
| `<leader>m` | `n` | 打开 Mason | `mason.nvim` |
| `<A-h>` | `n` | 移动到左侧 Neovim 窗口 / tmux pane | `vim-tmux-navigator` |
| `<A-j>` | `n` | 移动到下方 Neovim 窗口 / tmux pane | `vim-tmux-navigator` |
| `<A-k>` | `n` | 移动到上方 Neovim 窗口 / tmux pane | `vim-tmux-navigator` |
| `<A-l>` | `n` | 移动到右侧 Neovim 窗口 / tmux pane | `vim-tmux-navigator` |
| `<leader>e` | `n` | 切换文件树 | `snacks.nvim` |
| `<leader>s` | `n`,`x` | 打开搜索替换面板（字面量） | `grug-far.nvim` |
| `<leader>S` | `n` | 打开搜索替换面板（正则） | `grug-far.nvim` |
| `<leader>ff` | `n` | 搜索文件 | `snacks.nvim` |
| `<leader>fg` | `n` | 全局搜索文本 | `snacks.nvim` |
| `<leader>fb` | `n` | Buffer 列表 | `snacks.nvim` |
| `<leader>fh` | `n` | 命令历史 | `snacks.nvim` |
| `<leader>fH` | `n` | 搜索帮助文档 | `snacks.nvim` |
| `<leader>fr` | `n` | 最近文件 | `snacks.nvim` |
| `<leader>fk` | `n` | 快捷键列表 | `snacks.nvim` |
| `<leader>cf` | `n` | 格式化代码 | `conform.nvim` |
| `<leader>aa` | `n` | 接受 Claude Diff | `claudecode.nvim` |
| `<leader>ab` | `n` | 把当前 Buffer 加入 Claude 上下文 | `claudecode.nvim` |
| `<leader>ac` | `n` | 打开/关闭 Claude Code | `claudecode.nvim` |
| `<leader>aC` | `n` | 继续 Claude 会话 | `claudecode.nvim` |
| `<leader>ad` | `n` | 拒绝 Claude Diff | `claudecode.nvim` |
| `<leader>af` | `n` | 聚焦 Claude Code | `claudecode.nvim` |
| `<leader>am` | `n` | 选择 Claude 模型 | `claudecode.nvim` |
| `<leader>ar` | `n` | 恢复 Claude 会话 | `claudecode.nvim` |
| `<leader>as` | `v` | 把选区发送给 Claude | `claudecode.nvim` |
| `<leader>ll` | `n` | 标记/取消标记当前文件 | `grapple.nvim` |
| `<leader>lt` | `n` | 打开 Grapple 标签管理窗口 | `grapple.nvim` |
| `<leader>1`-`<leader>9` | `n` | 跳转到对应 Grapple 标签 | `grapple.nvim` |
| `<leader>pv` | `n` | 选择 Python 虚拟环境 | `venv-selector.nvim` |
| `<leader>pt` | `n` | 运行当前 Python 测试 | `neotest` |
| `<leader>pT` | `n` | 运行当前文件测试 | `neotest` |
| `<leader>pl` | `n` | 重跑上次测试 | `neotest` |
| `<leader>pd` | `n` | 调试当前测试 | `neotest` + `nvim-dap` |
| `<leader>ps` | `n` | 切换测试结构面板 | `neotest` |
| `<leader>pO` | `n` | 切换测试输出面板 | `neotest` |
| `<leader>po` | `n` | 切换项目任务面板 | `overseer.nvim` |
| `<leader>pa` | `n` | 运行全部测试 | `overseer.nvim` |
| `<leader>pm` | `n` | 运行 mypy src | `overseer.nvim` |
| `<leader>pr` | `n` | Ruff 检查 | `overseer.nvim` |
| `<leader>pR` | `n` | Ruff 自动修复 | `overseer.nvim` |
| `<leader>pf` | `n` | Ruff 格式检查 | `overseer.nvim` |
| `<leader>pc` | `n` | 运行提交前检查 | `overseer.nvim` |
| `<leader>pC` | `n` | 运行 pre-commit 全量检查 | `overseer.nvim` |
| `<leader>cc` | `n` | CMake Configure | `cmake-tools.nvim` |
| `<leader>cb` | `n` | CMake Build | `cmake-tools.nvim` |
| `<leader>cr` | `n` | CMake Run | `cmake-tools.nvim` |
| `<leader>ct` | `n` | 选择 CMake 构建目标 | `cmake-tools.nvim` |
| `<leader>cx` | `n` | 选择 CMake configure preset | `cmake-tools.nvim` |
| `<leader>cp` | `n` | 选择 CMake build preset | `cmake-tools.nvim` |
| `<leader>cs` | `n` | 停止 CMake | `cmake-tools.nvim` |
| `<leader>gg` | `n` | 打开 LazyGit | `snacks.nvim` |
| `<leader>gG` | `n` | 用 LazyGit 打开当前文件 | `snacks.nvim` |
| `<leader>gc` | `n` | LazyGit Commits | `snacks.nvim` |
| `<leader>gd` | `n` | 打开 Diffview | `diffview.nvim` |
| `<leader>gD` | `n` | 关闭 Diffview | `diffview.nvim` |
| `<leader>gh` | `n` | 查看当前文件历史 | `diffview.nvim` |
| `<leader>gH` | `n` | 查看项目历史 | `diffview.nvim` |
| `<leader>gn` | `n` | 打开 Neogit | `neogit` |
| `<leader>gC` | `n` | Neogit Commit | `neogit` |
| `<leader>y` | `n` | 打开剪切板历史 | `yanky.nvim` |
| `p` | `n` | 通过 Yanky 在光标后粘贴 | `yanky.nvim` |
| `P` | `n` | 通过 Yanky 在光标前粘贴 | `yanky.nvim` |
| `<leader>um` | `n` | 切换 minimap | `mini.map` |
| `<leader>uM` | `n` | 聚焦 minimap | `mini.map` |
| `<C-S-j>` | `n`,`x` | 选择下一个匹配项 | `vim-visual-multi` |
| `<C-S-p>` | `n`,`x` | 跳过当前匹配项 | `vim-visual-multi` |
| `s` | `n`,`x`,`o` | Flash 跳转 | `flash.nvim` |
| `S` | `n`,`x`,`o` | Flash Treesitter 跳转 | `flash.nvim` |
| `r` | `o` | Remote Flash | `flash.nvim` |
| `R` | `o`,`x` | Treesitter Search | `flash.nvim` |
| `<C-s>` | `c` | 切换 Flash Search | `flash.nvim` |
| `gcc` | `n` | 注释/取消注释当前行 | `Comment.nvim` |
| `gc{motion}` | `n` | 注释指定文本对象/移动范围 | `Comment.nvim` |
| `gc` | `v` | 注释选区 | `Comment.nvim` |
| `gbc` | `n` | 块注释当前行 | `Comment.nvim` |
| `gb{motion}` | `n` | 块注释指定范围 | `Comment.nvim` |
| `gb` | `v` | 块注释选区 | `Comment.nvim` |
| `gcO` | `n` | 在上方添加注释行 | `Comment.nvim` |
| `gco` | `n` | 在下方添加注释行 | `Comment.nvim` |
| `gcA` | `n` | 在行尾添加注释 | `Comment.nvim` |
| `ys{motion}{char}` | `n` | 给指定文本加包裹 | `nvim-surround` |
| `yss{char}` | `n` | 给当前整行加包裹 | `nvim-surround` |
| `yS{motion}{char}` | `n` | 以换行样式添加包裹 | `nvim-surround` |
| `ySS{char}` | `n` | 给当前整行添加换行包裹 | `nvim-surround` |
| `ds{char}` | `n` | 删除指定包裹 | `nvim-surround` |
| `cs{target}{replacement}` | `n` | 替换包裹 | `nvim-surround` |
| `<M-e>` | `i` | Fast Wrap 快速包裹 | `nvim-autopairs` |
| `<C-u>` | `n` | 平滑向上滚动半屏 | `neoscroll.nvim` |
| `<C-d>` | `n` | 平滑向下滚动半屏 | `neoscroll.nvim` |
| `<C-b>` | `n` | 平滑向上滚动整屏 | `neoscroll.nvim` |
| `<C-f>` | `n` | 平滑向下滚动整屏 | `neoscroll.nvim` |
| `<C-y>` | `n` | 平滑向上滚动一行 | `neoscroll.nvim` |
| `<C-e>` | `n` | 平滑向下滚动一行 | `neoscroll.nvim` |
| `zt` | `n` | 平滑滚动并将当前行放到顶部 | `neoscroll.nvim` |
| `zz` | `n` | 平滑滚动并将当前行放到中间 | `neoscroll.nvim` |
| `zb` | `n` | 平滑滚动并将当前行放到底部 | `neoscroll.nvim` |
| `<F5>` | `n` | 启动/继续调试 | `nvim-dap` |
| `<F6>` | `n` | 继续执行 | `nvim-dap` |
| `<F9>` | `n` | 切换断点 | `nvim-dap` |
| `<F10>` | `n` | 单步跳过 | `nvim-dap` |
| `<F11>` | `n` | 单步进入 | `nvim-dap` |
| `<S-F11>` | `n` | 单步跳出 | `nvim-dap` |
| `<leader>db` | `n` | 切换断点 | `nvim-dap` |
| `<leader>dc` | `n` | 继续执行 | `nvim-dap` |
| `<leader>dt` | `n` | 终止调试 | `nvim-dap` |
| `<leader>du` | `n` | 切换调试界面 | `nvim-dap-ui` |
| `<leader>de` | `n`,`v` | 计算表达式 | `nvim-dap-ui` |
| 自动弹窗 | `i` | 输入函数调用与参数分隔符时自动显示参数提示 | `lsp_signature.nvim` |

## 补全与选择相关

### blink.cmp

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<C-b>` | `i`,`s` | 文档向上滚动 |
| `<C-f>` | `i`,`s` | 文档向下滚动 |
| `<C-space>` | `i`,`s` | 手动触发补全 |
| `<C-n>` | `i`,`s` | 选择下一个补全项 |
| `<C-p>` | `i`,`s` | 选择上一个补全项 |
| `<C-e>` | `i`,`s` | 关闭补全菜单 |
| `<Tab>` | `i`,`s` | 选中并确认补全项，或跳转 snippet |
| `<S-Tab>` | `i`,`s` | snippet 反向跳转 |

### lsp_signature.nvim

| 触发方式 | 模式 | 功能 |
| --- | --- | --- |
| 输入 `(` / `,` 等 LSP 触发字符 | `i` | 自动弹出函数签名与当前参数高亮 |
| `<C-g>` | `n` | 手动显示一次参数提示 |

### Treesitter 增量选择

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `gnn` | `n` | 开始增量选择 |
| `grn` | `n` | 扩大选择范围 |
| `grm` | `n` | 缩小选择范围 |

### Flash 扩展字符跳转

启用 `opts = {}` 后，`flash.nvim` 会接管并增强这些字符跳转键：

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `f{char}` | `n`,`x`,`o` | 向前跳到字符 |
| `F{char}` | `n`,`x`,`o` | 向后跳到字符 |
| `t{char}` | `n`,`x`,`o` | 向前跳到字符前 |
| `T{char}` | `n`,`x`,`o` | 向后跳到字符后 |
| `;` | `n`,`x`,`o` | 重复下一次字符跳转 |
| `,` | `n`,`x`,`o` | 重复上一次字符跳转 |

## 仅在特定上下文中生效的映射

### Markdown / Quarto / R Markdown 文件中

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `,p` | `n` | 切换 Markdown 表格预览模式 |

### grug-far 面板中

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `,r` | `n` | 确认替换 | 
| `,s` | `n` | 同步所有结果到源文件 |
| `,w` | `n` | 切换字面量搜索（`--fixed-strings`） |
| `,c` | `n` | 关闭 grug-far 面板 |

### LSP 附加后

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `gd` | `n` | 跳转到定义 |
| `grr` | `n` | 查找引用 |
| `gh` | `n` | 显示悬浮信息 |
| `gra` | `n`,`v` | 代码操作 |
| `grn` | `n` | 重命名符号（预览） |
| `gri` | `n` | 查找实现 |
| `<leader>ch` | `n` | 切换头/源文件（clangd） |
| `<leader>ci` | `n` | 为声明写入 `.cpp` 实现骨架 |

### Java 文件中（`nvim-jdtls`）

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>jo` | `n` | 整理 Java 导入 |
| `<leader>jv` | `n` | 提取变量 |
| `<leader>jv` | `v` | 提取变量（可视模式） |
| `<leader>jc` | `n` | 提取常量 |
| `<leader>jm` | `v` | 提取方法 |

### Git 跟踪文件中（`gitsigns.nvim` attach 后）

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `]h` | `n` | 下一个 Git 改动块 |
