#!/usr/bin/env python

import argparse
import os
import signal
import subprocess
import sys

homedir = os.getenv('HOME')
outdefault = os.path.join(homedir, '.irssi', 'forward.log')

parser = argparse.ArgumentParser()
parser.add_argument('--output', default=outdefault)
parser.add_argument('--localport', default='6667')
parser.add_argument('--forward-to-host', default='localhost')
parser.add_argument('--forward-to-port', default='6667')
parser.add_argument('--user', default=None, required=True)
parser.add_argument('--host', default=None, required=True)
parser.add_argument('--shell-on-failure', default=False, action='store_true')
args = parser.parse_args()

forwardstring = '%s:%s:%s' % (args.localport, args.forward_to_host,
                              args.forward_to_port)

sshstat = subprocess.call(['/usr/bin/ssh',
                           '-a', # No agent forwarding
                           '-E', args.output, # SSH will put all output in a file
                           '-f', # Go into the background after connected
                           '-N', # No remote command will be executed
                           '-L', forwardstring, # Port forward to znc
                           '-o', 'ExitOnForwardFailure=yes', # Will quit if the forward fails
                           '-o', 'ControlMaster=no', # Don't create a control socket
                           '-o', 'ControlPath=none', # Don't share a connection
                           '-T', # Don't allocate a remote PTY
                           '-v', '-v', '-v', # Lots of logging
                           '-x', # No X forwarding
                           '-l', args.user, # User to login as
                           args.host], # Hostname
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

if sshstat != 0:
    sys.stderr.write('COULD NOT START SSH TUNNEL!\n')
    if args.shell_on_failure:
        sys.exit(subprocess.call(['/bin/sh']))

subprocess.call(['/usr/bin/irssi'])

ps = subprocess.Popen(['/bin/ps',
                       '-u', str(os.getuid()),
                       '--no-headers',
                       '-o', 'pid args'],
                      stdout=subprocess.PIPE, stderr=subprocess.PIPE)
killedssh = False
for line in ps.stdout:
    line = line.strip()
    pid, command = line.split(' ', 1)
    if command.startswith('/usr/bin/ssh') and forwardstring in command:
        os.kill(int(pid), signal.SIGTERM)
        killedssh = True
        break

if not killedssh:
    sys.stderr.write('COULD NOT KILL SSH TUNNEL!\n')
    if args.shell_on_failure:
        sys.exit(subprocess.call(['/bin/sh']))
