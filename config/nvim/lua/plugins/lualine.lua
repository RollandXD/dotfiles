return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "SmiteshP/nvim-navic",
  },
  config = function()
    local ui = require("config.ui")
    local lualine = require("lualine")
    local mode_names = {
      NORMAL = "普通",
      INSERT = "插入",
      VISUAL = "可视",
      ["V-LINE"] = "可视行",
      ["V-BLOCK"] = "可视块",
      REPLACE = "替换",
      COMMAND = "命令",
      TERMINAL = "终端",
      ["O-PENDING"] = "操作",
      SELECT = "选择",
      ["S-LINE"] = "选择行",
      ["S-BLOCK"] = "选择块",
      CONFIRM = "确认",
      MORE = "更多",
    }

    local function sync_laststatus()
      local target = ui.editor_window_count(vim.api.nvim_get_current_tabpage()) > 1 and 2 or 3

      if vim.o.laststatus == target then
        return
      end

      vim.o.laststatus = target
      pcall(lualine.refresh, { place = { "statusline" } })
    end

    lualine.setup({
      options = {
        theme = "catppuccin-nvim",
        globalstatus = false,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "snacks_picker_input", "neominimap" },
          winbar = {},
        },
        ignore_focus = ui.special_filetype_list(),
        refresh = {
          statusline = 500,
          tabline = 1000,
          winbar = 500,
        },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(mode)
              return " " .. (mode_names[mode] or mode)
            end,
          },
        },
        lualine_b = {
          {
            "filename",
            path = 0,
            shorting_target = 32,
            newfile_status = true,
            symbols = {
              modified = " [+]",
              readonly = " [锁]",
              unnamed = "[无名]",
              newfile = " [新]",
            },
          },
        },
        lualine_c = {
          { "branch", icon = "" },
          {
            "diff",
            symbols = {
              added = "+",
              modified = "~",
              removed = "-",
            },
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = {
              error = "E:",
              warn = "W:",
              info = "I:",
              hint = "H:",
            },
          },
          -- Grapple 标签显示
          {
            function()
              local ok, grapple_line = pcall(require, "grapple-line")
              if ok then
                return grapple_line.lualine()
              end
              return ""
            end,
          },
        },
        lualine_x = {
          -- 宏录制指示器
          {
            function()
              local reg = vim.fn.reg_recording()
              if reg ~= "" then
                return "录制 @" .. reg
              end
              return ""
            end,
            color = { fg = "#f38ba8" }, -- 红色醒目提示
          },
          {
            function()
              return ui.lsp_client_label(vim.api.nvim_get_current_buf())
            end,
            cond = function()
              return #vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }) > 0
            end,
          },
          { "filetype", colored = true, icon_only = false },
        },
        lualine_y = {
          "encoding",
          "fileformat",
          "progress",
        },
        lualine_z = {
          "location",
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {
          {
            "filename",
            path = 0,
            symbols = {
              modified = " [+]",
              readonly = " [锁]",
              unnamed = "[无名]",
              newfile = " [新]",
            },
          },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      winbar = {
        lualine_c = {
          {
            function()
              return require("nvim-navic").get_location()
            end,
            cond = function()
              return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
            end,
          },
        },
      },
      inactive_winbar = {
        lualine_c = {
          {
            "filename",
            path = 1,
            symbols = {
              modified = " [+]",
              readonly = " [锁]",
            },
          },
        },
      },
      extensions = {
        "lazy",
        "mason",
        "aerial",
        "trouble",
      },
    })

    local group = vim.api.nvim_create_augroup("UserLualineStatus", { clear = true })
    vim.api.nvim_create_autocmd({
      "BufWinEnter",
      "TabEnter",
      "VimEnter",
      "VimResized",
      "WinClosed",
      "WinEnter",
      "WinNew",
    }, {
      group = group,
      callback = function()
        vim.schedule(sync_laststatus)
      end,
    })

    sync_laststatus()
  end,
}
