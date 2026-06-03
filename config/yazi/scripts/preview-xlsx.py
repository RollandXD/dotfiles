#!/usr/bin/env python3
import sys, zipfile, xml.etree.ElementTree as ET, re

NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"

def tag(t): return f"{{{NS}}}{t}"

def get_shared_strings(z):
    try:
        with z.open("xl/sharedStrings.xml") as f:
            tree = ET.parse(f)
        return [
            "".join(t.text or "" for t in si.iter(tag("t")))
            for si in tree.findall(f".//{tag('si')}")
        ]
    except Exception:
        return []

def col_index(ref):
    letters = re.match(r"[A-Z]+", ref).group()
    n = 0
    for c in letters:
        n = n * 26 + (ord(c) - ord("A") + 1)
    return n - 1

def preview_sheet(z, name, shared):
    with z.open(name) as f:
        tree = ET.parse(f)
    rows_out = []
    for row in tree.findall(f".//{tag('row')}"):
        cells = {}
        for c in row.findall(tag("c")):
            ref = c.get("r", "A1")
            t   = c.get("t", "")
            v   = c.find(tag("v"))
            if v is not None and v.text is not None:
                if t == "s":
                    try:    val = shared[int(v.text)]
                    except: val = v.text
                else:
                    val = v.text
            else:
                val = ""
            cells[col_index(ref)] = val
        if cells:
            max_col = max(cells) + 1
            rows_out.append("\t".join(cells.get(i, "") for i in range(max_col)))
    return "\n".join(rows_out)

def main():
    path = sys.argv[1]
    try:
        with zipfile.ZipFile(path) as z:
            shared = get_shared_strings(z)
            sheets = sorted(
                [n for n in z.namelist()
                 if re.match(r"xl/worksheets/sheet\d+\.xml$", n)],
                key=lambda s: int(re.search(r"\d+", s).group())
            )
            # 读取工作表名称
            sheet_names = {}
            try:
                with z.open("xl/workbook.xml") as f:
                    wb = ET.parse(f)
                ns2 = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
                for i, s in enumerate(wb.findall(f".//{{{ns2}}}sheet"), 1):
                    sheet_names[i] = s.get("name", f"Sheet{i}")
            except Exception:
                pass

            for i, sheet in enumerate(sheets, 1):
                name = sheet_names.get(i, f"Sheet {i}")
                print(f"┌─ {name} {'─' * max(0, 40 - len(name))}")
                content = preview_sheet(z, sheet, shared)
                if content.strip():
                    print(content)
                else:
                    print("  (空)")
                print()
    except Exception as e:
        print(f"预览失败: {e}", file=sys.stderr)
        sys.exit(1)

main()
