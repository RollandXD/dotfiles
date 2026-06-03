#!/usr/bin/env python3
import sys, zipfile, xml.etree.ElementTree as ET, re

DRAW_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"

def extract_texts(xml_bytes):
    root = ET.fromstring(xml_bytes)
    texts = []
    for para in root.iter(f"{{{DRAW_NS}}}p"):
        line = "".join(t.text or "" for t in para.iter(f"{{{DRAW_NS}}}t")).strip()
        if line:
            texts.append(line)
    return texts

def main():
    path = sys.argv[1]
    try:
        with zipfile.ZipFile(path) as z:
            slides = sorted(
                [n for n in z.namelist()
                 if re.match(r"ppt/slides/slide\d+\.xml$", n)],
                key=lambda s: int(re.search(r"\d+", s).group())
            )
            total = len(slides)
            for i, slide in enumerate(slides, 1):
                print(f"── Slide {i}/{total} {'─' * 30}")
                with z.open(slide) as f:
                    data = f.read()
                texts = extract_texts(data)
                if texts:
                    print("\n".join(texts))
                else:
                    print("  (无文字内容)")
                print()
    except Exception as e:
        print(f"预览失败: {e}", file=sys.stderr)
        sys.exit(1)

main()
