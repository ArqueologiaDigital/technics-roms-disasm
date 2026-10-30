"""Helper of the port-edit scripts in this folder: exact, counted text replacement.

Each script here records one hand edit of hdae5000_v1_15i/ (README.md lists the order).
They match the exact text the tree had at the time, so they do not apply a second time.
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
TREE = os.environ.get("PORT_TREE", "hdae5000_v1_15i")


def path(f):
    return os.path.join(ROOT, TREE, f)


def read(f):
    return open(path(f), "rb").read()


def write(f, s):
    open(path(f), "wb").write(s)


def replace(f, pairs):
    """pairs: [(old, new[, count])] of bytes; each old must occur exactly count (default 1) times."""
    s = read(f)
    for p in pairs:
        old, new = p[0], p[1]
        n = p[2] if len(p) > 2 else 1
        c = s.count(old)
        if c != n:
            sys.exit("%s: %r occurs %d times, expected %d" % (f, old[:80], c, n))
        s = s.replace(old, new)
    write(f, s)


def _is_comment(ln):
    return ln.lstrip().startswith(b";")


def delete_routine(f, label, next_label, keep_header=True):
    """Delete the routine `label` of file f up to `next_label` (exclusive): from its own
    header comment (the comment lines right above it) to the header comment of next_label.
    Returns the deleted lines."""
    L = read(f).split(b"\n")
    starts = [i for i, ln in enumerate(L) if ln.startswith(label.encode() + b":")]
    ends = ([i for i, ln in enumerate(L) if ln.startswith(next_label.encode() + b":")]
            if next_label else [len(L)])
    if len(starts) != 1 or len(ends) != 1 or ends[0] <= starts[0]:
        sys.exit("%s: %s / %s not found once, in order" % (f, label, next_label))
    s, e = starts[0], ends[0]
    while s > 0 and _is_comment(L[s - 1]):
        s -= 1
    while keep_header and e > s and (_is_comment(L[e - 1]) or not L[e - 1].strip()):
        e -= 1
    gone = L[s:e]
    L[s:e] = []
    write(f, b"\n".join(L))
    return gone


def next_routine(f, label):
    """The first label after `label` that is neither a local (.L) one nor `label`_<suffix>."""
    import re
    L = read(f).split(b"\n")
    k = [i for i, ln in enumerate(L) if ln.startswith(label.encode() + b":")][0]
    for ln in L[k + 1:]:
        m = re.match(rb"^([A-Za-z_][A-Za-z0-9_]*):", ln)
        if m and not m.group(1).startswith(label.encode() + b"_"):
            return m.group(1).decode()
    return None


def delete_routines(f, labels):
    for lab in labels:
        nxt = next_routine(f, lab)
        gone = delete_routine(f, lab, nxt)
        print("%s: deleted %s (%d lines, up to %s)" % (f, lab, len(gone), nxt))


def delete_block(f, label, keep_header=True):
    """Delete the data block at `label` up to the next label of any kind (its own header
    comment lines included, the next one's kept).  Returns the deleted lines."""
    import re
    L = read(f).split(b"\n")
    k = [i for i, ln in enumerate(L) if ln.startswith(label.encode() + b":")]
    if len(k) != 1:
        sys.exit("%s: label %s found %d times" % (f, label, len(k)))
    k = k[0]
    e = next((i for i in range(k + 1, len(L)) if re.match(rb"^[A-Za-z_.][A-Za-z0-9_]*:", L[i])), len(L))
    return delete_routine(f, label, L[e].split(b":")[0].decode() if e < len(L) else None, keep_header)


def delete_lines(f, lines):
    """Delete each of the given exact lines (bytes, without newline), each exactly once."""
    L = read(f).split(b"\n")
    for x in lines:
        k = [i for i, ln in enumerate(L) if ln == x]
        if len(k) != 1:
            sys.exit("%s: line %r found %d times" % (f, x, len(k)))
        del L[k[0]]
    write(f, b"\n".join(L))


def delete_record(f, label):
    """Delete from the line `label:` through the first blank line after it."""
    L = read(f).split(b"\n")
    k = [i for i, ln in enumerate(L) if ln.startswith(label.encode() + b":")]
    if len(k) != 1:
        sys.exit("%s: label %s found %d times" % (f, label, len(k)))
    e = next(i for i in range(k[0], len(L)) if not L[i].strip())
    del L[k[0]:e + 1]
    write(f, b"\n".join(L))


def delete_between(f, start_label, end_label):
    """Delete the lines from `start_label:` up to `end_label:` (exclusive) and send every
    reference to start_label to end_label instead (a block the target lacks, whose callers'
    branches now land on what followed it)."""
    import re
    L = read(f).split(b"\n")
    s = [i for i, ln in enumerate(L) if ln.startswith(start_label.encode() + b":")]
    e = [i for i, ln in enumerate(L) if ln.startswith(end_label.encode() + b":")]
    if len(s) != 1 or len(e) != 1 or e[0] <= s[0]:
        sys.exit("%s: %s / %s not found once, in order" % (f, start_label, end_label))
    del L[s[0]:e[0]]
    pat = re.compile(rb"(?<![\w.])" + re.escape(start_label.encode()) + rb"(?![\w])")
    L = [pat.sub(end_label.encode(), ln) for ln in L]
    write(f, b"\n".join(L))
