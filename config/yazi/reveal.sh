#!/usr/bin/env bash
# 在默认图形文件管理器中打开父目录并选中传入的文件
# 走 freedesktop 标准 org.freedesktop.FileManager1.ShowItems 接口
# 由 yazi keymap 调用，参数为当前悬停文件的绝对路径

path="$1"
[ -z "$path" ] && exit 0

# 转成正确编码的 file:// URI（保留斜杠，编码空格/中文/特殊字符）
uri="file://$(python3 -c 'import sys, os, urllib.parse; print(urllib.parse.quote(os.path.abspath(sys.argv[1])))' "$path")"

gdbus call --session \
  --dest org.freedesktop.FileManager1 \
  --object-path /org/freedesktop/FileManager1 \
  --method org.freedesktop.FileManager1.ShowItems \
  "['$uri']" "" >/dev/null 2>&1
