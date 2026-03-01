return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",  -- 安装后自动更新解析器
  event = { "BufReadPost", "BufNewFile" },  -- 打开文件时加载

  config = function()
    require("nvim-treesitter").setup({
      -- 自动安装的语言解析器
      ensure_installed = { "lua", "vim", "vimdoc" },  -- 基础必装

      -- 自动安装（打开文件时自动安装对应语言）
      auto_install = true,

      -- 语法高亮
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      -- 代码缩进
      indent = { enable = true },

      -- 增量选择（使用不冲突的快捷键）
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",       -- 开始选择（改为 gnn，避免占用回车键）
          node_incremental = "grn",     -- 扩大选择
          node_decremental = "grm",     -- 缩小选择
        },
      },
    })
  end,
}
