#!/usr/bin/env python3
"""strip_hdae5000_ram_address_comments.py -- drop the addresses that line comments repeat after an operand got a name.

QUESTION IT ANSWERS
  scripts/converters/hdae5000_symbolize_ram.py rewrites `ld (0x23900a:24), wa` as
  `ld (HDAE5000_RAM_PportService:24), wa`, but leaves the line's comment alone, so many lines now carry
  `; st (0x2390F2), 0x00`, `; ld XWA, (0x23A1A2) - workspace ptr` or `; 0x201656` -- an inline address the No
  Inline Address Comments policy forbids, in a comment that mostly repeats the instruction.  On every
  instruction line whose operands use an HDAE5000_RAM_ / HDAE5000_IO_ name, a comment that mentions the
  address of one of those names (or of name+offset) is rewritten:
    - an echo -- the comment starts with a byte dump, an instruction mnemonic, a register assignment
      (`XBC = ...`) or the address itself -- is dropped, except the remark after its first dash
      (`- check ACK`, an em dash or ` - `), which stays unless its words are all in the operand's name
      (`- workspace ptr` on HDAE5000_RAM_MainWorkspacePtr);
    - in any other (prose) comment only a parenthesised ` (0x23A1A2)` is removed.
  Comments that name no such address are left alone.  Comments only: no byte of any image can move
  (make -j3 gate).

RUN (repository root)
  python3 scripts/tools/strip_hdae5000_ram_address_comments.py            # count
  python3 scripts/tools/strip_hdae5000_ram_address_comments.py --apply    # rewrite hdae5000/*.s (bytes in/out)
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EQU = re.compile(rb'^\s*\.equ\s+(HDAE5000_(?:RAM|IO)_\w+)\s*,\s*(0x[0-9a-fA-F]+)', re.M)
NAME = re.compile(rb'(HDAE5000_(?:RAM|IO)_\w+)(?:\+(\d+))?')
ADDR = re.compile(rb'(?<![0-9A-Za-z])(?:0x([0-9a-fA-F]{6,8})|([0-9a-fA-F]{6})h)(?![0-9A-Za-z])')
BYTES = re.compile(rb'^(?:[0-9a-fA-F]{2} )+[0-9a-fA-F]{2}\b\s*')
ECHO = re.compile(rb'^(?:(?:ld|lda|ldw|st|cp|cpw|bit|add|sub|inc|dec|incw|decw|and|or|xor)\b'
                  rb'|[A-Z]{1,3}\s*=|\(?\[?&?(?:0x[0-9a-fA-F]{6}|[0-9a-fA-F]{6}h))', re.I)
DASH = re.compile(rb'\s(?:\xe2\x80\x94|-{1,2})\s+')
PAREN = re.compile(rb'\s*\((?:0x([0-9a-fA-F]{6})|([0-9a-fA-F]{6})h)\)')


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


def addr_values(text):
    out = set()
    for m in ADDR.finditer(text):
        out.add(int(m.group(1) or m.group(2), 16))
    return out


def words(text):
    """lower-case words of a remark, or of a CamelCase / snake_case name"""
    text = re.sub(rb'([a-z0-9])([A-Z])', rb'\1 \2', text)
    return {w.lower() for w in re.findall(rb'[A-Za-z0-9]+', text)}


def rewrite(com, vals, names):
    body = com[1:].strip()
    if not (addr_values(body) & vals):
        return None
    rest = BYTES.sub(b"", body)
    if rest != body or ECHO.match(rest):
        m = DASH.search(rest)
        if m:
            remark = rest[m.end():].strip()
            # a remark that only repeats the operand's name ("workspace ptr" on MainWorkspacePtr) goes too
            if remark and not (addr_values(remark) & vals) and not words(remark) <= names:
                return b"; " + remark
        return b""
    new = PAREN.sub(lambda m: b"" if int(m.group(1) or m.group(2), 16) in vals else m.group(0), body)
    return None if new == body else b"; " + new


def main():
    files = sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s")))
    value = {}
    for p in files:
        for m in EQU.finditer(open(p, "rb").read()):
            value[m.group(1)] = int(m.group(2), 16)
    dropped = kept_remark = prose = 0
    for p in files:
        lines = open(p, "rb").read().split(b"\n")
        changed = False
        for i, ln in enumerate(lines):
            code, com = split_comment(ln)
            if not com or code.lstrip().startswith(b"."):
                continue
            used = [n for n, off in NAME.findall(code) if n in value]
            vals = {value[n] + int(off or 0) for n, off in NAME.findall(code) if n in value}
            if not vals:
                continue
            names = set().union(*(words(n) for n in used))
            new = rewrite(com, vals, names)
            if new is None:
                continue
            if new == b"":
                lines[i] = code.rstrip()
                dropped += 1
            else:
                lines[i] = code.rstrip() + "\t".encode() + new
                if ECHO.match(BYTES.sub(b"", com[1:].strip())) or BYTES.match(com[1:].strip()):
                    kept_remark += 1
                else:
                    prose += 1
            changed = True
        if changed and "--apply" in sys.argv[1:]:
            with open(p + ".tmp", "wb") as fh:
                fh.write(b"\n".join(lines))
            os.replace(p + ".tmp", p)
    print("echo comments dropped: %d; echoes cut to their remark: %d; prose comments with the address removed: %d%s"
          % (dropped, kept_remark, prose, "" if "--apply" in sys.argv[1:] else " (dry run)"))


if __name__ == "__main__":
    main()
