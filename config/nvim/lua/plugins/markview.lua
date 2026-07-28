return {
  "OXY2DEV/markview.nvim",
  lazy = false,      -- 官方建议不要 lazy load 
  -- ft = "markdown" -- 如果真的需要可以开启这行并注释上一行

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  },
  opts = {
    -- markview 默认已经配置好了绝佳的效果
    -- 如果需要自定义样式，可以在这里覆写
  },
  config = function(_, opts)
    require("markview").setup(opts)

    local function render_markview()
      local ok, actions = pcall(require, "markview.actions")
      if ok then
        local state_ok, state = pcall(require, "markview.state")
        if state_ok and not state.buf_attached(0) then
          actions.attach(0)
        end
        actions.enable(0)
        actions.render(0)
      end
    end

    local function notify_preview_state(enabled)
      local state = enabled and "开启" or "关闭"
      local message = string.format(
        "Markdown 表格预览：%s wrap=%s linebreak=%s sidescrolloff=%d",
        state,
        tostring(vim.wo.wrap),
        tostring(vim.wo.linebreak),
        vim.wo.sidescrolloff
      )

      vim.notify(message, vim.log.levels.INFO)
    end

    local function restore_writing_options(previous)
      if previous and previous.wrap == true then
        vim.wo.wrap = previous.wrap
        vim.wo.linebreak = previous.linebreak
        vim.wo.sidescrolloff = previous.sidescrolloff
      else
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.sidescrolloff = 0
      end
    end

    local function set_table_preview(enabled)
      if enabled then
        if vim.w.markdown_table_preview_active ~= true then
          vim.w.markdown_table_preview_options = {
            wrap = vim.wo.wrap,
            linebreak = vim.wo.linebreak,
            sidescrolloff = vim.wo.sidescrolloff,
          }
        end

        vim.w.markdown_table_preview_active = true
        vim.wo.wrap = false
        vim.wo.linebreak = false
        vim.wo.sidescrolloff = 8
      else
        restore_writing_options(vim.w.markdown_table_preview_options)
        vim.w.markdown_table_preview_options = nil
        vim.w.markdown_table_preview_active = false
      end

      render_markview()
      notify_preview_state(enabled)
      vim.cmd.redraw()
    end

    vim.api.nvim_create_user_command("MarkdownTablePreviewToggle", function()
      if vim.tbl_contains({ "markdown", "quarto", "rmd" }, vim.bo.filetype) == false then
        vim.notify("Markdown 表格预览只在 Markdown / Quarto / R Markdown 文件中使用", vim.log.levels.WARN)
        return
      end

      local preview_is_active = vim.w.markdown_table_preview_active == true
        or (vim.wo.wrap == false and vim.wo.linebreak == false)

      set_table_preview(not preview_is_active)
    end, { desc = "切换 Markdown 表格预览模式", force = true })

    local markdown_filetypes = {
      markdown = true,
      quarto = true,
      rmd = true,
    }

    local function set_markdown_keymap(buf)
      vim.keymap.set("n", "<localleader>p", "<cmd>MarkdownTablePreviewToggle<cr>", {
        buffer = buf,
        desc = "切换 Markdown 表格预览",
        silent = true,
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("UserMarkviewMarkdownKeys", { clear = true }),
      pattern = vim.tbl_keys(markdown_filetypes),
      callback = function(args)
        set_markdown_keymap(args.buf)
      end,
    })

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and markdown_filetypes[vim.bo[buf].filetype] then
        set_markdown_keymap(buf)
      end
    end
  end,
}
