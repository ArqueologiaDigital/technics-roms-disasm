#!/usr/bin/env python3
"""annotate_seq_wrapper_callers.py -- give one-line wrapper headers in v10/maincpu/sequencer their call sites.

QUESTION IT ANSWERS / JOB IT DOES
  About 70 routines in v10/maincpu/sequencer are thin wrappers (`push xiz / call X / pop xiz / ret`, a
  `jp X`, a fixed three-byte rhythm message).  Their header can say little more than "Calls X with XIZ
  preserved", which a reader could get from the four instructions.  What the instructions do NOT say is
  who uses the wrapper.  This script finds every single-line header of that shape (a comment line that
  starts with "Calls", "Jumps to", "Tail-calls" or "Sends the three-byte", directly above the label) and
  adds a second line naming the labels that reference the wrapper in the v10 maincpu sources (.s, .c,
  .h; comments ignored).  Each site is named by the nearest label above it, which may be a local branch
  label inside a larger routine.

  "Called from" is used when every reference is a call / calr; otherwise "Reached from".  More than
  six sites are cut to six plus a count.  The list covers textual references only: a call from a
  compiled-C .incbin blob that is not spelled symbolically would not be seen, so the line never claims
  to be the complete caller set.

  Comments only: bytes do not change (make gate).  Re-running is a no-op, because an annotated header
  is no longer directly above its label.

USAGE
  python3 scripts/tools/annotate_seq_wrapper_callers.py           # rewrite in place
  python3 scripts/tools/annotate_seq_wrapper_callers.py --check   # print what would change, exit 1 if any
"""
import os
import re
import sys
import textwrap

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MAINCPU = os.path.join(ROOT, 'v10', 'maincpu')
SEQ = os.path.join(MAINCPU, 'sequencer')
HEAD = re.compile(rb'^; (Calls|Jumps to|Tail-calls|Sends the three-byte)[^;]{0,90}\.$')
LABEL = re.compile(rb'^([A-Za-z_]\w*):')
MAXSITES = 6
WIDTH = 100


def load_sources():
    out = {}
    for d, _, fs in os.walk(MAINCPU):
        for f in sorted(fs):
            if f.endswith(('.s', '.c', '.h')):
                p = os.path.join(d, f)
                out[p] = open(p, 'rb').read()
    return out


def references(sources, lab):
    """Ordered, de-duplicated (site label, is_call) for every non-comment reference to lab."""
    rx = re.compile(rb'\b' + re.escape(lab) + rb'\b')
    sites = []
    for p in sorted(sources):
        cur = None
        for line in sources[p].split(b'\n'):
            m = LABEL.match(line)
            if m:
                cur = m.group(1)
            code = line.split(b';')[0].split(b'//')[0]
            if m and m.group(1) == lab:
                continue
            if cur is None or not rx.search(code):
                continue
            is_call = bool(re.match(rb'\s*(call|calr)\b', code))
            sites.append((cur, is_call))
    seen, out = set(), []
    calls_only = all(c for _, c in sites)
    for s, _ in sites:
        if s not in seen:
            seen.add(s)
            out.append(s.decode())
    return out, calls_only


def wrap(text):
    return '\n'.join(textwrap.wrap(text, WIDTH, initial_indent='; ', subsequent_indent='; ',
                                   break_on_hyphens=False, break_long_words=False))


def annotation(sites, calls_only):
    shown = sites[:MAXSITES]
    if len(shown) == 1:
        body = shown[0]
    else:
        body = ', '.join(shown[:-1]) + (', ' if len(sites) > MAXSITES else ' and ') + shown[-1]
    if len(sites) > MAXSITES:
        more = len(sites) - MAXSITES
        body +=' and %d more site%s' % (more, '' if more == 1 else 's')
    verb = 'Called from' if calls_only else 'Reached from'
    return wrap(verb + ' ' + body + '.').encode()


def main():
    check = '--check' in sys.argv
    sources = load_sources()
    total = 0
    for f in sorted(os.listdir(SEQ)):
        if not f.endswith('.s'):
            continue
        p = os.path.join(SEQ, f)
        lines = sources[p].split(b'\n')
        out, n = [], 0
        for i, line in enumerate(lines):
            out.append(line)
            if not HEAD.match(line) or i + 1 >= len(lines):
                continue
            m = LABEL.match(lines[i + 1])
            if not m:
                continue
            sites, calls_only = references(sources, m.group(1))
            if not sites:
                continue
            ann = annotation(sites, calls_only)
            out.append(ann)
            n += 1
            if check:
                print('%s: %s\n  %s' % (f, m.group(1).decode(), ann.decode().replace('\n', '\n  ')))
        total += n
        if n and not check:
            open(p, 'wb').write(b'\n'.join(out))
            print('%s: %d header(s) annotated' % (f, n))
    print('total: %d' % total)
    return 1 if (check and total) else 0


if __name__ == '__main__':
    sys.exit(main())
