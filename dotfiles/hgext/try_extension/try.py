#!/usr/bin/env python

import argparse

from mercurial import commands
from mercurial import extensions
from mercurial import util

PLATFORMS = ('all', 'none', 'linux', 'linux64', 'macosx64', 'win32', 'win64',
             'android', 'android-armv6')
MOCHITESTS = ('mochitest-1', 'mochitest-2', 'mochitest-3', 'mochitest-4',
              'mochitest-5', 'mochitest-o', 'mochitest-bc')
UNITTESTS = ('all', 'none', 'reftest', 'reftest-ipc', 'reftest-no-accel',
             'crashtest', 'crashtest-ipc', 'xpcshell', 'jsreftest', 'jetpack',
             'marionette', 'mozmill', 'mochitests', 'reftest-1', 'reftest-2',
             'reftest-3', 'reftest-4', 'jsreftest-1', 'jsreftest-2',
             'jsreftest-3', 'crashtest-2', 'crashtest-3', 'mochitest-6',
             'mochitest-7', 'mochitest-8', 'robocop') + MOCHITESTS
TALOS = ('all', 'none', 'tpn', 'chromez', 'nochromer', 'other', 'dirtypaint',
         'svgr', 'dromaeojs', 'xperf', 'remote-ts', 'remote-tdhtml',
         'remote-tsvg', 'remote-tpan', 'remote-trobopan', 'remote-trobocheck',
         'remote-troboprovider', 'remote-trobocheck2', 'remote-trobocheck3',
         'remote-tp4m_nochrome')

class Tryer(object):
    def __init__(self, ui, repo, args):
        self.ui = ui
        self.repo = repo

        self.args = {'build':None, 'platform':None, 'unittests':None,
                     'talos':None, 'email':None}

        self.debug = ui.configbool('try', 'debug', default=False)
        if self.debug:
            self.ui.write('in debug mode\n')

        self.qname = ui.config('try', 'qname', default='try_config')
        if self.debug:
            ui.write('got qname %s\n' % (self.qname,))

        self.url = ui.config('try', 'url', default='ssh://hg.mozilla.org/try')
        if self.debug:
            ui.write('got url %s\n' % (self.url,))

        default_args = ui.config('try', 'defaults', default=None)
        if default_args:
            if self.debug:
                ui.write('got default args %s\n' % (default_args,))
            self._parse_tryargs(default_args)

        self._compute_args(args)

    def _parse_tryargs(self, argstr):
        args = argstr.split()
        i = 0
        while i < len(args):
            skip = 1
            if args[i] in ('-b', '--build'):
                skip = 2
                self.args['build'] = args[i + 1]
            if args[i] in ('-p', '--platform'):
                skip = 2
                self.args['platform'] = args[i + 1]
            if args[i] in ('-u', '--unittests'):
                skip = 2
                self.args['unittests'] = args[i + 1]
            if args[i] in ('-t', '--talos'):
                skip = 2
                self.args['talos'] = args[i + 1]
            if args[i] in ('-e', '--all-emails'):
                self.args['email'] = '-e'
            if args[i] in ('-n', '--no-emails'):
                self.args['email'] = '-n'
            i += skip

    def _create_args(self, atype, args, check_mochitests=False):
        if 'all' in args:
            if len(args) != 1:
                raise util.Abort('all can not be used with any other %s' %
                        (atype,))
            return 'all'

        if 'none' in args:
            if len(args) != 1:
                raise util.Abort('none can not be used with any other %s' %
                        (atype,))
            return 'none'

        if check_mochitests and 'mochitests' in args:
            for m in MOCHITESTS:
                if m in args:
                    raise util.Abort('mochitests can not be used with any '
                            'other mochitest')

        # Make a set here to ensure there are no duplicates
        return ','.join(set(args))

    def _compute_args(self, args):
        """Given the command-line args
        """
        p = argparse.ArgumentParser(description='Do a try run on a patch',
                prog='hg try')
        p.add_argument('-b', '--build', choices=('d', 'o'), action='append')
        p.add_argument('-p', '--platform', choices=PLATFORMS,
                help='Platforms to build', action='append')
        p.add_argument('-u', '--unittests', choices=UNITTESTS,
                help='Unit tests to run', action='append')
        p.add_argument('-t', '--talos', choices=TALOS,
                help='Talos tests to run', action='append')
        p.add_argument('-e', '--all-emails', help='Send all email',
                action='store_true')
        p.add_argument('-n', '--no-emails', help='Send no email',
                action='store_true')
        p.add_argument('-m', '--mozilla-central', action='store_true',
                help='Use mozilla-central configuration')

        args = p.parse_args(args)

        if args.build:
            # Use a set to ensure there are no duplicates
            self.args['build'] = ''.join(set(args.build))

        if args.platform:
            self.args['platform'] = self._create_args('platform', args.platform)

        if args.unittests:
            self.args['unittests'] = self._create_args('unittests',
                    args.unittests, True)

        if args.talos:
            self.args['talos'] = self._create_args('talos', args.talos)

        if args.all_emails and args.no_emails:
            raise util.Abort('-e and -n are exclusive')

        if args.all_emails:
            self.args['email'] = '-e'

        if args.no_emails:
            self.args['email'] = '-n'

        if args.mozilla_central:
            if args.build or args.platform or args.unittests or args.talos:
                raise util.Abort('-m may not be used with -b, -p, -u or -t')
            self.args['build'] = 'do'
            self.args['platform'] = 'all'
            self.args['unittests'] = 'all'
            self.args['talos'] = 'all'

        if not self.args['build'] or not self.args['platform']:
            raise util.Abort('missing -b and -p')

    def _build_try(self):
        """Creates a valid try string out of the options we've parsed
        """
        trylist = ['try:']

        if self.args['build']:
            trylist.extend(['-b', self.args['build']])

        if self.args['platform']:
            trylist.extend(['-p', self.args['platform']])

        if self.args['unittests']:
            trylist.extend(['-u', self.args['unittests']])

        if self.args['talos']:
            trylist.extend(['-t', self.args['talos']])

        if self.args['email']:
            trylist.append(self.args['email'])

        return ' '.join(trylist)

    def run(self):
        """Drive the whole process of creating an mq entry and pushing to try.

        If we can't find mq, we'll just print the try syntax to the cli and have
        the user take care of the work themselves.
        """
        # Ensure there aren't any outstanding changes
        if self.repo[None].dirty():
            raise util.Abort('You have outstanding changes; refresh first')

        # Make our try selections
        trymsg = self._build_try()
        try:
            mq = extensions.find('mq')
        except KeyError:
            self.ui.warn('mq extension not found, use the following syntax:\n')
            self.ui.write('%s\n' % (trymsg,))
            return

        # Create a new mq entry
        self.ui.write('setting try selections...\n')
        mq.new(self.ui, self.repo, self.qname, message=trymsg)
        rev = self.repo[None].p1()

        # Push to the try server
        self.ui.write('pushing to try...\n')
        if self.debug:
            self.ui.write('would force push to %s\n' % (self.url,))
        else:
            commands.push(self.ui, self.repo, self.url, force=True)

        # Get rid of our mq entry
        self.ui.write('cleaning up...\n')

        try:
            commands.phase(self.ui, self.repo, 'mq()', draft=True, public=False,
                    secret=False, force=True, rev='')
        except AttributeError:
            # If the phase command doesn't exist, we can just ignore this
            pass

        if not self.debug:
            mq.pop(self.ui, self.repo)
            mq.delete(self.ui, self.repo, self.qname)

        self.ui.write('done!\n')
        self.ui.write('Your results will be at '
                'http://tbpl.mozilla.org/?tree=Try&rev=%s\n' % (rev,))

def run_try(ui, repo, *args, **opts):
    """Push current branch to try using the given options
    """
    if args:
        raise util.Abort('got unexpected extra arguments: %s\n' %
                (' '.join(args),))

    tryargs = []
    if opts['mozilla_central']:
        tryargs.append('-m')
    if opts['all_emails']:
        tryargs.append('-e')
    if opts['no_emails']:
        tryargs.append('-n')

    # These split methods are based on the actual try syntax, since we
    # try to emulate it on the cli as best as possible (but we also accept
    # people doing other things, such as one flag for each instance of the
    # argument to be sent)
    buildsplit = lambda s: [x for x in s]
    othersplit = lambda s: s.split(',')

    # Turn each option into a list of [flag, value, ...] for parsing by the
    # argument parser that does the hardcore work
    optflags = {'build':('-b', buildsplit),
                'platform':('-p', othersplit),
                'unittests':('-u', othersplit),
                'talos':('-t', othersplit)}
    for name, (flag, split) in optflags.items():
        if opts[name]:
            optargs = []
            for v in opts[name]:
                optargs.extend(split(v))
            for o in optargs:
                tryargs.extend([flag, o])

    # This class takes care of most of our actual effort
    tryer = Tryer(ui, repo, tryargs)
    tryer.run()

cmdtable = {
        'try': (run_try, [('b', 'build', [], 'Select build type(s) to perform'),
                          ('p', 'platform', [], 'Select platform(s) to build'),
                          ('u', 'unittests', [],
                           'Select unit test(s) to be run'),
                          ('t', 'talos', [], 'Select talos test(s) to be run'),
                          ('e', 'all-emails', None,
                           'Receive all emails (even success)'),
                          ('n', 'no-emails', None, 'Receive no emails'),
                          ('m', 'mozilla-central', None,
                           'Use mozilla-central configuration'),
                        ],
                'hg try -b <build opts> -p <platform opts> '\
                        '[-u <unittest opts> [-u ...]] '\
                        '[-t <talos opts> [-t ...]] '\
                        '[-e | -n]\n\n'\
                'hg try -m [-e | -n]')
}
