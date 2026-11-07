#!/usr/bin/env python3
r"""name_title_index_operands.py -- spell the title numbers the code passes by their TT_* names.

QUESTION ANSWERED
-----------------
"Which title does each piece of code open?"  Most screens are not opened by a data link (an
AcTitleMenu `title` field) but by code that passes a title INDEX in a register to

    UI_ChangeTitleByIndex     A = index: posts EVT_CHANGE_TITLE, param TITLE_PS + A
    UI_InterruptTitleByIndex  A = index: posts EVT_INTERRUPT_TITLE, param TITLE_PS + A
                              (both in ui/ui_control_panel.s; they were named
                              UI_PostModeChangeEvent / SoundCtrl_SendCommand)

or to a routine that forwards its argument to one of them.  This tool finds, for every call or
jump to such a routine, every instruction that can set the index register on a path reaching it
(a backward walk over each file's control flow: fall-through and every jr/jrl/jp/djnz to a
label), and rewrites the immediate it loads (`ldw wa, 0x61`, `ld a, 0x61:opc`) as the title's
`TT_<NAME>` index constant (shared/event_codes.s: TT_X = TITLE_X - TITLE_PS).  A path that
reaches the routine's entry makes that routine a forwarder too (fixpoint over all files).
Forwarders that spill the argument to the stack first are declared in STACK_FORWARDERS, each
read from its code.  The value does not change, so the bytes do not (make gate).

The same walk is the library scripts/generators/gen_naka_menu_map.py uses to say which titles a
menu box's function opens (`titles_opened_by`).

RUN (repository root)
    python3 scripts/converters/name_title_index_operands.py [--tree v10] [--apply] [--report]
    for t in v10 v9 v7 v6 v5: ... --tree $t --apply; then make gate
"""
import argparse
import collections
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PRIMITIVES = {'UI_ChangeTitleByIndex': ('a',), 'UI_InterruptTitleByIndex': ('a',)}
# Forwarders that keep the index on the stack before passing it on (so the register walk stops at
# their entry for another reason).  Each was read from its code (demo/file_demo_proc.s):
#   FileIO_DiskEventDispatch: `ld (xsp), c; ld (xsp+2), a`; floppy/HD with bit 0 of 0x340F4 set
#     -> UI_ChangeTitleByIndex((xsp)) = C, otherwise A.
#   FileIO_GetDiskCapacity: `ld (xsp), a`; floppy/HD -> UI_ChangeTitleByIndex((xsp)) = A.
#   SeMenu_SendEvent (audio/semenu_routines.s; lane kn5000-notes, 2026-11-06): `ld (xsp), c`; C = 0 ->
#     UI_ChangeTitleByIndex(A), otherwise UI_PostRefreshEvent; either way C is stored in 0x698.  It is jumped
#     to from inside its own file (tail calls), so the register walk never sees its entry as an entry and
#     the fixpoint below does not find it: the sound editor's page changes all go through it.
#   SeMenu_GoToPageOnEnabledPart (audio/semenu_routines.s; lane kn5000-naka, 2026-11-06): `ld (xsp+6), a`, makes
#     sure the current part is enabled, then `ld a, (xsp+6); ld bc, 0` -> SeMenu_SendEvent, i.e.
#     UI_ChangeTitleByIndex(A) on all three of its paths.  Callers pass 32 / 38 / 61 (sound_editor_ui.s).
STACK_FORWARDERS = {'FileIO_DiskEventDispatch': ('a', 'c'), 'FileIO_GetDiskCapacity': ('a',),
                    'SeMenu_SendEvent': ('a',), 'SeMenu_GoToPageOnEnabledPart': ('a',)}
# Index registers the code COMPUTES, which the walk cannot evaluate: (file name, instruction with its
# whitespace collapsed) -> the titles it can yield, each read from the code around it (lane kn5000-naka,
# 2026-11-06).  The value an instruction adds is spelled as the title it is based on, so the key holds both
# spellings (v6 / v5 keep the number).
#   sound_editor_ui.s, UpdSeSel_DetailedUpdate (the filter page's type step, before UpdSeSel_DetailedUpdate_Join9):
#     A = the part's filter type byte (xbc); 2..5 -> `dec 1, a; ld (xbc), a; add a, TT_SEFILLPQ1` = page
#     TT_SEFILLPQ1 + 1..4 (HPQ1, L241, H241, BPF1), then SeMenu_SendEvent with C = 0.  Type 0 opens TT_SEFILBCF1 on
#     the other path (a constant the walk reads); type 1 redraws the LPQ1 page in place (pushw 48,
#     SeTitle_DrawStaticScreen).
_SEFIL_TYPES = ('TT_SEFILHPQ1', 'TT_SEFILL241', 'TT_SEFILH241', 'TT_SEFILBPF1')
COMPUTED = {('sound_editor_ui.s', 'add a, TT_SEFILLPQ1'): _SEFIL_TYPES,
            ('sound_editor_ui.s', 'add a, 48'): _SEFIL_TYPES}
# The same for an index register LOADED from a title table, keyed by (file name, the instruction before, the
# load), both with whitespace collapsed: the instruction text alone is not unique (lane kn5000-naka2, 2026-11-06).
#   file_demo_proc.s, Demo_SelectEntry_DrawSecondary: `lda xbc, (DemoSong_TitleCol:24); ld a, (xbc+wa)` with WA =
#     2 * DEMO_CURRENT_SONG, then UI_ChangeTitleByIndex: the title column of the 23-song demo order, whose bytes
#     (DemoSong_TitleCol + 2k, k = 0..22, read from the v10 ROM) are 0xE1..0xE4 only: TT_DEMOSTYLE, TT_DEMOSOUND,
#     TT_DEMORHY, TT_DEMOFEATURE (notes/kn5000-naka2-2026-11-06/probes/demo_title_column.py prints them).
COMPUTED_LOADS = {('file_demo_proc.s', 'lda xbc, (DemoSong_TitleCol:24)', 'ld a, (xbc+wa)'):
                  ('TT_DEMOSTYLE', 'TT_DEMOSOUND', 'TT_DEMORHY', 'TT_DEMOFEATURE')}
REGS = {'a': {'a', 'wa', 'xwa'}, 'c': {'c', 'bc', 'xbc'}}
LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):')
BRANCH = re.compile(r'^(jr|jrl|jp|djnz)\s+(?:(\w+)\s*,\s*)?(\(?[A-Za-z_.$][\w.$]*(?::24)?\)?)\s*$')
CALL = re.compile(r'^(call|calr|jp|jr|jrl)\s+(?:(\w+)\s*,\s*)?\(?([A-Za-z_.$][\w.$]*)(?::24)?\)?\s*$')
CONDS = {'t', 'z', 'nz', 'c', 'nc', 'eq', 'ne', 'mi', 'pl', 'ge', 'gt', 'le', 'lt', 'uge', 'ugt',
         'ule', 'ult', 'ov', 'nov', 'pe', 'po', 'f'}
IMM = re.compile(r'^(0x[0-9a-fA-F]+|\d+|TT_\w+|MD_\w+)(:opc|:i3)?$')


def read(p):
    return open(p, 'rb').read().decode('latin-1')


def title_indices(tree):
    out = {}
    for ln in read(os.path.join(ROOT, tree, 'maincpu', 'shared', 'event_codes.s')).split('\n'):
        m = re.match(r'^\.equ (TITLE_(\w+)), 0x1a0([0-9a-f]{4})\b', ln)
        if m:
            out.setdefault(int(m.group(3), 16), 'TT_' + m.group(2))
    return out


class File:
    def __init__(self, path):
        self.path = path
        self.lines = read(path).split('\n')
        self.ins = []           # (line index, code text)
        self.label_at = {}      # label -> instruction position
        self.labels_of = collections.defaultdict(list)
        pending = []
        for i, ln in enumerate(self.lines):
            m = LABEL.match(ln)
            rest = ln
            if m:
                pending.append(m.group(1))
                rest = ln[m.end():]
            code = rest.split(';')[0].strip()
            if not code or code.startswith('.'):
                if code.startswith('.') and not code.startswith(('.L', '.set')) and pending:
                    # data directive: labels on data are not code
                    pending = []
                continue
            pos = len(self.ins)
            self.ins.append((i, code))
            for lab in pending:
                self.label_at[lab] = pos
                self.labels_of[pos].append(lab)
            pending = []
        self.preds = collections.defaultdict(list)
        for pos, (i, code) in enumerate(self.ins):
            m = BRANCH.match(code)
            uncond = bool(re.match(r'^(ret|reti|retd)\b', code))
            if m:
                cond = m.group(2)
                tgt = m.group(3).strip('()').split(':')[0]
                if tgt in self.label_at:
                    self.preds[self.label_at[tgt]].append(pos)
                if m.group(1) != 'djnz' and (cond is None or cond == 't'):
                    uncond = True
            if re.match(r'^jp\s+(t\s*,\s*)?\(', code):
                uncond = True
            if not uncond and pos + 1 < len(self.ins):
                self.preds[pos + 1].append(pos)

    def routine_of(self, pos):
        """the nearest non-local label at or before pos."""
        while pos >= 0:
            for lab in self.labels_of.get(pos, []):
                if not lab.startswith('.'):
                    return lab
            pos -= 1
        return None


def defines(code, reg):
    """(True, value text) when code writes the index register reg; (True, None) when it writes it
    with something unknown; (False, None) when it leaves it alone."""
    m = re.match(r'^(\w+)\s+(\w+)\s*(?:,\s*(.*))?$', code)
    if not m:
        return False, None
    op, dst, src = m.group(1), m.group(2).lower(), (m.group(3) or '').strip()
    if op in ('call', 'calr'):
        return True, None
    if dst not in REGS[reg]:
        return False, None
    if op in ('cp', 'push', 'bit', 'extz', 'exts', 'tset'):
        return False, None
    if op in ('ld', 'ldw') and IMM.match(src):
        return True, src
    return True, None


GUARD_CP = re.compile(r'^cp\s+(a|wa)\s*,\s*(0x[0-9a-fA-F]+|\d+|TT_\w+)\s*$')


def guard_value(f, p, s, reg):
    """the value reg must hold on the edge p -> s when p is a branch on equality after `cp a, K`:
    `cp a, K; jr z, L` taken (s = L) or `cp a, K; jr nz, L` not taken (s = p + 1) mean A == K there
    (lane kn5000-naka3, 2026-11-07: FileIO_ErrorCodeByteBlock reaches UI_ChangeTitleByIndex only
    through `cp a, 119; jr z`, on both of its paths).  None when no such guard decides it."""
    if reg != 'a' or p < 1:
        return None
    m = BRANCH.match(f.ins[p][1])
    g = GUARD_CP.match(f.ins[p - 1][1])
    if not m or not g or m.group(1) == 'djnz':
        return None
    tgt = f.label_at.get(m.group(3).strip('()').split(':')[0])
    cond = m.group(2)
    if (cond in ('z', 'eq') and s == tgt and s != p + 1) or (cond in ('nz', 'ne') and s == p + 1 and tgt != s):
        return g.group(2)
    return None


CELL_LOAD = re.compile(r'^ld\s+(a|wa|xwa)\s*,\s*\(([A-Za-z_]\w*|0x[0-9a-fA-F]+)(?::16|:24)?\)$')


def _cell(tok):
    return '0x%x' % int(tok, 16) if tok.lower().startswith('0x') else tok


def return_cells(files):
    """RAM cells that hold only the title a dialog was opened from: every write to the cell is
    `ldmm8 CELL, PREVIOUS_TITLE` or `ld a, (PREVIOUS_TITLE); ld (CELL), a`, done when the dialog's
    title procedure is activated (lane kn5000-naka3, 2026-11-07: FmmFormatFunc 0x7F6A, the disk load
    0x7F6E, SmfLoad 0x808A, SmfMed 0x843A, the utility pages 0x7F5C / 0x7F5E).  Opening the title in
    such a cell goes back to the opener, which has its own path, so a site that loads one is resolved."""
    saved, other = set(), set()
    dest = re.compile(r'^(?:ld|ldw|ldl|ldmm8|ldmm16|inc|dec|incw|decw|set|res|or|and|xor|add|sub)\s+'
                      r'(?:\d\s*,\s*)?\(?([A-Za-z_]\w*|0x[0-9a-fA-F]+)(?::16|:24)?\)?\s*,')
    for f in files:
        for k, (i, code) in enumerate(f.ins):
            m = re.match(r'^ldmm8\s+([A-Za-z_]\w*|0x[0-9a-fA-F]+)\s*,\s*PREVIOUS_TITLE$', code)
            if m:
                saved.add(_cell(m.group(1)))
                continue
            if (re.match(r'^ld\s+a\s*,\s*\(PREVIOUS_TITLE(?::16)?\)$', f.ins[k - 1][1]) if k else False):
                m = re.match(r'^ld\s+\(([A-Za-z_]\w*|0x[0-9a-fA-F]+)(?::16|:24)?\)\s*,\s*a$', code)
                if m:
                    saved.add(_cell(m.group(1)))
                    continue
            m = dest.match(code)
            if m and not code.startswith(('ld a', 'ld wa', 'ld xwa')):
                other.add(_cell(m.group(1)))
    return saved - other


def walk(f, pos, reg, limit=400, cells=frozenset()):
    """reaching definitions of reg at instruction pos: (defs [(pos, value)], unknown?, entry?);
    a load of a return cell (return_cells) is a definition with the value 'PREVIOUS_TITLE'."""
    defs, unknown, entry = [], False, False
    seen, stack, n = set(), [(q, pos) for q in f.preds.get(pos, [])], 0
    if not f.preds.get(pos):
        entry = True
    while stack and n < limit:
        p, s = stack.pop()
        gv = guard_value(f, p, s, reg)
        if gv is not None:
            defs.append((p - 1, gv))
            continue
        if p in seen:
            continue
        seen.add(p)
        n += 1
        comp = COMPUTED.get((os.path.basename(f.path), re.sub(r'\s+', ' ', f.ins[p][1])))
        if comp is None and p > 0:
            comp = COMPUTED_LOADS.get((os.path.basename(f.path), re.sub(r'\s+', ' ', f.ins[p - 1][1]),
                                       re.sub(r'\s+', ' ', f.ins[p][1])))
        if comp and reg == 'a':
            defs.extend((p, v) for v in comp)
            continue
        mc = CELL_LOAD.match(f.ins[p][1])
        if reg == 'a' and mc and _cell(mc.group(2)) in cells:
            defs.append((p, 'PREVIOUS_TITLE'))
            continue
        d, v = defines(f.ins[p][1], reg)
        if d:
            if v is None:
                unknown = True
            else:
                defs.append((p, v))
            continue
        ps = f.preds.get(p, [])
        if not ps:
            entry = True
        stack.extend((q, p) for q in ps)
    if n >= limit:
        unknown = True
    return defs, unknown, entry


MODE_PRIMITIVES = {'UI_ChangeModeByIndex': ('a',)}     # EVT_CHANGE_MODE, NAKA_MODE_MD_PS + A


def mode_indices(tree):
    out = {}
    for ln in read(os.path.join(ROOT, tree, 'maincpu', 'shared', 'event_codes.s')).split('\n'):
        m = re.match(r'^\.equ NAKA_MODE_(MD_\w+), 0x180([0-9a-f]{4})\b', ln)
        if m:
            out.setdefault(int(m.group(2), 16), m.group(1))
    return out


def analyse(tree, kind='title', files=None):
    if files is None:
        files = [File(p) for p in sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'),
                                                    recursive=True))]
    if kind == 'mode':
        targets = dict(MODE_PRIMITIVES)
    else:
        targets = dict(PRIMITIVES)
        targets.update(STACK_FORWARDERS)
    cells = return_cells(files)
    changed = True
    sites = []
    while changed:
        changed = False
        sites = []
        for f in files:
            for pos, (i, code) in enumerate(f.ins):
                m = CALL.match(code)
                if not m or m.group(3) not in targets:
                    continue
                for reg in targets[m.group(3)]:
                    defs, unk, entry = walk(f, pos, reg, cells=cells)
                    rout = f.routine_of(pos)
                    sites.append(dict(file=f, pos=pos, target=m.group(3), reg=reg, defs=defs,
                                      unknown=unk, entry=entry, routine=rout))
                    if entry and rout and rout not in targets:
                        # the index arrives as this routine's own argument: it forwards it
                        if not defs and not unk:
                            targets[rout] = (reg,)
                            changed = True
                        elif rout not in targets:
                            targets[rout] = (reg,)
                            changed = True
    return files, targets, sites


def opened_by(tree, kind='title'):
    """routine -> set of TT_* (or MD_*) names it passes to a by-index routine, plus the
    files, so a caller can follow calls."""
    names = title_indices(tree) if kind == 'title' else mode_indices(tree)
    files, targets, sites = analyse(tree, kind)
    out = collections.defaultdict(set)
    for s in sites:
        for p, v in s['defs']:
            v = v.split(':')[0]
            if v == 'PREVIOUS_TITLE':
                continue
            out[s['routine']].add(names.get(int(v, 0), v) if re.match(r'^(0x|\d)', v) else v)
    return files, targets, out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('--report', action='store_true')
    ap.add_argument('--kind', choices=('title', 'mode'), default='title')
    a = ap.parse_args()
    tt = title_indices(a.tree) if a.kind == 'title' else mode_indices(a.tree)
    files, targets, sites = analyse(a.tree, a.kind)
    edits = collections.defaultdict(dict)        # file -> {line index: new line}
    st = collections.Counter()
    unnamed = collections.Counter()
    for s in sites:
        f = s['file']
        st['sites'] += 1
        if s['unknown']:
            st['sites with an unknown path'] += 1
        for p, v in s['defs']:
            if v == 'PREVIOUS_TITLE':
                st['returns to the opener'] += 1
                continue
            if not re.match(r'^(0x|\d)', v):
                st['already named'] += 1
                continue
            x = int(v.split(':')[0], 0)
            name = tt.get(x)
            i = f.ins[p][0]
            if not name:
                unnamed[(x, os.path.relpath(f.path, ROOT), i + 1)] += 1
                continue
            ln = edits[f].get(i, f.lines[i])
            new = re.sub(r'(,\s*)%s(?=(:opc|:i3)?\s*(;|$))' % re.escape(v.split(':')[0]), r'\g<1>' + name, ln, count=1)
            if new != ln:
                edits[f][i] = new
                st['operands named'] += 1
    for f, ed in edits.items():
        for i, ln in ed.items():
            f.lines[i] = ln
        if a.apply:
            open(f.path, 'wb').write('\n'.join(f.lines).encode('latin-1'))
    fw = sorted(k for k in targets if k not in PRIMITIVES and k not in MODE_PRIMITIVES)
    print('%s: %d call sites of %d %s-by-index routines (%d forwarders); %s'
          % (a.tree, st['sites'], len(targets), a.kind, len(fw), dict(st)))
    if unnamed:
        print('  index values with no TITLE_ name:', sorted({k[0] for k in unnamed}))
    if a.report:
        print('  forwarders:', ', '.join(fw))
        for s in sites:
            if s['unknown'] or not s['defs']:
                print('  unresolved: %s:%d %s -> %s (%s)' % (os.path.relpath(s['file'].path, ROOT),
                                                         s['file'].ins[s['pos']][0] + 1, s['routine'],
                                                         s['target'], s['reg']))


if __name__ == '__main__':
    main()


def routine_entries(files, extra=()):
    """labels that start a routine: every call / calr target, plus `extra` (function-table and
    title-procedure entries, whose address is taken rather than called)."""
    ent = set(extra)
    for f in files:
        for i, code in f.ins:
            m = re.match(r'^(call|calr)\s+(?:\w+\s*,\s*)?\(?([A-Za-z_.$][\w.$]*)', code)
            if m:
                ent.add(m.group(2))
    return ent


def opens_by_routine(tree, kind='title', extra=()):
    """routine entry label -> set of TT_* / MD_* names passed inside its body (from the entry
    label to the next routine entry of the same file)."""
    names = title_indices(tree) if kind == 'title' else mode_indices(tree)
    files, targets, sites = analyse(tree, kind)
    ent = routine_entries(files, extra) | set(targets)
    out = collections.defaultdict(set)
    for s in sites:
        f, pos = s['file'], s['pos']
        r = None
        while pos >= 0 and r is None:
            for lab in f.labels_of.get(pos, []):
                if lab in ent:
                    r = lab
            pos -= 1
        for p, v in s['defs']:
            v = v.split(':')[0]
            if v == 'PREVIOUS_TITLE':
                continue
            out[r].add(names.get(int(v, 0), v) if re.match(r'^(0x|\d)', v) else v)
    if kind == 'title':
        # titles posted directly: `ld xbc, EVT_CHANGE_TITLE` (or EVT_INTERRUPT_TITLE) and
        # `ld xde, TITLE_X` in the 6 instructions before a call / jump to ApPostEvent
        for f in files:
            for pos, (i, code) in enumerate(f.ins):
                if not re.match(r'^(call|calr|jp|jr|jrl)\s+(?:\w+\s*,\s*)?\(?ApPostEvent\b', code):
                    continue
                ev = tl = None
                for k in range(pos - 1, max(-1, pos - 7), -1):
                    c = f.ins[k][1]
                    if f.labels_of.get(k + 1) and k + 1 != pos and False:
                        break
                    m = re.match(r'^ld\s+xbc\s*,\s*(EVT_CHANGE_TITLE|EVT_INTERRUPT_TITLE)\b', c)
                    if m:
                        ev = m.group(1)
                    m = re.match(r'^ld\s+xde\s*,\s*TITLE_(\w+)\s*$', c)
                    if m and tl is None:
                        tl = 'TT_' + m.group(1)
                if ev and tl and tl != 'TT_PS':
                    q, r = pos, None
                    while q >= 0 and r is None:
                        for lab in f.labels_of.get(q, []):
                            if lab in ent:
                                r = lab
                        q -= 1
                    out[r].add(tl)
    return out


def routines_naming(tree, pattern, extra=()):
    """routine entry labels whose body (from the entry to the next entry) has an instruction matching
    `pattern` (a compiled regex), e.g. the panel-switch handlers: \\bEVT_SW_IN\\w*\\b (lane kn5000-naka2)."""
    files = [File(p) for p in sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'),
                                                recursive=True))]
    ent = routine_entries(files, extra)
    out = set()
    for f in files:
        cur = None
        for pos, (i, code) in enumerate(f.ins):
            for lab in f.labels_of.get(pos, []):
                if lab in ent:
                    cur = lab
            if cur and pattern.search(code):
                out.add(cur)
    return out


def callees(tree, extra=()):
    """routine entry label -> set of routines its body calls (call / calr / jp to an entry)."""
    files = [File(p) for p in sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'),
                                                recursive=True))]
    ent = routine_entries(files, extra)
    out = collections.defaultdict(set)
    for f in files:
        cur = None
        for pos, (i, code) in enumerate(f.ins):
            for lab in f.labels_of.get(pos, []):
                if lab in ent:
                    cur = lab
            m = CALL.match(code)
            if m and cur and m.group(3) in ent and m.group(3) != cur:
                out[cur].add(m.group(3))
    return out
