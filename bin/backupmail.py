#!/usr/bin/env python

import os
import sys
import tempfile

fd, fname = tempfile.mkstemp()
os.system("/bin/tar cjf %s /home/hurley/Maildir" % fname)
os.system("/home/hurley/bin/filerotate.py /home/hurley/mailbackups %s mail" %
    fname)
os.close(fd)

sys.exit(0)
