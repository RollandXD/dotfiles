"""Kitty 只读接口：仅允许读当前窗口的当前选区，其他操作一律拒绝。"""


def is_cmd_allowed(pcmd, window, from_socket, extra_data):
    p = pcmd.get('payload') or {}
    return bool(from_socket and pcmd.get('cmd') == 'get-text'
                and p.get('extent') == 'selection'
                and p.get('match') == 'state:focused'
                and not any(p.get(k) for k in ('ansi', 'clear_selection', 'add_cursor', 'self')))
