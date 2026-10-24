#!/usr/bin/env python3
"""Frame prom_a's disk-layer and FDC switch tables symbolically (one-shot source edit, 2026-10-24).

QUESTION IT ANSWERS / JOB IT DOES
  When the WSA1 macro respelling (scripts/converters/respell_wsa1_macros.py, family `mx`) turned the
  `mx_ld_rm` / `mx_jp_cc` byte emitters into `ld WA,(XIX+WA)` / `jp T,(XIX+WA)`, the dispatch census's
  D detector (scripts/analysis/dispatch_table_census/census.py) could see ten compiled-switch sites in
  prom_a's disk command layer (0xFE3000-0xFE4C72) and FDC driver (0xFE54EC-0xFE6E83) for the first time:
    - the four FDC offset tables at 0xFE6E3A-0xFE6E83, spelled as bare `.short 0x000A`, with eleven
      arms of Fdc_Request's dispatch unlabelled (census: prom_a NOT 0 -> 2, newT 0 -> 11);
    - six disk-layer switches whose table lives inside the 123-byte `.byte` blob Table_FE6DBF
      ("framing NOT established") and whose base is an assembler-local `.L` label, so the detector
      could not read them (census: prom_a D-unres 0 -> 8).
  This script frames all of them from the ROM bytes and the readers' own code:
    1. it labels every switch arm (inserting a label, promoting the arm's `.L` label, or renaming a
       `sub_` placeholder), and collapses `.L` aliases sitting under a global label at the same address
       when they are the calr targets of an arm it labels;
    2. it splits Table_FE6DBF at the offsets its nine readers load (`lda XIX,(Table_FE6DBF+N:24)`) into
       one leading byte and nine tables (6 switch tables, 1 word table, 2 byte tables) that tile the
       123 bytes with no gap, and points each reader at its table;
    3. it respells all ten switch tables as `.short Case - Base`, computing each entry from the ROM
       (base + sign-extended 16-bit word, as the CPU does) and refusing if the computed target is not
       the address of the label it would name;
    4. it updates the headers whose text it made stale (Disk_CommandDispatch, DiskCmd_CountFreeSpace).
  The bytes do not change: `make gate-wsa1` proves that afterwards.

  Names are read off the code (each reason is in ARMS below), never guessed:
    - the disk tables are indexed by the media type (0x605D36), range-checked to 0..5 before every load;
    - Disk_CommandDispatch maps command 0x0F+i (i = 0..12) and 0x80+(i-13) (i = 13..18) to entry i, and
      each arm calls exactly one DiskCmd_* routine, which names the arm;
    - DiskCmd_CheckMediaId's arms compare the FAT's first byte with 0xF9 / 0xFE / 0xF0 / 0xF7;
    - Fat_Load's arms set the FAT size (QIZ sectors) and the sector size ((XSP+8) bytes);
    - DiskCmd_ReadFileBlock / _WriteFileBlock's media-3 arm moves a second 0x200-byte cluster.

RUN (from wsa1/; edits prom_a/wsa1_prom_a.s in place, refuses if it has already run)
  python3 notes/frame_disk_switch_tables.py --apply
  python3 notes/frame_disk_switch_tables.py           # dry run: prints what it would do
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
WSA1 = os.path.dirname(HERE)
SRC = os.path.join(WSA1, "prom_a", "wsa1_prom_a.s")
ROM = os.path.join(WSA1, "original_ROMs", "wsa1_prom_a.ic12")
BASE = 0xF80000

# address -> (label, reason).  A `.L<addr>` already there is promoted; a sub_ placeholder is renamed.
ARMS = {
    # Fdc_ResetAndIdentifyMedia: (0x605A5B) & 0x0F through Fdc_MediaTypeJumpTable; each arm stores the
    # geometry index into (0x605A5A)
    0xFE5682: "Fdc_ResetAndIdentifyMedia__geometry2",
    0xFE568A: "Fdc_ResetAndIdentifyMedia__geometry3",
    0xFE569C: "Fdc_ResetAndIdentifyMedia__geometry4",
    0xFE56A4: "Fdc_ResetAndIdentifyMedia__geometry5",
    0xFE56AC: "Fdc_ResetAndIdentifyMedia__geometry0",
    # Fdc_ValidateRequest: the operation word through Fdc_ValidateJumpTable
    0xFE5746: "Fdc_ValidateRequest__op0",            # calr Fdc_SelectFormatParameters, then out
    0xFE574C: "Fdc_ValidateRequest__op9",            # the head check, then falls into the field checks
    0xFE574F: "Fdc_ValidateRequest__checkFields",    # unit, track and sector range checks
    0xFE5780: "Fdc_ValidateRequest__accept",         # L = 0
    # Fdc_Request: the operation word through Fdc_OperationJumpTable; 5-byte arms `calr Fdc_OpN / jr`
    0xFE67A9: "Fdc_Request__op1", 0xFE67AE: "Fdc_Request__op2", 0xFE67B3: "Fdc_Request__op3",
    0xFE67B8: "Fdc_Request__op4", 0xFE67BD: "Fdc_Request__op5", 0xFE67C2: "Fdc_Request__op6",
    0xFE67C7: "Fdc_Request__op7", 0xFE67CC: "Fdc_Request__op8", 0xFE67D1: "Fdc_Request__op9",
    0xFE67D6: "Fdc_Request__op10", 0xFE67DB: "Fdc_Request__op11",
    # Disk_SetDriveGeometry: one arm per media type, each storing that type's fixed parameters
    0xFE33BE: "Disk_SetDriveGeometry__media0", 0xFE341C: "Disk_SetDriveGeometry__media1",
    0xFE347A: "Disk_SetDriveGeometry__media2", 0xFE34D8: "Disk_SetDriveGeometry__media3",
    0xFE3536: "Disk_SetDriveGeometry__media4", 0xFE3593: "Disk_SetDriveGeometry__media5",
    # DiskCmd_CheckMediaId: the media-ID byte each media type expects at the FAT's start
    0xFE3F1C: "DiskCmd_CheckMediaId__expectF9",      # or 00 FF FF, then reads sectors 0x12 and 9
    0xFE3F6C: "DiskCmd_CheckMediaId__expectFE",      # was sub_FE3F6C
    0xFE3F73: "DiskCmd_CheckMediaId__expectF0",
    0xFE3F7A: "DiskCmd_CheckMediaId__expectF7",
    # DiskCmd_ReadFileBlock / _WriteFileBlock: media 3 moves a second 0x200-byte cluster
    0xFE4080: "DiskCmd_ReadFileBlock__secondCluster",
    0xFE40B5: "DiskCmd_ReadFileBlock__done",
    0xFE41CD: "DiskCmd_WriteFileBlock__secondCluster",
    0xFE423A: "DiskCmd_WriteFileBlock__done",
    # Disk_CommandDispatch: one arm per command, named by the DiskCmd_* routine it calls
    0xFE42B4: "Disk_CommandDispatch__cmd00_MountDrive",
    0xFE42DB: "Disk_CommandDispatch__cmd0F_OpenFile",
    0xFE42E3: "Disk_CommandDispatch__cmd10_CloseFile",
    0xFE42EB: "Disk_CommandDispatch__cmd11_FindFirst",
    0xFE42F3: "Disk_CommandDispatch__cmd12_FindNext",
    0xFE42F8: "Disk_CommandDispatch__cmd13_DeleteFile",
    0xFE4300: "Disk_CommandDispatch__cmd16_CreateFile",
    0xFE4308: "Disk_CommandDispatch__cmd1A_SetTransferAddress",
    0xFE4310: "Disk_CommandDispatch__cmd1B_CheckMediaId",
    0xFE431A: "Disk_CommandDispatch__cmd80_CountFreeSpace",
    0xFE431F: "Disk_CommandDispatch__cmd81_ReadSectors",
    0xFE432A: "Disk_CommandDispatch__cmd82_WriteSectors",
    0xFE4335: "Disk_CommandDispatch__cmd83_ReadFileBlock",
    0xFE433D: "Disk_CommandDispatch__cmd84_WriteFileBlock",
    0xFE4345: "Disk_CommandDispatch__cmd85_StoreFatIfConsistent",
    0xFE434A: "Disk_CommandDispatch__badCommand",
    # Fat_Load: QIZ = FAT sectors, (XSP+8) = bytes per sector
    0xFE4979: "Fat_Load__fat2Sectors1024",
    0xFE4983: "Fat_Load__fat9Sectors512",
    0xFE498A: "Fat_Load__fat3Sectors512",
}
# labels that already exist and are used as they are
KNOWN = {0xFE67A4: "Fdc_Request__dispatch", 0xFE5D2A: "Fdc_ClassifyCommandOpcode__valid",
         0xFE5D2D: "Fdc_ClassifyCommandOpcode__invalid"}

# Table_FE6DBF + offset -> (new name, kind, entries, base address, index comment)
DISK_TABLES = [
    (0x01, "Disk_SetDriveGeometry_MediaCases", "switch", 6, 0xFE33BE, "media type"),
    (0x0D, "DiskCmd_CloseFile_ClusterBytesByMedia", "word", 6, None, "media type"),
    (0x19, "DiskCmd_CheckMediaId_MediaCases", "switch", 6, 0xFE3F1C, "media type"),
    (0x25, "DiskCmd_ReadFileBlock_MediaCases", "switch", 6, 0xFE4080, "media type"),
    (0x31, "DiskCmd_WriteFileBlock_MediaCases", "switch", 6, 0xFE41CD, "media type"),
    (0x3D, "Disk_CommandDispatch_CommandCases", "switch", 19, 0xFE42B4, "command"),
    (0x63, "Fat_Load_MediaCases", "switch", 6, 0xFE4979, "media type"),
    (0x6F, "Fat_Store_FatSectorsByMedia", "byte", 6, None, "media type"),
    (0x75, "DiskCmd_CountFreeSpace_ByMedia", "byte", 6, None, "media type"),
]
FDC_TABLES = [  # (address, existing name, entries, base address, index comment)
    (0xFE6E3A, "Fdc_MediaTypeJumpTable", 6, 0xFE5682, "media nibble"),
    (0xFE6E46, "Fdc_ValidateJumpTable", 12, 0xFE5746, "operation"),
    (0xFE6E5E, "Fdc_OpcodeValidityJumpTable", 7, 0xFE5D2A, "opcode & 0x1F"),
    (0xFE6E6C, "Fdc_OperationJumpTable", 12, 0xFE67A4, "operation"),
]
T0 = 0xFE6DBF
TOKEN = r'(?<![\w.$@])%s(?![\w.$@])'
ADDR_RE = re.compile(r';\s*([0-9A-F]{6})\b')
LABEL_RE = re.compile(r'^([A-Za-z_.$][\w.$@]*):\s*(;.*)?$')


def die(msg):
    sys.exit("frame_disk_switch_tables: " + msg)


def align(block):
    """pad every `\t.dir\toperands\t; comment` line of a generated table so the comments share a column"""
    rows = [re.match(r'^(\t\.(?:short|byte)\t)(.*?)\t(; .*)$', t) for t in block]
    w = max(len(m.group(2)) for m in rows if m)
    return [("%s%s  %s" % (m.group(1), m.group(2).ljust(w), m.group(3))) if m else t
            for t, m in zip(block, rows)]


def main(apply):
    rom = open(ROM, "rb").read()
    lines = open(SRC, "rb").read().decode("latin-1").split("\n")
    if any(l.startswith("Disk_SetDriveGeometry_MediaCases:") for l in lines):
        die("already applied")

    def rd16(a):
        return rom[a - BASE] | rom[a - BASE + 1] << 8

    def code_line(addr):
        """index of the instruction line whose address comment is addr"""
        hits = [i for i, t in enumerate(lines)
                if t.startswith("\t") and not t.lstrip().startswith(";")
                and (lambda m: m and int(m.group(1), 16) == addr)(ADDR_RE.search(t))]
        if len(hits) != 1:
            die("0x%06X: %d instruction lines" % (addr, len(hits)))
        return hits[0]

    def labels_above(i):
        out, j = [], i - 1
        while j >= 0:
            m = LABEL_RE.match(lines[j])
            if m:
                out.append((j, m.group(1)))
            elif lines[j].strip() and not lines[j].lstrip().startswith(";"):
                break
            j -= 1
        return out

    def rename(old, new):
        rx = re.compile(TOKEN % re.escape(old))
        n = 0
        for k, t in enumerate(lines):
            t2, c = rx.subn(new, t)
            if c:
                lines[k], n = t2, n + c
        return n

    log = []
    # 1. arms
    names = dict(KNOWN)
    for addr, name in sorted(ARMS.items()):
        i = code_line(addr)
        labs = labels_above(i)
        glob = [n for _, n in labs if not n.startswith(".L")]
        loc = [n for _, n in labs if n == ".L%06X" % addr]
        plh = [n for n in glob if n == "sub_%06X" % addr]
        if plh:
            log.append("rename   %-22s -> %s (%d refs)" % (plh[0], name, rename(plh[0], name)))
        elif glob:
            die("0x%06X already labelled %s" % (addr, glob))
        elif loc:
            log.append("promote  %-22s -> %s (%d refs)" % (loc[0], name, rename(loc[0], name)))
        else:
            lines.insert(i, "%s:" % name)
            log.append("insert   %-22s    %s" % ("", name))
        names[addr] = name
    # 1b. `.L` aliases under a global label: the arms' calr targets, and the FDC opcode classifier's two
    for addr in sorted(list(range(0xFE67A4, 0xFE67E0, 5)) + [0xFE5D2A, 0xFE5D2D]):
        t = lines[code_line(addr)]
        m = re.match(r'^\tcalr (\.LFE[0-9A-F]{4})\s', t)
        loc = m.group(1) if m else (".L%06X" % addr if addr in (0xFE5D2A, 0xFE5D2D) else None)
        if not loc:
            continue
        d = [k for k, x in enumerate(lines) if x.rstrip() == loc + ":"]
        if len(d) != 1:
            die("%s: %d definitions" % (loc, len(d)))
        g = LABEL_RE.match(lines[d[0] - 1])
        if not g or g.group(1).startswith(".L"):
            die("%s has no global label directly above it" % loc)
        del lines[d[0]]
        log.append("collapse %-22s -> %s (%d refs)" % (loc, g.group(1), rename(loc, g.group(1))))

    def case(base, k, tab):
        w = rd16(tab + 2 * k)
        tgt = (base + (w - 0x10000 if w & 0x8000 else w)) & 0xFFFFFF
        if tgt not in names:
            die("table 0x%06X entry %d -> 0x%06X has no label" % (tab, k, tgt))
        return tgt, names[tgt]

    def short_line(tab, k, base, idx):
        tgt, nm = case(base, k, tab)
        return "\t.short\t%s - %s\t; %06X  %s" % (nm, names[base], tab + 2 * k, idx)

    # 2. the readers of Table_FE6DBF
    for off, name, kind, n, base, idx in DISK_TABLES:
        old = "Table_FE6DBF+0x%X:24" % off
        hit = [k for k, t in enumerate(lines) if old in t]
        if len(hit) != 1:
            die("%s: %d readers" % (old, len(hit)))
        t = lines[hit[0]]
        col = t.index(";")
        code = t[:col].rstrip().replace(old, name + ":24")
        lines[hit[0]] = code + " " * max(1, col - len(code)) + t[col:]

    # 3a. the Table_FE6DBF block
    s = next(k for k, t in enumerate(lines) if t.startswith("; Table_FE6DBF -- 123 bytes")) - 1
    e = next(k for k in range(s, len(lines)) if lines[k].startswith("; 0xFE6E3A-0xFE6E83")) - 1
    if not lines[s].startswith("; ----") or not lines[e].startswith("; ===="):
        die("Table_FE6DBF block boundaries moved")
    cmd = lambda k: (0x0F + k) if k < 13 else (0x80 + k - 13)
    out = [
        "; ---------------------------------------------------------------------",
        "; 0xFE6DBF-0xFE6E39 -- the disk command layer's per-media tables (123 bytes)",
        ";",
        "; Until 2026-10-24 this was one `.byte` blob, Table_FE6DBF, \"framing NOT",
        "; established\".  Its nine readers frame it: each loads `lda XIX,<table>` and",
        "; indexes it by the media type (0x605D36), which it first range-checks to",
        "; 0..5 -- except Disk_CommandDispatch's, indexed by the command.  Six are",
        "; word-offset switch tables (`ld WA,(XIX+WA)` then `jp T,(XIX+WA)` from the",
        "; base the reader loads), one is a word table, two are byte tables.  With the",
        "; leading byte they tile the 123 bytes: 1 + 6 x 12 + 38 + 2 x 6.",
        ";",
        "; Read across, the tables agree with each other per media type:",
        ";   media   ID byte   cluster   FAT sectors   Fat_Load reads",
        ";   0 1 4   0xF9      1024      3             3 x 512",
        ";   2       0xFE      1024      2             2 x 1024",
        ";   3       0xF0       512      9             9 x 512",
        ";   5       0xF7      1024      3             3 x 512",
        "; (ID byte: DiskCmd_CheckMediaId's arms; cluster: DiskCmd_CloseFile's",
        "; divisor, and media 3 alone moving a second 0x200-byte cluster in",
        "; DiskCmd_ReadFileBlock / _WriteFileBlock; FAT sectors: Fat_Store's count.)",
        "; ---------------------------------------------------------------------",
        "; Data_FE6DBF: one byte between DiskImage_HardDisk_MBR and the word tables,",
        "; which start on an even address.  No reader located.",
        "Data_FE6DBF:",
        "\t.byte 0x%02x                                           ; FE6DBF" % rom[T0 - BASE],
    ]
    for off, name, kind, n, base, idx in DISK_TABLES:
        tab = T0 + off
        out.append("%s:" % name)
        if kind == "switch":
            out.append("; index = the %s; base %s" % (idx, names[base]))
            for k in range(n):
                tag = ("command 0x%02X" % cmd(k)) if idx == "command" else ("media %d" % k)
                out.append(short_line(tab, k, base, tag))
        elif kind == "word":
            out.append("; DiskCmd_CloseFile divides the file size by this; 0x1000 on a type-1 drive")
            out.append("\t.short\t%s\t; %06X" % (", ".join(str(rd16(tab + 2 * k)) for k in range(n)), tab))
        else:
            out.append({"Fat_Store_FatSectorsByMedia":
                        "; Fat_Store's sector count for each of the two FAT copies",
                        "DiskCmd_CountFreeSpace_ByMedia":
                        "; stored to (XSP+8), which is only ever compared with 0xFFFF (the type-1-drive\n"
                        "; marker), so the values do not reach the result; what they meant is unknown"}[name])
            out.append("\t.byte\t%s\t; %06X" % (", ".join(str(rom[tab - BASE + k]) for k in range(n)), tab))
    if sum(2 * n if k != "byte" else n for _, _, k, n, _, _ in DISK_TABLES) + 1 != 123:
        die("the tables do not tile 123 bytes")
    lines[s:e] = align(out)

    # 3b. the four FDC tables
    s = next(k for k, t in enumerate(lines) if t.startswith("Fdc_MediaTypeJumpTable:"))
    e = next(k for k, t in enumerate(lines) if t.startswith("; sub_FE6E84 -- unreferenced"))
    out = []
    for tab, name, n, base, idx in FDC_TABLES:
        out.append("%s:" % name)
        out.append("; index = the %s; base %s" % (idx, names[base]))
        for k in range(n):
            tag = ("0x%02X" % (0x0B + k)) if name == "Fdc_OpcodeValidityJumpTable" else "%d" % k
            out.append(short_line(tab, k, base, tag))
    lines[s:e] = align(out)

    # 4. headers made stale
    text = "\n".join(lines)
    for old, new in HEADER_EDITS:
        if text.count(old) != 1:
            die("header text not found once: %r" % old[:60])
        text = text.replace(old, new)
    for l in log:
        print(l)
    print("%d labels" % len(log))
    if apply:
        open(SRC, "wb").write(text.encode("latin-1"))
        print("APPLIED to", os.path.relpath(SRC, WSA1))


HEADER_EDITS = [
    ("; Reads a command code from (XSP+0x04) and routes it through a word-offset jump\n"
     "; table (offsets at 0xFE6DFE, base 0xFE42B4) to one of ~19 handlers, each of\n",
     "; Reads a command code from (XSP+0x04) and routes it through a word-offset jump\n"
     "; table (Disk_CommandDispatch_CommandCases, 19 entries) to one of 14 arms (or\n"
     "; Disk_CommandDispatch__badCommand), each of\n"),
    ("; Evidence: 0xFE42A0 `lda XIX,0xFE6DFC` + `mx_ld_rm` + `lda XIX,0xFE42B4` +\n"
     ";           `mx_jp_cc` is the TLCS-900 word-offset dispatch idiom; the command\n"
     ";           is range-checked before indexing.",
     "; Evidence: `lda XIX,Disk_CommandDispatch_CommandCases` / `ld WA,(XIX+WA)` /\n"
     ";           `lda XIX,<base>` / `jp T,(XIX+WA)` is the TLCS-900 word-offset\n"
     ";           dispatch idiom; the command is range-checked before indexing:\n"
     ";           0 goes straight to the base arm (DiskCmd_MountDrive), 0x0F..0x1B are\n"
     ";           entries 0..12 and 0x80..0x85 entries 13..18.  Each arm calls one\n"
     ";           DiskCmd_* routine and is named after it; 0x0F..0x1B are the MS-DOS\n"
     ";           INT 21h function numbers of the same operations (open, close, find\n"
     ";           first/next, delete, create, set DTA, FAT info).  0x14, 0x15, 0x17,\n"
     ";           0x18, 0x19 and every other code return HL = 0xFF."),
    ("; NOT established: the semantics of the individual command handlers -- they stay\n"
     ";           sub_XXXXXX.  Naming the dispatcher does not name what it dispatches.\n", ""),
    (";   8 on FAT16 or by the format's factor from Table_FE6DBF+0x75.",
     ";   8 on a type-1 drive (where it stops at 129 free clusters) and halved on media type 3; else as counted."),
]

if __name__ == "__main__":
    main("--apply" in sys.argv[1:])
