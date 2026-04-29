-- ========== copilot.lua - GitHub Copilot AI 补全 ==========
-- 灰色幽灵文本自动补全，需要 GitHub Copilot 订阅
-- 首次使用运行 :Copilot auth 登录 GitHub 授权

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      -- 建议设置
      suggestion = {
        enabled = true,
        auto_trigger = true, -- 自动触发建议（不需要手动按键）
        debounce = 200,      -- 输入 200ms 后触发（减少网络请求频率）
        keymap = {
          -- Tab 已被 blink.cmp 占用，用 Alt 键组合
          accept = "<A-y>",         -- Alt-y 接受整行建议
          accept_word = "<A-w>",    -- Alt-w 只接受一个词
          accept_line = "<A-l>",    -- Alt-l 接受到行尾（避免与 Alt-j 行移动冲突）
          next = "<A-]>",           -- Alt-] 下一个建议
          prev = "<A-[>",           -- Alt-[ 上一个建议
          dismiss = "<A-e>",        -- Alt-e 忽略建议
        },
      },
      -- 不接入 nvim-cmp 面板（独立显示为幽灵文本）
      panel = { enabled = false },
      -- 对所有文件类型启用
      filetypes = {
        ["*"] = true,
      },
    })

    -- 切换 Copilot 开关
    vim.keymap.set("n", "<leader>tc", function()
      require("copilot.suggestion").toggle_auto_trigger()
      local enabled = vim.b.copilot_suggestion_auto_trigger
      -- 如果 toggle 后值为 nil 表示全局状态，默认认为开启
      if enabled == nil then enabled = true end
      vim.notify("Copilot: " .. (enabled and "已开启" or "已关闭"), vim.log.levels.INFO)
    end, { desc = "Copilot 开关" })
  end,
}
