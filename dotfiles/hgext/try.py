#!/usr/bin/env python

import os
import tempfile

from mercurial import commands
from mercurial import extensions
from mercurial import util


def run_try(ui, repo, *args, **opts):
    """Push the current head to try
    """
    if not opts['build'] or not opts['platform']:
        raise util.Abort('Both -b and -p are required')

    # We rely on the try server to validate anything beyond that simple
    # check above, so let's just blindly go about our business!

    tryopts = []
    tryopts.append('-b')
    tryopts.extend(opts['build'])
    tryopts.append('-p')
    tryopts.extend(opts['platform'])
    if opts.get('unit'):
        tryopts.append('-u')
        tryopts.extend(opts['unit'])
    if opts.get('talos'):
        tryopts.append('-t')
        tryopts.extend(opts['talos'])

    trymsg = 'try: %s' % (' '.join(tryopts),)

    if repo[None].dirty():
        raise util.Abort('You have outstanding changes')

    try:
        strip = extensions.find('strip')
    except KeyError:
        ui.warn('strip extension not found, use the following syntax:\n')
        ui.write('%s\n' % (trymsg,))
        return

    ui.write('setting try selections...\n')

    # This next bit here is a hack to get an empty commit
    cwd = os.getcwd()
    junkfile = tempfile.mktemp(prefix='hgjunk', dir='')
    os.chdir(repo.root)
    file(junkfile, 'w').close()
    commands.add(ui, repo, junkfile)
    commands.commit(ui, repo, message='add junk file (will be gone)')
    commands.remove(ui, repo, junkfile)
    commands.commit(ui, repo, amend=True, message=trymsg, logfile=None)
    os.chdir(cwd)

    # Get the revision of our try commit so we can strip it later
    node = repo[None].p1().hex()

    ui.write('pushing to try...\n')
    commands.push(ui, repo, 'try', force=True)

    # Now we must clean up after ourslves by stripping the try commit
    strip.stripcmd(ui, repo, node, rev=[], no_backup=True)


cmdtable = {
    'try': (run_try, [('b', 'build', [], 'Select build types to perform'),
                      ('p', 'platform', [], 'Select platforms to build'),
                      ('u', 'unit', [], 'Select unit tests to run'),
                      ('t', 'talos', [], 'Select talos tests to run')],
            'hg try -b <builds> -p <platforms> [-u <unit tests>] '
            '[-t <talos>]')
}
