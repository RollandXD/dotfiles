-- ========== 自动命令 ==========

local augroup = vim.api.nvim_create_augroup("UserCustomAutocmds", { clear = true })

local function setup_lazy_keys(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end

  local opts = { buffer = buf, silent = true, nowait = true }

  -- 在 Lazy 面板中保持 K 为向上移动
  vim.keymap.set("n", "K", "5k", vim.tbl_extend("force", opts, { desc = "向上移动 5 行（Lazy 窗口）" }))

  -- gK 保留 hover 行为（容错处理，避免报错弹栈）
  vim.keymap.set("n", "gK", function()
    local ok, view = pcall(require, "lazy.view")
    if not (ok and view and view.view and view.view.hover) then
      vim.notify("Lazy hover 暂不可用", vim.log.levels.WARN)
      return
    end

    local hover_ok, err = pcall(function()
      view.view:hover()
    end)

    if not hover_ok then
      local msg = "打开链接失败：当前环境缺少可用的浏览器启动命令（建议安装 wslview 或 xdg-open）"
      if type(err) == "string" and err ~= "" then
        msg = msg .. "\n" .. err
      end
      vim.notify(msg, vim.log.levels.WARN)
    end
  end, vim.tbl_extend("force", opts, { desc = "Lazy 悬浮信息" }))
end

local function apply_lazy_view_keys()
  local ok, view = pcall(require, "lazy.view")
  if not (ok and view and view.view and view.view.buf) then
    return
  end

  -- 延后一个事件循环，确保覆盖掉 lazy.nvim 自己的默认键位
  vim.schedule(function()
    setup_lazy_keys(view.view.buf)
  end)
end

-- Lazy 窗口打开/刷新时都强制应用一次
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = { "LazyFloatResized", "LazyRender" },
  callback = function()
    apply_lazy_view_keys()
  end,
})

-- 高亮复制的文本（闪烁效果）
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

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
