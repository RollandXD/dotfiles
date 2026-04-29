-- ========== LSP 通用 on_attach ==========
-- 所有 LSP 共享的快捷键和功能（lspconfig / jdtls 等复用）

local M = {}

function M.on_attach(client, bufnr)
  -- DiffView 等插件创建的 buffer 使用非 file:// URI，clangd 不支持，需要跳过
  local uri = vim.uri_from_bufnr(bufnr)
  if not vim.startswith(uri, "file://") then
    vim.defer_fn(function()
      vim.lsp.buf_detach_client(bufnr, client.id)
    end, 0)
    return
  end

  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- 代码导航快捷键
  vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end,
    vim.tbl_extend("force", opts, { desc = "跳转到定义" }))
  vim.keymap.set("n", "gh", vim.lsp.buf.hover,
    vim.tbl_extend("force", opts, { desc = "悬浮文档" }))
  vim.keymap.set("n", "grr", function() Snacks.picker.lsp_references() end,
    vim.tbl_extend("force", opts, { desc = "查找引用" }))
  vim.keymap.set({ "n", "v" }, "gra", vim.lsp.buf.code_action,
    vim.tbl_extend("force", opts, { desc = "代码操作" }))
  vim.keymap.set("n", "grn", function()
    local ok, _ = pcall(require, "inc_rename")
    if ok then
      vim.api.nvim_feedkeys(":IncRename " .. vim.fn.expand("<cword>"), "n", false)
    else
      vim.lsp.buf.rename()
    end
  end, vim.tbl_extend("force", opts, { desc = "重命名符号（预览）" }))
  vim.keymap.set("n", "gri", function() Snacks.picker.lsp_implementations() end,
    vim.tbl_extend("force", opts, { desc = "查找实现" }))

  -- LSP 符号搜索
  vim.keymap.set("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end,
    vim.tbl_extend("force", opts, { desc = "文件符号" }))
  vim.keymap.set("n", "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end,
    vim.tbl_extend("force", opts, { desc = "工作区符号" }))

  -- 参数签名提示
  vim.keymap.set("n", "<C-g>", vim.lsp.buf.signature_help,
    vim.tbl_extend("force", opts, { desc = "显示参数提示" }))

  -- Inlay Hints（参数名、推导类型）
  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  -- 切换 inlay hints
  vim.keymap.set("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(
      not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
      { bufnr = bufnr }
    )
  end, vim.tbl_extend("force", opts, { desc = "切换内联提示" }))

  -- 光标停留时高亮当前作用域内的相同变量
  if client.server_capabilities.documentHighlightProvider then
    local hl_group = vim.api.nvim_create_augroup("UserLspHighlight_" .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = hl_group,
      buffer = bufnr,
      callback = function()
        -- 只在 LSP client 仍然存活时发请求
        if client:supports_method("textDocument/documentHighlight") then
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

return M
