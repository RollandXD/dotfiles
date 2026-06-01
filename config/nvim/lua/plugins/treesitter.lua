return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",  -- 安装后自动更新解析器
  lazy = false,          -- 新版 nvim-treesitter 官方建议不要 lazy-load

  config = function()
    local treesitter = require("nvim-treesitter")
    local parsers = {
      "lua",
      "vim",
      "vimdoc",
      "c",
      "cpp",
      "cmake",
      "python",
      "markdown",
      "markdown_inline",
      "yaml",
      "toml",
    }

    treesitter.setup()
    treesitter.install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
      pattern = { "lua", "vim", "help", "c", "cpp", "cmake", "python", "markdown", "yaml", "toml" },
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
