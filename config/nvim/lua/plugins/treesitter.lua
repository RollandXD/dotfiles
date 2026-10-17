return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",  -- 安装后自动更新解析器
  lazy = false,          -- 新版 nvim-treesitter 官方建议不要 lazy-load

  config = function()
    local treesitter = require("nvim-treesitter")
    local parsers = {
      "bash",
      "c",
      "cmake",
      "cpp",
      "diff",
      "gitcommit",
      "html", -- markview / snacks.image 渲染内嵌 HTML
      "java",
      "json",
      "latex", -- markview 渲染数学公式
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      "sql",
      "toml",
      "vim",
      "vimdoc",
      "yaml",
    }

    treesitter.setup()
    treesitter.install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
      pattern = {
        "bash", "c", "cmake", "cpp", "diff", "gitcommit", "help", "java", "json", "jsonc",
        "lua", "markdown", "python", "sh", "sql", "toml", "vim", "yaml",
      },
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
