local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local function section_comment(trig, default_title, name)
  return s(
    { trig = trig, name = name or ("C++ section comment: " .. default_title) },
    fmt("// ── {} ───────────────────────────────────────────", {
      i(1, default_title),
    })
  )
end

local function label_comment(trig, label, default_text)
  return s(
    { trig = trig, name = "C++ label comment: " .. label },
    fmt("// {}: {}", {
      i(1, label),
      i(2, default_text),
    })
  )
end

return {
  section_comment("sec", "ctor", "C++ section comment"),
  section_comment("ctor", "ctor"),
  section_comment("dtor", "dtor"),
  section_comment("pub", "public api"),
  section_comment("pri", "private helpers"),
  section_comment("pro", "protected"),
  section_comment("ovr", "overrides"),
  section_comment("st", "state"),
  section_comment("reg", "region"),
  section_comment("endr", "endregion"),
  label_comment("todo", "TODO", "fill me"),
  label_comment("fix", "FIXME", "fill me"),
  label_comment("warn", "WARN", "fill me"),
  label_comment("perf", "PERF", "fill me"),
  label_comment("note", "NOTE", "fill me"),

  -- 类定义骨架
  s({ trig = "cls", name = "C++ class" }, fmt([[
class {} {{
public:
    {}();
    ~{}();

    {}

private:
    {}
}};]], { i(1, "ClassName"), rep(1), rep(1), i(2, "// public"), i(3, "// private") })),

  -- 智能指针
  s({ trig = "uptr", name = "unique_ptr" }, fmt("std::unique_ptr<{}> {}", { i(1, "Type"), i(2, "name") })),
  s({ trig = "sptr", name = "shared_ptr" }, fmt("std::shared_ptr<{}> {}", { i(1, "Type"), i(2, "name") })),
  s({ trig = "mkup", name = "make_unique" }, fmt("std::make_unique<{}>({})", { i(1, "Type"), i(2) })),
  s({ trig = "mksp", name = "make_shared" }, fmt("std::make_shared<{}>({})", { i(1, "Type"), i(2) })),

  -- Range-based for
  s({ trig = "fora", name = "for auto&" }, fmt([[
for (auto& {} : {}) {{
    {}
}}]], { i(1, "item"), i(2, "container"), i(3) })),
  s({ trig = "forc", name = "for const auto&" }, fmt([[
for (const auto& {} : {}) {{
    {}
}}]], { i(1, "item"), i(2, "container"), i(3) })),

  -- 头文件保护
  s({ trig = "guard", name = "header guard" }, fmt([[
#ifndef {}_H
#define {}_H

{}

#endif // {}_H]], { i(1, "HEADER"), rep(1), i(2), rep(1) })),

  -- Include
  s({ trig = "inc", name = '#include ""' }, fmt('#include "{}"', { i(1, "header.h") })),
  s({ trig = "incs", name = "#include <>" }, fmt("#include <{}>", { i(1, "iostream") })),
}
