#!/usr/bin/env python3
"""Apply the wave-3/4 lanes' ITEM-OUTCOMES blocks to notes/open-items/triage.json.

Each outcome line: <id> <CLOSED|BLOCKED|OPEN> <evidence / blocker / plan>.  CLOSED -> RESOLVED (evidence),
BLOCKED -> BLOCKED (blocker), OPEN -> ACTIONABLE (plan, owner cleared).  Ids not in triage.json are reported.
"""
import json, re, sys, glob, os
TRIAGE = sys.argv[1]
d = json.load(open(TRIAGE))
applied, missing = 0, []
for path in sorted(glob.glob(os.path.join(sys.argv[2], '*.txt'))):
    lane = os.path.basename(path)[:-4]
    for line in open(path):
        m = re.match(r'^(\S+)\s+(CLOSED|BLOCKED|OPEN)\s+(.*)$', line.rstrip())
        if not m:
            continue
        iid, st, text = m.groups()
        if iid not in d:
            missing.append((lane, iid)); continue
        row = d[iid]
        for k in ('evidence', 'blocker', 'plan', 'owner'):
            row.pop(k, None)
        if st == 'CLOSED':
            row['status'] = 'RESOLVED'; row['evidence'] = f'lane {lane} (2026-10-31): {text}'
        elif st == 'BLOCKED':
            row['status'] = 'BLOCKED'; row['blocker'] = f'{text} (lane {lane}, 2026-10-31)'
        else:
            row['status'] = 'ACTIONABLE'; row['plan'] = f'{text} (lane {lane}, 2026-10-31)'
            row.setdefault('size', 'M')
        applied += 1
json.dump(d, open(TRIAGE, 'w'), indent=1, ensure_ascii=False); open(TRIAGE, 'a').write('\n')
print('applied', applied)
for lane, iid in missing: print('not in triage:', lane, iid)
