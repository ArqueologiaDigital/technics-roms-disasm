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
    # Data-flash windows recovered by RE (notes in kn7000_mame):
    ("CUSTOM_FLASH_READ", 0x56000000, "custom-data flash read view (idd7000-programmed; u32 dir archive @+0x200)"),
    ("CUSTOM_FLASH_BANK", 0x56020000, "compressed custom-style bank in the custom flash (Huffman/LZH; decoded on style-load)"),
    ("PICTURE_PLANE2", 0x500F9880, "companion picture plane (green4<<4|blue4); pairs with framebuffer 0x500D4080 (0xD0|red4)"),
    ("CUSTOM_FLASH_CMD",  0x96800000, "custom-data flash command/program window (AMD 29LV160; unlocks 0x9680AAAA)"),
    ("FACTORY_DATA_FLASH", 0x57000000, "factory read-only rhythm/style data flash"),
    ("INSTALL_SCRATCH",   0x502B8000, "SDRAM scratch for the disk->flash install"),
    ("CUR_RHYTHM_GENRE",  0x50034C3C, "RAM: current rhythm-genre index (byte)"),
    ("FAVORITES_SRAM",    0x50083D72, "battery-SRAM favorites block ('KN7000 SDDIR INF')"),
]

# Symbols recovered by manual reverse-engineering (NOT in the firmware's own reflection
# tables). Format: (cpu_addr, name, note). Emitted after the auto-recovered symbols,
# skipping any address the auto-pass already named.
MANUAL_SYMBOLS = [
    # --- rhythm genre -> style-list system (see kn7000_mame notes/rhythm-name-list-bug.md)
    (0x48735EE4, "GenreStyleTable",       "16 x 0x18 genre records {name[16],flag,styleCount@+0x11,listPtr@+0x14}"),
    (0x48736064, "GenreCount",            "u16 = 16 rhythm genres"),
    (0x48734EE4, "StyleNumToBankSlotLUT", "2048 x u16: style number -> bank/slot"),
    (0x48435A1B, "GetCurrentGenreIndex",  "reads RAM CUR_RHYTHM_GENRE"),
    (0x48435A9F, "GetGenreName",          "record+0x00, 16-byte memcpy"),
    (0x48435AD9, "GetGenreStyleCount",    "record+0x11"),
    (0x48435B33, "ResolveStyleId",        "source-select &0x00700000 then LUT"),
    (0x4843FB0D, "StyleFlatOrdinalBuilder", "sums preceding genres' counts -> flat ordinal"),
    (0x4858B424, "ResourceIdTrie",        "nibble-indexed resource-id trie (used by libROM 0x4C01BB1C)"),

    # Panel button/LED matrix (RE'd via the MAME driver; kn7000_mame/notes/panel-descriptor-map.md)
    (0x484ADB59, "PanelButtonDispatch",   "reads per-normSeg 12-byte descriptor arrays; posts 0x00700000|event"),
    (0x48614978, "PanelButtonDescPtrTable", "per-normSeg -> 12-byte {event u16, +4 mask, +5 bit, +6 gate, +7 arg, +8 type}"),
    (0x486135A0, "PanelWireNormTable",     "wire ADDR -> normSeg (KN7000 bank A; select flag @RAM 0x5006BE94==0)"),
    (0x4860C9F4, "PanelSwitchClassTable",  "2-byte entries indexed by switch-MATRIX (row*8+col)*2 at reader 0x484A0D23; self-test scan map, NOT a normSeg.bit->LED map"),
    (0x484A0D07, "PanelSelfTestScanEntry", "reads PanelSwitchClassTable by (row*8+col)*2 -- self-test switch/LED matrix scan"),
    (0x48615058, "PanelLedRegMap",         "21-entry (0..0x14) LED-group index -> LED register byte; reader 0x484B1714"),
    (0x484B1707, "PanelLedGroupToReg",     "indexes PanelLedRegMap (bound 0x15) to select an LED register byte"),

    # Style-name / style-list build (RE'd via unidasm mn10300; kn7000_mame/notes/style-name-build.md)
    (0x48441D1B, "StyleRecordToTemplate",  "parse one style record @a2 -> template RAM 0x5003A2BC+idx*0x18 (subtypes 0xB0/C0/D0/E0)"),
    (0x48441CBF, "StyleTemplateToNameTable","memcpy 0xC0 B: template 0x5003A2BC -> displayed name-table 0x5003A37C"),
    (0x48441CDB, "StyleTemplateBuildLoop",  "8x0x18 build loop; per entry calls 0x48440862, handler ptr 0x48435DD0"),
    (0x48442072, "StyleNameDefaultFill",   "memcpy the 15-byte default name ('8 Beat 1' @0x4872AB42) into a name slot"),
    (0x48435DD0, "StyleIdArrayHandler",    "per record: build style-ID arrays 0x50034C48/0x50035448 (u16 counters 0x50034C40/44, lim 0x1FF)"),
    (0x48435D83, "StyleIdArrayStore",      "store a style-ID + source tag into the style-ID arrays"),
    (0x484334A4, "StyleNameCommit",        "memcpy 13 B from *(0x50034B8C) -> name buf 0x50034B9C; default 0x4872AB42 => '8 Beat 1'"),
    (0x48433400, "StyleNameSourceSet",     "set *(0x50034B8C) from style-ID source bits &0x00700000: 0=builtin(0x48433AC4)/0x100000=MEM/0x200000=CUSTOM"),
    (0x48433AC4, "StyleBuiltinNameLookup", "builtin name via RAM dir 0x50034B7C(*2)/0x50034B80(*3), base 0x50034B78; returns default on unresolved style-ID (runtime: rhythm passes style-ID 0 -> '8 Beat 1'; sounds pass 0x65A -> real names)"),
    (0x48435E84, "StyleIdQueueDequeue",    "dequeue a style-ID from ring 0x50034C48/0x50035448 (read idx 0x50034C42, count 0x50034C44)"),

    # --- custom-data flash driver (AMD 29LV160 command set at 0x96800000)
    (0x4847F721, "FlashWordProgram",      "AMD program: AA/55/A0 + data"),
    (0x4847F75A, "FlashSectorErase",      ""),
    (0x4847F980, "FlashReadAutoselect",   "read chip manufacturer/device ID"),
    (0x4847F6C7, "FlashReset",            "reset to read-array mode"),
    (0x4847F9F7, "FlashProgram128Words",  "128-word chunk programmer"),
    (0x4847E7C0, "FlashAddrToSector",     ""),
    (0x485CF9E0, "FlashChipIdTable",      "MBM29LV160B / MX29LV160B / AT49BV16X4 descriptors"),
    (0x485CF788, "FlashSectorMap",        "bottom-boot sector geometry, total 0x200000"),
    (0x4844A000, "CustomFlashArchiveParse", "parses 0x56000000 directory into RAM ptrs ~0x5003A5xx"),
    # --- disk file load / install-to-flash path (idd7000)
    (0x4852CFE4, "DiskLoadDispatch",      "walks disk-file handler table"),
    (0x486642B0, "DiskFileHandlerTable",  "per-file-type load handlers"),
    (0x4852CC9E, "AstLoadHandler",        "handles 'J K' (.AST) custom/style files"),
    (0x48664090, "DiskFileTagTable",      "tag signatures: JK / J K / TCMP / TPAD / KN7000 SOUND RAM"),
    (0x48664438, "DiskFileExtTable",      "extensions: MD / FAV / HMP / AST / SQF / SEQ / ACT"),
    (0x5008FDCA, "FavoritesBankDir",      "40 x 34-byte {name[16], u16 items[9]}"),
    (0x4855CCE6, "SdcFavBankNameFunc",    "reads FavoritesBankDir[idx].name for the Favorites list"),
    (0x48561CDB, "FavNameSetter",         "writes FavoritesBankDir[idx].name (0x5008FDCA+idx*0x22)"),
    (0x48561D8E, "FavItemSetter",         "writes FavoritesBankDir[idx].items[slot] (u16)"),
    (0x4855EC34, "FavFormat",             "memset the favorites directory (0x550 bytes)"),
    # --- boot opening-screen splash animation (see notes/splash-green-palette-bug.md)
    (0x4848A931, "OpeningFrameDraw",      "boot opening-screen draw callback; plays the splash JPEG animation"),
    (0x4848A4D8, "InitializeBlock04",     "installs OpeningFrameDraw (boot class table 0x487270BC)"),
    (0x48424EC2, "DrawJpegFile",          "JPEG-file decoder/blitter"),
    (0x48424F28, "JpegDecodeBlit",        "JPEG decode+blit body (called by DrawJpegFile; gated by *0x5002A01C)"),
    (0x484870C8, "JpegPixelStore",        "picture writer: YCbCr->RGB, 4-bit quantize, store 0xD0|red4 to FB + green4/blue4 to companion plane"),
    # --- software JPEG decoder (fixed by implementing udf07/BSCH; see notes/mn10300-udf-instructions-unimplemented.md)
    (0x48486341, "JpegSetup",             "JPEG decode setup: installs the output callback, calls JpegEngine"),
    (0x4840E721, "JpegEngine",            "JPEG decode engine (Huffman + IDCT, drives the DCT block decode)"),
    (0x48425267, "JpegHeaderParse",       "JPEG header parser (SOI/APPn/DHT/DQT markers)"),
    (0x4840FC3A, "JpegBitRefill",         "JPEG bit-buffer refill / ensure-N-bits (state @0x501739C4/C8)"),
    (0x4842D9AD, "InitPaletteRGB",        "seeds the 256-entry CLUT @0x50031490 from ROM table 0x4872573C"),
    (0x485E68B8, "OpeningFrameTable",     "7-entry splash frame sequence {00,10,12,14,16,20,42,FFFF}"),
    (0x5006B5A4, "OpeningFrameTarget",    "boot-splash sequencer target counter (++ per OpeningFrameDraw redraw)"),
    (0x5006B5A8, "OpeningFrameIndex",     "boot-splash current index into OpeningFrameTable (-1/0xFFFF = done)"),
    # --- idd7000 .AST custom-style install (writes the compressed bank raw to CUSTOM_FLASH_BANK)
    (0x4848594D, "AstHeaderIngest",       "reads the .AST header, sets install buffer 0x502B8000"),
    (0x485335FF, "FatSectorRead",         "FAT sector reader used by the .AST loader"),
    # --- MILK class-system tables (see notes/milk-class-tables.md)
    (0x48726CE4, "MilkMethodDict",        "MILK method-name dictionary: 241 MT_ name ptrs (0x48726CE4..0x487270A4)"),
    (0x487270AC, "InitBlockTable",        "boot init-block func-ptr table: 48 x InitializeBlockNN"),
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
        # Layout: [code[0..n-1]] [NUL] [name[0..n-1]], aligned 1:1 (code[k] is the
        # function that name[k] names -- proven by getter/setter behaviour: every
        # Get* reads its variable and every Set* writes it only under this direct
        # alignment). The code array (same length) sits just before the NUL.
        if read_u32(data, name_off - 4) != 0:
            continue
        code_off = name_off - 4 - 4 * n_names
        if code_off < 0:
            continue
        codes = [read_u32(data, code_off + 4 * k) for k in range(n_names)]
        good = sum(_is_code(c) for c in codes)
        if good >= 0.9 * n_names:
            yield code_off, name_off, n_names


def recover_symbols(data):
    """Returns a sorted list of (cpu_addr, file_offset, name)."""
    ident_offsets = _ident_offsets(data)
    out = {}          # file_offset -> name
    used = set()      # names already taken (keep them unique)
    # Direct alignment: code[k] is named by name[k].
    for code_arr, name_arr, n in find_tables(data, ident_offsets):
        for k in range(n):
            code = read_u32(data, code_arr + 4 * k)
            name = read_name(data, read_u32(data, name_arr + 4 * k))
            coff = code - PROGRAM_BASE
            if name is None or not (CODE_LO <= coff < CODE_HI) or coff in out:
                continue
            if not (name[0].isalpha() or name[0] == "_"):
                continue
            unique = name
            k2 = 2
            while unique in used:                 # disambiguate rare name clashes
                unique = f"{name}_{k2}"
                k2 += 1
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

    # Manually-RE'd symbols that the auto-pass can't find; skip any address/name it did.
    rec_addrs = {cpu for cpu, _off, _name in syms}
    rec_names = {name for _cpu, _off, name in syms}
    manual = [(a, n, note) for a, n, note in MANUAL_SYMBOLS
              if a not in rec_addrs and n not in rec_names]

    with open(args.sym, "w") as f:
        f.write("; KN7000 program-image symbols recovered from the MILK toolkit\n")
        f.write("; reflection tables (tools/gen_symbols.py). cpu_addr  name\n")
        f.write(";\n; Verified memory map:\n")
        for name, addr, note in MEMORY_MAP:
            f.write(f"0x{addr:08X}  {name}\t; {note}\n")
        f.write(f";\n; {len(syms)} recovered function symbols:\n")
        for cpu, _off, name in syms:
            f.write(f"0x{cpu:08X}  {name}\n")
        f.write(f";\n; {len(manual)} manually reverse-engineered symbols (RE, not from reflection tables):\n")
        for addr, name, note in manual:
            f.write(f"0x{addr:08X}  {name}\t; {note}\n" if note else f"0x{addr:08X}  {name}\n")

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
        f.write(f"\n# {len(manual)} manually reverse-engineered symbols:\n")
        for addr, name, note in manual:
            f.write(f".equ {name}, 0x{addr:08X}" + (f"   # {note}\n" if note else "\n"))

    print(f"gen_symbols: recovered {len(syms)} function symbols "
          f"-> {args.sym}, {args.inc}")


if __name__ == "__main__":
    main()
