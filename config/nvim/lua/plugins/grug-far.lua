return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>s",
      function()
        require("grug-far").open({
          prefills = {
            flags = "--fixed-strings",
          },
        })
      end,
      mode = { "n", "x" },
      desc = "搜索替换（字面量）",
    },
    { "<leader>S", "<cmd>GrugFar<CR>", mode = "n", desc = "搜索替换（正则）" },
  },
  config = function()
    require("grug-far").setup({})

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("grug-far-custom-keymaps", { clear = true }),
      pattern = "grug-far",
      callback = function()
        vim.keymap.set("n", "<localleader>w", function()
          local state = unpack(require("grug-far").get_instance(0):toggle_flags({ "--fixed-strings" }))
          vim.notify("grug-far: 字面量搜索" .. (state and "已开启" or "已关闭"))
        end, { buffer = true, desc = "切换字面量搜索" })
      end,
    })
  end,
}
