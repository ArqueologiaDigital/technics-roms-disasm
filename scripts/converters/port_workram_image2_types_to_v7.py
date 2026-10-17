#!/usr/bin/env python3
"""port_workram_image2_types_to_v7.py -- v7's work-RAM image 2 typed like v10's, without v10's part-control queue.

QUESTION IT ANSWERS / WHAT IT DOES
  naka_sequencer_channels.bin +0x19EE.. is work-RAM image 2: Boot_InitWorkRAM copies it to RAM (v10 0xE35E, v7
  0xE2C2).  v10 types it (nakarest rounds 2-3): WorkRamInit_Image2, DrawBitmap_BitMasks, the SeqBuf event templates,
  eight one-byte flags, PartCtrl_EventQueue[10] + PartCtrl_EventQueueCount (42 bytes), the "KN3000 SOUND RAM" /
  "TECHNICS" / " V1.0   " tags, FDC_InitSequenceCount, Dirmd_PostRequests, Vga_InitPalette[256],
  NoteMap_LinkArray32[35], NoteMap_LinkArray128[33].  v7 has the same bytes EXCEPT the 42-byte part-control queue,
  which v7 does not have: v7's final blob is v10's with those 42 bytes removed (v10 +0x19EE..+0x1A20 = v7
  +0x19EE..+0x1A20, v10 +0x1A4A..+0x1F00 = v7 +0x1A20..+0x1ED6), and v7's code reads the shifted RAM copy
  (VGA palette base 0xE322 = 0xE2C2 + 0x60; NoteMap_LinkArray32 base 0xE722 = 0xE2C2 + 0x460).  v7's C nevertheless
  kept v10's 7936-byte layout with placeholder members (pad_304[42] where the queue is), so v7_c_divergence.json had
  to patch 1206 raw bytes over the shifted tail.
  This script asserts that byte relationship, then rewrites v7's naka_sequencer_channels.c: the 13 element typedefs
  and their notes from v10, v10's members and initializers from +0x19EE to the end minus the queue and its count,
  and the struct size 7936 -> 7894.  regenerate_v7_c_divergence.py --apply then drops the raw bytes the C now
  reproduces.

  --asm does the same for v7's ui_widgets/sequencer_channel_containers.s: its two .incbin labels over this range
  (Boot_InitWorkRAM_ROMCopy2_Start_Data +0x19EE 0x8A and Palette_8bit_RGBA_2_Data +0x1A78 0x45E -- the second one
  42 bytes INSIDE the palette, a v10 offset carried over) become v10's labelled pieces at v7 offsets, with v10's
  headers; the RAM addresses in them are v7's (copy 0x931 bytes to 0xE2C2, head node 128 next at 0xE869), and the
  copy source reference in boot/system_handlers.s follows the rename.

RUN (repository root, built tree, clean v7 C)
  python3 scripts/converters/port_workram_image2_types_to_v7.py            # check only
  python3 scripts/converters/port_workram_image2_types_to_v7.py --apply
  then: python3 scripts/build/regenerate_v7_c_divergence.py --apply; make all; make gate-all
  python3 scripts/converters/port_workram_image2_types_to_v7.py --asm      # the asm labels (after the C step)
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
C10 = os.path.join(ROOT, "v10/maincpu/ui_widgets/naka_sequencer_channels.c")
C7 = os.path.join(ROOT, "v7/maincpu/ui_widgets/naka_sequencer_channels.c")
B10 = os.path.join(ROOT, "v10/maincpu/includes/generated/naka_sequencer_channels.bin")
B7 = os.path.join(ROOT, "v7/maincpu/includes/generated/naka_sequencer_channels.bin")
TYPES = ["WorkRamInit_Image2", "BmDrEdit_TempoAnimTick", "SeqBuf_EventTemplateD2", "SeqBuf_EventTemplateB0",
         "SeqPlay_StartInitActive", "SeqAcc_ReInitGuard", "SeqBuffer_MoveEntryMarker", "EffEdit_ParamWrittenFlag",
         "PlySngSel_TimerPending", "Dirmd_PostRequests", "Vga_InitPalette", "NoteMap_LinkArray32",
         "NoteMap_LinkArray128"]
QUEUE_DECL = ["    /* part-control event queue entries {WA, C, E}; filled by PartCtrl_AppendToEventQueue */",
              "    PartCtrl_EventQueue_t PartCtrl_EventQueue[10];",
              "    /* entries in PartCtrl_EventQueue (at most 10) */",
              "    uint16_t PartCtrl_EventQueueCount;"]


S10 = os.path.join(ROOT, "v10/maincpu/ui_widgets/sequencer_channel_containers.s")
S7 = os.path.join(ROOT, "v7/maincpu/ui_widgets/sequencer_channel_containers.s")
BOOT7 = os.path.join(ROOT, "v7/maincpu/boot/system_handlers.s")
V7_HEADER_FIX = [   # v10 text -> v7 text inside the copied headers
    ("Boot_InitWorkRAM copies 0x95B bytes from\n; here to RAM 0xE35E).  Its first cells are the inter-CPU E1 DMA "
     "watchdog: the poll counts ticks while\n; control register 0x40 stays unchanged and, after 10, aborts the "
     "transfer and counts it (+0); the wait\n; with a 250-tick timeout counts its aborts at +6.  +8..+11 are not "
     "referenced.",
     "Boot_InitWorkRAM copies 0x931 bytes from\n; here to RAM 0xE2C2 in v7; v10 copies 0x95B bytes to 0xE35E -- v7 "
     "has no PartCtrl_EventQueue, 42 bytes).  Its\n; first cells are the inter-CPU E1 DMA watchdog: the poll counts "
     "ticks while control register 0x40 stays unchanged\n; and, after 10, aborts the transfer and counts it (+0); "
     "the wait with a 250-tick timeout counts its aborts at +6.\n; +8..+11 are not referenced."),
    ("reads at RAM 0xE92F)", "reads at RAM 0xE869 in v7)"),
    ("records a match in 0x48AC.", "records a match in a RAM flag (0x48AC in v10)."),
    (" / NoteMap_FindLinkedSlotByKey", ""),
]


def port_asm():
    L10 = open(S10, "rb").read().decode("latin-1").split("\n")
    t7 = open(S7, "rb").read().decode("latin-1")
    if "\nVga_InitPalette:" in t7:
        sys.exit("v7 asm already has the image-2 pieces")
    beg = next(i for i, x in enumerate(L10) if x.startswith("; WorkRamInit_Image2 -- "))
    end = next(i for i, x in enumerate(L10) if x.startswith("NoteMap_LinkArray128:"))
    out, skip = [], False
    for x in L10[beg:end + 1]:
        if x.startswith("; PartCtrl_EventQueue"):
            skip = True                                    # header + label of the queue and of its count
        if skip:
            if re.match(r'^PartCtrl_EventQueue(Count)?:', x) and x.startswith("PartCtrl_EventQueueCount:"):
                skip = False
            continue
        m = re.match(r'^(\w+:\s+\.incbin "includes/generated/naka_sequencer_channels\.bin", )0x([0-9A-F]+), (0x[0-9A-F]+)$', x)
        if m:
            off = int(m.group(2), 16)
            off = off - 0x2A if off >= 0x1A4A else off
            assert off < 0x1A20 or off >= 0x1A20, off
            x = "%s0x%X, %s" % (m.group(1), off, m.group(3))
        out.append(x)
    block = "\n".join(out)
    for a_, b_ in V7_HEADER_FIX:
        assert block.count(a_) == 1, a_
        block = block.replace(a_, b_)
    old = re.search(r'Boot_InitWorkRAM_ROMCopy2_Start_Data:\t\.incbin "includes/generated/naka_sequencer_channels\.bin", '
                    r'0x19EE, 0x8A\n(; \[nakarest\] [^\n]*\n)*Palette_8bit_RGBA_2_Data:\t\.incbin '
                    r'"includes/generated/naka_sequencer_channels\.bin", 0x1A78, 0x45E', t7)
    assert old, "v7's two image-2 labels not found"
    t7 = t7[:old.start()] + block + t7[old.end():]
    data = t7.encode("latin-1")
    with open(S7 + ".tmp", "wb") as f:
        f.write(data)
    os.replace(S7 + ".tmp", S7)
    b = open(BOOT7, "rb").read().decode("latin-1")
    assert b.count("Boot_InitWorkRAM_ROMCopy2_Start_Data") == 1
    b = b.replace("Boot_InitWorkRAM_ROMCopy2_Start_Data", "WorkRamInit_Image2")
    with open(BOOT7 + ".tmp", "wb") as f:
        f.write(b.encode("latin-1"))
    os.replace(BOOT7 + ".tmp", BOOT7)
    print("v7 asm: %d lines of v10's image-2 pieces at v7 offsets" % len(out))


def main():
    if "--asm" in sys.argv:
        return port_asm()
    a, b = open(B10, "rb").read(), open(B7, "rb").read()
    assert len(a) == 7936 and len(b) == 7894, (len(a), len(b))
    assert a[0x19EE:0x1A20] == b[0x19EE:0x1A20], "head of image 2 differs"
    assert a[0x1A20:0x1A4A] == bytes(42), "v10's queue is not all zero"
    assert a[0x1A4A:] == b[0x1A20:], "tail of image 2 is not v10's shifted by 42"
    s10 = open(C10, encoding="latin-1").read().split("\n")
    s7 = open(C7, encoding="latin-1").read().split("\n")
    if any("} Vga_InitPalette_t;" in x for x in s7):
        sys.exit("v7 already has the image-2 types")
    # 1. typedef blocks and their element notes from v10
    blocks = []
    for t in TYPES:
        end = s10.index("} %s_t;" % t)
        beg = max(i for i in range(end) if s10[i].startswith("typedef struct"))
        blocks += s10[beg:end + 1] + [""]
    notes = ["/* %s's element (scripts/converters/nakarest_reviewed_slices.py). */" % t for t in TYPES]
    for n in notes:
        assert n in s10, n
    # 2. v10's members and initializers after field_19ec, minus the queue
    m10 = s10.index("    uint16_t field_19ec;") + 1
    e10 = s10.index("} naka_sequencer_channels_t;")
    members = s10[m10:e10]
    for q in QUEUE_DECL:
        members.remove(q)
    i10 = s10.index("    .field_19ec = NAKA_NONE,") + 1
    j10 = next(i for i in range(i10, len(s10)) if s10[i] == "};")
    inits = s10[i10:j10]
    q0 = inits.index("    .PartCtrl_EventQueue = {")
    q1 = inits.index("    .PartCtrl_EventQueueCount = 0x0000,")
    del inits[q0:q1 + 2]                            # the queue, its count and the blank line after it
    # 3. splice into v7
    m7 = s7.index("    uint16_t field_19ec;") + 1
    e7 = s7.index("} naka_sequencer_channels_t;")
    i7 = s7.index("    .field_19ec = NAKA_NONE,") + 1
    j7 = next(i for i in range(i7, len(s7)) if s7[i] == "};")
    big = max(i for i in range(e7) if s7[i].startswith("typedef struct"))     # start of the blob's own struct
    anchor = s7.index("/* Root_NamingSymbolToggleView's element (scripts/converters/nakarest_reviewed_slices.py). */")
    out = (s7[:anchor + 1] + notes + s7[anchor + 1:big] + blocks + s7[big:m7] + members + s7[e7:i7] + inits
           + s7[j7:])
    text = "\n".join(out)
    assert text.count("_Static_assert(sizeof(naka_sequencer_channels_t) == 7936,") == 1
    text = text.replace("_Static_assert(sizeof(naka_sequencer_channels_t) == 7936,",
                        "_Static_assert(sizeof(naka_sequencer_channels_t) == 7894,")
    # v10's member notes quote v10 RAM addresses; v7's copy is 42 bytes lower (Boot_InitWorkRAM: 0x931 bytes to 0xE2C2)
    text = text.replace("start of work-RAM image 2 (-> RAM 0xE35E)", "start of work-RAM image 2 (-> RAM 0xE2C2 in v7)")
    text = text.replace("(128 slots + head 128 at RAM 0xE92E)", "(128 slots + head 128 at RAM 0xE868 in v7)")
    text = text.replace('"naka_sequencer_channels must be exactly 7936 bytes"',
                        '"naka_sequencer_channels must be exactly 7894 bytes (v7 has no part-control event queue)"')
    print("v7: %d member lines and %d initializer lines replaced by %d / %d; %d typedefs added" % (
        e7 - m7, j7 - i7, len(members), len(inits), len(TYPES)))
    if "--apply" in sys.argv:
        data = text.encode("latin-1")
        with open(C7 + ".tmp", "wb") as f:
            f.write(data)
        os.replace(C7 + ".tmp", C7)
        print("written", os.path.relpath(C7, ROOT))


if __name__ == "__main__":
    main()
