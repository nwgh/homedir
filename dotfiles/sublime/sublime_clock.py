'''
Shows a very simple clock within the status bar.

@todo Only show when in fullscreen mode.
@todo Disable clock by default.
@todo Make format string user definable.
@todo Make weekdays user definable.
@todo Code cleanup.
'''

from datetime import datetime

import sublime
import sublime_plugin


class Clock(object):
    status_key = '000_clock'

    def __init__(self):
        self.views = {}

    def add_view(self, view):
        if view.id() not in self.views:
            self.views[view.id()] = view
            self.update()

    def del_view(self, view):
        if view.id() in self.views:
            del self.views[view.id()]
            view.erase_status(Clock.status_key)

    def update(self):
        for id_, view in self.views.iteritems():
            now = datetime.now().strftime('%H:%M')
            view.set_status(Clock.status_key, now)

    def run(self):
        self.update()
        sublime.set_timeout(self.run, 60 * 1000)


class ClockListener(sublime_plugin.EventListener):
    def __init__(self, *args, **kwargs):
        self.clock = Clock()
        self.clock.run()

    def on_load(self, view):
        self.clock.add_view(view)

    def on_post_save(self, view):
        self.clock.add_view(view)

    def on_activated(self, view):
        self.clock.add_view(view)

    def on_deactivated(self, view):
        self.clock.del_view(view)
