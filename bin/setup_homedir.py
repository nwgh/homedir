#!/usr/bin/env python
"""setup_homedir.py

A simple script for setting up a home directory from an SCM repository.

It's pretty simple, just run

setup_homedir.py -h <HOME> -s <SOURCE>

The layout of <SOURCE> should be something like:
<SOURCE>/<{osx,linux.windows}> - A subdirectory that is like the top-level,
                                 but specific to the OS on which this is being
                                 instaled
<SOURCE>/dotfiles - Any files that should be dotfiles in <HOME>
<SOURCE>/<anything> - All other files

If you really feel like being lazy, <HOME> will default to $HOME, and <SOURCE>
will default to the current directory.

Note that this will NOT link ANY file ANYWHERE under <SOURCE> that has a
filename starting with a dot (.).
"""

import getopt
import os
import platform
import sys

__author__ = "Nick Hurley <hurley@todesschaf.org>"
__copyright__ = "Copyright 2010, Nick Hurley"
__license__ = "BSD"

def __getos():
    if platform.mac_ver()[0]:
        return 'osx'
    elif platform.linux_ver()[0]:
        return 'linux'
    elif platform.win32_ver()[0]:
        return 'windows'
    return None

def __safelink(src, dst, verbose=False, in_os=False):
    """Like os.symlink, but does't behave badly if dst already exists
    """
    if not os.path.exists(dst):
        if verbose:
            print '%s -> %s' % (dst, src)
        os.symlink(src, dst)
    elif verbose:
        print '%s already exists, not creating link' % (dst,)

def setup_homedir(homedir, setupdir, verbose=False):
    """For each file, f, in setupdir, do the equivalent of:
       ln -s <setupdir>/<f> <homedir>/<f>
    Except for <setupdir>/dotfiles, where for each file f there, do:
       ln -s <setupdir>/dotfiles/<f> <homedir>/.<f>
    This ignores any files in <setupdir> that start with '.'
    """
    # Get the real (no symlinks, no relatives, nothing) path for each directory
    homedir = os.path.realpath(homedir)
    setupdir = os.path.realpath(setupdir)

    # Do sanity checks on the source and dest directories
    if homedir == setupdir:
        raise Exception, 'homedir cannot be the same as setupdir'
    if not os.path.isdir(homedir):
        raise Exception, 'homedir must be a directory'
    if not os.path.isdir(setupdir):
        raise Exception, 'setupdir must be a directory'

    # Setup
    dotfiledir = None
    osdir = None
    setupfiles = dict.fromkeys([f for f in os.listdir(setupdir)
                                if not f.startswith('.')])

    # See if we have an os-specific directory. If so, handle that first so the
    # os-specific bits take priority
    osname = __getos()
    if (not in_os) and (osname in setupfiles):
        if os.path.isdir(os.path.join(setupdir, osname)):
            osdir = os.path.join(setupdir, osname)
            del setupfiles[osname]
            if verbose:
                print 'Found osdir at %s' % (osdir,)
            setup_homedir(homedir, osdir, verbose, True)
    if verbose and not osdir:
        print 'No osdir found'

    # See if we have a dotfiles directory
    if 'dotfiles' in setupfiles:
        if os.path.isdir(os.path.join(setupdir, 'dotfiles')):
            dotfiledir = os.path.join(setupdir, 'dotfiles')
            del setupfiles['dotfiles']
            if verbose:
                print 'Found dotfiledir at %s' % (dotfiledir,)
    if verbose and not dotfiledir:
        print 'No dotfiledir found'

    setupfiles = setupfiles.keys()
    setupfiles.sort()

    # Symlink all the non-dotfiles
    for f in setupfiles:
        # Create the symlink
        src = os.path.join(setupdir, f)
        dst = os.path.join(homedir, f)
        __safelink(src, dst, verbose=verbose)

    # Handle the case where we have dotfiles to link
    if dotfiledir:
        dotfiles = [f for f in os.listdir(dotfiledir)
                    if not f.startswith('.')]
        for f in dotfiles:
            src = os.path.join(dotfiledir, f)
            dst = os.path.join(homedir, '.%s' % (f,))
            __safelink(src, dst, verbose=verbose)

if __name__ == '__main__':
    # No point in having this usage if we aren't running as main
    def usage():
        print >>sys.stderr, '%s [-h homedir] [-s setupdir] [-v]'
        print >>sys.stderr, '   -h homedir    Put links in <homedir> ' \
            '(default $HOME)'
        print >>sys.stderr, '   -s setupdir   Create links to files in ' \
            '<setupdir> (default .)'
        print >>sys.stderr, '   -v            Be verbose'
        sys.exit(1)
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'h:s:v')
    except:
        usage()

    homedir = os.getenv('HOME') or os.getcwd()
    setupdir = os.getcwd()
    verbose = False

    for o, a in opts:
        if o == '-h':
            homedir = a
        elif o == '-s':
            setupdir = a
        elif o == '-v':
            verbose = True
        else:
            usage()

    if args:
        # Extra args == invalid usage
        usage()

    try:
        setup_homedir(homedir, setupdir, verbose=verbose)
    except Exception, e:
        print >>sys.stderr, str(e)
        sys.exit(1)

    sys.exit(0)
