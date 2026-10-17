#!/usr/bin/env python3
"""For every routine that compares XBC with EVT_GET_LSW_DATA_NO / EVT_GET_LSW_ADDRESS and branches, print the
routine (nearest preceding non-local label), the arm label and the first instructions of the arm (read-only)."""
import glob, os, re, sys
root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))) + '/'
tree = sys.argv[1] if len(sys.argv) > 1 else 'v10'
EV = ('EVT_GET_LSW_DATA_NO', 'EVT_GET_LSW_ADDRESS')
for p in sorted(glob.glob(root + tree + '/maincpu/**/*.s', recursive=True)):
    L = open(p, 'rb').read().decode('latin-1').split('\n')
    labels = {}
    for i, l in enumerate(L):
        m = re.match(r'^([A-Za-z_.$][\w.$]*):', l)
        if m: labels[m.group(1)] = i
    for i, l in enumerate(L):
        m = re.match(r'\s+cp\s+x(bc|iz|de|wa)\s*,\s*(EVT_GET_LSW_DATA_NO|EVT_GET_LSW_ADDRESS)\s*$', l)
        if not m: continue
        j = re.match(r'\s+(jrl?|jp)\s+(z|eq)\s*,\s*(\w+)', L[i+1]) if i+1 < len(L) else None
        fn = None
        for k in range(i, -1, -1):
            mm = re.match(r'^([A-Za-z_][\w]*):', L[k])
            if mm and not re.search(r'_(Skip|Join|Loop|Return|Done|Next|Exit|Cont|End|Default|Resume|Nop)\d*$', mm.group(1)):
                fn = mm.group(1); break
        arm = j.group(3) if j else None
        body = []
        if arm and arm in labels:
            k = labels[arm] + 1
            while len(body) < 4 and k < len(L):
                t = L[k].split(';')[0].strip()
                if t: body.append(t)
                k += 1
        elif not j:
            # fall-through arm (jr nz to elsewhere)
            k = i + 2
            while len(body) < 4 and k < len(L):
                t = L[k].split(';')[0].strip()
                if t: body.append(t)
                k += 1
            arm = '(fallthrough after %s)' % L[i+1].strip()
        print('%-6s %-40s %-36s | %s' % ('DATA' if 'DATA' in m.group(2) else 'ADDR', fn, arm, ' ; '.join(body)), '|', p.split('/maincpu/')[1] + ':' + str(i+1))
