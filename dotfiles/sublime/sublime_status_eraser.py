import sublime
import sublime_plugin

junk_status_keys = [
    'git-branch',
    'git-status',
    'git-status-index',
    'git-status-working',
    'CodeIntel-info',
    'CodeIntel-event',
    'CodeIntel-warning',
]

def erase_junk():
    view = sublime.active_window().active_view()
    for k in junk_status_keys:
        view.erase_status(k)
    sublime.set_timeout(erase_junk, 1000)

class JunkEraser(sublime_plugin.EventListener):
    def __init__(*args, **kwargs):
        erase_junk()
