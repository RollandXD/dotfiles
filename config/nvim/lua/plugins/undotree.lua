-- ========== undotree - 可视化撤销历史 ==========
-- 用树形结构浏览和恢复撤销分支

return {
  "mbbill/undotree",
  keys = {
    { "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "撤销历史树" },
  },
  config = function()
    -- 窗口在右侧打开
    vim.g.undotree_WindowLayout = 3
    -- 窗口宽度
    vim.g.undotree_SplitWidth = 35
    -- 打开时自动聚焦到 undotree 窗口
    vim.g.undotree_SetFocusWhenToggle = 1
    -- 短时间戳
    vim.g.undotree_ShortIndicators = 1
  end,
}
