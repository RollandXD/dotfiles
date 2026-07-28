-- ========== nvim-lint - 异步 Linting ==========
-- 代码规范检查（与 conform 的格式化互补）

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
  config = function()
    local lint = require("lint")

    -- 按文件类型配置 Linter
    lint.linters_by_ft = {
      c = { "cppcheck" },
      cpp = { "cppcheck" },
      -- Python 不在这里：ruff 已作为 LSP 启用（见 lspconfig.lua），
      -- 由它提供诊断和 code action。若这里再挂一次，同一条警告会出现两份。
      -- markdown = { "markdownlint" },
      -- lua = { "luacheck" },
    }

    -- 自动触发 Lint
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("UserNvimLint", { clear = true }),
      callback = function()
        -- 只在有对应 linter 时触发
        local ft = vim.bo.filetype
        if lint.linters_by_ft[ft] then
          lint.try_lint()
        end
      end,
    })
  end,
}
