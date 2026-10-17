-- ========== 自动命令 ==========

local augroup = vim.api.nvim_create_augroup("UserCustomAutocmds", { clear = true })

-- 复制高亮由 yanky.nvim 的 highlight.on_yank 负责，这里不再重复。

-- 打开文件时跳转到上次编辑位置
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Python 项目优先使用仓库内 .venv，确保 ruff / pytest / mypy 与 uv 环境一致。
-- 必须同时监听 BufEnter：FileType 只在 buffer 首次加载时触发一次，
-- 在多个项目之间切 buffer 时环境不会跟着换，终端会继承到上一个项目的 venv。
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  group = augroup,
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "python" then
      return
    end
    require("config.python").activate_project_venv(args.buf)
  end,
})
