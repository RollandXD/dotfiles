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
      -- 后续可以添加更多：
      python = { "ruff" },
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
