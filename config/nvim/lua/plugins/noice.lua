-- ========== noice.nvim - 现代化 UI ==========
-- 重做命令行、消息、通知系统

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",       -- 你已有
    "folke/snacks.nvim",          -- 通知路由到 snacks.notifier
  },
  opts = {
    -- 命令行浮动弹窗
    cmdline = {
      enabled = true,
      view = "cmdline_popup",     -- 浮动弹窗样式
    },

    -- 消息路由
    messages = {
      enabled = true,
      view_search = "virtualtext", -- 搜索计数显示为虚拟文本
    },

    -- LSP 相关
    lsp = {
      -- 用 noice 的 UI 替代默认 hover/signature
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
      -- LSP 进度交给 fidget.nvim，避免重复显示
      progress = { enabled = false },
    },

    -- 预设
    presets = {
      bottom_search = false,       -- 搜索不在底部（用浮动弹窗）
      command_palette = true,      -- 命令行居中
      long_message_to_split = true, -- 长消息自动进 split
      lsp_doc_border = true,       -- LSP 文档有边框
    },

    -- 路由规则：某些消息静默不显示
    routes = {
      -- 过滤掉 "written" 消息（保存文件时的提示）
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
    },
  },
}
