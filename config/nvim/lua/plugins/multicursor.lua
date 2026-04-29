-- ========== multicursor.nvim - 多光标编辑 ==========
-- 替代 vim-visual-multi，原生支持 Lua 生态
-- 通过 on_key 钩子捕获按键，兼容已有插件和 keymap

return {
  "jake-stewart/multicursor.nvim",
  event = "VeryLazy",
  config = function()
    local mc = require("multicursor-nvim")

    mc.setup()

    local map = vim.keymap.set

    -- ========== 添加/删除光标 ==========

    -- 添加光标到下一个匹配词（类似 VS Code 的 Ctrl-D）
    map({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end,
      { desc = "多光标: 添加下一个匹配" })

    -- 添加光标到上一个匹配词
    map({ "n", "x" }, "<C-p>", function() mc.matchAddCursor(-1) end,
      { desc = "多光标: 添加上一个匹配" })

    -- 跳过当前匹配，移到下一个
    map({ "n", "x" }, "<C-s>", function() mc.matchSkipCursor(1) end,
      { desc = "多光标: 跳过当前，选下一个" })

    -- 选中所有匹配词（全选）
    map({ "n", "x" }, "<leader>Mn", function() mc.matchAllAddCursors() end,
      { desc = "多光标: 选中所有匹配" })

    -- ========== 方向添加光标 ==========

    -- 向上/下添加光标（按列）
    map({ "n", "x" }, "<leader>Mk", function() mc.lineAddCursor(-1) end,
      { desc = "多光标: 向上添加光标" })
    map({ "n", "x" }, "<leader>Mj", function() mc.lineAddCursor(1) end,
      { desc = "多光标: 向下添加光标" })

    -- ========== 光标管理 ==========

    -- 切换光标（在当前位置放置/移除一个光标）
    map({ "n", "x" }, "<C-q>", mc.toggleCursor,
      { desc = "多光标: 切换光标位置" })

    -- Escape 智能处理：清除多光标 → 取消搜索高亮 → 普通 Esc
    -- 同时绑定 <Esc> 和 <C-[>，因为 noremap 下 <C-[> 不会触发 <Esc> 的映射
    local function smart_esc()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        vim.cmd("nohlsearch")
      end
    end
    map("n", "<Esc>", smart_esc, { desc = "清除多光标/搜索高亮" })
    map("n", "<C-[>", smart_esc, { desc = "清除多光标/搜索高亮" })

    -- ========== 多光标模式下的操作 ==========

    -- 对齐所有光标列
    map("n", "<leader>Ma", mc.alignCursors,
      { desc = "多光标: 对齐光标列" })

    -- 在每个光标位置拆分粘贴（每行分别粘贴不同内容）
    map("x", "<leader>Ms", mc.splitCursors,
      { desc = "多光标: 拆分选区为光标" })

    -- 在可视模式下将选区拆成每行一个光标
    map("x", "I", mc.insertVisual,
      { desc = "多光标: 选区每行行首插入" })
    map("x", "A", mc.appendVisual,
      { desc = "多光标: 选区每行行尾追加" })

    -- 旋转光标内容（多光标选区内容轮转）
    map("x", "<leader>Mt", function() mc.transposeCursors(1) end,
      { desc = "多光标: 向下轮转内容" })
    map("x", "<leader>MT", function() mc.transposeCursors(-1) end,
      { desc = "多光标: 向上轮转内容" })

    -- ========== 自定义高亮 ==========
    -- 基于 Catppuccin Frappe 调色板的醒目配色
    local hl = vim.api.nvim_set_hl

    -- 活跃光标：Mauve 反色，非常醒目
    hl(0, "MultiCursorCursor", { fg = "#303446", bg = "#ca9ee6", bold = true })

    -- 光标选区：Blue 半透明底色
    hl(0, "MultiCursorVisual", { bg = "#414559" })

    -- 光标所在行标记列
    hl(0, "MultiCursorSign", { fg = "#ca9ee6", bold = true })

    -- ⭐ 下一个匹配词预览：Peach 底色 + 下划线，一眼就能看到
    hl(0, "MultiCursorMatchPreview", {
      fg = "#ef9f76",
      bg = "#3e3548",
      underline = true,
      bold = true,
    })

    -- 禁用状态（按了 <C-q> 后暂停的光标）：灰暗色调
    hl(0, "MultiCursorDisabledCursor", { fg = "#303446", bg = "#737994" })
    hl(0, "MultiCursorDisabledVisual", { bg = "#363a4f" })
    hl(0, "MultiCursorDisabledSign", { fg = "#737994" })
  end,
}
