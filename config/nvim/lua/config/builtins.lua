-- ========== Neovim 内置能力的补充映射 ==========
-- 原先由 Comment.nvim / undotree 插件提供的功能，现由 Neovim 0.12 原生实现。

local map = vim.keymap.set

-- 在上/下方新开一行注释（原生 gc 没有 gco / gcO）
map("n", "gco", "o<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>", { desc = "在下方添加注释" })
map("n", "gcO", "O<Esc>Vcx<Esc><cmd>normal gcc<CR>fxa<BS>", { desc = "在上方添加注释" })

-- 内置撤销树（0.12 的可选插件 nvim.undotree，首次使用时才 packadd）
map("n", "<leader>tu", function()
  vim.cmd.packadd("nvim.undotree")
  vim.cmd.Undotree()
end, { desc = "撤销历史树" })
