#!/usr/bin/env python

import argparse
import os
import sys
import textwrap

HOME = os.getenv('HOME')
LIBPATH = os.path.abspath(os.path.join(HOME, 'src', 'mozilla', 'm-c',
                                       'security', 'manager', 'ssl', 'tests',
                                       'unit', 'psm_common_py'))
sys.path.append(LIBPATH)


def error(message):
    lines = textwrap.wrap(message)
    sys.stderr.write('%s\n' % '\n'.join(lines))
    sys.exit(1)


try:
    import CertUtils
except ImportError:
    error('Could not import CertUtils. Does it exist in %s?' % (LIBPATH,))


CA_BASIC_CONSTRAINTS = 'basicConstraints = critical, CA:TRUE\n'
CA_KEY_USAGE = 'keyUsage = keyCertSign, cRLSign\n'

EE_BASIC_CONSTRAINTS = 'basicConstraints = CA:FALSE\n'

AUTHORITY_KEY_IDENT = 'authorityKeyIdentifier = keyid, issuer\n'
SUBJECT_KEY_IDENT = 'subjectKeyIdentifier = hash\n'


def gen_cert(cliopts, extensions, ca_key=None, ca_cert=None, subject=None):
    return CertUtils.generate_cert_generic(cliopts.output_dir,
                                           cliopts.output_dir, cliopts.serial,
                                           'rsa', cliopts.certname, extensions,
                                           ca_key, ca_cert, subject)


def gen_ca(cliopts):
    subject = None
    if cliopts.subject:
        subject = '/CN=%s' % (cliopts.subject,)
    nameconstraints = ''
    for index, nameconstraint in enumerate(cliopts.nameconstraints):
        c1 = 'nameConstraints = permitted;DNS.%d:%s' % (2 * index,
                                                        nameconstraint)
        c2 = 'nameConstraints = permitted;DNS.%d:.%s' % (2 * index + 1,
                                                         nameconstraint)
        nameconstraints += '%s\n%s\n' % (c1, c2)
    for index, ipconstraint in enumerate(cliopts.ipconstraints):
        nameconstraints += 'nameConstraints = permitted:IP.%d:%s' % \
            (index, ipconstraint)
    return gen_cert(cliopts,
                    CA_BASIC_CONSTRAINTS + CA_KEY_USAGE + SUBJECT_KEY_IDENT,
                    subject=subject)


def gen_ee(cliopts):
    extensions = EE_BASIC_CONSTRAINTS + AUTHORITY_KEY_IDENT
    altnames = 'subjectAltName = DNS.0:%s\n' % (cliopts.subject,)
    for index, altname in enumerate(cliopts.altnames):
        altnames += 'subjectAltName = DNS.%d:%s\n' % (index + 1, altname)
    for index, altip in enumerate(cliopts.altips):
        altnames += 'subjectAltName = IP.%d:%s\n' % (index, altip)
    extensions += altnames
    subject = '/CN=%s' % (cliopts.subject,)
    return gen_cert(cliopts, extensions, cliopts.ca_key, cliopts.ca_cert,
                    subject)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate a certificate')
    parser.add_argument('-n', dest='subject', help='CN of end entity')
    parser.add_argument('-d', dest='output_dir', required=True,
                        help='Output directory')
    parser.add_argument('-o', dest='certname', required=True,
                        help='Certificate Name')
    parser.add_argument('-s', dest='serial', required=True,
                        help='Certificate serial number or file with serial')
    parser.add_argument('-k', dest='ca_key', help='Path to signing CA key')
    parser.add_argument('-c', dest='ca_cert', help='Path to signing CA cert')
    parser.add_argument('-a', dest='altnames', action='append',
                        help='Subject Alternate DNS Name(s)')
    parser.add_argument('-i', dest='altips', action='append',
                        help='Subject Alternate IP Address(es)')
    parser.add_argument('-l', dest='nameconstraints', action='append',
                        help='DNS nameConstraint')
    parser.add_argument('-j', dest='ipconstraints', action='append',
                        help='IP Address nameConstraint')

    opts = parser.parse_args()

    if bool(opts.ca_key) != bool(opts.ca_cert):
        error('Either both -k and -c must be present to generate an EE cert, '
              'or neither must be present to generate a CA cert')

    serialfile = None
    try:
        opts.serial = int(opts.serial)
    except ValueError:
        serialfile = opts.serial
        try:
            with file(serialfile) as f:
                opts.serial = int(f.read().strip())
        except:
            error('Could not get serial from %s' % (opts.serial,))

    if serialfile:
        with file(serialfile, 'w') as f:
            f.write('%d' % (opts.serial + 1,))

    if opts.altnames is None:
        opts.altnames = []

    if opts.altips is None:
        opts.altips = []

    if opts.nameconstraints is None:
        opts.nameconstraints = []

    if opts.ipconstraints is None:
        opts.ipconstraints = []

    if opts.ca_key:
        if not opts.subject:
            error('You must supply a subject for an end-entity certificate')
        if opts.namecosntraints or opts.ipconstraints:
            error('You may not have any name constraints for an end-entity '
                  'certificate')
        generate = gen_ee
    else:
        if opts.altnames or opts.altips:
            error('You may not have any alternate names for a CA certificate')
        generate = gen_ca

    key, cert = generate(opts)
    os.unlink(os.path.join(opts.output_dir, 'openssl-exts'))
    msg = 'Your key is at %s and your cert is at %s' % (key, cert)
    sys.stdout.write('%s\n' % '\n'.join(textwrap.wrap(msg)))
