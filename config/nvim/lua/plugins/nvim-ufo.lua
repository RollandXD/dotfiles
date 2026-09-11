-- ========== nvim-ufo - 更好的折叠体验 ==========
-- 折叠行末尾预览内容；优先使用 Treesitter，失败时回退到 indent

return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = "BufReadPost",
  keys = {
    { "zR", function() require("ufo").openAllFolds() end, desc = "折叠：展开全部（保持层级）" },
    { "zM", function() require("ufo").closeAllFolds() end, desc = "折叠：关闭全部（保持层级）" },
    {
      "zr",
      function() require("ufo").openFoldsExceptKinds() end,
      desc = "折叠：展开全部（小写快捷键）",
    },
    {
      "zm",
      function() require("ufo").closeFoldsWith() end,
      desc = "折叠：关闭全部（小写快捷键）",
    },
    {
      "zp",
      function() require("ufo").peekFoldedLinesUnderCursor() end,
      desc = "折叠：预览当前关闭折叠",
    },
  },
  opts = {
    -- 优先用 Treesitter 折叠，回退到缩进
    provider_selector = function(_, _, _)
      return { "treesitter", "indent" }
    end,
    -- 折叠行末尾的预览文本
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = ("  … 共 %d 行"):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,
  },
}
