#!/usr/bin/env python

import sys

MOD_BASE_OFFSET = 0x45
COMPONENTS = [
        None,
        'XPCOM',
        'BASE',
        'GFX',
        'WIDGET',
        'CALENDAR',
        'NETWORK',
        'PLUGINS',
        'LAYOUT',
        'HTMLPARSER',
        'RDF',
        'UCONV',
        'REG',
        'FILES',
        'DOM',
        'IMGLIB',
        'MAILNEWS',
        'EDITOR',
        'XPCONNECT',
        'PROFILE',
        'LDAP',
        'SECURITY',
        'DOM_XPATH',
        'DOM_RANGE',
        'URILOADER',
        'CONTENT',
        'PYXPCOM',
        'XSLT',
        'IPC',
        'SVG',
        'STORAGE',
        'SCHEMA',
        'DOM_FILE',
        'DOM_INDEXEDDB',
        'DOM_EVENTS'
]

err = 0

try:
    err = int(sys.argv[1], 10)
except ValueError:
    try:
        err = int(sys.argv[1], 16)
    except ValueError:
        sys.stderr.write('Invalid input (neither decimal nor hex): %s' % sys.argv[1])
        sys.exit(1)

is_error = False
if (err >> 31) & 0x1:
    is_error = True

component = ((err >> 16) - MOD_BASE_OFFSET) & 0x1fff
code = err & 0xffff

comp_name = 'Unknown'
if component == 51:
    comp_name = 'General'
elif component and component < len(COMPONENTS):
    comp_name = COMPONENTS[component]

if is_error:
    sys.stdout.write('Error')
else:
    sys.stdout.write('Success')
sys.stdout.write(': Component %s (%s), Code %s\n' % (component, comp_name, code))
