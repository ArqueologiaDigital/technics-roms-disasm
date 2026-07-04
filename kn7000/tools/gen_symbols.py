#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Recovers named function symbols for the KN7000 program image by parsing the
# "MILK toolkit" reflection tables the firmware embeds for its own runtime
# class/procedure lookup (MT_GetProcedure & friends).
#
# This directly reuses KN5000 research: the KN7000 and KN5000 share the same
# object-oriented UI toolkit, so these names (RegisterObjectTable, DispatchEvent,
# the Ac*/Vw*/Ps*/Iv* widget window-procedures, ...) match documented KN5000
# functions. See: technics-shared-codebase in the kn5000-docs site.
#
# The reflection data has two index-parallel arrays in the program image:
#   * a NUL-terminated u32 array of CODE pointers  at file 0x3270AC
#   * a NUL-terminated u32 array of NAME pointers   at file 0x3277A0
# The arrays are offset by one: the function at code[j] is named by name[j-1]
# (equivalently name[i] describes code[i+1]). This was pinned down semantically:
# e.g. code index for 0x2936F is a tiny no-argument init helper == the name
# "InitializeEventQueue" that sits one slot back, while the next two entries are
# the two-argument DispatchEvent/SendEvent siblings -- which only lines up under
# the shift. code[0] (leading) and the last name (trailing) are therefore
# unpaired. Verified: essentially every target begins with an MN10300 prologue.
#
# Program flash maps at CPU 0x48400000, so cpu_addr = file_offset + 0x48400000.
#
# Outputs:
#   kn7000.sym        - "0xCPUADDR  name" table (sorted; the portable artifact)
#   src/symbols.inc   - ".equ name, 0xCPUADDR" for the assembler / disassembly

import argparse
import os
import struct

PROGRAM_BASE = 0x48400000
CODE_LO, CODE_HI = 0x80, 0x3F6F01          # valid code file-offset range
CODE_ARRAY = 0x3270AC                       # u32 code pointers (NUL-terminated)
NAME_ARRAY = 0x3277A0                       # u32 name pointers (index-parallel)

# Verified memory-map / framework equates worth carrying as named constants.
MEMORY_MAP = [
    ("PROGRAM_ROM_BASE", 0x48400000, "program flash mapping"),
    ("TABLE_ROM_BASE",   0x48000000, "table flash mapping"),
    ("BOOTROM_BASE",     0x4C000000, "library/kernel code (undumped internal ROM)"),
    ("WORK_RAM_BASE",    0x50000000, "work RAM"),
    ("INITIAL_SP",       0x50021CF8, "initial stack pointer"),
    ("PICTURE_FLASH",    0x57800000, "picture flash (separate device)"),
]


def read_u32(data, off):
    return struct.unpack_from("<I", data, off)[0]


def read_name(data, ptr):
    off = ptr - PROGRAM_BASE
    if not (0 <= off < len(data)):
        return None
    end = data.find(b"\x00", off)
    s = data[off:end]
    if not s or not all(32 <= c < 127 for c in s):
        return None
    return s.decode("latin1")


def _is_code(v):
    return CODE_LO <= v - PROGRAM_BASE < 0x186000 or 0x3B8000 <= v - PROGRAM_BASE < CODE_HI


def _is_strptr(data, ident_offsets, v):
    return (v - PROGRAM_BASE) in ident_offsets


def _prologue(data, cpu):
    o = cpu - PROGRAM_BASE
    if not (0 <= o < len(data) - 1):
        return False
    b = data[o]
    if b in (0xCF, 0xCE):                                  # movm  (save regs)
        return True
    if b in (0xF8, 0xFA, 0xFC) and data[o + 1] == 0xFE:    # add  imm,sp
        return True
    return False


def _ident_offsets(data):
    import re
    return {m.start() for m in re.finditer(
        rb"[A-Za-z_][A-Za-z0-9_]{2,31}\x00", data)}


def find_tables(data, ident_offsets):
    """Yield (code_array_off, name_array_off, n) for every MILK reflection table.

    Each table is a run of code pointers, a NUL, then an index-parallel run of
    name pointers (into identifier strings). Discovered generically so that all
    ~100+ widget/handler tables are found, not just the main one. A prologue
    check on the paired code targets rejects look-alike arrays that are really
    event-id / widget-id / field-name pointer tables (their "code" side isn't
    code at all).
    """
    n_words = len(data) // 4
    i = 0
    while i < n_words:
        # locate the start of a name-pointer run
        if not _is_strptr(data, ident_offsets, read_u32(data, 4 * i)):
            i += 1
            continue
        name_off = 4 * i
        j = i
        while j < n_words and _is_strptr(data, ident_offsets, read_u32(data, 4 * j)):
            j += 1
        n_names = j - i
        i = j
        if n_names < 4:
            continue
        # the code array ends with a NUL immediately before the name array
        p = name_off - 4
        if read_u32(data, p) != 0:
            continue
        p -= 4
        codes = []
        while p >= 0 and _is_code(read_u32(data, p)):
            codes.append(read_u32(data, p))
            p -= 4
        codes.reverse()
        n = len(codes)
        if n < 4 or n < n_names:              # need code[j]<->name[j-1]
            continue
        code_off = name_off - 4 - 4 * n
        # validate: the paired code targets are overwhelmingly function prologues
        paired = [read_u32(data, code_off + 4 * k) for k in range(1, min(n, n_names + 1))]
        good = sum(_prologue(data, c) for c in paired)
        if paired and good >= 0.8 * len(paired):
            yield code_off, name_off, n


def recover_symbols(data):
    """Returns a sorted list of (cpu_addr, file_offset, name)."""
    ident_offsets = _ident_offsets(data)
    out = {}          # file_offset -> name
    used = set()      # names already taken (keep them unique)
    # code[j] is named by name[j-1]; code[0] is the unpaired leading entry.
    for code_arr, name_arr, n in find_tables(data, ident_offsets):
        for j in range(1, n):
            code = read_u32(data, code_arr + 4 * j)
            name = read_name(data, read_u32(data, name_arr + 4 * (j - 1)))
            coff = code - PROGRAM_BASE
            if name is None or not (CODE_LO <= coff < CODE_HI) or coff in out:
                continue
            if not (name[0].isalpha() or name[0] == "_"):
                continue
            unique = name
            k = 2
            while unique in used:                 # disambiguate rare name clashes
                unique = f"{name}_{k}"
                k += 1
            used.add(unique)
            out[coff] = unique

    return sorted((PROGRAM_BASE + off, off, name) for off, name in out.items())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("program_rom", nargs="?",
                        default="baserom/kn7000_program.rom")
    parser.add_argument("--sym", default="kn7000.sym")
    parser.add_argument("--inc", default="src/symbols.inc")
    args = parser.parse_args()

    data = open(args.program_rom, "rb").read()
    syms = recover_symbols(data)

    with open(args.sym, "w") as f:
        f.write("; KN7000 program-image symbols recovered from the MILK toolkit\n")
        f.write("; reflection tables (tools/gen_symbols.py). cpu_addr  name\n")
        f.write(";\n; Verified memory map:\n")
        for name, addr, note in MEMORY_MAP:
            f.write(f"0x{addr:08X}  {name}\t; {note}\n")
        f.write(f";\n; {len(syms)} recovered function symbols:\n")
        for cpu, _off, name in syms:
            f.write(f"0x{cpu:08X}  {name}\n")

    os.makedirs(os.path.dirname(args.inc), exist_ok=True)
    with open(args.inc, "w") as f:
        f.write("# KN7000 symbols (generated by tools/gen_symbols.py — do not edit).\n")
        f.write("# Function names recovered from the firmware's own MILK-toolkit\n")
        f.write("# reflection tables; shared with the KN5000 (see kn5000-docs).\n\n")
        for name, addr, note in MEMORY_MAP:
            f.write(f".equ {name}, 0x{addr:08X}   # {note}\n")
        f.write(f"\n# {len(syms)} recovered functions:\n")
        for cpu, _off, name in syms:
            f.write(f".equ {name}, 0x{cpu:08X}\n")

    print(f"gen_symbols: recovered {len(syms)} function symbols "
          f"-> {args.sym}, {args.inc}")


if __name__ == "__main__":
    main()
