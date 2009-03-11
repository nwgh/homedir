#!/usr/bin/env python

import getopt
import os
import re
import stat
import sys

def __get_filenum(max_dots, filename):
    """
    """
    parts = filename.split('.')
    if len(parts) == max_dots:
        return 0
    if len(parts) == max_dots + 1:
        return int(parts[-1])
    return -1

def __rotate_cmp(max_dots, s1, s2):
    """Compare strings s1 and s2 of the form <str>[.<num>] based on the
    (optional) .<num> bit (if the .<num> bit doesn't exist, assume .0)
    """
    n1 = __get_filenum(max_dots, s1)
    n2 = __get_filenum(max_dots, s2)
    return cmp(n1, n2)

def __die(msg):
    """Print msg to stderr and exit the program
    """
    print >>sys.stderr, msg
    sys.exit(1)

def __usage(msg=None):
    """Print a usage message (optionally with an error message prepended)
    to stderr and exit the program
    """
    lines = []
    if msg is not None:
        lines.append(msg)
    lines.append("Usage: filerotate [-n num] <dir> <file> "
        "<pattern>")
    __die('\n'.join(lines))

def main():
    """Main function for filerotate
    """
    num_files = 5

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'n:')
    except:
        __usage()

    for o, a in opts:
        if o == '-n':
            try:
                num_files = int(a)
            except:
                __usage()
        else:
            __usage()

    # Make sure we have the right number of arguments
    if len(args) != 3:
        __usage()

    # Make sure we're keeping at least one backup
    if num_files < 1:
        __die('num must be >= 1')
        
    target = args[0]
    source = args[1]
    pattern = args[2]

    # Make sure the first arg is the directory where we keep our files
    mode = os.stat(target)[stat.ST_MODE]
    if not stat.S_ISDIR(mode):
        __die('%s is not a directory' % target)

    # Get the max number of dots in a file
    max_dots = pattern.count('.') + 1

    # Make sure the second arg is the file to rotate in
    mode = os.stat(source)[stat.ST_MODE]
    if not stat.S_ISREG(mode):
        __die('%s is not a file' % source)

    # Get the list of files that match our pattern
    files = os.listdir(target)
    pattern_re = re.compile('^%s(\.[1-9][0-9]*)?$' % re.escape(pattern))
    files = [ f for f in files if pattern_re.match(f) ]

    if len(files) > num_files:
        # Sort the matching files and remove enough to have at most num_files
        # files matching the pattern in the directory
        files.sort(cmp=lambda x, y: __rotate_cmp(max_dots, x, y))
        keep_files = files[:num_files]
        rm_files = files[num_files:]

        # Remove the no-longer needed files
        for f in rm_files:
            try:
                os.unlink('%s/%s' % (target, f))
            except:
                pass
    else:
        # Keeping everything we currently have
        keep_files = files

    # Need to go through the keep files in reverse order
    keep_files.reverse()

    # Rename the already-existing files to one number older
    for f in keep_files:
        new_num = __get_filenum(max_dots, f) + 1
        try:
            os.rename('%s/%s' % (target, f), '%s/%s.%s' % (target, pattern,
                new_num))
        except Exception, e:
            __die('%s\ncould not rotate to %s.%s' % (str(e), pattern, new_num))

    # Copy the new file into the directory
    try:
        os.rename(source, '%s/%s' % (target, pattern))
    except:
        __die('could not insert %s' % source)

if __name__ == '__main__':
    main()
    sys.exit(0)
