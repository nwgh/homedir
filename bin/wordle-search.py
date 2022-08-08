#!/usr/bin/env python3

import argparse
import os
import sys


def die(msg):
    print(msg)
    sys.exit(1)


parser = argparse.ArgumentParser()
parser.add_argument('--contains')
parser.add_argument('--not-contains')
parser.add_argument('pattern')
args = parser.parse_args()

if args.contains and not args.contains.isalpha():
    die(f'Contains list must be letters a-z: {args.contains}')
if args.not_contains and not args.not_contains.isalpha():
    die(f'Does not contain list must be letters a-z: {args.not_contains}')

if args.contains and args.not_contains:
    overlap = set(args.contains).intersection(set(args.not_contains))
    if overlap:
        print('Contains and does not contain lists share one or more elements:')
        die(''.join(c for c in overlap))

pipeline = [f"grep -i '^{args.pattern}$' /usr/share/dict/words"]
if args.contains:
    for c in args.contains:
        pipeline.append(f'grep -i {c}')
if args.not_contains:
    for c in args.not_contains:
        pipeline.append(f'grep -i -v {c}')

cmd = ' | '.join(pipeline)
os.system(cmd)
