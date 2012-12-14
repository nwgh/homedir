#!/usr/bin/env python

import copy
import os
import subprocess
import sys


def setup_env():
    global env
    mypath = os.path.abspath(__file__)
    mydir = os.path.split(mypath)[0]
    path = os.getenv('PATH', '')
    entries = path.split(os.pathsep)
    path = []
    for entry in entries:
        if entry != mydir:
            path.append(entry)

    env['PATH'] = os.pathsep.join(path)


def setup_packagedir():
    global packagedir
    bindir = os.path.join(env['HOME'], 'bin')
    bindir = os.readlink(bindir)
    packagedir = os.path.join(bindir, os.pardir, 'packages')
    packagedir = os.path.abspath(packagedir)


env = copy.copy(os.environ)
setup_env()

packagedir = None
setup_packagedir()


def do_installer(command):
    """This runs an installer command (which may or may not actually end up
    installing a package).
    """
    pid = os.fork()
    if pid == 0:
        # This is the child that will install the thing
        os.execvpe(command, sys.argv, env)
    else:
        # Wait until the child is done so we can save off a copy of our package
        # list after the new install completes
        os.waitpid(pid, 0)


def get_raw_output(*args):
    """Return a list of the lines (without newlines) printed to stdout by the
    command specified by *args.
    """
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        env=env)
    p.wait()
    return p.stdout.read().split('\n')


def do_save(packages, filename):
    """Saves a list of installed packages/programs/gems/whatever to the
    specified file.
    """
    if not packagedir:
        return

    outfile = os.path.join(packagedir, filename)
    with file(outfile, 'w') as f:
        f.write('\n'.join(packages))


def do_brew():
    """Install a program using homebrew. When done, save a list of the
    installed brews.
    """
    do_installer('brew')
    brews = get_raw_output('brew', 'list')
    do_save(brews, 'brews.txt')


def do_pip():
    """Install a python package using pip. If the package was installed for the
    global python (something not in a virtualenv), then save an updated copy of
    the list of installed packages.
    """
    do_installer('pip')
    if 'VIRTUAL_ENV' not in env:
        packages = get_raw_output('pip', 'freeze')
        packagenames = [p.split('=')[0] for p in packages]
        do_save(packagenames, 'python.txt')


def do_gem():
    """Install something for ruby using gem. If the gem was installed while not
    in an rbenv (our approximation for globally), then save an updated copy of
    the list of installed gems.
    """
    do_installer('gem')
    try:
        subprocess.check_call(['rbenv', 'local'], stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, env=env)
    except subprocess.CalledProcessError:
        # If rbenv exited with non-zero status, that means we are using the
        # globally set ruby, so we need to save our gems.
        gems = get_raw_output('gem', 'list', '--local')
        gemnames = []
        for gem in gems:
            if not gem or gem.startswith('***'):
                continue
            gemname = gem.split(' ')[0]
            gemnames.append(gemname)
        do_save(gemnames, 'ruby.txt')


def do_unknown():
    """This is here just in case we get linked to a program we don't know how
    to handle.
    """
    do_installer(sys.argv[0])


if __name__ == '__main__':
    workers = {
        'brew': do_brew,
        'pip': do_pip,
        'gem': do_gem,
    }
    installer = os.path.basename(sys.argv[0])
    worker = workers.get(installer, do_unknown)

    worker()
