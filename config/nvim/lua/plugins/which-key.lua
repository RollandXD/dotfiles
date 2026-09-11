-- ========== which-key.nvim - 快捷键提示 ==========
-- 按下 Leader 键后显示可用的快捷键

return {
  "folke/which-key.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "echasnovski/mini.icons",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 1000 -- 1s，适配慢速按键习惯
  end,
  config = function()
    local wk = require("which-key")
    local immediate_prefixes = {
      [vim.keycode("<leader>")] = true,
      [vim.keycode("<localleader>")] = true,
    }

    wk.setup({
      delay = function(ctx)
        -- Leader/LocalLeader 和插件提示立即出现；原生多键前缀稍作延迟，减少干扰。
        return (ctx.plugin or immediate_prefixes[ctx.keys]) and 0 or 250
      end,
      triggers = {
        { "<auto>", mode = "nxso" },
        { "<leader>", mode = { "n", "v" } },
      },
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = false,
        },
        presets = {
          z = false, -- 使用下方与 Neovim 0.12 对齐的完整中文速查
        },
      },
      win = {
        border = "rounded",
      },
    })

    -- 新版 spec：使用 desc/group 字段
    wk.add({
      { "<localleader>", group = "文件标记/局部操作" },

      -- ========== g 前缀：跳转/LSP ==========
      { "g", group = "跳转/LSP" },
      -- LSP 相关
      { "gd", desc = "跳转到定义" },
      { "gh", desc = "智能悬浮文档" },
      { "gr", group = "LSP 重构" },
      { "grr", desc = "查找引用" },
      { "gra", desc = "代码操作", mode = { "n", "v" } },
      { "grn", desc = "重命名符号" },
      { "gri", desc = "查找实现" },
      -- Vim 内置 g 跳转
      { "gg", desc = "跳到文件开头" },
      { "gf", desc = "打开光标下文件" },
      { "gv", desc = "重选上次选区" },
      { "gi", desc = "跳到上次插入位置并插入" },
      { "g;", desc = "上一个修改位置" },
      { "g,", desc = "下一个修改位置" },
      { "gx", desc = "用系统程序打开" },
      { "go", desc = "跳到第 N 字节" },
      -- 搜索/匹配
      { "gn", desc = "选中下一个搜索匹配" },
      { "gN", desc = "选中上一个搜索匹配" },
      { "g*", desc = "模糊搜索光标词（向后）" },
      { "g#", desc = "模糊搜索光标词（向前）" },
      { "g%", desc = "反向匹配括号" },
      -- 移动
      { "ge", desc = "上一个单词尾" },
      { "gE", desc = "上一个字串尾" },
      { "gj", desc = "向下移动（屏幕行）" },
      { "gk", desc = "向上移动（屏幕行）" },
      { "g0", desc = "屏幕行首" },
      { "g$", desc = "屏幕行尾" },
      { "g^", desc = "屏幕行首（非空白）" },
      { "gm", desc = "屏幕行中间" },
      { "gM", desc = "文本行中间" },
      -- 大小写/格式化（操作符）
      { "gu", desc = "转小写", mode = { "n", "v" } },
      { "gU", desc = "转大写", mode = { "n", "v" } },
      { "g~", desc = "切换大小写", mode = { "n", "v" } },
      { "gw", desc = "格式化（保持光标）", mode = { "n", "v" } },
      { "gq", desc = "格式化文本", mode = { "n", "v" } },
      -- Tab 页
      { "gt", desc = "下一个标签页" },
      { "gT", desc = "上一个标签页" },
      -- 编辑
      { "gJ", desc = "合并行（不加空格）" },
      { "gp", desc = "粘贴并移动光标到末尾" },
      { "gP", desc = "向前粘贴并移动光标" },
      -- 信息
      { "ga", desc = "显示字符编码" },
      { "g8", desc = "显示 UTF-8 编码" },
      { "g<C-g>", desc = "显示光标位置信息" },
      -- 其他
      { "gI", desc = "在行首插入（第 1 列）" },

      -- ========== z 前缀：折叠/视图/拼写/块编辑 ==========
      -- UFO 映射（zR/zM/zr/zm/zp）直接读取插件 keys 中的 desc，不在这里重复登记。
      { "z", group = "折叠/视图/拼写/块编辑" },
      -- 折叠操作
      { "za", desc = "折叠：切换当前层" },
      { "zA", desc = "折叠：递归切换" },
      { "zc", desc = "折叠：关闭当前层" },
      { "zC", desc = "折叠：递归关闭" },
      { "zo", desc = "折叠：打开当前层" },
      { "zO", desc = "折叠：递归打开" },
      { "zj", desc = "折叠：下一个折叠起点" },
      { "zk", desc = "折叠：上一个折叠终点" },
      { "zf", desc = "折叠：按移动/选区创建", mode = { "n", "v" } },
      { "zF", desc = "折叠：创建 N 行折叠" },
      { "zd", desc = "折叠：删除当前层（不可撤销）" },
      { "zD", desc = "折叠：递归删除（不可撤销）" },
      { "zE", desc = "折叠：删除窗口内全部（不可撤销）" },
      { "zi", desc = "折叠：切换显示开关" },
      { "zn", desc = "折叠：暂时显示全部" },
      { "zN", desc = "折叠：恢复启用" },
      { "zv", desc = "折叠：展开到光标可见" },
      { "zx", desc = "折叠：重算层级并显示光标行" },
      { "zX", desc = "折叠：重算并重新应用层级" },
      -- 视图/滚动
      { "zt", desc = "视图：当前行置顶（保留列）" },
      { "z<CR>", desc = "视图：当前行置顶并到首个非空白" },
      { "zz", desc = "视图：当前行居中（保留列）" },
      { "z.", desc = "视图：当前行居中并到首个非空白" },
      { "zb", desc = "视图：当前行置底（保留列）" },
      { "z-", desc = "视图：当前行置底并到首个非空白" },
      { "z+", desc = "视图：下一屏置顶并到首个非空白" },
      { "z^", desc = "视图：上一屏置底并到首个非空白" },
      { "zh", desc = "视图：查看更左侧内容" },
      { "zl", desc = "视图：查看更右侧内容" },
      { "zH", desc = "视图：向左查看半屏" },
      { "zL", desc = "视图：向右查看半屏" },
      { "zs", desc = "视图：光标列对齐窗口左侧" },
      { "ze", desc = "视图：光标列对齐窗口右侧" },
      -- 拼写
      { "z=", desc = "拼写：查看替换建议" },
      { "zg", desc = "拼写：加入正确词表" },
      { "zG", desc = "拼写：临时标为正确" },
      { "zw", desc = "拼写：加入错误词表" },
      { "zW", desc = "拼写：临时标为错误" },
      { "zug", desc = "拼写：撤销词表标记" },
      { "zuw", desc = "拼写：撤销词表标记" },
      { "zuG", desc = "拼写：撤销临时标记" },
      { "zuW", desc = "拼写：撤销临时标记" },
      -- Neovim 0.12 块编辑；原生 zp 已明确让给 UFO 预览
      { "zP", desc = "块编辑：向前粘贴且不补尾随空格" },
      { "zy", desc = "块编辑：复制且忽略尾随空格", mode = { "n", "v" } },

      -- ========== [ 前缀：向前导航 ==========
      { "[", group = "向前跳转" },
      -- 诊断/插件
      { "[d", desc = "上一个诊断" },
      { "[h", desc = "上一个 Git 改动" },
      { "[f", desc = "上一个函数" },
      { "[c", desc = "上一个类" },
      -- Vim 内置
      { "[(", desc = "上一个未匹配 (" },
      { "[{", desc = "上一个未匹配 {" },
      { "[[", desc = "上一个段首" },
      { "[]", desc = "上一个段尾" },
      { "[m", desc = "上一个方法开头" },
      { "[M", desc = "上一个方法结尾" },
      { "[s", desc = "上一个拼写错误" },
      { "[z", desc = "当前折叠开头" },
      { "[#", desc = "上一个未匹配 #if/#else" },
      { "[*", desc = "上一个注释开头" },
      { "[/", desc = "上一个注释开头" },
      -- Neovim 0.11 内置 unimpaired
      { "[a", desc = "上一个参数文件" },
      { "[A", desc = "第一个参数文件" },
      { "[b", desc = "上一个缓冲区" },
      { "[B", desc = "第一个缓冲区" },
      { "[l", desc = "上一个位置列表项" },
      { "[L", desc = "第一个位置列表项" },
      { "[q", desc = "上一个快速修复项" },
      { "[Q", desc = "第一个快速修复项" },
      { "[t", desc = "上一个标签" },
      { "[T", desc = "第一个标签" },
      { "[<C-L>", desc = "上一个位置列表文件" },
      { "[<C-Q>", desc = "上一个快速修复文件" },
      { "[<C-T>", desc = "上一个预览标签" },
      { "[<Space>", desc = "在上方添加空行" },
      { "[<", desc = "上一个 HTML 标签" },
      { "[%", desc = "上一个未匹配分组" },

      -- ========== ] 前缀：向后导航 ==========
      { "]", group = "向后跳转" },
      -- 诊断/插件
      { "]d", desc = "下一个诊断" },
      { "]h", desc = "下一个 Git 改动" },
      { "]f", desc = "下一个函数" },
      { "]c", desc = "下一个类" },
      -- Vim 内置
      { "])", desc = "下一个未匹配 )" },
      { "]}", desc = "下一个未匹配 }" },
      { "]]", desc = "下一个段首" },
      { "][", desc = "下一个段尾" },
      { "]m", desc = "下一个方法开头" },
      { "]M", desc = "下一个方法结尾" },
      { "]s", desc = "下一个拼写错误" },
      { "]z", desc = "当前折叠结尾" },
      { "]#", desc = "下一个未匹配 #endif" },
      { "]*", desc = "下一个注释结尾" },
      { "]/", desc = "下一个注释结尾" },
      -- Neovim 0.11 内置 unimpaired
      { "]a", desc = "下一个参数文件" },
      { "]A", desc = "最后一个参数文件" },
      { "]b", desc = "下一个缓冲区" },
      { "]B", desc = "最后一个缓冲区" },
      { "]l", desc = "下一个位置列表项" },
      { "]L", desc = "最后一个位置列表项" },
      { "]q", desc = "下一个快速修复项" },
      { "]Q", desc = "最后一个快速修复项" },
      { "]t", desc = "下一个标签" },
      { "]T", desc = "最后一个标签" },
      { "]<C-L>", desc = "下一个位置列表文件" },
      { "]<C-Q>", desc = "下一个快速修复文件" },
      { "]<C-T>", desc = "下一个预览标签" },
      { "]<Space>", desc = "在下方添加空行" },
      { "]>", desc = "下一个 HTML 标签" },
      { "]%", desc = "下一个未匹配分组" },

      -- ========== <leader> 分组 ==========
      -- 叶子快捷键直接读取 vim.keymap.set / lazy.nvim keys 中的 desc，避免维护两份说明。
      { "<leader>a", group = "AI" },
      { "<leader>b", group = "缓冲区" },
      { "<leader>c", group = "代码/CMake" },
      { "<leader>d", group = "调试" },
      { "<leader>f", group = "查找/文件" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Git 变更块" },
      { "<leader>J", group = "Java" },
      { "<leader>n", group = "笔记（Obsidian）" },
      { "<leader>P", group = "会话" },
      { "<leader>p", group = "Python/项目" },
      { "<leader>t", group = "工具/终端" },
      { "<leader>u", group = "界面/通知" },
      { "<leader>M", group = "多光标" },
      { "<leader>x", group = "诊断/结构编辑" },
    })
  end,
}
