# Neovim 快捷键总览

这份文档记录当前配置中的自定义快捷键。叶子快捷键的 `desc` 和运行时
which-key 才是最终真相；本文负责解释分组、使用场景和容易混淆的地方，不再在
`which-key.lua` 中重复维护同一批叶子说明。

## 前缀与模式

- `<leader>` 是空格，负责跨文件、跨项目和工具级操作。
- `<localleader>` 是逗号，负责当前文件的标记和局部操作。
- 空格和逗号的 which-key 提示立即显示；`g`、`z`、`[`、`]` 等原生前缀等待
  250ms 后显示，避免熟练操作时频繁闪窗。
- 因为逗号是前缀，单按 `,` 会等待约 1 秒；原生 `,`（反向重复 `f`/`t`）仍可用，
  但会有这段等待。正向重复仍是 `;`。
- 模式缩写：`n` 普通、`i` 插入、`v`/`x` 可视、`o` 操作符等待、`c` 命令行。
- 随时按 `<leader>?` 查看 Leader 帮助；`<leader>fk` 可搜索全部已注册快捷键。

## 基础编辑与窗口

| 按键 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>w` | `n` | 保存文件 |
| `<leader>q` | `n` | 关闭当前窗口 |
| `<leader>j` | `n` | 合并当前行和下一行（原生 `J`） |
| `j` / `k` | `n` | 按屏幕视觉行移动，适合软换行文本 |
| `J` / `K` | `n`,`v` | 向下 / 向上移动 5 行 |
| `H` / `L` | `n` | 到行首非空白 / 行尾 |
| `<` / `>` | `v` | 缩进并保持选区 |
| `p` | `v` | 替换选区且不污染默认寄存器 |
| `<A-j>` / `<A-k>` | `i`,`v` | 下移 / 上移当前行或选中行 |
| `<A-h/j/k/l>` | `n` | 在 Neovim 窗口与 tmux pane 间移动 |
| `<leader>=` | `n` | 均分所有窗口 |
| `<leader>-` / `<leader>+` | `n` | 减小 / 增大窗口高度 |
| `<A-H/L>` | `n` | 减小 / 增大窗口宽度 5 列 |
| `<A-J/K>` | `n` | 减小 / 增大窗口高度 5 行 |
| `<leader>bd` | `n` | 关闭 Buffer，但保留窗口布局 |
| `[b` / `]b` | `n` | 上一个 / 下一个 Buffer |
| `<Esc>` / `<C-[>` | `n` | 清除多光标；无多光标时清除搜索高亮 |

`Y` 使用 Neovim 原生“复制到行尾”。`<C-[>` 在插入和可视模式下
也保留原生 Esc 语义，只在普通模式参与多光标清理。

## 文件、搜索与导航

| 按键 | 功能 |
| --- | --- |
| `<leader>e` | 打开文件树 |
| `<leader>ff` | 搜索文件 |
| `<leader>fg` | 全局搜索文本 |
| `<leader>fb` | Buffer 列表 |
| `<leader>fl` | 搜索当前 Buffer 的行 |
| `<leader>fr` | 最近文件 |
| `<leader>fp` | 选择项目 |
| `<leader>fR` | 恢复上一次 Picker |
| `<leader>fh` / `<leader>fH` | 命令历史 / 帮助文档 |
| `<leader>ft` | 搜索 TODO 注释 |
| `<leader>fy` | 用 Yazi 打开当前文件（普通/可视模式） |
| `<leader>fY` | 用 Yazi 打开当前工作目录 |
| `<C-Up>` | 恢复上次 Yazi 会话 |
| `<leader>o` | 符号大纲 |
| `<leader>s` / `<leader>S` | 字面量 / 正则搜索替换 |
| `<leader>y` | 剪切板历史 |
| `<leader>.` / `<leader>,` | 打开草稿 / 选择草稿 |

在普通模式中，`p` / `P` 由 Yanky 接管粘贴，但保持原生方向；历史通过
`<leader>y` 选择。

## 文件标记：逗号前缀

| 按键 | 功能 |
| --- | --- |
| `,m` | 标记 / 取消标记当前文件 |
| `,l` | 打开 Grapple 标签管理窗口 |
| `,1` … `,9` | 跳转到第 1 … 9 个项目内文件标签 |

Grapple 以 Git 仓库为作用域；逗号数字键用于项目内常用文件直达。

局部上下文还会使用逗号：Markdown 中 `,p` 切换表格预览；grug-far 窗口中
`,w` 切换字面量搜索。这些映射不会与 Grapple 的 `,m` / `,l` / 数字冲突。

## `z` 前缀：折叠与视图

最常用的一组：

| 按键 | 功能 |
| --- | --- |
| `za` / `zA` | 切换当前折叠 / 递归切换 |
| `zo` / `zO` | 打开当前折叠 / 递归打开 |
| `zc` / `zC` | 关闭当前折叠 / 递归关闭 |
| `zR` | UFO 展开全部折叠，保持可恢复的层级 |
| `zM` | UFO 关闭全部折叠，保持层级 |
| `zr` | UFO 展开全部折叠（小写快捷键） |
| `zm` | UFO 关闭全部折叠（小写快捷键） |
| `zp` | 预览光标下已关闭折叠，不真正展开 |
| `zv` | 展开到足以看见光标行 |
| `zj` / `zk` | 下一个折叠起点 / 上一个折叠终点 |

`zp` 明确让给 UFO 预览，因此覆盖 Neovim 0.12 的同名块粘贴动作；需要块编辑时仍可用
`zP`（向前粘贴且不补尾随空格）和 `zy`（复制时忽略尾随空格）。

其余原生 `z` 命令仍保留：

- `zf{motion}` / 可视模式 `zf` 创建折叠，`zF` 创建 N 行折叠。
- `zd` / `zD` 删除当前 / 递归手工折叠，`zE` 删除窗口内全部手工折叠。
- `zi` 切换折叠功能，`zn` 暂时显示全部，`zN` 恢复启用。
- `zx` / `zX` 重算折叠；`zt` / `zz` / `zb` 把当前行放到顶部 / 中部 / 底部。
- `zh` / `zl` 水平滚动，`zH` / `zL` 水平滚动半屏。
- `z=`、`zg`、`zw` 等是拼写建议与词表命令。

按 `z` 会显示完整中文 which-key 速查。UFO 默认用 Treesitter 生成折叠，失败时回退到
缩进，并保持文件初次打开时展开。

## 代码、LSP 与结构编辑

LSP 附加到当前 Buffer 后生效：

| 按键 | 功能 |
| --- | --- |
| `gd` | 跳转到定义 |
| `gh` | 智能悬浮文档（Pyright 优先，无正文时回退 Jedi） |
| `grr` | 查找引用 |
| `gra` | 代码操作（普通/可视模式） |
| `grn` | 预览式重命名 |
| `gri` | 查找实现 |
| `<C-g>` | 函数参数签名提示 |
| `<leader>fs` / `<leader>fS` | 文件符号 / 工作区符号 |
| `<leader>th` | 切换内联提示 |
| `<leader>cf` | 格式化当前文件 |
| `<leader>xl` | 查看当前行诊断浮窗 |
| `[d` / `]d` | 上一个 / 下一个诊断 |
| `<leader>xx` / `<leader>xd` | 全局 / 当前文件诊断列表 |
| `<leader>xq` | 快速修复列表 |
| `<leader>cj` | TreeSJ 拆分 / 合并当前代码结构 |
| `<leader>xp` / `<leader>xP` | 参数与后一个 / 前一个参数交换 |
| `[f` / `]f` | 上一个 / 下一个函数 |
| `[c` / `]c` | 上一个 / 下一个类 |

Treesitter 文本对象：`af` / `if` 选择整个函数 / 函数体，`ac` / `ic` 选择整个类 /
类体，`aa` / `ia` 选择参数（含逗号）/ 参数值；用于可视和操作符等待模式。

### C / C++

| 按键 | 功能 |
| --- | --- |
| `<leader>ch` / `<leader>ci` | 切换头源文件 / 生成 `.cpp` 实现骨架 |
| `<leader>cT` / `<leader>ca` / `<leader>cm` | 类型层次 / AST / 内存布局 |
| `<leader>cc` / `<leader>cb` / `<leader>cr` | CMake 配置 / 构建 / 运行 |
| `<leader>ct` | 选择 CMake 构建目标 |
| `<leader>cx` / `<leader>cp` | 选择 configure / build preset |
| `<leader>cs` | 停止 CMake 任务 |

### Java

仅 Java Buffer 生效：`<leader>Jo` 整理导入，`<leader>Jv` 提取变量，
`<leader>Jc` 提取常量，可视模式 `<leader>Jm` 提取方法。大写 `J` 分组避免占用
全局 `<leader>j` 的“合并行”。打开 Java 项目并等待 JDTLS 就绪后，可用
`:DapNew` 自动发现主类；远程调试仍可从 DAP 配置中选择“附加到远程 Java 进程”。

## Python 与项目任务

| 按键 | 功能 |
| --- | --- |
| `<leader>pv` | 选择 Python 虚拟环境 |
| `<leader>pt` / `<leader>pT` | 运行当前测试 / 当前文件测试 |
| `<leader>pl` / `<leader>pd` | 重跑上次测试 / 调试当前测试 |
| `<leader>ps` / `<leader>pO` | 测试结构 / 输出面板 |
| `<leader>po` | 项目任务面板 |
| `<leader>pa` | 运行全部测试 |
| `<leader>pm` | 运行 mypy |
| `<leader>pr` / `<leader>pR` | Ruff 检查 / 自动修复 |
| `<leader>pf` | Ruff 格式检查 |
| `<leader>pc` | Ruff、mypy、pytest 提交前检查 |
| `<leader>pC` | 运行完整 pre-commit |

## Git

| 按键 | 功能 |
| --- | --- |
| `<leader>gg` | LazyGit |
| `<leader>gG` / `<leader>gc` | 当前文件历史 / Git 提交记录（LazyGit） |
| `<leader>gn` / `<leader>gC` | Neogit / Neogit Commit |
| `<leader>gd` / `<leader>gs` | 切换工作区 Diff / 暂存区 Diff |
| `<leader>gh` / `<leader>gH` | 当前文件（或可视选区）/ 项目历史 |
| `<leader>gb` | 在浏览器打开当前行（普通/可视模式） |
| `[h` / `]h` | 上一个 / 下一个 Git 改动块 |
| `<leader>hs` / `<leader>hr` | 暂存 / 重置改动块或可视选区 |
| `<leader>hS` / `<leader>hR` | 暂存 / 重置整个文件 |
| `<leader>hu` / `<leader>hp` | 撤销暂存 / 预览改动块 |
| `<leader>hb` / `<leader>hB` | 查看当前行 Blame / 持续切换 Blame |
| `<leader>hd` / `<leader>hD` | Diff 当前文件 / 与 HEAD 比较 |
| `ih` | Git 改动块文本对象（可视/操作符等待） |

LazyGit 用于快速日常操作；Neogit 保留为更偏编辑器内、Magit 风格的工作流。

## 调试

高频调试只用功能键，Leader 组保留高级动作：

| 按键 | 功能 |
| --- | --- |
| `<F5>` | 启动 / 继续 |
| `<F9>` | 切换断点 |
| `<F10>` / `<F11>` / `<S-F11>` | 单步跳过 / 进入 / 跳出 |
| `<leader>dB` / `<leader>dl` | 条件断点 / 日志断点 |
| `<leader>da` / `<leader>dr` | 带参数运行 / 重运行上次调试 |
| `<leader>dC` | 运行到光标 |
| `<leader>dj` / `<leader>dk` | 调用栈向下 / 向上 |
| `<leader>dP` / `<leader>dt` | 暂停 / 终止 |
| `<leader>dw` | 悬浮查看变量 |
| `<leader>du` / `<leader>de` | 切换调试界面 / 计算表达式 |

## 终端、界面与工具

| 按键 | 功能 |
| --- | --- |
| `<C-\>` | 切换唯一的浮动终端 |
| `<leader>tv` | 右侧垂直终端 |
| `<leader>tz` / `<leader>td` | 禅模式 / Dim 聚焦模式 |
| `<leader>tu` | 撤销历史树 |
| `<leader>ut` | 切换 Treesitter 上下文行 |
| `<leader>un` | 通知历史 |
| `<leader>us` / `<leader>uw` | 拼写检查 / 自动换行 |
| `<leader>ul` / `<leader>ud` | 相对行号 / 诊断显示 |
| `<leader>uc` | Conceal 显示 |
| `<leader>m` | Mason |
| `<leader>tD` | 数据库界面 |
| `<leader>ai` | 切换 Copilot 自动建议 |
| `<leader>aa` | 在 Neovim 输入问题并发送到 OpenCode |
| `<leader>ap` | 将选区/光标上下文追加到 OpenCode prompt，不提交 |
| `<leader>ae` / `<leader>ar` / `<leader>am` | 解释 / 审查 / 实现当前代码 |
| `<leader>as` | 选择 OpenCode 预设、命令或服务 |
| `<C-.>` | 切换右侧备用 OpenCode 终端 |

OpenCode 优先连接 tmux 中用 `oc`（即 `opencode --port`）启动的当前项目服务；只有找不到
匹配服务时，才在 Neovim 右侧启动备用终端。备用终端在普通和终端模式下可用 `<C-.>`
切换，Alt-HJKL 可导航且重新进入后会自动进入输入模式。浮动终端在普通和终端模式下都用 `<C-\>` 开关。Copilot 插入模式快捷键：
`<A-y>` 接受全部、`<A-w>` 接受一个词、`<A-l>` 接受到行尾、`<A-]>` / `<A-[>`
切换建议、`<A-e>` 忽略建议。

## 会话与 Obsidian

| 按键 | 功能 |
| --- | --- |
| `<leader>Ps` / `<leader>Pl` | 恢复当前目录 / 最近会话 |
| `<leader>Pd` | 本次退出不保存会话 |
| `<leader>no` / `<leader>nn` | 在 Obsidian 打开 / 新建笔记 |
| `<leader>ns` / `<leader>nq` | 搜索 / 快速切换笔记 |
| `<leader>nl` / `<leader>nb` | 链接 / 反向链接 |
| `<leader>nt` / `<leader>nd` | 标签 / 每日笔记 |

Obsidian 会在 Markdown 文件中自动加载；这些快捷键也可主动触发插件，主要用于
Obsidian 工作区。

## 多光标、跳转、注释与包裹

- 多光标：`<C-n>` / `<C-p>` 添加下一个 / 上一个匹配，`<C-s>` 跳过当前匹配，
  `<C-q>` 切换当前位置光标；`<leader>Mn` 全选匹配，`<leader>Mj/Mk` 向下 / 上添加，
  `<leader>Ma` 对齐。可视模式还有 `<leader>Ms`、`<leader>Mt/MT`、`I`、`A`。
- Flash：`s` 普通跳转，`S` 语法树跳转，操作符模式 `r` 远程跳转，`R` 语法树搜索，
  命令行 `<C-s>` 切换 Flash 搜索。
- 注释：`gcc` / `gbc` 行注释 / 块注释，`gc{motion}` / `gb{motion}` 范围注释，
  `gcO` / `gco` / `gcA` 在上方 / 下方 / 行尾添加注释。
- Surround：`ys{motion}{char}` 添加包裹，`yss{char}` 包裹整行，`ds{char}` 删除，
  `cs{target}{replacement}` 替换。
- Autopairs：插入模式 `<M-e>` 快速包裹。

## 补全

blink.cmp 使用 super-tab：`<Tab>` 选择并确认或跳转 snippet，`<S-Tab>` 反向跳转，
`<C-n>/<C-p>` 浏览候选，`<C-space>` 手动触发，`<C-e>` 关闭菜单，`<C-b>/<C-f>`
滚动文档；回车始终换行。Lua 文件额外使用 LazyDev 补全 Neovim 与插件 API。

## 排查与维护

- `<leader>?`：查看 Leader 分组。
- 直接按 `g`、`z`、`[`、`]` 并等待 250ms：查看这些原生前缀的中文速查。
- `<leader>fk`：搜索实际注册的全部映射。
- `:verbose nmap <按键>`：确认最终映射和最后定义它的脚本。
- 新增映射必须带中文 `desc`；插件叶子键写在插件的 `keys` 或实际
  `vim.keymap.set` 中，`which-key.lua` 只登记分组和原生命令说明。
