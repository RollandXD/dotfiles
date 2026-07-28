-- ========== 上游 bug 临时补丁 ==========
-- 每个补丁标注对应版本与移除条件，升级 Neovim 后逐条复查。

-- 【补丁 1】vim._with 对失效 buffer 抛错（Neovim 0.12.3）
-- 现象：snacks.nvim picker 跳转（如 LSP 定义跳转）打开临时 buffer 后，
--   内置 runtime/filetype.lua 的 BufRead 自动命令在 vim.schedule 延迟执行，
--   期间 buffer 已被 picker 关闭，vim._with({ buf = ... }) 收到失效 id 直接报错。
-- 根因：filetype.lua 只在回调开头校验一次 nvim_buf_is_valid，
--   到第 27 行调用 vim._with 时未重新校验（TOCTOU 竞争）。
-- 移除条件：上游 runtime/filetype.lua 在 vim._with 前补上二次校验后可删。
local orig_with = vim._with
---@diagnostic disable-next-line: duplicate-set-field
vim._with = function(ctx, f)
  if ctx and ctx.buf and not vim.api.nvim_buf_is_valid(ctx.buf) then
    return
  end
  if ctx and ctx.win and not vim.api.nvim_win_is_valid(ctx.win) then
    return
  end
  return orig_with(ctx, f)
end
