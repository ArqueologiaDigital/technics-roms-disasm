#!/usr/bin/env python3
"""Which survey candidates go to which C-drafting helper (pools/pool_<TAG>.txt)?

QUESTION ANSWERED: the leaf and absolute-call-only routines of survey.tsv that are not hand assembly, have no
memory-to-memory move and were not tried in round 1, split by hand source into five pools (A: 05 + 07, B: 06 + 09,
C: 08 + 10, D: 11 / 12 / 13, E: 14 and the rest).  subcpu_fp_math.s is left out: it is Toshiba's double library.
Columns: bytes, instructions, label, hand source, kind, erp / nop counts, and the runtime routines (FP_* / Math_* /
Int_*) it calls, which need a name map before V4.23's calls can be checked.
    python3 -B notes/cc900-c-subcpu-2026-11-16/pools.py      (from the repository root)
"""
import re, sys, collections
import os
R=os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
rows=[l.rstrip('\n').split('\t') for l in open(R+'/notes/cc900-c-subcpu-2026-11-16/survey.tsv')][1:]
done=set(l.split('\t')[0] for l in list(open(R+'/notes/cc900-c-subcpu-2026-11-16/verdicts/2026-11-16-43-sub-r1.tsv'))[1:])
perfile=collections.defaultdict(list)
for r in rows: perfile[r[4]].append(r)
def body(r):
    lines=open(R+'/v142/subcpu/'+r[4],encoding='latin-1').read().split('\n')
    sib=sorted(perfile[r[4]],key=lambda x:int(x[0],16)); a=int(r[0],16)
    nxt=[x for x in sib if int(x[0],16)>a]
    s=next(i for i,l in enumerate(lines) if re.match(re.escape(r[3])+r':',l))
    e=next(i for i,l in enumerate(lines) if re.match(re.escape(nxt[0][3])+r':',l)) if nxt else len(lines)
    return [l.split(';')[0] for l in lines[s:e]]
pools=collections.defaultdict(list)
assign={'core/05_voice_params_and_tvf.s':'A','core/07_voice_ctrlchange.s':'A','core/06_voice_envelopes_and_channels.s':'B',
 'core/09_dsp_algo_select.s':'B','core/08_voice_noteon_and_tonegen.s':'C','core/10_dsp_voice_params.s':'C'}
for r in rows:
    if r[4]=='subcpu_fp_math.s': continue   # Toshiba's double library: library C, not ours
    if r[6] not in ('leaf','abs') or r[5]=='hand' or r[1]=='None' or r[14]!='0' or r[3] in done: continue
    b=body(r)
    tg=[m.group(1) for l in b for m in [re.match(r'\s+call\s+(\w+)',l)] if m]
    rt=sorted(set(t for t in tg if re.match(r'(FP_|Math_|Int_)',t)))
    pools[assign.get(r[4],'E' if r[4] in ('core/14_dsp_control_routines.s','subcpu_data_tables.s','core/02_audio_system_init.s','core/03_task_scheduler_kernel.s','core/04_intercpu_link.s') else 'D')].append((int(r[1]),int(r[2]),r[3],r[4],r[6],r[12],r[13],','.join(rt) or '-'))
for k,v in sorted(pools.items()):
    v.sort(key=lambda x:-x[0])
    with open(R+'/notes/cc900-c-subcpu-2026-11-16/pools/pool_%s.txt'%k,'w') as fh:
        for x in v: fh.write('%5d %4d %-44s %-42s %-4s erp %2s nop %3s runtime %s\n'%x)
    print(k,len(v),sum(x[0] for x in v), 'runtime-calling', sum(1 for x in v if x[7]!='-'))
