-- ========== Git 集成插件 ==========
-- 提供完整的 Git 工作流支持

return {
  -- ========== LazyGit - TUI Git 客户端 ==========
  -- 最强大的 Git 操作界面，完全替代命令行
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (根目录)" },
      { "<leader>gG", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (当前文件)" },
      { "<leader>gc", "<cmd>LazyGitFilter<cr>", desc = "LazyGit Commits" },
    },
  },

  -- ========== GitSigns - Git 文件变化标记 ==========
  -- 在行号旁显示 git diff，提供行级 Git 操作
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- 导航
        map("n", "]h", gs.next_hunk, "下一个 Git 改动")
        map("n", "[h", gs.prev_hunk, "上一个 Git 改动")

        -- 操作
        map("n", "<leader>hs", gs.stage_hunk, "暂存改动块")
        map("n", "<leader>hr", gs.reset_hunk, "重置改动块")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "暂存选中行")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "重置选中行")

        map("n", "<leader>hS", gs.stage_buffer, "暂存整个文件")
        map("n", "<leader>hR", gs.reset_buffer, "重置整个文件")

        map("n", "<leader>hu", gs.undo_stage_hunk, "撤销暂存")

        map("n", "<leader>hp", gs.preview_hunk, "预览改动")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "查看行 Blame")
        map("n", "<leader>hB", gs.toggle_current_line_blame, "切换行 Blame 显示")

        map("n", "<leader>hd", gs.diffthis, "Diff 当前文件")
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, "Diff 当前文件 (HEAD)")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "选择改动块")
      end,
    },
  },

  -- ========== Diffview - 强大的 Diff 查看器 ==========
  -- 提供完整的 diff 和文件历史查看功能
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "打开 Diff 视图" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "关闭 Diff 视图" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "当前文件历史" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "项目历史" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
    },
  },

  -- ========== Neogit - Magit 风格的 Git 界面 ==========
  -- 类似 Emacs Magit 的 Git 界面（可选，如果你更喜欢 LazyGit 可以不用）
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gC", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
    },
    opts = {
      integrations = {
        telescope = true,
        diffview = true,
      },
      -- 使用浮动窗口而不是分屏
      kind = "tab",
    },
  },
}
