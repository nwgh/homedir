#!/usr/bin/env python

import os
import sys

CROSS_PATH = '/usr/local/cross-compile'
POINTER = 'current'

if not os.path.isdir(CROSS_PATH):
    print >>sys.stderr, "Can not find cross-compile installation!"
    sys.exit(1)

os.chdir(CROSS_PATH)
files = os.listdir('.')

files = [f for f in files if os.path.isdir(f) and not os.path.islink(f)]
didx = -1
if os.path.islink(POINTER):
    dest = os.readlink(POINTER).strip('/')
    try:
        didx = files.index(dest)
    except ValueError:
        pass
print "Choose the compiler version to run (* = current):"
for i, f in enumerate(files):
    marker = ''
    if didx == i:
        marker = ' *'
    print "%d. %s%s" % (i + 1, f, marker)

choice = didx
try:
    choice = int(raw_input('> ')) - 1
except EOFError:
    sys.exit(0)
except ValueError:
    print >>sys.stderr, "Invalid choice!"
    sys.exit(1)

if choice >= len(files):
    print >>sys.stderr, "Invalid choice!"
    sys.exit(1)

if choice > -1 and choice != didx:
    print "Updating %s/%s -> %s/%s" % (CROSS_PATH, POINTER, CROSS_PATH,
        files[choice])
    if os.path.exists(POINTER):
        os.unlink(POINTER)
    os.symlink(files[choice], POINTER)

sys.exit(0)
