#!/usr/bin/env python3
"""routine_dossier.py -- the facts a reader needs before writing one routine's header comment.

QUESTION IT ANSWERS
  "For each KN5000 routine that still lacks a header (doc_quality_census.py debt (a)), what does its code
   touch, who calls it, and through what?"  Writing a header means reading the body AND the callers; this
   gathers both into one plain-text dossier per routine so the reader does not have to grep for each one.
   It writes nothing into the sources: the headers themselves are written by a person (or agent) from the
   dossier and inserted with scripts/tools/insert_routine_headers.py.

  Per routine (routines and their header state come from doc_quality_census.py --routines, so the two
  always agree on what a routine is):
    callers   every `call` / `calr` site in the image, by the routine that contains it (and its file when
              that is not the routine's own file), with the count of sites;
    jumps-in  branches from other routines (tail calls), same format;
    address   every other use of the name: table entries (`.long Name`, with the table's label), pushed or
              loaded pointers, `.set` / `.equ` right-hand sides;
    RAM       absolute memory operands in the body, `(0x2668:16)` / `(9832:16)` / `(CURRENT_TITLE:16)`,
              shown in hex and classified R (read: ld r,(m) / cp / bit / push), W (ld (m),..), RW
              (set res and or xor add sub inc dec chg tset ex ...);
    callees   call targets (and branch targets that are routines: tail calls) in the body, with the first
              informative line of the callee's header if it has one -- the callee's own documentation is often the best clue to the caller's purpose;
    body      the source from the label to the next routine label of the census (internal blocks
              included), capped at --max-lines.

USAGE
  python3 scripts/analysis/routine_dossier.py v10 --path v10/maincpu/sequencer/ --order calls > dossier.txt
  python3 scripts/analysis/routine_dossier.py v10 --path v10/maincpu/sequencer/smf_playback.s --all
      --order calls  most call sites first, then address-taken, xfile_jump, unreferenced (the WP16 priority)
      --order file   source order
      --all          include routines that already have a header
      --names A,B    only these routines
      --list         one line per routine (calls, reason, file:line, name) instead of dossiers

  Every .s file is read as bytes and decoded latin-1 (CLAUDE.md: `.ascii` lines hold non-UTF-8 bytes).
"""
import argparse
import os
import re
import subprocess
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import doc_quality_census as dqc  # noqa: E402

LABEL_RE = re.compile(r'^([A-Za-z_.$][\w.$]*):')
NAME_RE = re.compile(r'[A-Za-z_.$][\w.$]*')
CALL_RE = re.compile(r'^\s*(call|calr)\s+(.*)$', re.I)
JUMP_RE = re.compile(r'^\s*(jp|jr|jrl|djnz|djnz16)\s+(.*)$', re.I)
MEM_RE = re.compile(r'\(\s*(0x[0-9a-fA-F]+|\d+|[A-Za-z_][\w]*)\s*(?::(?:8|16|24))?\s*\)')
REGS = set('a w b c d e h l wa bc de hl ix iy iz sp xwa xbc xde xhl xix xiy xiz xsp qwa qbc qde qhl'.split())
RMW = {'set', 'res', 'and', 'or', 'xor', 'add', 'adc', 'sub', 'sbc', 'inc', 'dec', 'incw', 'decw', 'chg', 'tset',
       'ex', 'rlc', 'rrc', 'rl', 'rr', 'sla', 'sra', 'sll', 'srl', 'rld', 'rrd', 'andw', 'orw', 'xorw', 'addw',
       'subw', 'incb', 'decb', 'neg', 'cpl', 'stcf', 'andcf', 'orcf', 'xorcf'}
READ_ONLY = {'cp', 'cpw', 'bit', 'push', 'pushw', 'ldcf', 'mul', 'muls', 'div', 'divs', 'cpb', 'lda'}


def read_lines(path):
    with open(os.path.join(ROOT, path), 'rb') as f:
        return f.read().decode('latin-1').split('\n')


def census_routines(key):
    out = subprocess.run([sys.executable, os.path.join(HERE, 'doc_quality_census.py'), '--routines', key],
                         capture_output=True, text=True, cwd=ROOT, check=True).stdout
    rows = []
    for ln in out.splitlines():
        parts = ln.split('\t')
        if len(parts) != 4 or ':' not in parts[0]:
            continue
        f, line = parts[0].rsplit(':', 1)
        rows.append((f, int(line), parts[1], parts[2], parts[3]))
    return rows


def hexify(tok):
    if tok.isdigit():
        return '0x%x' % int(tok)
    if tok.lower().startswith('0x'):
        return '0x%x' % int(tok, 16)
    return tok


def target_of(ops):
    ops = ops.split(';', 1)[0].strip()
    parts = dqc.split_operands(ops) if ops else []
    if not parts:
        return None
    t = parts[-1].strip()
    t = t.strip('()')
    t = t.split(':', 1)[0].strip()
    m = NAME_RE.fullmatch(t)
    return t if m and t.lower() not in REGS else None


def first_header_line(lines, i, name):
    hdr = dqc.header_lines_above(lines, i)
    for h in reversed(hdr):
        if dqc.informative(h, {name.lower()}):
            return h.strip().lstrip(';#').strip()[:160]
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    ap.add_argument('key')
    ap.add_argument('--path', default='')
    ap.add_argument('--order', choices=['calls', 'file'], default='calls')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--names', default='')
    ap.add_argument('--list', action='store_true')
    ap.add_argument('--max-lines', type=int, default=90)
    ap.add_argument('--skip', type=int, default=0)
    ap.add_argument('--count', type=int, default=0)
    a = ap.parse_args()

    rows = census_routines(a.key)
    files = sorted({r[0] for r in rows} | set(dqc.image_files(a.key, dqc.git_tracked())[0]))
    text = {f: read_lines(f) for f in files}
    routine_starts = defaultdict(list)  # file -> sorted [(line, name)]
    info = {}
    for f, line, name, reason, hdr in rows:
        routine_starts[f].append((line, name))
        info[name] = (f, line, reason, hdr)
    for f in routine_starts:
        routine_starts[f].sort()

    def enclosing(f, lineno):
        best = None
        for ln, nm in routine_starts.get(f, ()):
            if ln <= lineno:
                best = nm
            else:
                break
        return best

    def nearest_label(f, lineno):
        L = text[f]
        for j in range(lineno - 1, -1, -1):
            m = LABEL_RE.match(L[j])
            if m:
                return m.group(1)
        return None

    calls = defaultdict(lambda: defaultdict(int))
    jumps = defaultdict(lambda: defaultdict(int))
    addrs = defaultdict(list)
    for f, L in text.items():
        for i, raw in enumerate(L, 1):
            code = dqc.strip_comment(raw, None)
            m = LABEL_RE.match(code)
            body = code[m.end():] if m else code
            if not body.strip():
                continue
            cm = CALL_RE.match(body)
            jm = JUMP_RE.match(body)
            if cm or jm:
                t = target_of((cm or jm).group(2))
                if t:
                    src = enclosing(f, i) or nearest_label(f, i) or '?'
                    tag = src if f == (info.get(t, (f,))[0]) else '%s [%s]' % (src, os.path.basename(f))
                    (calls if cm else jumps)[t][tag] += 1
                rest = (cm or jm).group(2)
                names = set(NAME_RE.findall(rest)) - ({t} if t else set())
            else:
                names = set(NAME_RE.findall(body))
            for n in names:
                if n in info and not body.lstrip().startswith(n + ':'):
                    owner = nearest_label(f, i)
                    addrs[n].append('%s: %s' % (owner if owner else os.path.basename(f), body.strip()[:100]))

    sel = [r for r in rows if r[0].startswith(a.path) and (a.all or r[4] != 'header')]
    if a.names:
        want = set(a.names.split(','))
        sel = [r for r in sel if r[2] in want]
    rank = {'call': 0, 'address': 1, 'xfile_jump': 2, 'unreferenced': 3}
    if a.order == 'calls':
        sel.sort(key=lambda r: (rank.get(r[3], 4), -sum(calls[r[2]].values()), r[0], r[1]))
    if a.skip:
        sel = sel[a.skip:]
    if a.count:
        sel = sel[:a.count]

    for f, line, name, reason, hdr in sel:
        nc = sum(calls[name].values())
        if a.list:
            print('%4d\t%s\t%s:%d\t%s' % (nc, reason, f, line, name))
            continue
        L = text[f]
        nxt = len(L) + 1
        for ln, nm in routine_starts[f]:
            if ln > line:
                nxt = ln
                break
        body = L[line - 1:nxt - 1]
        while body and not body[-1].strip():
            body.pop()
        ram = {}
        callees = []
        for b in body:
            code = b.split(';', 1)[0]
            m = LABEL_RE.match(code)
            code = code[m.end():] if m else code
            s = code.strip()
            if not s:
                continue
            mn = s.split(None, 1)[0].lower()
            ops = s[len(mn):].strip()
            cm = CALL_RE.match(s) or JUMP_RE.match(s)
            if cm:
                t = target_of(cm.group(2))
                if t and t not in callees and info.get(t, (None, None, None, None))[1] != line:
                    callees.append(t)
            if mn in ('call', 'calr', 'jp', 'jr', 'jrl', 'lda'):
                continue
            parts = dqc.split_operands(ops) if ops else []
            for k, p in enumerate(parts):
                for mm in MEM_RE.finditer(p):
                    tok = mm.group(1)
                    if tok.lower() in REGS:
                        continue
                    if mn in READ_ONLY:
                        acc = 'R'
                    elif mn in RMW:
                        alu2 = mn in ('and', 'or', 'xor', 'add', 'adc', 'sub', 'sbc', 'andw', 'orw', 'xorw', 'addw',
                                      'subw')
                        acc = 'RW' if (not alu2) or k == 0 else 'R'
                    elif mn.startswith('ld'):
                        acc = 'W' if k == 0 else 'R'
                    else:
                        acc = '?'
                    key = hexify(tok)
                    prev = ram.get(key)
                    ram[key] = acc if prev in (None, acc) else ''.join(sorted(set((prev + acc).replace('?', ''))))
        print('=' * 100)
        print('%s  [%s, %d call sites, header=%s]  %s:%d' % (name, reason, nc, hdr, f, line))
        if calls[name]:
            print('  callers : ' + ', '.join('%s%s' % (k, '' if v == 1 else ' x%d' % v)
                                           for k, v in sorted(calls[name].items(), key=lambda kv: -kv[1])[:14]))
        if jumps[name]:
            print('  jumps-in: ' + ', '.join('%s%s' % (k, '' if v == 1 else ' x%d' % v)
                                           for k, v in sorted(jumps[name].items(), key=lambda kv: -kv[1])[:10]))
        if addrs[name]:
            print('  address : ' + ' | '.join(addrs[name][:6]))
        if ram:
            print('  RAM     : ' + ', '.join('%s %s' % (k, v) for k, v in ram.items()))
        for c in callees:
            if c in info:
                cf, cl, _, _ = info[c]
                h = first_header_line(text[cf], cl - 1, c)
                if h:
                    print('  callee  : %s -- %s' % (c, h))
        print('  ' + '-' * 60)
        cap = a.max_lines
        for b in body[:cap]:
            print('  ' + b.rstrip())
        if len(body) > cap:
            print('  ... (%d more lines)' % (len(body) - cap))


if __name__ == '__main__':
    main()
