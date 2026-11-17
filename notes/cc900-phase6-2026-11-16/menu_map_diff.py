#!/usr/bin/env python3
"""menu_map_diff.py OLD.md NEW.md

Did a regenerated main-CPU menu map (docs/gui/kn5000-menu-map.md) lose any code reference, or only re-credit it?

QUESTION ANSWERED / WHY: scripts/generators/gen_naka_menu_map.py names, on many lines, the routines whose code
opens a title or enters a mode (`also entered by code in` in the Modes table, `(by `R`)` on menu-path lines,
`-> by code, `F`` ...).  When a function moves from hand assembly to firmware C (cc900 phase 6) the generator must
still see its code; a reference the hand source credited to an inner label (`F_Join`) may now be credited to the
function F itself.  The main-CPU twin of lane_hd's notes/cc900-c-hdae5000-2026-11-16/menu_map_diff.py.

A line's key is its text with every backticked routine name and every `+N` overflow count removed, prefixed by the
nearest heading; a table row's key is its first cell.  For every key, each routine name of OLD is

  kept         also named on NEW's line
  re-credited  absent, and NEW names a routine F with OLD = F + "_..." (an inner label of F)
  hidden       absent, but NEW's line still counts at least as many references (names + `+N`), so the
               generator's three-name limit hides it
  DROPPED      none of these: the reference is lost

and every NEW name no OLD name explains is `added`.  A routine name is a backticked name that is not a title, mode,
object, class or event constant (TITLE_ / TT_ / MD_ / OBJ_ / EVT_ / CPL_ / CPR_ prefixes).  Exit 1 when anything
is DROPPED.

    python3 -B notes/cc900-phase6-2026-11-16/menu_map_diff.py OLD.md NEW.md
"""
import re
import sys

TICK = re.compile(r'`([A-Za-z_]\w*)`')
MORE = re.compile(r'\s\+(\d+)\b')
NOT_ROUTINE = ('TITLE_', 'TT_', 'MD_', 'OBJ_', 'EVT_', 'CPL_', 'CPR_')


def routines(text):
    return [n for n in TICK.findall(text) if not n.startswith(NOT_ROUTINE)]


def parse(path):
    """{key: (set of routine names, overflow count)}"""
    out, head = {}, ''
    for line in open(path, encoding='utf-8').read().split('\n'):
        s = line.strip()
        if s.startswith('#'):
            head = s
            continue
        names = routines(s)
        more = sum(int(x) for x in MORE.findall(s))
        if not names and not more:
            continue
        if s.startswith('|'):
            key = head + ' || ' + s.split('|')[1].strip()
        else:
            key = head + ' || ' + MORE.sub('', TICK.sub(lambda m: '' if not m.group(1).startswith(NOT_ROUTINE)
                                                          else m.group(0), s))
        n, k = out.get(key, (set(), 0))
        out[key] = (n | set(names), k + more)
    return out


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    old, new = parse(sys.argv[1]), parse(sys.argv[2])
    kept = rec = hidden = 0
    dropped, added, recs = [], [], []
    for key, (on, om) in sorted(old.items()):
        nn, nm = new.get(key, (set(), 0))
        explained = set()
        missing = []
        for r in sorted(on):
            if r in nn:
                kept += 1
                explained.add(r)
            else:
                f = [x for x in nn if r.startswith(x + '_')]
                if f:
                    rec += 1
                    explained.add(max(f, key=len))
                    recs.append((key, r, max(f, key=len)))
                else:
                    missing.append(r)
        room = (len(nn) + nm) - (len(on) + om)          # references NEW's line counts beyond OLD's
        for r in missing:
            if nm and room >= 0:
                hidden += 1
            else:
                dropped.append((key, r))
        for x in sorted(nn - on - explained):
            added.append((key, x))
    for key in sorted(set(new) - set(old)):
        for x in sorted(new[key][0]):
            added.append((key, x))
    print('kept %d, re-credited %d, hidden by the name limit %d, DROPPED %d, added %d'
          % (kept, rec, hidden, len(dropped), len(added)))
    for key, r, f in recs:
        print('  re-credited  %-40s -> %-32s  %s' % (r, f, key[:110]))
    for key, r in dropped:
        print('  DROPPED      %-40s  %s' % (r, key[:110]))
    for key, x in added:
        print('  added        %-40s  %s' % (x, key[:110]))
    sys.exit(1 if dropped else 0)


if __name__ == '__main__':
    main()
