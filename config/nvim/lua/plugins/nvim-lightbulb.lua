return {
  "kosayoda/nvim-lightbulb",
  event = "LspAttach",
  config = function()
    require("nvim-lightbulb").setup({
      -- 对 C/C++ 禁用：clangd code action 请求开销大，容易卡顿
      ignore = {
        ft = { "c", "cpp", "objc", "objcpp" },
      },

      -- 只观察与光标位置真正相关的操作。
      -- 默认 nil 表示匹配所有 kind，而 ruff 会在【每一行】都返回
      -- source.fixAll.ruff 和 source.organizeImports.ruff——这两个是作用于
      -- 整个文件的 source 级操作，与光标无关，导致 Python 文件里处处亮灯。
      -- 该值会作为 LSP 请求的 context.only 下发，由服务端按 kind 层级前缀过滤。
      action_kinds = { "quickfix", "refactor" },
      sign = {
        enabled = true,
        text = "󰌵", -- 灯泡图标，占一列；原为文字 "CA"（两列，会挤压 git 标记与断点）
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
