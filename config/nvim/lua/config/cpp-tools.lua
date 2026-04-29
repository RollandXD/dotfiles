-- ========== C++ 开发辅助命令 ==========

-- :CreateClass ClassName [目录路径]
-- 在指定目录（默认当前文件所在目录）创建 ClassName.h 和 ClassName.cpp
-- 自动生成 #pragma once、#include、命名空间等模板

local function create_class(opts)
  local args = vim.split(opts.args, "%s+", { trimempty = true })
  if #args == 0 then
    vim.notify("用法: :CreateClass 类名 [目录路径]", vim.log.levels.ERROR)
    return
  end

  local class_name = args[1]
  local target_dir

  if #args >= 2 then
    -- 用户指定了目录
    target_dir = vim.fn.fnamemodify(args[2], ":p")
  else
    -- 默认：当前文件所在目录，没有文件时用 cwd
    local current_file = vim.fn.expand("%:p:h")
    target_dir = current_file ~= "" and current_file or vim.fn.getcwd()
  end

  -- 确保目录存在
  vim.fn.mkdir(target_dir, "p")

  local h_path = vim.fs.joinpath(target_dir, class_name .. ".h")
  local cpp_path = vim.fs.joinpath(target_dir, class_name .. ".cpp")

  -- 检查文件是否已存在
  local existing = {}
  if vim.fn.filereadable(h_path) == 1 then
    table.insert(existing, class_name .. ".h")
  end
  if vim.fn.filereadable(cpp_path) == 1 then
    table.insert(existing, class_name .. ".cpp")
  end

  if #existing > 0 and not opts.bang then
    vim.notify(
      "文件已存在: " .. table.concat(existing, ", ") .. "\n使用 :CreateClass! 强制覆盖",
      vim.log.levels.WARN
    )
    return
  end

  -- 生成 .h 文件内容
  local h_content = {
    "#pragma once",
    "",
    "class " .. class_name .. " {",
    "public:",
    "    " .. class_name .. "();",
    "    ~" .. class_name .. "();",
    "",
    "private:",
    "",
    "};",
    "",
  }

  -- 生成 .cpp 文件内容
  local cpp_content = {
    '#include "' .. class_name .. '.h"',
    "",
    class_name .. "::" .. class_name .. "() {",
    "",
    "}",
    "",
    class_name .. "::~" .. class_name .. "() {",
    "",
    "}",
    "",
  }

  -- 写入文件
  vim.fn.writefile(h_content, h_path)
  vim.fn.writefile(cpp_content, cpp_path)

  -- 打开 .h 文件
  vim.cmd("edit " .. vim.fn.fnameescape(h_path))

  vim.notify(
    "已创建:\n  " .. h_path .. "\n  " .. cpp_path,
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_user_command("CreateClass", create_class, {
  nargs = "+",
  bang = true,
  complete = "dir",
  desc = "创建 C++ 类文件（.h + .cpp）",
})
