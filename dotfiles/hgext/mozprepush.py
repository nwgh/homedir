#!/usr/bin/env python

def mozprepush(**kwargs):
    ui = kwargs['ui']
    default = ui.config('paths', 'default', default='')
    dflt_push = ui.config('paths', 'default-push', default=default)
    urls = []
    for p in kwargs['pats']:
        if p.startswith('http://') or p.startswith('https://') or \
           p.startswith('ssh://'):
            urls.append(p)
        else:
            url = ui.config('paths', p, default=None)
            if url:
                urls.append(url)

    if not urls:
        urls = [dflt_push]

    for u in urls:
        if 'mozilla-central' in u:
            ui.write('Not pushing to mozilla-central!\n')
            return True
