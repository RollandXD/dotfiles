return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
  keys = {
    { "<leader>fe", mode = { "n", "v" }, "<cmd>Yazi<cr>",        desc = "打开 yazi（当前文件）" },
    { "<leader>cw",                       "<cmd>Yazi cwd<cr>",    desc = "打开 yazi（工作目录）" },
    { "<C-Up>",                           "<cmd>Yazi toggle<cr>", desc = "恢复上次 yazi 会话" },
  },
  opts = {
    open_for_directories = true,
    open_multiple_tabs = false,
    change_neovim_cwd_on_close = false,
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",
    highlight_hovered_buffers_in_same_directory = true,
    keymaps = {
      show_help = "<F1>",
    },
    integrations = {
      grep_in_directory = "snacks.picker",
      replace_in_directory = function(directory)
        require("grug-far").open({
          prefills = { paths = directory:make_relative(vim.uv.cwd()) },
        })
      end,
      bufdelete_implementation = "bundled-snacks",
    },
  },
  init = function()
    vim.g.loaded_netrwPlugin = 1

    -- niri 的 NIRI_SOCKET 经 tmux 等中间层时容易丢失，nvim 内置终端里的 yazi
    -- 因此拿不到它，会误判“合成器不支持 ueberzug”而回退到 Chafa——表现为图片
    -- 每个字符格只有一个色块，非常糊。这里在缺失时按运行时目录主动探测补回，
    -- 让 nvim 内的 yazi 走 Wayland + ueberzugpp 的真实图片预览。
    if (vim.env.NIRI_SOCKET or "") == "" then
      local runtime = vim.env.XDG_RUNTIME_DIR or ("/run/user/" .. vim.uv.getuid())
      local socks = vim.fn.glob(runtime .. "/niri.*.sock", false, true)
      if #socks > 0 then
        vim.env.NIRI_SOCKET = socks[1]
      end
    end
  end,
}
