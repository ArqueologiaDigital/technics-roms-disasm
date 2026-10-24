#!/usr/bin/env python3
"""strip_hdae5000_branch_echo_comments.py -- drop the target addresses that HD-AE5000 branch comments repeat.

QUESTION IT ANSWERS
  The conversion left unidasm echoes on the hdae5000 branch lines: `; [66 14] jr Z,0x280424` after a jr / jrl,
  `; jp 0x298540` or `; call 0x29AF71 (memcpy)` after a jp / call.  The target is a label on the line itself,
  so the echo restates the instruction, and the address is what the No Inline Address Comments policy forbids.

  Phase 1 (first run, commit ab8dc2f77): a comment that is the whole tail of a jr / jrl line and has exactly the
  shape `; [bytes] jr CC,0xADDR` is deleted, and a tab is put after the mnemonic (cross-version policy 3).
  It needs nothing but the sources.

  Phase 2 (second run, 2026-10-24, reviewer finding): every jp / jr / jrl / call / calr / djnz line whose comment
  names the address the branch goes to.  The address of the operand (`Label`, `(Label:24)`, `Label + N`) comes
  from a line map of the linked tree (scripts/analysis/hdae5000_line_map.py --dump), passed with --map; an
  address in the comment that is NOT the target is left alone.  Then:
    - a pure echo (`jp 0x298540`, `jp Z, 0x298540`, `call 0x29AF71`) goes;
    - an echo with a remark keeps the remark: `jp Z, 0x298540 -- abort` -> `; abort`,
      `call 0x29AF71 (memcpy)` -> `; memcpy`, `jp Z, exit (0x2981C0)` -> `; exit`;
    - in any other comment only the target address goes (with the preposition or arrow leading to it, or as
      `(0x...)`), and a leading `jp Z ->` / `jp Z,` echo goes with it.
  A remark whose words are all in the target label's name goes too, and so does one of the conversion's guesses
  at what the callee is (STALE_IDENTITY: `memcpy`, `strlen`, `display`, `utility` ...): the callee is now named
  (HDAE5000_StrLen, HDAE5000_SPrintf), and some of those guesses contradict the name (`memcpy` after a call to
  HDAE5000_StrCpy, `strcpy_len` after HDAE5000_MemCopy).
  Lines where the comment's address differs from the target are only counted (`other address`) -- they are
  prose about something else (an argument, a buffer), or a stale echo to look at by hand.

  The .s files hold raw ROM bytes in .ascii literals, so they are read and written as bytes.
  Proof that no byte of any image moved: make -j3 gate.

RUN (repository root)
  python3 scripts/tools/strip_hdae5000_branch_echo_comments.py                      # phase 1, count only
  python3 scripts/tools/strip_hdae5000_branch_echo_comments.py --apply              # phase 1, rewrite
  python3 scripts/analysis/hdae5000_line_map.py --dump "$TMPDIR/hdae5000_linemap.tsv"
  python3 scripts/tools/strip_hdae5000_branch_echo_comments.py --map "$TMPDIR/hdae5000_linemap.tsv" [-v] [--apply]
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ECHO = re.compile(rb'^\t(jrl?)[ \t]+([^;\n]*[^; \t\n])[ \t]*; \[[0-9a-f]{2}(?: [0-9a-f]{2})*\] jrl? [A-Z]{1,3},'
                  rb'0x[0-9a-f]{6}[ \t]*$', re.M)

BRANCH = re.compile(rb'^\s+(jp|jr|jrl|call|calr|djnz)\s+(.*?)\s*$')
LABEL = re.compile(rb'^\s*([A-Za-z_.$][\w.$]*):')
EQU = re.compile(rb'^\s*\.(?:equ|set)\s+([A-Za-z_.$][\w.$]*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;|$)')
ADDR = re.compile(rb'(?<![0-9A-Za-z])(?:0x([0-9a-fA-F]{5,8})|([0-9a-fA-F]{6})h)(?![0-9A-Za-z])')
BYTES = re.compile(rb'^\[[0-9a-f]{2}(?: [0-9a-f]{2})*\]\s*')
MNEM = rb'(?:jp|jr|jrl|call|calr|djnz)'
COND = rb'(?:T|F|Z|NZ|C|NC|EQ|NE|LT|GE|LE|GT|ULT|UGE|ULE|UGT|PL|MI|OV|NOV|PE|PO|ZE|NZE)'
STALE_IDENTITY = {b"memcpy", b"strcat", b"strlen", b"strcpy_len", b"strcpy with length", b"display",
                  b"call display", b"utility", b"setup utility", b"formatted-output engine"}
ARROW = rb'(?:\xe2\x80\x94|\xe2\x86\x92|->|--|-|=)'


def split_comment(line):
    q = None
    for k, ch in enumerate(line):
        c = chr(ch)
        if q:
            if c == q:
                q = None
        elif c in "\"'":
            q = c
        elif c == ";":
            return line[:k], line[k:]
    return line, b""


def words(text):
    text = re.sub(rb'([a-z0-9])([A-Z])', rb'\1 \2', text)
    return {w.lower() for w in re.findall(rb'[A-Za-z0-9]+', text)}


def phase1(apply):
    total = 0
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        data = open(p, "rb").read()
        new, n = ECHO.subn(rb'\t\1\t\2', data)
        if n:
            print("%-36s %d" % (os.path.relpath(p, ROOT), n))
            total += n
            if apply:
                with open(p + ".tmp", "wb") as fh:
                    fh.write(new)
                os.replace(p + ".tmp", p)
    print("phase 1: total %d%s" % (total, " (removed)" if apply else ""))


def load_symbols(map_path):
    sym = {}
    with open(map_path, "rb") as fh:
        for row in fh:
            parts = row.rstrip(b"\n").split(b"\t", 3)
            if len(parts) < 4:
                continue
            m = LABEL.match(parts[3])
            if m:
                sym[m.group(1)] = int(parts[0], 16)
    for p in glob.glob(os.path.join(ROOT, "hdae5000", "*.s")):
        for ln in open(p, "rb").read().split(b"\n"):
            m = EQU.match(ln)
            if m and m.group(1) not in sym:
                sym[m.group(1)] = int(m.group(2), 0)
    return sym


def target_of(operands, sym):
    """address of a branch operand: `cc, Label`, `(Label:24)`, `Label + N`; None when not a plain label"""
    op = operands.split(b",")[-1].strip()
    op = re.sub(rb'^\((.*?)(?::24)?\)$', rb'\1', op).strip()
    m = re.match(rb'^([A-Za-z_.$][\w.$]*)\s*(?:([+-])\s*(0x[0-9a-fA-F]+|\d+))?$', op)
    if not m or m.group(1) not in sym:
        return None, None
    a = sym[m.group(1)]
    if m.group(2):
        a += int(m.group(3), 0) * (1 if m.group(2) == b"+" else -1)
    return a, m.group(1)


def rewrite(body, target, label):
    """new comment body (b"" = drop the comment) or None when the comment does not name the target"""
    hits = [m for m in ADDR.finditer(body) if int(m.group(1) or m.group(2), 16) == target]
    if not hits:
        return None
    lw = words(label)
    rest = BYTES.sub(b"", body)
    a = rb'(?:0x[0-9a-fA-F]{5,8}|[0-9a-fA-F]{6}h)'
    # echo, optionally followed by a remark: `jp Z, 0x298540 -- abort`, `call 0x29AF71 (memcpy)`, `strlen 0x29AF71`
    m = re.match(rb'^(?:' + MNEM + rb'\s+(?:' + COND + rb'\s*,\s*)?|[a-z_]+\s+)\(?' + a + rb'(?::24)?\)?\s*(.*)$',
                 rest, re.I)
    if m and int(ADDR.search(rest).group(1) or ADDR.search(rest).group(2), 16) == target:
        remark = m.group(1).strip()
        remark = re.sub(rb'^' + ARROW + rb'\s*', b"", remark)
        remark = re.sub(rb'^\((.*)\)$', rb'\1', remark).strip()
        lead = re.match(rb'^([a-z_]+)\s', rest, re.I).group(1).lower()
        if lead not in (b"jp", b"jr", b"jrl", b"call", b"calr", b"djnz"):
            remark = (lead + b" " + remark).strip()
        if not remark or words(remark) <= lw or remark.lower() in STALE_IDENTITY:
            return b""
        return remark
    # prose: drop the target address (and the preposition / arrow / parenthesis that carries it)
    new = re.sub(rb'\s*\(' + a + rb'(?::24)?(?:\s+[^()]*)?\)', lambda k: b"" if int(ADDR.search(k.group(0)).group(1) or ADDR.search(k.group(0)).group(2), 16) == target else k.group(0), body)
    new = re.sub(rb'(?:\s+(?:at|to|into|from|' + ARROW + rb'))?\s*' + a,
                 lambda k: b"" if int(ADDR.search(k.group(0)).group(1) or ADDR.search(k.group(0)).group(2), 16) == target else k.group(0), new)
    new = re.sub(rb'^' + MNEM + rb'\s+(?:' + COND + rb'\s*(?:,|' + ARROW + rb')|' + ARROW + rb')\s*', b"", new, flags=re.I)
    new = re.sub(rb'(?:\s+(?:at|to|into|from|' + ARROW + rb'))+\s*$', b"", new).strip()
    if new == body:
        return None
    if not new or words(new) <= lw or new.lower() in STALE_IDENTITY:
        return b""
    return new


def phase2(map_path, apply, verbose):
    sym = load_symbols(map_path)
    total = kept = other = 0
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        lines = open(p, "rb").read().split(b"\n")
        changed = 0
        for i, ln in enumerate(lines):
            code, com = split_comment(ln)
            m = BRANCH.match(code)
            if not com or not m or not ADDR.search(com):
                continue
            target, label = target_of(m.group(2), sym)
            if target is None:
                continue
            new = rewrite(com[1:].strip(), target, label)
            if new is None:
                other += 1
                if verbose:
                    print("%s:%d: other address: %s" % (os.path.relpath(p, ROOT), i + 1, ln.decode("latin-1").strip()))
                continue
            out = code + b"; " + new if new else code.rstrip()
            if verbose:
                print("%s:%d: %s\n    -> %s" % (os.path.relpath(p, ROOT), i + 1, ln.decode("latin-1"), out.decode("latin-1")))
            lines[i] = out
            changed += 1
            kept += bool(new)
        if changed:
            print("%-36s %d" % (os.path.relpath(p, ROOT), changed))
            total += changed
            if apply:
                with open(p + ".tmp", "wb") as fh:
                    fh.write(b"\n".join(lines))
                os.replace(p + ".tmp", p)
    print("phase 2: %d comments rewritten (%d dropped, %d cut to their remark); %d name another address%s"
          % (total, total - kept, kept, other, "" if apply else " (dry run)"))


def main():
    args = sys.argv[1:]
    apply = "--apply" in args
    if "--map" in args:
        phase2(args[args.index("--map") + 1], apply, "-v" in args)
    else:
        phase1(apply)


if __name__ == "__main__":
    main()
