#!/usr/bin/env python3
"""Is any Voice_ApplyParamChange_Dispatch call site inside an interrupt handler?  (N-ecb9e1d8)

Method: every vector of prom_c's table (boot/reset_and_vectors.s) except RESET is a root.
Their forward closure over `call`/`calr`/`jp`/`jr`/`jrl` edges and computed-goto `.long`
tables (prom_c_callgraph.py) is everything that can run with an interrupt being serviced.
The computed branches inside that closure (`call (xRR)` / `jp (xRR)`) are listed and each
one's target set is stated below; a target outside the closure would have to be added.

Asserted:
  * the closure does not contain Voice_ApplyParamChange_Dispatch, nor any of its 18
    transitive callers;
  * every transitive caller chain of the dispatcher ends at MAIN, the body of a TASK
    (EntryPoint_Records), i.e. thread level;
  * the only computed branches in the closure are the ones in EXPECTED_COMPUTED.
Exit 0 = PASS.  Run: python3 notes/open4-a-probes/isr_reach_param_dispatch.py
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

# (routine, mnemonic text) -> where its target comes from
EXPECTED_COMPUTED = {
    'INTT1_HANDLER': 'INTT1_PHASE_TABLE, a .long table inside the closure',
    'INT0_HANDLER': 'INT0_HANDLER__jumptable: its own local arms',
    'INTTC3_HANDLER': 'INTTC3_HANDLER__jumptable: its own local arms',
    'Kernel_ServiceSoftTimers': 'a soft-timer slot +4; the ONE SoftTimer_Register call installs '
                                'KERNEL_BOOT_TIMER_CALLBACK = SoftTimer_RotateLevel2, added as a root',
}

owner, edges = g.graph()
src = open(os.path.join(g.ROOT, 'prom_c/boot/reset_and_vectors.s'), 'rb').read()
vec = re.findall(rb'^\t\.long ([A-Za-z_]\w*)\t; 0x([0-9A-F]{2})', src, re.M)
assert len(vec) == 33, len(vec)
roots = {v for v, off in vec if off != b'00'}
# the soft-timer callbacks run from the INTT3 tick: there is exactly one registration
regs = [c for _, c in g.lines() if re.search(rb'\bcall\s+SoftTimer_Register\b', c)]
assert len(regs) == 1, regs
inc = open(os.path.join(g.ROOT, 'kernel/kernel_subcpu.inc'), 'rb').read()
assert re.search(rb'KERNEL_BOOT_TIMER_CALLBACK,\s*0x00F98112', inc)
assert owner.get(b'SoftTimer_RotateLevel2') and b'SoftTimer_RotateLevel2' in owner
roots.add(b'SoftTimer_RotateLevel2')
cl = g.closure(roots, edges)
fail = 0
D = b'Voice_ApplyParamChange_Dispatch'
up, rev = g.callers(D, edges)
print('ISR roots       :', ', '.join(sorted(r.decode() for r in roots)))
print('ISR closure     :', len(cl), 'routines')
print('dispatcher callers (transitive):', len(up))
for r in sorted(up):
    print('   ', r.decode())
bad = (up | {D}) & cl
if bad:
    fail += 1
    print('FAIL: in the ISR closure:', sorted(b.decode() for b in bad))
tops = {r for r in up if not rev.get(r)}
print('caller roots    :', sorted(t.decode() for t in tops))
bm = open(os.path.join(g.ROOT, 'prom_c/boot/boot_and_main.s'), 'rb').read()
if not re.search(rb'^EntryPoint_Records:\n\t\.long\tMAIN, 0x0000FFF0, 0x00028800', bm, re.M):
    fail += 1
    print('FAIL: MAIN is not task 1 of EntryPoint_Records (initial SR 0x8800: IFF = 0, thread level)')
if tops != {b'MAIN'}:
    fail += 1
    print('FAIL: expected MAIN as the only root')
# computed branches in the closure
comp = set()
cur = None
for raw, code in g.lines():
    m = g.LABEL.match(code)
    if m and not g.is_local(m.group(1)):
        cur = m.group(1)
    c = code[m.end():] if m else code
    if cur in cl and re.search(rb'\b(call|jp)\s+(t,\s*)?\(?x[a-z]{2}\)?\s*$', c.strip(), re.I):
        comp.add(cur.decode())
print('computed branches in the closure:', sorted(comp))
for r in sorted(comp):
    if r not in EXPECTED_COMPUTED:
        fail += 1
        print('FAIL: unexplained computed branch in', r)
    else:
        print('   %-18s %s' % (r, EXPECTED_COMPUTED[r]))
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
