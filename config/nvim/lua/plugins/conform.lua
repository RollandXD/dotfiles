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

  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- 仅对 C/C++ 文件保存时自动格式化
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
      python = { "ruff_format", "ruff_organize" },
    },
  },
}
