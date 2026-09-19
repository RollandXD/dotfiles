#!/usr/bin/env python3
"""dank-ocr 的 RapidOCR 后端：图片 → 纯文本（每行一条）。

为什么需要这层包装：RapidOCR 的命令行（`rapidocr -img 图片`）会把整个
RapidOCROutput 的 repr 打到 stdout——里面含 numpy 图像数组，脚本没法消费；
真正有用的 `txts` / `scores` 只有 Python API 才拿得到。

用法：
    dank-ocr-rapidocr.py <图片> [--text-score 0.5] [--report-file 文件] [--debug]

退出码：
    0  识别到文本
    2  运行错误（图片不可读、导入失败、推理异常）
    3  没有识别到文本

`--report-file` 会写入一行摘要，供 bash 前端显示置信度：
    lines=6 avg_score=0.9874 min_score=0.9750 max_score=0.9992
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

DEFAULT_TEXT_SCORE = 0.5


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="dank-ocr-rapidocr", description=__doc__, add_help=True)
    parser.add_argument("image", help="待识别的图片路径")
    parser.add_argument(
        "--text-score",
        type=float,
        default=DEFAULT_TEXT_SCORE,
        metavar="0-1",
        help=f"低于该置信度的文本会被丢弃（默认 {DEFAULT_TEXT_SCORE}）",
    )
    parser.add_argument(
        "--report-file",
        metavar="文件",
        help="把 lines/avg_score/min_score/max_score 写到该文件",
    )
    parser.add_argument("--debug", action="store_true", help="把诊断信息打到 stderr")
    return parser.parse_args(argv)


def silence_info_logs() -> None:
    """RapidOCR 默认以 INFO 打印模型路径；被当后端调用时这些噪音会污染日志。"""
    logging.disable(logging.INFO)


def write_report(path: str, texts: list[str], scores: list[float], debug: bool) -> None:
    fields = [f"lines={len(texts)}"]
    if scores:
        fields += [
            f"avg_score={sum(scores) / len(scores):.4f}",
            f"min_score={min(scores):.4f}",
            f"max_score={max(scores):.4f}",
        ]
    try:
        Path(path).write_text(" ".join(fields) + "\n", encoding="utf-8")
    except OSError as exc:
        if debug:
            print(f"dank-ocr-rapidocr: 摘要写入失败：{exc}", file=sys.stderr)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    silence_info_logs()

    image = Path(args.image).expanduser()
    if not image.is_file():
        print(f"dank-ocr-rapidocr: 图片不存在或不可读：{image}", file=sys.stderr)
        return 2

    try:
        from rapidocr import RapidOCR
    except ImportError as exc:  # 解释器选错或环境被删
        print(f"dank-ocr-rapidocr: 无法导入 rapidocr（{exc}）", file=sys.stderr)
        return 2

    try:
        engine = RapidOCR()
        result = engine(str(image), text_score=args.text_score)
    except Exception as exc:  # noqa: BLE001 — 后端边界：任何推理期异常都转成可读信息
        print(f"dank-ocr-rapidocr: 推理失败：{type(exc).__name__}: {exc}", file=sys.stderr)
        return 2

    texts = [t for t in (getattr(result, "txts", None) or []) if t and t.strip()]
    raw_scores = list(getattr(result, "scores", None) or [])
    scores = [float(s) for s in raw_scores if isinstance(s, (int, float))]

    if not texts:
        if args.debug:
            print("dank-ocr-rapidocr: 未检测到文本", file=sys.stderr)
        return 3

    sys.stdout.write("\n".join(texts) + "\n")

    if args.report_file:
        write_report(args.report_file, texts, scores, args.debug)

    if args.debug:
        elapse = getattr(result, "elapse", None)
        detail = f"{len(texts)} 行"
        if elapse is not None:
            detail += f"，elapse={elapse:.3f}s"
        print(f"dank-ocr-rapidocr: {detail}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
