#!/usr/bin/env python3
"""Apply the wave-3/4 lanes' ITEM-OUTCOMES blocks to notes/open-items/triage.json.

Each outcome line: <id> <CLOSED|BLOCKED|OPEN> <evidence / blocker / plan>.  CLOSED -> RESOLVED (evidence),
BLOCKED -> BLOCKED (blocker), OPEN -> ACTIONABLE (plan, owner cleared).  Ids not in triage.json are reported.
"""
import json, re, sys, glob, os
TRIAGE = sys.argv[1]
d = json.load(open(TRIAGE))
# the date the lanes reported: the outcome folder's name ends in it (outcomes-YYYY-MM-DD), else argv[3]
m_date = re.search(r'(\d{4}-\d{2}-\d{2})', os.path.basename(os.path.normpath(sys.argv[2])))
DATE = sys.argv[3] if len(sys.argv) > 3 else (m_date.group(1) if m_date else sys.exit('give the date as argv[3]'))
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
            row['status'] = 'RESOLVED'; row['evidence'] = f'lane {lane} ({DATE}): {text}'
        elif st == 'BLOCKED':
            row['status'] = 'BLOCKED'; row['blocker'] = f'{text} (lane {lane}, {DATE})'
        else:
            row['status'] = 'ACTIONABLE'; row['plan'] = f'{text} (lane {lane}, {DATE})'
            row.setdefault('size', 'M')
        applied += 1
json.dump(d, open(TRIAGE, 'w'), indent=1, ensure_ascii=False); open(TRIAGE, 'a').write('\n')
print('applied', applied)
for lane, iid in missing: print('not in triage:', lane, iid)
