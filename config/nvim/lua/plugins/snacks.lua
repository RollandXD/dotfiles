-- ========== snacks.nvim - 多功能集合 ==========
-- 替代 neoscroll、telescope、neo-tree、toggleterm、lazygit.nvim
-- 提供 dashboard、通知、缩进线、dim、zen 等

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- ===== 启动页 =====
    dashboard = {
      enabled = true,
      preset = {
        header = [[
 ██████╗  ██████╗ ██╗     ██╗      █████╗ ███╗   ██╗██████╗
 ██╔══██╗██╔═══██╗██║     ██║     ██╔══██╗████╗  ██║██╔══██╗
 ██████╔╝██║   ██║██║     ██║     ███████║██╔██╗ ██║██║  ██║
 ██╔══██╗██║   ██║██║     ██║     ██╔══██║██║╚██╗██║██║  ██║
 ██║  ██║╚██████╔╝███████╗███████╗██║  ██║██║ ╚████║██████╔╝
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝]],
        keys = {
          { icon = " ", key = "f", desc = "搜索文件", action = function() Snacks.picker.files() end },
          { icon = " ", key = "r", desc = "最近文件", action = function() Snacks.picker.recent() end },
          { icon = " ", key = "g", desc = "搜索文本", action = function() Snacks.picker.grep() end },
          { icon = " ", key = "s", desc = "恢复会话", action = function() require("persistence").load() end },
          { icon = "󰒲 ", key = "l", desc = "插件管理", action = ":Lazy" },
          { icon = " ", key = "m", desc = "Mason", action = ":Mason" },
          { icon = " ", key = "q", desc = "退出", action = ":qa" },
        },
      },
    },

    -- ===== 模糊搜索（替代 Telescope） =====
    picker = {
      enabled = true,
      -- 布局配置
      layout = {
        preset = "default",
      },
      -- 文件忽略模式
      sources = {
        files = {
          hidden = true,
        },
      },
      -- 键位映射
      win = {
        input = {
          keys = {
            ["<C-j>"] = { "list_down", mode = { "i", "n" } },
            ["<C-k>"] = { "list_up", mode = { "i", "n" } },
            ["<Esc>"] = "close",
            ["<C-c>"] = "close",
          },
        },
      },
    },

    -- ===== 文件浏览器（替代 neo-tree） =====
    explorer = {
      enabled = true,
    },

    -- ===== 终端管理（替代 toggleterm） =====
    terminal = {
      enabled = true,
      win = {
        border = "rounded",
        wo = { winbar = "" },
        keys = {
          float_close = { "<C-q>", "hide", mode = { "n", "t" }, desc = "关闭浮动终端" },
        },
      },
    },

    -- ===== 通知系统 =====
    notifier = {
      enabled = true,
      timeout = 3000,
    },

    -- ===== 缩进线 =====
    indent = {
      enabled = true,
      animate = { enabled = true },
    },

    -- ===== 平滑滚动（替代 neoscroll） =====
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 15, total = 150 },
        easing = "linear",
      },
    },

    -- ===== 非活动代码变暗 =====
    dim = { enabled = true },

    -- ===== 禅模式 =====
    zen = { enabled = true },

    -- ===== 美化输入框 =====
    input = { enabled = true },

    -- ===== 美化 scope =====
    scope = { enabled = true },

    -- ===== lazygit 集成 =====
    lazygit = { enabled = true },

    -- ===== 大文件优化 =====
    bigfile = { enabled = true },

    -- ===== 快速渲染文件（在插件加载完成前就画出内容，加快 nvim foo.cpp）=====
    quickfile = { enabled = true },

    -- ===== 状态列（整合行号 / 折叠 / gitsigns 标记）=====
    -- 若不习惯新的行号列外观，把这项改回 false 即可
    statuscolumn = { enabled = true },

    -- ===== 在浏览器打开当前行对应的 GitHub 链接 =====
    gitbrowse = { enabled = true },

    -- ===== 临时草稿缓冲区 =====
    scratch = { enabled = true },

    -- ===== 开关集合（供 <leader>u 系列使用）=====
    toggle = { enabled = true },
  },
  keys = {
    -- 文件搜索（替代 Telescope）
    { "<leader>ff", function() Snacks.picker.files() end, desc = "搜索文件" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "全局搜索文本" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "缓冲区列表" },
    { "<leader>fh", function() Snacks.picker.command_history() end, desc = "命令历史" },
    { "<leader>fH", function() Snacks.picker.help() end, desc = "搜索帮助文档" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "最近文件" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "快捷键列表" },
    -- 文件浏览器（替代 neo-tree）
    { "<leader>e", function() Snacks.explorer() end, desc = "文件树" },
    -- 终端（替代 toggleterm）
    { "<C-\\>", function() Snacks.terminal(nil, { win = { position = "float" }, count = 1 }) end, desc = "切换终端" },
    { "<leader>tf", function() Snacks.terminal(nil, { win = { position = "float" }, count = 2 }) end, desc = "浮动终端" },
    { "<leader>tv", function() Snacks.terminal(nil, { win = { position = "right", width = 0.4 }, count = 3 }) end, desc = "垂直终端" },
    -- Git（替代 lazygit.nvim）
    { "<leader>gg", function() Snacks.lazygit() end, desc = "打开 LazyGit" },
    { "<leader>gG", function() Snacks.lazygit.log_file() end, desc = "LazyGit 当前文件历史" },
    { "<leader>gc", function() Snacks.lazygit.log() end, desc = "查看 Git 提交记录" },
    -- 禅模式 / Dim / 通知
    { "<leader>tz", function() Snacks.zen() end, desc = "禅模式（再按关闭）" },
    {
      "<leader>td",
      function()
        if Snacks.dim.enabled then
          Snacks.dim.disable()
        else
          Snacks.dim.enable()
        end
      end,
      desc = "Dim 聚焦模式（切换）",
    },
    { "<leader>un", function() Snacks.notifier.show_history() end, desc = "通知历史" },
    -- 在浏览器打开当前行的 GitHub 链接（复用 lazy.lua 里配置的 open-uri.sh）
    { "<leader>gb", function() Snacks.gitbrowse() end, mode = { "n", "v" }, desc = "在浏览器打开当前行" },
    -- 草稿缓冲区
    { "<leader>.", function() Snacks.scratch() end, desc = "草稿缓冲区" },
    { "<leader>,", function() Snacks.scratch.select() end, desc = "选择草稿" },
    -- UI 开关（<leader>u 组）
    { "<leader>us", function() Snacks.toggle.option("spell"):toggle() end, desc = "拼写检查" },
    { "<leader>uw", function() Snacks.toggle.option("wrap"):toggle() end, desc = "自动换行" },
    { "<leader>ul", function() Snacks.toggle.option("relativenumber"):toggle() end, desc = "相对行号" },
    { "<leader>ud", function() Snacks.toggle.diagnostics():toggle() end, desc = "诊断显示" },
    { "<leader>uc", function() Snacks.toggle.option("conceallevel", { off = 0, on = 2 }):toggle() end, desc = "Conceal 显示" },
  },
}
