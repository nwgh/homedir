#!/usr/bin/env python
"""setup_homedir.py

A simple script for setting up a home directory from an SCM repository.

It's pretty simple, just run

setup_homedir.py -d <DESTINATION> -s <SOURCE>

The layout of <SOURCE> should be something like:
<SOURCE>/dotfiles/* - Any files that should be dotfiles in <DESTINATION>
<SOURCE>/<anything> - All other files (not linked into <DESTINATION>)

If you really feel like being lazy, <DESTINATION> will default to $HOME, and
<SOURCE> will default to the current directory.

Note that this will NOT link ANY file ANYWHERE under <SOURCE> that has a
filename starting with a dot (.).
"""

import argparse
import functools
import os
import sys

__author__ = "Nicholas Hurley <nwgh@nwgh.org>"
__copyright__ = "Copyright 2010-2019, Nicholas Hurley"
__license__ = "BSD"

# Do things for compatibility between python 2 and 3
p = getattr(__builtins__, "print")
e = functools.partial(p, file=sys.stderr)


def __listdir(directory):
    """Like os.listdir, but strips out any files beginning with .
    """
    files = os.listdir(directory)
    return [f for f in files if not f.startswith('.')]


def __safelink(src, dst, act=True, verbose=False):
    """Like os.symlink, but does't behave badly if dst already exists.
    Also, ensures parent directory exists.
    """
    if not os.path.exists(dst):
        dirname = os.path.dirname(dst)
        if not os.path.exists(dirname):
            if verbose:
                p('mkdir %s' % (dirname,))
            if act:
                os.makedirs(dirname)
        if verbose:
            p('%s -> %s' % (dst, src))
        if act:
            os.symlink(src, dst)
    elif verbose:
        p('%s already exists, not creating link' % (dst,))


def setup_homedir(destdir, srcdir, act=True, verbose=False):
    """For each file, f, in <srcdir>/dotfiles, do a safer equivalent of:
       ln -s <srcdir>/dotfiles/<f> <destdir>/.<f>
    """
    # Get the real (no symlinks, no relatives, nothing) path for each directory
    destdir = os.path.realpath(destdir)
    srcdir = os.path.realpath(srcdir)

    # Do sanity checks on the source and dest directories
    if destdir == srcdir:
        raise Exception('destdir cannot be the same as srcdir')
    if not os.path.isdir(destdir):
        raise Exception('destdir must be a directory')
    if not os.path.isdir(srcdir):
        raise Exception('srcdir must be a directory')

    dotfiledir = os.path.join(srcdir, 'dotfiles')
    if os.path.exists(dotfiledir) and os.path.isdir(dotfiledir):
        dotfiles = __listdir(dotfiledir)
        for f in dotfiles:
            dst = os.path.join(destdir, '.%s' % (f,))
            src = os.path.join(dotfiledir, f)
            __safelink(src, dst, act=act, verbose=verbose)
    elif verbose:
        p('No dotfiledir found')

    source_stamp = os.path.join(destdir, '.homedir_setup_source')
    if act:
        with open(source_stamp, 'w') as f:
            f.write(srcdir)
        prefix = 'Wrote'
    else:
        prefix = 'Would write'
    if verbose:
        p('%s %s to %s' % (prefix, srcdir, source_stamp))


if __name__ == '__main__':
    class DryRunAction(argparse._StoreTrueAction):
        """Special action to force verbose to true.
        """
        def __call__(self, parser, namespace, values, option_string=None):
            super(DryRunAction, self).__call__(parser, namespace, values,
                option_string=option_string)
            setattr(namespace, 'verbose', True)

    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--dry-run',
        help='Do nothing, just print what would be done', action=DryRunAction)
    parser.add_argument('-d', '--destination',
        help='Put links in <destination>', default=os.getenv('HOME'))
    parser.add_argument('-s', '--srcdir',
        help='Create links to files in <srcdir>', default=os.getcwd())
    parser.add_argument('-v', '--verbose', help='Be verbose',
        action='store_true')
    args = parser.parse_args()

    try:
        setup_homedir(args.destination, args.srcdir, act=not args.dry_run,
                verbose=args.verbose)
    except Exception as exc:
        e(str(exc))
        sys.exit(1)

    sys.exit(0)
