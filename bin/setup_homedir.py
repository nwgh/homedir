#!/usr/bin/env python
"""setup_homedir.py

A simple script for setting up a home directory from an SCM repository.

It's pretty simple, just run

setup_homedir.py -h <HOME> -s <SOURCE>

The layout of <SOURCE> should be something like:
<SOURCE>/<{osx,linux,windows}> - A subdirectory that is like the top-level,
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
import subprocess
import sys

__author__ = "Nick Hurley <hurley@todesschaf.org>"
__copyright__ = "Copyright 2010, Nick Hurley"
__license__ = "BSD"

__osdirs = ['osx', 'linux', 'windows']


def __install_packages(packagefile, command, act=True, verbose=False):
    with file(packagefile) as f:
        packages = f.read().strip().split('\n')

    for package in packages:
        commandline = command.format(package=package)
        stdout = subprocess.PIPE
        if verbose:
            stdout = None
            print commandline
        if act:
            subprocess.call(commandline, shell=True, stdout=stdout,
                stderr=subprocess.STDOUT)


def __listdir(directory):
    """Like os.listdir, but strips out any files beginning with .
    """
    files = os.listdir(directory)
    return [f for f in files if not f.startswith('.')]


def __getos():
    """Return a string telling us what directory os-specific files live in.
    """
    if platform.mac_ver()[0]:
        return 'osx'
    elif platform.linux_distribution()[0]:
        return 'linux'
    elif platform.win32_ver()[0]:
        return 'windows'
    return None


def __safelink(src, dst, act=True, verbose=False):
    """Like os.symlink, but does't behave badly if dst already exists.
    """
    if not os.path.exists(dst):
        if verbose:
            print '%s -> %s' % (dst, src)
        if act:
            os.symlink(src, dst)
    elif verbose:
        print '%s already exists, not creating link' % (dst,)


def setup_homedir(homedir, setupdir, act=True, verbose=False, in_os=False,
    packages=False, vundle=True):
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
        raise Exception('homedir cannot be the same as setupdir')
    if not os.path.isdir(homedir):
        raise Exception('homedir must be a directory')
    if not os.path.isdir(setupdir):
        raise Exception('setupdir must be a directory')

    # Setup
    packagesdir = None
    dotfiledir = None
    osdir = None
    setupfiles = set(__listdir(setupdir))

    # See if we have an os-specific directory. If so, handle that first so the
    # os-specific bits take priority
    osname = __getos()
    if (not in_os) and (osname in setupfiles):
        if os.path.isdir(os.path.join(setupdir, osname)):
            osdir = os.path.join(setupdir, osname)
            setupfiles.discard(osname)
            if verbose:
                print 'Found osdir at %s' % (osdir,)
            setup_homedir(homedir, osdir, act=act, verbose=verbose, in_os=True,
                          vundle=False)
    if not in_os and verbose and not osdir:
        print 'No osdir found'

    for d in __osdirs:
        setupfiles.discard(d)

    # See if we have a dotfiles directory
    if 'dotfiles' in setupfiles:
        if os.path.isdir(os.path.join(setupdir, 'dotfiles')):
            dotfiledir = os.path.join(setupdir, 'dotfiles')
            setupfiles.discard('dotfiles')
            if verbose:
                print 'Found dotfiledir at %s' % (dotfiledir,)
    if verbose and not dotfiledir:
        print 'No dotfiledir found'

    # See if we have a packages directory
    if 'packages' in setupfiles:
        if os.path.isdir(os.path.join(setupdir, 'packages')):
            packagesdir = os.path.join(setupdir, 'packages')
            setupfiles.discard('packages')
            if verbose:
                print 'Found packagesdir at %s' % (packagesdir,)
    if not in_os and verbose and not packagesdir:
        print 'No packagesdir found'

    # Symlink all the non-dotfiles
    for f in setupfiles:
        # Create the symlink
        src = os.path.join(setupdir, f)
        dst = os.path.join(homedir, f)
        __safelink(src, dst, act=act, verbose=verbose)

    # Handle the case where we have dotfiles to link
    if dotfiledir:
        dotfiles = __listdir(dotfiledir)
        for f in dotfiles:
            if f == 'sublime':
                if osname == 'osx':
                    dst = os.path.join(homedir, 'Library',
                        'Application Support', 'Sublime Text 2', 'Packages',
                        'User')
                elif osname == 'linux':
                    dst = os.path.join(homedir, '.Sublime Text 2', 'Packages',
                        'User')
                else:
                    if verbose:
                        print >>sys.stderr, 'Unknown os type for Sublime: %s' \
                            % (osname,)
                    continue
            else:
                dst = os.path.join(homedir, '.%s' % (f,))
            src = os.path.join(dotfiledir, f)
            __safelink(src, dst, act=act, verbose=verbose)

        # Vundle goes in the dotfile directory, if anywhere
        if vundle:
            vimbundles = os.path.join(dotfiledir, 'vim', 'bundle')
            if not os.path.exists(vimbundles):
                if verbose:
                    print >>sys.stderr, 'Install vundle to %s' % (vimbundles,)
                if act:
                    os.mkdir(vimbundles)
                    cwd = os.getcwd()
                    os.chdir(vimbundles)
                    os.system('git clone https://github.com/gmarik/vundle.git vundle')
                    os.chdir(cwd)
            elif verbose:
                print >>sys.stderr, 'Not installing vundle: %s already exists' \
                        % (vimbundles,)

    # Handle installing packages if requested
    if packages:
        packagefiles = __listdir(packagesdir)
        installer_file = None
        for p in packagefiles:
            filename = os.path.join(packagesdir, p)
            if p == 'installers.txt':
                installer_file = filename
            elif p == 'brews.txt':
                __install_packages(filename, 'brew install {package}',
                    act=act, verbose=verbose)
            elif p == 'python.txt':
                __install_packages(filename, 'pip install {package}', act=act,
                    verbose=verbose)
            elif p == 'ruby.txt':
                __install_packages(filename, 'gem install {package}', act=act,
                    verbose=verbose)
            elif verbose:
                print 'Invalid packages filename'

        if installer_file:
            installers = []
            installer_wrapper = os.path.join(setupdir, 'bin', 'installer.py')
            destdir = os.path.join(os.path.sep, 'todesschaf', 'bin')
            with file(installer_file) as f:
                installers = f.read().strip().split('\n')
            for installer in installers:
                dest = os.path.join(destdir, installer)
                if verbose:
                    print '%s => %s' % (dest, installer_wrapper)
                if act:
                    os.link(installer_wrapper, dest)


if __name__ == '__main__':
    # No point in having this usage if we aren't running as main
    def usage():
        print >>sys.stderr, '%s [-n] [-h homedir] [-p] [-s setupdir] [-v]' % (
            sys.argv[0],)
        print >>sys.stderr, '   -b            DO NOT install vundle'
        print >>sys.stderr, '   -n            Do nothing, just print what ' \
            'would be done (implies -v)'
        print >>sys.stderr, '   -h homedir    Put links in <homedir> ' \
            '(default $HOME)'
        print >>sys.stderr, '   -p            Install packages'
        print >>sys.stderr, '   -s setupdir   Create links to files in ' \
            '<setupdir> (default .)'
        print >>sys.stderr, '   -v            Be verbose'
        sys.exit(1)

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'bnh:ps:v')
    except:
        usage()

    act = True
    homedir = os.getenv('HOME') or os.getcwd()
    setupdir = os.getcwd()
    verbose = False
    packages = False
    vundle = True

    for o, a in opts:
        if o == '-b':
            vundle = False
        elif o == '-n':
            act = False
            verbose = True
        elif o == '-h':
            homedir = a
        elif o == '-s':
            setupdir = a
        elif o == '-v':
            verbose = True
        elif o == '-p':
            packages = True
        else:
            usage()

    if args:
        # Extra args == invalid usage
        usage()

    try:
        setup_homedir(homedir, setupdir, act=act, verbose=verbose,
            packages=packages, vundle=vundle)
    except Exception, e:
        print >>sys.stderr, str(e)
        sys.exit(1)

    sys.exit(0)
