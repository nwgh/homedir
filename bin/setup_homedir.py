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


def __dir_sort(a, b):
    """Comparator to sort a list of paths such that any file or subdirectory of
    directory D comes before D in the sorted list.
    """
    if a.startswith(b):
        return -1
    elif b.startswith(a):
        return 1
    elif a < b:
        return -1
    elif b < a:
        return 1
    return 0


def __listdir_nodot(directory):
    """Like os.listdir, but omits any files beginning with .
    """
    files = os.listdir(directory)
    return [f for f in files if not f.startswith('.')]


def __safelink(src, dst, act=True, verbose=False):
    """Like os.symlink, but does't behave badly if dst already exists.
    Also, ensures parent directory exists.

    Returns a set of all the paths it created.
    """
    created_paths = set()
    if not os.path.exists(dst):
        dirname = os.path.dirname(dst)
        if not os.path.exists(dirname):
            if verbose:
                p('mkdir %s' % (dirname,))
            if act:
                created_paths.add(dirname)
                os.makedirs(dirname)
        if verbose:
            p('%s -> %s' % (dst, src))
        if act:
            created_paths.add(dst)
            os.symlink(src, dst)
    elif verbose:
        p('%s already exists, not creating link' % (dst,))

    return created_paths


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

    created_paths = set()
    dotfiledir = os.path.join(srcdir, 'dotfiles')
    if os.path.exists(dotfiledir) and os.path.isdir(dotfiledir):
        dotfiles = __listdir_nodot(dotfiledir)
        for f in dotfiles:
            dst = os.path.join(destdir, '.%s' % (f,))
            src = os.path.join(dotfiledir, f)
            created_paths.union(__safelink(src, dst, act=act, verbose=verbose))
    elif verbose:
        p('No dotfiledir found')

    source_stamp = os.path.join(destdir, '.homedir_setup_source')
    if act:
        created_paths.add(source_stamp)
        with open(source_stamp, 'w') as f:
            f.write(srcdir)
        prefix = 'Wrote'
    else:
        prefix = 'Would write'
    if verbose:
        p('%s %s to %s' % (prefix, srcdir, source_stamp))

    manifest = os.path.join(srcdir, '.manifest')
    if act:
        if os.path.exists(manifest):
            with open(manifest) as f:
                paths = f.read().strip().split('\n')
            paths = set(paths)

            # Get rid of links that are no longer part of the homedir. If it's
            # a directory, remove it only if it's empty.
            old_paths = list(paths.difference(created_paths))
            old_paths.sort(cmp=__dir_sort)
            for path in paths:
                if os.path.islink(path) and not os.path.exists(path):
                    os.unlink(path)
                elif os.path.isdir(path):
                    files = os.listdir(d)
                    if not files:
                        os.rmdir(d)

        created_paths = list(created_paths)
        created_paths.sort(cmp=__dir_sort)
        with open(manifest, 'w') as f:
            f.write('\n'.join(created_paths))
    if verbose:
        p('%s manifest to %s' % (prefix, manifest))


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
