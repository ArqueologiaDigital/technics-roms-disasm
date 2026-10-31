#!/usr/bin/env python3
"""Who raises panel key codes 0x11-0x18 (KEY_SoftKeyCol*Alt) and 0x19 (KEY_PageAlt)?

QUESTION (open-items T-wsa1-todo-which-physical, T-wsa1-todo-as-key, N-2e8a536d)
  include/wsa1_gui.inc said "no prom_a panel template emits" codes 0x11-0x19.  The templates
  (PanelGroupEventLists_Variant1/2) indeed carry only BASE codes; this probe finds the code that
  turns a base into 0x11..0x19 and proves which inputs can reach it.

WHAT IT CHECKS (exit 1 on any failure)
  C1  The ONLY event-code rewrites to the alternate range in prom_a + prom_b are
      `add (XIX-1),0x11` (8c ff 38 11) and `ld (XIX-1),0x19` (bc ff 00 19), four of each, all inside
      PanelAction_PairPos0_HeldMaskAltCode (0xF8AE68) and PanelAction_PairPos1_HeldMaskAltCode
      (0xF8AEDB).
  C2  Those two handlers are named by the action pool ONLY for VARIANT 1 groups 0x03-0x06, and never
      by any variant-2 entry.  Variant 2 ((0xC4) = 2, PB0 low) is the SX-WSA1R
      (notes/wave7_panel_names_round11.py), so on the SX-WSA1R nothing produces 0x11-0x19.
  C3  Every variant-1 event-list entry those handlers intercept is class 0xA9 with a base code in
      0x00..0x07 (the eight SOFT KEY columns), and groups 0x03/0x04 and 0x05/0x06 carry
      byte-identical lists -- every soft-key (code, pair position) is wired TWICE on variant 1.
  C4  The handlers rewrite a PRESS whose held bit (PanelHeld_Pos0/1, bit = code) is already set --
      i.e. the second of the two wires for one (code, position) pressed while the first is held --
      to code + 0x11, and record it at bit code+17 (`sla 16 / sla 1`); the release of that second
      press is delivered with the same alternate code.  0x19 is written only when bit code+17
      falls out of 32 bits (press arm) or code+0x11 > 0x1F (release arm), i.e. code >= 0x0F.
      With bases 0x00..0x07 only, the produced set is exactly {0x11..0x18}: 0x19 is UNREACHABLE.
  C5  No instruction in either image loads class 0xA9 as an immediate (round 9's negative,
      re-measured on the linear listings): every `ld W,0xa9` / `push 0xa9xx` hit lies in the event
      tables or in a span the sources hold as data.

RUN
  python3 notes/open4-c-probes/key_alt_code_census.py          # report + checks
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "notes"))
import wave7_panel_event_index as ev  # noqa: E402  (reads only ROM bytes for these helpers)

A = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_a.ic12"), "rb").read()
B = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_b.ic13"), "rb").read()
A_BASE, B_BASE = 0xF80000, 0xF00000
H0, H1 = 0xF8AE68, 0xF8AEDB          # the two rewriting handlers
H_END = 0xF8AF4E                     # PanelAction_PairPos0_HeldMask follows them
fails = []


def ck(name, cond, detail=""):
    print("%-4s %s %s" % (name, "ok  " if cond else "FAIL", detail))
    if not cond:
        fails.append(name)


def find_all(img, base, pat):
    out, i = [], img.find(pat)
    while i >= 0:
        out.append(base + i)
        i = img.find(pat, i + 1)
    return out


# C1 ---------------------------------------------------------------------------------------
adds = find_all(A, A_BASE, bytes.fromhex("8cff3811")) + find_all(B, B_BASE, bytes.fromhex("8cff3811"))
lds = find_all(A, A_BASE, bytes.fromhex("bcff0019")) + find_all(B, B_BASE, bytes.fromhex("bcff0019"))
# any immediate 0x11..0x19 stored/added into (XIX-1) at all
other = []
for img, base in ((A, A_BASE), (B, B_BASE)):
    for v in range(0x11, 0x1A):
        for pat in (bytes([0x8C, 0xFF, 0x38, v]), bytes([0xBC, 0xFF, 0x00, v])):
            other += [a for a in find_all(img, base, pat) if a not in adds + lds]
ck("C1", sorted(adds) == [0xF8AE7E, 0xF8AEBC, 0xF8AEF1, 0xF8AF2F]
     and sorted(lds) == [0xF8AE8A, 0xF8AEC6, 0xF8AEFD, 0xF8AF39] and not other
     and all(H0 <= a < H_END for a in adds + lds),
   "add 0x11 at %s; ld 0x19 at %s; other 0x11..0x19 writes to (XIX-1): %s" % (
       " ".join("%06X" % a for a in sorted(adds)), " ".join("%06X" % a for a in sorted(lds)),
       other or "none"))

# C2 / C3 -----------------------------------------------------------------------------------
users = {1: [], 2: []}
for var in (1, 2):
    for g in range(ev.n_action_slots(var)):
        try:
            _, _, recs = ev.action_list(var, g)
        except RuntimeError:
            continue
        for grp, mask, h in recs:
            if h in (H0, H1):
                users[var].append((g, mask, h))
ck("C2", users[2] == [] and sorted({g for g, _, _ in users[1]}) == [3, 4, 5, 6],
   "variant 1 groups %s; variant 2 entries %d" % (sorted({g for g, _, _ in users[1]}), len(users[2])))

codes = set()
bad = []
for g, mask, h in users[1]:
    _, _, recs = ev.group_list(1, g)
    hit = [r for r in recs if r[3] == mask]
    for cls, code, shift, m in hit:
        if cls != 0xA9:
            bad.append((g, mask, cls))
        codes.add(code)
        pos = ev.position(m, shift)
        want = H0 if pos == 0 else H1
        if h != want:
            bad.append((g, mask, "pos%s->%06X" % (pos, h)))
same = ev.group_list(1, 3)[2] == ev.group_list(1, 4)[2] and ev.group_list(1, 5)[2] == ev.group_list(1, 6)[2]
ck("C3", not bad and codes == set(range(8)) and same,
   "class A9 base codes %s; groups 3==4 and 5==6: %s" % (sorted(codes), same))

# C4 ---------------------------------------------------------------------------------------
def produced(code):
    out = set()
    # press arm: bit (code) already held -> code+0x11; xde<<17 == 0 -> 0x19
    out.add(0x19 if code + 17 >= 32 else code + 0x11)
    # release arm: alt bit (code+17, or bit 25 when it falls out) held -> code+0x11, >0x1F -> 0x19
    alt = code + 0x11
    out.add(0x19 if alt > 0x1F else alt)
    return out
prod = set().union(*(produced(c) for c in codes))
ck("C4", prod == set(range(0x11, 0x19)) and 0x19 not in prod,
   "alternate codes produced: %s; 0x19 needs a base >= 0x0F, none routed" % " ".join("%02X" % c for c in sorted(prod)))
# the instruction bytes C4 reasons from
ck("C4b", A[0xF8AE82 - A_BASE:0xF8AE88 - A_BASE] == bytes.fromhex("eaec00eaec01")
     and A[0xF8AEC0 - A_BASE:0xF8AEC4 - A_BASE] == bytes.fromhex("8cff3f1f"),
   "sla 16 / sla 1 at F8AE82; cp (XIX-1),0x1f at F8AEC0")

# C5 ---------------------------------------------------------------------------------------
EV_TABLES = (0xF8B446, 0xF8B9F2)    # PanelGroupEventLists_* .. end of the action pool
DATA_HITS = {
    0xFA2476: "prom_a f9c000 system_menu_screens: inside an .ascii string row",
    0xF06568: "prom_b COVER-R1 0xF06562-0xF06576: display-list data (Data_F06562)",
    0xF33A7D: "prom_b sound_edit_display_lists COVER-R1 0xF339BC-0xF33A3F/F33A49 records",
}
# the linear unidasm listings: every decoded `ld W,0xa9` / `push 0xa9..` must be table or data bytes
lst = {}
for name, base in (("wsa1_prom_a.ic12.unidasm", A_BASE), ("wsa1_prom_b.ic13.unidasm", B_BASE)):
    for line in open(os.path.join(ROOT, "original_ROMs", name), errors="replace"):
        if ("ld W,0xa9" in line or "push 0xa9" in line) and ":" in line:
            lst[int(line.split(":")[0], 16)] = line.strip()
decoded = [a for a in lst if not (EV_TABLES[0] <= a < EV_TABLES[1])]
ck("C5", sorted(decoded) == sorted(DATA_HITS),
   "listing hits outside the event tables: %s" % ", ".join("%06X" % a for a in sorted(decoded)))

print("\nFAILURES:", len(fails))
sys.exit(1 if fails else 0)
