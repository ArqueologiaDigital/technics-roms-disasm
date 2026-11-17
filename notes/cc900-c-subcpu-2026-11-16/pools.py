#!/usr/bin/env python3
"""Which survey candidates go to which C-drafting helper (pools/pool_<TAG>.txt)?

QUESTION ANSWERED: the leaf and absolute-call-only routines of survey.tsv that are not hand assembly, have no
memory-to-memory move and were not tried in round 1, split by hand source into five pools (A: 05 + 07, B: 06 + 09,
C: 08 + 10, D: 11 / 12 / 13, E: 14 and the rest).  subcpu_fp_math.s is left out: it is Toshiba's double library.
Columns: bytes, instructions, label, hand source, kind, erp / nop counts, and the runtime routines (FP_* / Math_* /
Int_*) it calls, which need a name map before V4.23's calls can be checked.
    python3 -B notes/cc900-c-subcpu-2026-11-16/pools.py      (from the repository root)
    python3 -B notes/cc900-c-subcpu-2026-11-16/pools.py --remaining
        every routine of any kind (not hand) that v142/subcpu/cc900/ and cc900-staged/ do not define yet, into
        pools/pool_<TAG>_remaining.txt, with its calr targets
    python3 -B notes/cc900-c-subcpu-2026-11-16/pools.py --rel
        the routines that also call through `calr` (kind rel), now checkable with a `cc900-module:` comment, into
        pools/pool_<TAG>_rel.txt; the last column lists the calr targets (the comment's names)
"""
import re, sys, collections
REL = '--rel' in sys.argv
REMAINING = '--remaining' in sys.argv       # every kind; skip what <tree>/subcpu/cc900 or cc900-staged already defines
import os
R=os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
rows=[l.rstrip('\n').split('\t') for l in open(R+'/notes/cc900-c-subcpu-2026-11-16/survey.tsv')][1:]
done=set(l.split('\t')[0] for l in list(open(R+'/notes/cc900-c-subcpu-2026-11-16/verdicts/2026-11-16-43-sub-r1.tsv'))[1:])
if REMAINING:
    import glob
    done=set()
    for p in glob.glob(R+'/v142/subcpu/cc900/*.c')+glob.glob(R+'/v142/subcpu/cc900-staged/*.c'):
        t=open(p).read(); lm=dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)',t))
        done|={lm.get(n,n) for n in re.findall(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{',t,re.M)}
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
    if (not REMAINING and r[6] not in (('rel',) if REL else ('leaf','abs'))) or r[5]=='hand' or r[1]=='None' or r[14]!='0' or r[3] in done: continue
    try: b=body(r)
    except StopIteration: continue   # a label the splice turned into `.set INNER, NAME + n` (inside a built function)
    # `link xiz,-N` / `unlk xiz` frames: another compiler's convention (the SX-WSA1R's; arguments at (xiz+8)),
    # which V4.23 never emits: not candidates (coordinator / WSA1R lane, 2026-11-17).  Listed on stderr.
    if any(re.match(r'\s+(link|unlk)\b',l) for l in b):
        sys.stderr.write('link/unlk frame, not a V4.23 candidate: %s (%s B, %s)\n'%(r[3],r[1],r[4])); continue
    tg=[m.group(1) for l in b for m in [re.match(r'\s+call\s+(\w+)',l)] if m]
    rt=sorted(set(t for t in tg if re.match(r'(FP_|Math_|Int_)',t)))
    cr=sorted(set(m.group(1) for l in b for m in [re.match(r'\s+calr\s+(\w+)',l)] if m))
    pools[assign.get(r[4],'E' if r[4] in ('core/14_dsp_control_routines.s','subcpu_data_tables.s','core/02_audio_system_init.s','core/03_task_scheduler_kernel.s','core/04_intercpu_link.s') else 'D')].append((int(r[1]),int(r[2]),r[3],r[4],r[6],r[12],r[13],','.join(rt) or '-')+((' '.join(cr),) if REL or REMAINING else ()))
for k,v in sorted(pools.items()):
    v.sort(key=lambda x:-x[0])
    with open(R+'/notes/cc900-c-subcpu-2026-11-16/pools/pool_%s%s.txt'%(k, '_remaining' if REMAINING else '_rel' if REL else ''),'w') as fh:
        for x in v: fh.write(('%5d %4d %-44s %-42s %-4s erp %2s nop %3s runtime %s' + ('  calr %s' if REL or REMAINING else '') + '\n')%x)
    print(k,len(v),sum(x[0] for x in v), 'runtime-calling', sum(1 for x in v if x[7]!='-'))
