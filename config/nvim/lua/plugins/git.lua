-- ========== Git 集成插件 ==========
-- 提供完整的 Git 工作流支持
-- lazygit 已由 snacks.nvim 内置管理

return {
  -- ========== GitSigns - Git 文件变化标记 ==========
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
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gd",
        function()
          local lib = require("diffview.lib")
          if next(lib.views) then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Toggle Diff 视图",
      },
      {
        "<leader>gs",
        function()
          local lib = require("diffview.lib")
          if next(lib.views) then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen --staged")
          end
        end,
        desc = "Toggle Staged Diff",
      },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "当前文件历史" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "项目历史" },
      { "<leader>gh", ":'<,'>DiffviewFileHistory<cr>", mode = "v", desc = "选中行历史" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      default_args = {
        DiffviewOpen = { "--untracked-files=no" },
      },
      hooks = {
        diff_buf_read = function(_)
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.relativenumber = false
        end,
      },
    },
  },

  -- ========== Neogit - Magit 风格的 Git 界面 ==========
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "打开 Neogit" },
      { "<leader>gC", "<cmd>Neogit commit<cr>", desc = "使用 Neogit 提交" },
    },
    opts = {
      integrations = {
        diffview = true,
      },
      kind = "tab",
    },
  },
}
