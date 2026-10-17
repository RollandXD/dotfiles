#!/bin/bash
# 保留 SIGUSR1 上膛与 15 秒取消超时；只在截图文件真正写完后播放。
# niri 当前截图路径：~/Pictures/Screenshots/Screenshot from ...png
set -u
TRIGGER_FILE="/dev/shm/niri_screenshot_armed"
TIMEOUT_SEC=15
SCREENSHOT_DIR="${SYSTEM_SOUNDS_SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
if ! command -v system-sounds >/dev/null || ! command -v inotifywait >/dev/null; then
    notify-send "截图提示音" "需要 system-sounds 与 inotify-tools"
    exit 1
fi
mkdir -p "$SCREENSHOT_DIR"
arm_trigger() { touch "$TRIGGER_FILE"; }
trap arm_trigger USR1
coproc EVENT_WATCH {
    exec inotifywait -m -q -e close_write -e moved_to --format '%f' -- "$SCREENSHOT_DIR"
}
WATCHER_PID=$EVENT_WATCH_PID
WATCH_FD=${EVENT_WATCH[0]}
cleanup() {
    trap - INT TERM EXIT
    kill "$WATCHER_PID" 2>/dev/null || true
    wait "$WATCHER_PID" 2>/dev/null || true
}
trap 'cleanup; exit' INT TERM
trap cleanup EXIT
echo "截图提示音服务已启动：等待 SIGUSR1 与截图文件完成"
while true; do
    if IFS= read -r filename <&"$WATCH_FD"; then
        [[ "$filename" == Screenshot\ from\ *.png ]] || continue
        if [[ -f "$TRIGGER_FILE" ]]; then
            now=$(date +%s)
            file_time=$(stat -c %Y "$TRIGGER_FILE" 2>/dev/null) || continue
            if (( now - file_time < TIMEOUT_SEC )); then
                rm -f "$TRIGGER_FILE"
                system-sounds play screenshot &
            fi
        fi
    else
        # USR1 会中断 read；只有监测进程真正退出时才结束服务。
        kill -0 "$WATCHER_PID" 2>/dev/null || break
    fi
done
