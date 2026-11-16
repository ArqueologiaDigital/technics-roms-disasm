#!/usr/bin/env python3
"""Did a regenerated HD-AE5000 menu map lose any code reference, or only re-credit it?

QUESTION ANSWERED: scripts/analysis/hdae5000_menu_map.py lists, per UI object, the routines whose code names the
object's id ("-- code: `A`, `B`" on the object's line, "- named in code by: `A`, ..." under a top-level object).
When a function moves from hand assembly to firmware C (cc900 phase 6), a reference that the hand source credited to
an inner label of the function (`F_Join`, `F_Skip`) is credited to the function `F` itself.  This compares an OLD and
a NEW map and classifies every (object, routine) reference of OLD:

  kept         the same routine is credited for the object in NEW
  re-credited  the routine is gone, and NEW credits a routine F for the same object with OLD = F + "_..." (an inner
               label of F); several inner labels may collapse into one F
  DROPPED      neither: the reference is lost

and every reference of NEW that no OLD reference explains (added).  Exit 1 when anything is DROPPED.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/menu_map_diff.py OLD.md NEW.md

An object is keyed by the text of its line before " -- code:", or, for a "named in code by" line, by the nearest
heading or object line above it.
"""
import re, sys

NAME = re.compile(r'`([A-Za-z_]\w*)`')


def refs(path):
    out, key = {}, None
    for l in open(path, encoding='utf-8').read().split('\n'):
        s = l.strip()
        if ' -- code: ' in s:
            k, code = s.split(' -- code: ', 1)
            out.setdefault(k, [])
            out[k] += NAME.findall(code)
            key = k
        elif s.startswith('- named in code by: '):
            out.setdefault(key, [])
            out[key] += NAME.findall(s[len('- named in code by: '):])
        elif s.startswith('#') or s.startswith('- `'):
            key = s
    return out


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    old, new = refs(sys.argv[1]), refs(sys.argv[2])
    kept = rec = 0
    dropped, added, recs = [], [], {}
    for k, rs in old.items():
        ns = new.get(k, [])
        used = set()
        for r in rs:
            if r in ns:
                kept += 1
                used.add(r)
                continue
            f = [n for n in ns if r.startswith(n + '_')]
            if f:
                best = max(f, key=len)
                rec += 1
                used.add(best)
                recs.setdefault((r, best), 0)
                recs[(r, best)] += 1
            else:
                dropped.append((k, r))
        added += [(k, n) for n in ns if n not in used]
    added += [(k, n) for k, ns in new.items() if k not in old for n in ns]
    print('objects with code references: old %d, new %d' % (sum(1 for v in old.values() if v),
                                                           sum(1 for v in new.values() if v)))
    print('references: old %d, new %d' % (sum(len(v) for v in old.values()), sum(len(v) for v in new.values())))
    print('kept %d, re-credited %d, DROPPED %d, added %d' % (kept, rec, len(dropped), len(added)))
    for (r, f), n in sorted(recs.items()):
        print('  re-credited  %s -> %s  (%d)' % (r, f, n))
    for k, r in dropped:
        print('  DROPPED  %s  from  %s' % (r, k[:90]))
    for k, n in added:
        print('  added  %s  to  %s' % (n, k[:90]))
    return 1 if dropped else 0


if __name__ == '__main__':
    sys.exit(main())
