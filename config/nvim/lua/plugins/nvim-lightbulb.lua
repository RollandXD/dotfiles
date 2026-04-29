return {
  "kosayoda/nvim-lightbulb",
  event = "LspAttach",
  config = function()
    require("nvim-lightbulb").setup({
      -- 对 C/C++ 禁用：clangd code action 请求开销大，容易卡顿
      ignore = {
        ft = { "c", "cpp", "objc", "objcpp" },
      },
      sign = {
        enabled = true,
        text = "CA",
      },
      virtual_text = {
        enabled = false,
      },
      float = {
        enabled = false,
      },
      autocmd = {
        enabled = true,
        updatetime = 200,
      },
    })
  end,
}
