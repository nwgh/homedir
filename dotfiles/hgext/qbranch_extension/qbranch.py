from mercurial import extensions
from mercurial import util

mq = extensions.find('mq')

def find_current_guard(q):
    """Returns the name of the current active guard, or None if none are active
    """
    guards = q.active()
    if not guards:
        return None

    if isinstance(guards, str):
        return guards

    return guards[0]

def add_guard(ui, repo, *args, **kwargs):
    """If configured properly, add the current guard to the newly-created
    patch
    """
    if not ui.configbool('qbranch', 'autoguard', default=True):
        # User doesn't want us doing this
        return

    if not repo.mq.applied:
        # Strange, we somehow got called with no patches applied
        return

    guard = find_current_guard(repo.mq)
    if not guard:
        # No active guards, nothing to do here
        return

    # Make the list with positive guard as expected by setguards()
    guards = ['+%s' % (guard,)]

    # Figure out the index of our patch
    patch = repo.mq.applied[-1].name
    idx = repo.mq.findseries(patch)

    # Finally, do the real work
    repo.mq.setguards(idx, guards)
    repo.mq.savedirty()

def uisetup(ui):
    """Set up a hook to (maybe) add the current guard to the
    newly-created patch
    """
    ui.setconfig('hooks', 'post-qnew.qbranch', add_guard)

def run_qbranch(ui, repo, *args, **kwargs):
    """Treat your mercurial queues kind of like git local branches!

    This uses patch guards as "branch" names, and allows you to switch between
    them. Assume you have 2 features you're working on in parallel, featureA and
    featureB, along with patches that are guarded +featureA or +featureB, as
    appropriate.

    hg qbranch featureA

    will set featureA to be the ONLY active guard, and push all the patches
    with the +featureA guard set. If you later do

    hg qbranch featureB

    then all the patches with +featureA will be popped, featureB will be set as
    the ONLY active guard, and all the patches with the +featureB guard will
    be pushed. Finally

    hg qbranch

    will set no guards as active, and pop any guarded mq entries.
    If, while pushing patches, one fails to apply, the operation will abort, and
    you will have to fix the problems, qrefresh, and continue to qpush on your
    own (or fix, qrefresh, and re-do the qbranch).

    By default, enabling this extension will make it so that any time you do a
    hg qnew, the patch that you create will be given a positive guard on
    whatever the current active guard is. So, if you have featureA as your
    current active guard, doing

    hg qnew foo.patch

    will have the same effect as

    hg qnew foo.patch
    hg qguard foo.patch +featureA

    if you didn't have this extension installed. If you don't want this
    functionality, set qbranch.autoguard = False in the appropriate hgrc.
    """
    if len(args) > 1:
        raise util.Abort('usage: hg qbranch [name]\n')

    # First, pop all our patches, we'll apply the appropriate ones later
    mq.pop(ui, repo, all=True)

    # Now set the current guard (or not) as appropriate
    if args:
        mq.select(ui, repo, args[0], none=True)
    else:
        mq.select(ui, repo, none=True)

    # Go through and push all the eligible patches
    for idx, patch in enumerate(repo.mq.series):
        if repo.mq.pushable(idx)[0]:
            if mq.push(ui, repo, patch, move=True) != 0:
                raise util.Abort('Error applying patches. Fix the problem, '
                        'then qrefresh, then re-run qbranch.\n')

cmdtable = {
    'qbranch':(run_qbranch, [], 'hg qbranch [name]'),
}
