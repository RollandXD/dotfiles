return {
  "Badhi/nvim-treesitter-cpp-tools",
  ft = { "cpp" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = function()
    local function write_to_cpp_current_window(output, _)
      local config = require("nt-cpp-tools.config").get_cfg()
      local util = require("nt-cpp-tools.util")
      local source_file = vim.fn.expand("%:r") .. "." .. config.source_extension

      vim.cmd("keepalt edit " .. vim.fn.fnameescape(source_file))
      local last_line = vim.api.nvim_buf_line_count(0)
      util.add_text_edit(output, last_line, 0)
    end

    return {
      preview = {
        quit = "q",
        accept = "<tab>",
      },
      header_extension = "h",
      source_extension = "cpp",
      custom_define_class_function_commands = {
        TSCppImplWrite = {
          output_handle = write_to_cpp_current_window,
        },
      },
    }
  end,
  config = true,
}
