#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""data_field_uses.py -- what the code does with a record field after it loads it.

QUESTION ANSWERED
-----------------
"A record field is read by `movhu (8, a0), d0`: what does the routine then do with d0 -- call
through it, hand it to a named routine, compare it with a named constant, count a loop with it,
index a table with it, test bits of it, follow it as a pointer?"  tools/data_struct_names.py
names the fields whose use this shows (lane mn10300-formats, 2026-10-31); the macro header of
every record kind still cites the reading instruction, and the field's name now says its use.

HOW
---
For each reading instruction (tools/data_readers.py's Access: the function or local label it is
under, and the instruction's text) the converted code is searched from that label for the
instruction, and the loaded register is followed through the next instructions of the same
straight-line block (it may be copied to another register; the walk stops where the register is
overwritten, at a call for the scratch registers d0 / d1 / a0 / a1 once their use as an argument
is seen, at a `ret` / `jmp` / `bra`, or after LOOKAHEAD instructions).  The uses it records:

  call        `calls (rN)` / `jmp (rN)`: a code pointer (a handler, a procedure)
  arg         the register (or its copy) is d0 / d1 / a0 / a1 at a `call F` / `call F_entry`:
              (F, register); the parameter name comes from PARAMS when F is listed there; otherwise
              F's own code is followed from its entry with that register live (two levels deep), and
              a use found there counts as the field's (`via`)
  cmpk        `cmp SYMBOL, rN` with a symbolic constant (EV_*, MT_*, ...): its prefix names a kind
  cmp         `cmp N, rN` with a number
  deref       `(rN)` / `(off, rN)`: it is used as a pointer to a record
  index       `(rN, aX)` / `(dX, rN)` / `asl`, `asl2`, `mulu`: an index or offset into a table
  bits        `btst` / `and` / `or` with a constant: flag bits
  loopcount   compared with a register and followed by a backward conditional branch, or the
              bound of a `setlb` loop: a count
  key         compared with a register and followed by beq / bne (forward): a key the routine
              matches against a value it was given (a lookup)

[INFERENCE] The walk is linear and local: a value stored to the frame and reloaded later, or used
in another block, is not followed.  A field with no use found keeps its offset name.

RUN (from kn7000/):  python3 tools/data_field_uses.py --profile 941 FUNC 'movhu (8, a0), d0'
"""

import collections
import glob
import re
import sys

LOOKAHEAD = 14
NEAR = 20
# (lane mn10300-rest) switches of the follow rules it added, all on; GEN_DATA_S_OFF (a comma list, as
# gen_data_s.FEATURES) turns them off by name: field_pos, field_slots, field_bra, field_keyloop, field_merge,
# field_screen
import os as _os
_OFF = set(x.strip() for x in _os.environ.get("GEN_DATA_S_OFF", "").split(",") if x.strip())
POS = "field_pos" not in _OFF          # follow the access's own place (Access.pos), not every place
SLOTS = "field_slots" not in _OFF      # follow a value parked in the frame to its reloads
BRA = "field_bra" not in _OFF          # go on at the target of an unconditional branch
KEYLOOP = "field_keyloop" not in _OFF  # a compare and a backward beq / bne is a search key
MERGE = "field_merge" not in _OFF      # places that disagree: the uses of all of them, by precedence
SLOT_SPAN = 400
# (lane mn10300-rest) the LCD every MN10300 tree drives is 640 x 240 (LcdOut 0x48414D05 clamps x to 640
# and y to 240; the SX-KN6000 / KN6500 / KN2400 and the HD-SX3 plug-in draw on the same panel): a field
# compared with the width (or the last column) and nothing else is a column, with the height a row;
# switch field_screen
SCREEN = "field_screen" not in _OFF
SCREEN_X = {640, 639}
SCREEN_Y = {240, 239}
_WIDTH = {"mov": 4, "movhu": 2, "movh": 2, "movbu": 1, "movb": 1}
SCRATCH = ("d0", "d1", "a0", "a1")
REG = r"(?:d[0-3]|a[0-3])"

# Parameter names of routines records hand their fields to, from the routines' own code or their
# symbol-file notes (kn7000_manual.sym; the siblings use the same MILK framework names)
PARAMS = {
    ("SendEvent", "d0"): "object",          # SendEvent(d0 = object id, d1 = event / message)
    ("SendEvent", "d1"): "event",
    ("PostEvent", "d0"): "object",
    ("PostEvent", "d1"): "event",
    ("GetViewInstance", "d0"): "view",      # the view id it finds the instance of
    ("SubView", "d0"): "view",
    ("ChangeTitle", "d0"): "title",         # a title id (TT_*)
    ("DrawIcons", "d0"): "icon",            # an icon index into IconTablePtr's table
    ("DrawBitmap", "d0"): "bitmap",
    ("Malloc", "d0"): "size",
    ("memset", "d1"): "size",
    ("memcpy", "d0"): "size",
    ("strncpy", "d0"): "size",
    ("strcpy", "a1"): "text",
    ("strncpy", "a1"): "text",
    ("strcmp", "a1"): "text",
    ("strlen", "a0"): "text",
    ("LibStrlen", "a0"): "text",
    ("DrawString", "a0"): "text",
    ("set_flg", "d0"): "flag",
    ("clr_flg", "d0"): "flag",
    ("GetM3Em", "d0"): "param_key",         # GetM3Em / GetM3EmVal: a parameter-memory key
    ("GetM3EmVal", "d0"): "param_key",
    ("PutM3Em", "d0"): "param_key",
    ("SetApTimer", "d0"): "timer",
    ("KillApTimer", "d0"): "timer",
    ("cre_tsk", "d0"): "task_id",
    ("act_tsk", "d0"): "task_id",
    ("sta_tsk", "d0"): "task_id",
    ("wai_flg", "d0"): "flag_id",
    ("set_flg", "d1"): "flag_bits",
    ("LibDiv32", "d1"): "divisor",
    ("LibDiv32", "d0"): "dividend",
}


def base_name(f):
    """A routine's name without the register-save entry suffix."""
    return f[:-6] if f.endswith("_entry") else f


def generic(f):
    """A routine named only by its address (func_XXXXXXXX, loc_, a local label)."""
    return bool(re.match(r"(func|loc|sub)_[0-9A-Fa-f]{6,8}", f)) or bool(re.search(r"_L[0-9a-f]+$", f))


class CodeIndex:
    """The converted code of a build, by label."""

    def __init__(self, src_glob):
        self.lines = []
        self.file_start = []     # (lane mn10300-rest) where each file's lines start: Access.pos -> line
        for f in sorted(glob.glob(src_glob)):
            self.file_start.append(len(self.lines))
            self.lines += [ln.split("#", 1)[0].rstrip() for ln in open(f, encoding="latin-1")]
        self.at = {}
        for i, ln in enumerate(self.lines):
            m = re.match(r"^([A-Za-z_.$][\w.$]*):", ln)
            if m:
                self.at.setdefault(m.group(1), i)
        self.cache = {}

    @staticmethod
    def norm(s):
        return " ".join(s.replace(",", ", ").split()).replace(" ,", ",")

    def find(self, func, insn, limit=4000):
        """Line numbers of `insn` after label `func` (before the next function header)."""
        i0 = self.at.get(func)
        if i0 is None:
            return []
        want = self.norm(insn)
        out = []
        for i in range(i0, min(len(self.lines), i0 + limit)):
            ln = self.lines[i]
            ml = re.match(r"^([A-Za-z_.$][\w.$]*):", ln)
            if ml and i > i0 and not re.search(r"(_L[0-9a-f]+_*|_entry)$|^loc_", ml.group(1)):
                break            # the next function
            body = ln[ml.end():].strip() if ml else ln.strip()
            if body and self.norm(body) == want:
                out.append(i)
        return out

    def at_pos(self, pos, insn):
        """(lane mn10300-rest) The line of an access's own place (tools/data_readers.py Access.pos:
        file index, line index), when it holds `insn`; else None."""
        if pos is None or not 0 <= pos[0] < len(self.file_start):
            return None
        i = self.file_start[pos[0]] + pos[1]
        if not 0 <= i < len(self.lines):
            return None
        ln = self.lines[i]
        ml = re.match(r"^([A-Za-z_.$][\w.$]*):", ln)
        body = ln[ml.end():].strip() if ml else ln.strip()
        return i if body and self.norm(body) == self.norm(insn) else None

    def uses(self, func, insn, near=(), pos=None):
        """The uses (see the module docstring) of the register `insn` loads: one Counter per place the
        instruction occurs in the function.  `near`: names of the record array; when some of the places
        have one of them in the NEAR lines before (the `mov Base, aN` the read goes through), only
        those places count.  `pos` (lane mn10300-rest): the access's own place; when it holds the
        instruction, that place alone counts (the path the walk read the field on), so two places of
        one instruction that load different things no longer disagree."""
        key = (func, insn, tuple(sorted(near)), pos)
        if key in self.cache:
            return self.cache[key]
        m = re.match(r"\s*mov(?:bu|hu|b|h)?\s+.*,\s*(" + REG + r")\s*$", insn)
        res = []
        here = self.at_pos(pos, insn) if (m and POS) else None
        if here is not None:
            res = [collections.Counter(self.follow(here, m.group(1)))]
            self.cache[key] = res
            return res
        if m:
            places = self.find(func, insn)
            if near and len(places) > 1:
                rx = re.compile(r"\b(" + "|".join(re.escape(x) for x in near) + r")\b")
                close = [i for i in places if any(rx.search(self.lines[k]) for k in range(max(0, i - NEAR), i))]
                if close:
                    places = close
            res = [collections.Counter(self.follow(i, m.group(1))) for i in places]
        self.cache[key] = res
        return res

    def func_end(self, i, limit=4000):
        """The line after the last of the function line i is in (the next function's label)."""
        for k in range(i + 1, min(len(self.lines), i + limit)):
            ml = re.match(r"^([A-Za-z_.$][\w.$]*):", self.lines[k])
            if ml and not re.search(r"(_L[0-9a-f]+_*|_entry)$|^loc_", ml.group(1)):
                return k
        return min(len(self.lines), i + limit)

    def follow(self, i, reg, depth=0, _seen=None):
        """The uses of the value register `reg` holds after line i (see the module docstring).  Lane
        mn10300-rest added, each a switch of this module: a value parked in the frame (`mov dN,
        (N, sp)`) is followed to every reload of that slot further down the function (SLOTS); an
        unconditional `bra` / `jmp` to a label of the same function continues the block there
        (BRA); a compare with a register followed by a backward beq / bne is a key search, not a
        count (KEYLOOP)."""
        seen = _seen if _seen is not None else set()
        live = {reg}
        out = []
        n = 0
        j = i + 1
        lookahead = LOOKAHEAD
        while j < len(self.lines) and n < lookahead:
            if (j, frozenset(live)) in seen:
                break
            seen.add((j, frozenset(live)))
            ln = self.lines[j]
            j += 1
            if re.match(r"^[A-Za-z_.$][\w.$]*:", ln):
                lab = re.match(r"^([A-Za-z_.$][\w.$]*):", ln).group(1)
                ln = ln[len(lab) + 1:]
                # a function boundary ends the block; a local label (a loop head) does not
                if not re.search(r"(_L[0-9a-f]+|^loc_[0-9A-F]+)$", lab):
                    break
            ln = ln.strip()
            if not ln:
                continue
            n += 1
            parts = ln.split(None, 1)
            op, rest = parts[0], (parts[1] if len(parts) > 1 else "")
            args = [a.strip() for a in re.split(r",(?![^(\[]*[)\]])", rest)] if rest else []
            uses_live = [r for r in live if re.search(r"\b" + r + r"\b", rest)]
            if op in ("calls", "jmp") and args and args[0].strip("()") in live:
                out.append(("call",))
                break
            if op == "call":
                f = base_name(args[0]) if args else "?"
                for r in sorted(live):
                    if r in SCRATCH:
                        out.append(("arg", f, r))
                        # what the routine does with its parameter, when its own name does not say
                        # (two levels: the depth tools/data_readers.py's callee walk also keeps short of)
                        if depth < 2 and (f, r) not in PARAMS and args:
                            k = self.at.get(args[0], self.at.get(f))
                            if k is not None:
                                out += [("via", f) + u for u in self.follow(k, r, depth + 1)]
                live -= set(SCRATCH)
                if not live:
                    break
                continue
            if BRA and op in ("bra", "jmp") and args and re.fullmatch(r"[A-Za-z_.$][\w.$]*", args[0]) and \
                    re.search(r"(_L[0-9a-f]+_*|^loc_[0-9A-F]+)$", args[0]) and args[0] in self.at:
                # (lane mn10300-rest) the block goes on at the label (a local one: the same function)
                j = self.at[args[0]]
                continue
            if op in ("ret", "retf", "rets", "rti", "bra", "jmp"):
                break
            if not uses_live:
                continue
            r = uses_live[0]
            if op == "cmp" and len(args) == 2:
                other = args[0] if args[1] == r else args[1]
                if re.fullmatch(REG, other):
                    # compared with a register: a loop count when a backward branch (or a setlb loop's
                    # Lcc) follows, else a key the routine matches against a value it was given
                    nxt = self.lines[j].strip() if j < len(self.lines) else ""
                    mb = re.match(r"(b\w\w|l\w\w)\b\s*(\S*)", nxt)
                    back = mb and (mb.group(1)[0] == "l" or self.at.get(mb.group(2), len(self.lines)) < j)
                    if KEYLOOP and back and mb.group(1) in ("beq", "bne", "leq", "lne"):
                        # (a search loop: go on while the value is not, or is, the one sought)
                        out.append(("key",))
                    elif back:
                        out.append(("loopcount",))
                    elif mb and mb.group(1) in ("beq", "bne"):
                        out.append(("key",))
                elif re.fullmatch(r"-?(0x[0-9a-fA-F]+|\d+)", other):
                    out.append(("cmp", int(other, 0)))
                else:
                    out.append(("cmpk", other))
                continue
            if op in ("btst", "and", "or", "xor") and len(args) == 2 and args[1] == r and \
                    re.fullmatch(r"(0x[0-9a-fA-F]+|\d+)", args[0]):
                out.append(("bits",))
                if op != "btst":
                    break
                continue
            if op in ("asl", "asl2", "mulu", "mul", "lsr", "asr") and args and args[-1] == r:
                out.append(("index",))
                break
            ms = re.fullmatch(r"\((-?(?:0x[0-9a-fA-F]+|\d+))\s*,\s*sp\)", args[1]) if len(args) == 2 else None
            if SLOTS and ms and op.startswith("mov") and args[0] in live:
                # (lane mn10300-rest) parked in the frame: followed to the slot's reloads below
                out += self.reloads(j, ms.group(1), op, depth, seen)
                continue
            mem = re.findall(r"\(([^()]*)\)", rest)
            if any(re.fullmatch(r"\s*(?:-?(?:0x[0-9a-fA-F]+|\d+)\s*,\s*)?" + r + r"\s*", x) for x in mem):
                out.append(("deref",))
                break
            if any(re.fullmatch(r"\s*" + REG + r"\s*,\s*" + REG + r"\s*", x) and r in x for x in mem):
                out.append(("index",))
                break
            # a copy: mov rN, rM keeps the value live in rM
            if op == "mov" and len(args) == 2 and args[0] == r and re.fullmatch(REG, args[1]):
                live.add(args[1])
                continue
            # overwritten
            if args and args[-1] == r and op.startswith("mov"):
                live.discard(r)
                if not live:
                    break
                continue
            if op in ("extb", "extbu", "exth", "exthu"):
                continue
            if op in ("add", "sub", "inc", "dec", "inc4"):
                continue
        return out

    def reloads(self, j, slot, sop, depth, seen):
        """(SLOTS) The uses of a value stored to frame slot `slot` (`sop`, a mov of some width) at the
        line before j: every `mov (slot, sp), rM` of the same width further down the function, up to a
        store of something else to that slot or a change of the stack pointer, followed as the
        field's own.  [INFERENCE: the reloads are on a path the store is on; the compiler gives a
        slot one variable]"""
        out = []
        width = _WIDTH.get(sop)
        end = self.func_end(j - 1)
        slot_rx = re.compile(r"\(\s*" + re.escape(slot) + r"\s*,\s*sp\s*\)")
        for k in range(j, min(end, j + SLOT_SPAN)):
            ln = self.lines[k]
            ml = re.match(r"^([A-Za-z_.$][\w.$]*):", ln)
            body = (ln[ml.end():] if ml else ln).strip()
            if not body:
                continue
            parts = body.split(None, 1)
            op, rest = parts[0], (parts[1] if len(parts) > 1 else "")
            if op == "add" and rest.replace(" ", "").endswith(",sp"):
                break
            if not slot_rx.search(rest):
                continue
            a = [x.strip() for x in re.split(r",(?![^(\[]*[)\]])", rest)]
            if len(a) == 2 and slot_rx.fullmatch(a[0]) and re.fullmatch(REG, a[1]) and op.startswith("mov"):
                if _WIDTH.get(op) == width:
                    out += self.follow(k, a[1], depth, seen)
                continue
            if len(a) == 2 and slot_rx.fullmatch(a[1]):
                break                    # the slot takes another value
        return out


def name_for_all(occs, fkind):
    """A field name from the uses of every place its readers occur (Counters), when the places that
    show a use agree on it; else (MERGE, lane mn10300-rest) the name the uses of all the places give
    together, by name_for()'s precedence (a call through it, a known parameter, a symbolic
    constant's family, a loop count, a search key, a named routine's argument, an index, flags):
    every place is a reader of the same field, so each use is evidence for it.  None when no place
    shows a use that names it."""
    names = {name_for(c, fkind) for c in occs if c}
    if len(names) == 1:
        return names.pop()
    if not MERGE or not names:
        return None
    total = collections.Counter()
    for c in occs:
        total.update(c)
    return name_for(total, fkind)


def name_for(uses, fkind):
    """A field name from its uses (a Counter of use tuples), or None."""
    if not uses:
        return None
    # a use inside a routine the field is handed to counts as the field's own (`via`)
    flat = collections.Counter()
    for u, c in uses.items():
        while u and u[0] == "via":
            u = u[2:]
        if u:
            flat[u] += c
    direct_args = [(u[1], u[2]) for u in uses if u[0] == "arg"]
    uses = flat
    kinds = collections.Counter()
    for u, c in uses.items():
        kinds[u[0]] += c
    if kinds["call"]:
        return "proc"
    args = [(u[1], u[2]) for u in uses if u[0] == "arg" and not generic(u[1])]
    for fr in args:
        if fr in PARAMS:
            return PARAMS[fr]
    cmpk = [u[1] for u in uses if u[0] == "cmpk"]
    if cmpk:
        pre = re.match(r"([A-Z][A-Z0-9]*)_", cmpk[0])
        if pre:
            return {"EV": "event", "MT": "message", "TT": "title", "FN": "function", "CL": "color",
                    "ES": "editsw", "VF": "flags", "BD": "border"}.get(pre.group(1), pre.group(1).lower() + "_id")
    if kinds["loopcount"]:
        return "count"
    if kinds["key"]:
        return "key"
    named = [fr for fr in direct_args if not generic(fr[0])]
    if named:
        f, r = named[0]
        return f"{f}_{r}"
    if kinds["index"]:
        return "index"
    if kinds["bits"]:
        return "flags"
    if kinds["deref"] and fkind == "ptr":
        return None          # a pointer used as one: data_struct_names names it by its targets
    cmps = [u[1] for u in uses if u[0] == "cmp"]
    if cmps and len(set(cmps)) > 1:
        return "kind"
    if SCREEN and cmps and set(cmps) <= SCREEN_X:
        return "x"           # (lane mn10300-rest) checked against the LCD's width: a column
    if SCREEN and cmps and set(cmps) <= SCREEN_Y:
        return "y"           # checked against its height: a row
    if SCREEN and kinds["deref"] and fkind == "num":
        return "addr"        # (lane mn10300-rest) a number used as a pointer: an address outside the data
    return None


def main():
    import os
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import gen_data_s as G
    a = sys.argv[1:]
    prof = "941"
    if a and a[0] == "--profile":
        prof, a = a[1], a[2:]
    G.configure(prof)
    ci = CodeIndex(G.code_glob())
    u = ci.uses(a[0], a[1])
    print([dict(c) for c in u], "->", name_for_all(u, "num"))


if __name__ == "__main__":
    main()
