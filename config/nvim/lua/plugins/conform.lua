return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({
          async = false,
          timeout_ms = 1000,
          lsp_format = "fallback",
        })
      end,
      desc = "格式化代码",
    },
  },

  opts = function()
    local python_tools = require("config.python")

    return {
      notify_on_error = true,
      format_on_save = function(bufnr)
      -- 仅对 C/C++ 与 Python 文件保存时自动格式化
      local ft = vim.bo[bufnr].filetype
      if vim.tbl_contains({ "c", "cpp", "objc", "objcpp", "python" }, ft) then
        return { timeout_ms = 500, lsp_format = "fallback" }
      end
      end,
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        objc = { "clang-format" },
        objcpp = { "clang-format" },
        json = { "prettier" },
        jsonc = { "prettier" },
        -- 先整理 import 再排版；organize imports 的内置名是 ruff_organize_imports，
        -- 写成 ruff_organize 会解析到一个没有 args 的空 formatter，静默失效
        python = { "ruff_organize_imports", "ruff_format" },
      },
      formatters = {
        ruff_format = {
          command = function()
            return python_tools.executable("ruff")
          end,
          env = function()
            return python_tools.env()
          end,
        },
        ruff_organize_imports = {
          command = function()
            return python_tools.executable("ruff")
          end,
          env = function()
            return python_tools.env()
          end,
        },
      },
    }
  end,
}
