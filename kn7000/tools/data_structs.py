#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""data_structs.py -- struct arrays of the program data region, from their readers.

QUESTION ANSWERED
-----------------
"Which bytes of the data region are an array of fixed-size records, what is
the record's stride and what are its fields -- each field's offset, width,
signedness and the instructions that read it?"

The evidence is tools/data_readers.py: an access through base + index * stride
+ offset (the compiler's `mov STRIDE, dN; mulu dI, dN; add Base, aN; movhu
(OFF, aN), dM` and its variants).  For each stride:

  * the array starts at the address the code adds the index to; a field's
    offset is the access offset modulo the stride (a reader of element i - 1
    or i + 1 adds or subtracts the stride; a 1-based index subtracts it once);
  * bases closer together than one stride (the code added a field offset to
    the base) are one array; a base a whole number of strides further on is
    another array (TechniChordHymn's 28 rows, then TechniChordBigBandBrass);
  * a field's width is the width most of its loads use, signed when an extb /
    exth of the loaded register follows; an access with a second, smaller
    index (base + i * stride + j * t) is an array of t-byte elements inside the
    record; a field passed to strncpy / memcpy / strcpy / strcmp is a char
    array (of the constant length the call is given, when it fits);
  * bytes no reader touches are kept: as a pointer when every record holds a
    program / RAM-image address or 0 there (4-aligned), else as bytes;
  * the array runs from its base while every record is free, its pointer
    fields hold addresses or 0, and no other array's base, symbol-file name or
    typed item is reached (gen_data_s.Gen.struct_arrays).  [INFERENCE] an
    array whose fields are all numbers can run on into whatever follows it, up
    to such a boundary.

gen_data_s.py writes one macro per record kind into <data dir>/data_structs.inc,
its parameters the field names: tools/data_struct_names.py names the fields
whose use is understood; the rest are f<off> (a number), p<off> (a pointer),
s<off> (text), a<off> (an array inside the record) and x<off> (bytes no reader
was seen to touch).
"""

import collections

import data_readers as DR

STRFUNCS = {"strncpy", "strcpy", "memcpy", "strcmp", "strncmp", "strlen", "memcmp", "strcat", "strncat",
            "strncpy_entry", "memcpy_entry"}
DIRECTIVE = {1: ".byte", 2: ".word", 4: ".long"}


class Field:
    __slots__ = ("off", "width", "kind", "signed", "accs", "name", "elem", "sub")

    def __init__(self, off, width, kind, signed=False, accs=(), elem=None, sub=None):
        self.off, self.width, self.kind, self.signed, self.accs = off, width, kind, signed, list(accs)
        self.name = None
        self.elem = elem          # array: the element size
        self.sub = sub            # array: the element's own width when all its loads use one


class Group:
    tail = None              # (pointed records of varying size) element width of the rows after the fields

    def __init__(self, base, stride):
        self.base, self.stride = base, stride
        self.accs = []           # (offset in the record, Access)
        self.raw = set()         # raw code bases merged here
        self.fields = []
        self.label = None
        self.macro = None
        self.count = 0


def readers(g, labels_path, src_glob):
    """data_readers.Reader over the build's converted code, with every label gen_data_s knows
    (labels_path: a build's `name hex` labels file, or a {name: address} dict)."""
    if isinstance(labels_path, dict):
        labels = dict(labels_path)
    else:
        labels = {}
        for line in open(labels_path):
            n, v = line.split()
            labels[n] = int(v, 16)
    labels.update(g.prev_data_label)
    return DR.Reader(src_glob, labels, g.in_data)


def groups(dr):
    """The record arrays the accesses show, merged."""
    raw = collections.defaultdict(list)
    absacc = collections.defaultdict(list)
    for acc in dr.accesses:
        k = acc.key
        if k[0] == "rec" and k[2] and k[2] >= 2:
            raw[(k[2], k[1])].append(acc)
        elif k[0] == "abs" and acc.width:
            absacc[k[1]].append(acc)
    # a pointer stepped from a base (`mov Base, aN` ... `add STRIDE, aN` / `inc4 aN`): an array of
    # STRIDE-byte records whose fields are the fixed accesses within its first record
    for acc in dr.accesses:
        if acc.key[0] == "step":
            b, s = acc.key[1], acc.off
            if (s, b) in raw:
                continue
            first = [a._replace(key=("rec", b, s), off=x - b) for x in range(b, b + s) for a in absacc.get(x, ())]
            if first:
                raw[(s, b)] = first
    out, by_s = [], collections.defaultdict(list)
    for (s, b), accs in sorted(raw.items()):
        g = None
        for h in by_s[s]:
            d = b - h.base
            if 0 <= d < s:
                g = h
                break
        if g is None:
            g = Group(b, s)
            by_s[s].append(g)
            out.append(g)
        g.raw.add(b)
        for a in accs:
            g.accs.append(((b - g.base + a.off) % s, a))
    return out


def layout(g, gen, base_off, n, offs=None):
    """The fields of group g, whose n records start at file offset base_off (or,
    for records a pointer leads to, at the file offsets `offs`)."""
    rom = gen.rom
    s = g.stride
    offs = offs if offs is not None else [base_off + r * s for r in range(n)]
    n = len(offs)
    widths = collections.defaultdict(collections.Counter)
    signed = collections.defaultdict(bool)
    byoff = collections.defaultdict(list)
    args = collections.defaultdict(list)
    inner = collections.defaultdict(list)     # element size -> [(offset, access)]
    for o, a in g.accs:
        if o < 0 or o >= s or a.inner == -1:
            continue          # (inner -1: an offset computed from here, see gen_data_s.ptr_records)
        if a.inner and a.inner < s and a.width:
            inner[a.inner].append((o, a))
        elif a.width:
            widths[o][a.width] += 1
            byoff[o].append(a)
            if a.signed:
                signed[(o, a.width)] = True
        elif a.rw.startswith("arg"):
            args[o].append(a)
    own = [None] * s
    fields = []

    def word(r, k, w=4):
        q = offs[r] + k
        return int.from_bytes(rom[q:q + w], "little")

    for o in sorted(widths, key=lambda o: (-sum(widths[o].values()), o)):
        for w, _c in widths[o].most_common():
            if not (o % w or o + w > s or any(own[o:o + w])):
                break
        else:
            continue
        f = Field(o, w, "num", signed[(o, w)], [a for a in byoff[o] if a.width == w])
        own[o:o + w] = [f] * w
        fields.append(f)
    # arrays inside the record: the accesses with a second index
    for t, lst in sorted(inner.items(), reverse=True):
        start = min(o for o, _a in lst)
        if any(own[start:start + t]):
            continue
        e = start
        while e < s and own[e] is None:
            e += 1
        e = start + (e - start) // t * t
        if e <= start:
            continue
        subw = {a.width for _o, a in lst}
        f = Field(start, e - start, "array", any(a.signed for _o, a in lst), [a for _o, a in lst], elem=t,
                  sub=(subw.pop() if len(subw) == 1 else 1))
        if f.sub > t or t % f.sub:
            f.sub = 1
        own[start:e] = [f] * (e - start)
        fields.append(f)
    # text fields: the field's address passed to a string / memory function
    for o, accs in sorted(args.items()):
        if own[o] is not None:
            continue
        fn = next((a.extra for a in accs if a.extra and a.extra[0] in STRFUNCS), None)
        if fn is None:
            continue
        e = o
        while e < s and own[e] is None:
            e += 1
        ln = fn[1].get("d0")
        if ln and o + ln <= e:
            e = o + ln
        f = Field(o, e - o, "text", accs=[a for a in accs if a.extra and a.extra[0] in STRFUNCS])
        own[o:e] = [f] * (e - o)
        fields.append(f)
    # 32-bit fields that hold addresses are pointers
    for f in fields:
        if f.width == 4 and f.kind == "num":
            vals = [word(r, f.off) for r in range(n)]
            if any(vals) and all(v == 0 or gen.is_addr(v) for v in vals):
                f.kind = "ptr"
    # the bytes no reader touches
    o = 0
    while o < s:
        if own[o] is not None:
            o += 1
            continue
        e = o
        while e < s and own[e] is None:
            e += 1
        k = o
        while k < e:
            if k % 4 == 0 and k + 4 <= e:
                vals = [word(r, k) for r in range(n)]
                if any(vals) and all(v == 0 or gen.is_addr(v) for v in vals):
                    if k > o:
                        fields.append(Field(o, k - o, "bytes"))
                    fields.append(Field(k, 4, "ptr"))
                    k += 4
                    o = k
                    continue
            k += 1
        if e > o:
            fields.append(Field(o, e - o, "bytes"))
        o = e
    fields.sort(key=lambda f: f.off)
    return fields


def name_fields(g, names):
    """Parameter names: the curated ones (data_struct_names) or kind + offset."""
    used = set()
    pre = {"num": "f", "ptr": "p", "text": "s", "bytes": "x", "array": "a"}
    for f in g.fields:
        n = names.get(f.off) if names else None
        if not n:
            n = f"{pre[f.kind]}{f.off}"
        while n in used or n == "this":
            n += "_"
        used.add(n)
        f.name = n


def cite(accs, k=2):
    seen, out = set(), []
    for a in sorted(accs, key=lambda a: (a.cpu or 0, a.func or "", a.insn)):
        key = (a.func, a.insn)
        if key in seen:
            continue
        seen.add(key)
        out.append(f"{a.func} 0x{a.cpu or 0:08X} `{' '.join(a.insn.split())}`")
        if len(out) == k:
            break
    more = len({(a.func, a.insn) for a in accs}) - len(out)
    return "; ".join(out) + (f" (+{more})" if more > 0 else "")


def field_type(f):
    if f.kind == "text":
        return f"char[{f.width}]"
    if f.kind == "bytes":
        return f"u8[{f.width}]"
    if f.kind == "array":
        return f"{f.width // f.elem} x {f.elem}" + (f" ({'s' if f.signed else 'u'}{8 * f.sub})" if f.sub else "")
    if f.kind == "ptr":
        return "ptr"
    return ("s" if f.signed else "u") + str(8 * f.width)


def vararg(g, f):
    """An array that ends the record is a vararg list of its elements; any other is bytes in a string."""
    return f.kind == "array" and f is g.fields[-1]


def macro_lines(g):
    out = [f"# {g.macro}: {g.stride}-byte records ({g.label}, {g.count} records); fields, and what reads them:"]
    for f in g.fields:
        rd = cite(f.accs) if f.accs else ("no reader seen" if f.kind in ("bytes", "ptr") else "")
        out.append(f"#   +{f.off:<4d}{f.name:12s} {field_type(f):14s} {rd}".rstrip())
    params = []
    for f in g.fields:
        if vararg(g, f):
            params.append(f"{f.name}:vararg")
        elif f.kind in ("bytes", "text", "array"):
            params.append(f.name)
        else:
            params.append(f"{f.name}=0")
    out.append(f".macro {g.macro} " + ", ".join(params))
    for f in g.fields:
        if vararg(g, f):
            out.append(f"\t{DIRECTIVE[f.sub]}\t\\{f.name}")
        elif f.kind in ("bytes", "text", "array"):
            out.append(f"\t.ascii\t\\{f.name}")
        else:
            out.append(f"\t{DIRECTIVE[f.width]}\t\\{f.name}")
    out += [".endm", ""]
    return out


def value(gen, g, f, rom, o):
    """The text of field f of the record at file offset o."""
    b = rom[o + f.off:o + f.off + f.width]
    if vararg(g, f):
        w = f.sub
        return ", ".join(str(int.from_bytes(b[i:i + w], "little", signed=f.signed)) for i in range(0, len(b), w))
    if f.kind in ("bytes", "text", "array"):
        return '"' + gen.c_escape(b) + '"'
    v = int.from_bytes(b, "little", signed=f.signed)
    if f.kind == "ptr":
        return gen.ref(v)
    if f.width == 4 and not f.signed and v > 0xFFFF:
        return f"0x{v:X}"
    return str(v)


def record_line(gen, g, rom, o):
    args, tail = [], None
    for f in g.fields:
        v = value(gen, g, f, rom, o)
        if vararg(g, f):
            tail = v
            continue
        if v == "0" and f.kind not in ("bytes", "text", "array"):
            continue
        args.append(f"{f.name}={v}")
    if tail is not None:
        # a vararg takes the arguments after the last positional one: give every field by position
        args = [value(gen, g, f, rom, o) for f in g.fields]
    return f"\t{g.macro}\t" + ", ".join(args)
