#!/todesschaf/bin/python
import feedparser
import optparse
import time

from todesschaf import tx

def get_lj(since=None):
    """Get up to the 25 most recent livejournal entries.

    since - <int> Timestamp to get all entries after (get all 25 if None)
    """
    feed = feedparser.parse('http://todesschaf.livejournal.com/data/atom')
    if feed['status'] != 200:
        # Hrm, something went wrong. Panic!
        return []

    entries = []
    #for entry in feed['entries']:
    #    tstamp = time.mktime(entry['updated_parsed'])
    #    if since and tstamp <= since:
    #        # We've reached the end of what we care about
    #        break
    #    entries.append({'title':str(entry['title']),
    #                    'content':str(entry['content']),
    #                    'tstamp':tstamp, 'link':entry['link'],
    #                    'source':'livejournal'})

    return entries, time.mktime(feed['updated'])

def get_twitter(since=None):
    """Get up to the 20 most recent tweets.

    since - <int> Timestamp to get all tweets after (get all 20 if None)
    """
    feed = feedparser.parse(
        'http://twitter.com/statuses/user_timeline/14691220.rss')
    if feed['status'] != 200:
        # Hrm, something went wrong. Panic!
        return []

    entries = []
    for entry in feed['entries']:
        tstamp = time.mktime(entry['updated_parsed'])
        if since and tstamp <= since:
            # We've reached the end of what we care about
            break
        content = entry['title']
        if content.startswith('todesschaf: '):
            content = content[12:]
        entries.append({'title':'Tweet, Tweet!', 'content':content,
                        'tstamp':tstamp, 'link':entry['link'],
                        'source':'twitter'})

    return entries, time.mktime(feed['updated'])

if __name__ == '__main__':
    tx.start(user='hurley')
    tx.execute('SELECT * FROM feed_times')
    last_times = tx.dictfetchone()

    try:
        ljentries, ljtstamp = get_lj(last_times['livejournal'])
    except:
        ljentries = []
        ljtstamp = last_times['livejournal']

    try:
        twentries, twtstamp = get_twitter(last_times['twitter'])
    except:
        twentries = []
        twtstamp = last_times['twitter']

    entries = ljentries + twentries
    entries.sort(key=lambda x: x['tstamp'], reverse=True)

    for entry in entries:
        tx.execute(
            """INSERT INTO feed (tstamp, title, content, link, source)
               VALUES (%s, %s, %s, %s, %s)""",
            (entry['tstamp'], entry['title'], entry['content'], entry['link'],
             entry['source']))

    tx.execute("UPDATE feed_times SET livejournal = %s, twitter = %s",
        (ljtstamp, twtstamp))
    tx.finish()
