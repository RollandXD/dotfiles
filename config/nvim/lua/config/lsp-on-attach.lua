-- ========== LSP 通用附加逻辑 ==========
-- 通过 LspAttach 自动命令统一处理，所有 server（含 nvim-jdtls 启动的 jdtls）自动复用，
-- 不再需要在每个 server 配置里传 on_attach（那样还会覆盖 nvim-lspconfig 自带的 on_attach）。

local M = {}

-- 只提供行内补全、不提供代码智能的 server，不挂通用 LSP 键位，
-- 否则在纯文本 buffer 里 gd 等会被换成空结果的 LSP 版本
local completion_only = { copilot = true }

local function setup_buffer(client, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = bufnr, desc = desc })
  end

  -- 代码导航
  map("n", "gd", function() Snacks.picker.lsp_definitions() end, "跳转到定义")
  map("n", "gh", vim.lsp.buf.hover, "悬浮文档")
  map("n", "grr", function() Snacks.picker.lsp_references() end, "查找引用")
  map({ "n", "v" }, "gra", vim.lsp.buf.code_action, "代码操作")
  map("n", "grn", function()
    local ok = pcall(require, "inc_rename")
    if ok then
      vim.api.nvim_feedkeys(":IncRename " .. vim.fn.expand("<cword>"), "n", false)
    else
      vim.lsp.buf.rename()
    end
  end, "重命名符号（预览）")
  map("n", "gri", function() Snacks.picker.lsp_implementations() end, "查找实现")

  -- LSP 符号搜索
  map("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end, "文件符号")
  map("n", "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, "工作区符号")

  -- 参数签名提示
  map("n", "<C-g>", vim.lsp.buf.signature_help, "显示参数提示")

  -- Inlay Hints（参数名、推导类型）
  if client:supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  map("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
  end, "切换内联提示")

  -- 光标停留时高亮当前作用域内的相同变量
  if client:supports_method("textDocument/documentHighlight") then
    local hl_group = vim.api.nvim_create_augroup("UserLspHighlight_" .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = hl_group,
      buffer = bufnr,
      callback = function()
        -- 只在 LSP client 仍然存活时发请求
        if not client:is_stopped() then
          vim.lsp.buf.document_highlight()
        end
      end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      group = hl_group,
      buffer = bufnr,
      callback = function()
        -- 只清除本地高亮 extmarks，不发 LSP RPC，避免阻塞
        pcall(vim.lsp.buf.clear_references)
      end,
    })
  end
end

-- Copilot：Neovim 0.12 原生行内补全（替代 copilot.lua）。首次使用运行 :LspCopilotSignIn
local function setup_inline_completion()
  local ic = vim.lsp.inline_completion
  ic.enable(true)

  -- Tab 归 blink.cmp，Copilot 继续用 Alt 组合键
  vim.keymap.set("i", "<A-y>", function() ic.get() end, { desc = "Copilot：接受建议" })
  vim.keymap.set("i", "<A-]>", function() ic.select({ count = 1 }) end, { desc = "Copilot：下一个建议" })
  vim.keymap.set("i", "<A-[>", function() ic.select({ count = -1 }) end, { desc = "Copilot：上一个建议" })
  vim.keymap.set("n", "<leader>ai", function()
    local enabled = not ic.is_enabled()
    ic.enable(enabled)
    vim.notify("Copilot 行内建议：" .. (enabled and "已开启" or "已关闭"), vim.log.levels.INFO)
  end, { desc = "切换 Copilot 建议" })
end

function M.setup()
  setup_inline_completion()

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      -- DiffView 等插件创建的 buffer 使用非 file:// URI，clangd 等不支持，需要跳过
      if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
        vim.schedule(function()
          vim.lsp.buf_detach_client(bufnr, client.id)
        end)
        return
      end

      if not completion_only[client.name] then
        setup_buffer(client, bufnr)
      end
    end,
  })
end

return M
