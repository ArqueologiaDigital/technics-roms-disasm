#!/usr/bin/env python3
r"""naka_type_welcome_steps.py -- type the AcWelcomScreen saved-step slots of the work-RAM image.

QUESTION ANSWERED
-----------------
"What are the 12 field_XX members of naka_sequencer_channels.c at blob 0xD3C..0xD5B (RAM 0x3EA10..)?"
(register item N-d8cf1242).  They are three 12-byte copies of a WELCOME-script step, at RAM 0x3EA0C,
0x3EA18 and 0x3EA24 (Boot_InitWorkRAM copies blob offset o to RAM 0x3D524 + 0x7B0 + o), read and
written by AcWelcomScreen_Select's ops (ui/drawbar_panel_ui.s):

  * a step is 12 bytes, script base = the u32 at RAM 0x24786, current step = the word at 0x24784,
    step k at base + 12 * k (AcWelcomScreen_Select): +0 u32 the SetApTimer interval
    (AcWelcomScreen_Select_StartTimer is reached with XWA = the next step's +0), +4 / +6 the x / y
    the op draws at (`lda xiy, (xwa+4)` then two `ldiw` into the rectangle), +8 the op (`ld hl,
    (xwa+8)`, 0..12, AcWelcomScreen_Select_CaseTable), +10 its argument (`lda xde, (xwa+10)`);
  * op 2 (AcWelcomScreen_Select_OpMoveBlit) keeps two slots at `lda xwa, (0x03ea0c:24)` + 12 * arg
    (arg 0 / 1): it blits back what the slot's step drew unless the slot's +10 is 0xFFFF, then
    copies the current step into the slot (`ld bc, 6; ldirw`);
  * ops 9 and 12 (AcWelcomScreen_Select_OpDrawColorWord, COLOR / COLOUR) keep one at 0x3EA24
    (`lda xhl, (0x03ea24:24)`, `cpw (xhl+10), 65535`, then the same 6-word copy into
    `ld xix, 0x03ea24`).
The power-on values are "empty" steps of the op that owns the slot: {0, x = y = 0xFFFF, op 2, arg
0xFFFF} twice and {0, 0xFFFF, 0xFFFF, op 9, 0xFFFF}.  Slot 0's +0 was the 28th (last, zero) word of
Part_CaptionStrPtrs, which its readers index by PART_SELECT (27 parts), and slots 1 / 2's +0 were the
`pad_169` / `pad_170` zero runs.

So the C gets `AcWelcomScreen_Step_t AcWelcomScreen_SavedSteps[3]` (Part_CaptionStrPtrs keeps 27
entries), and the asm view (ui_widgets/sequencer_channel_containers.s, which emits these bytes as
`.long` rows and one `.incbin`) one labelled row per step field.  The image does not change
(make gate).

RUN (repository root), per tree v10, v9, v7 (their text is the same here):
    python3 scripts/converters/naka_type_welcome_steps.py --tree v10
It refuses a tree it has already converted.
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

TYPEDEF = """\
/* A WELCOME-script step as AcWelcomScreen_Select (ui/drawbar_panel_ui.s) reads it, 12 bytes: the
 * script is an array of these at the u32 in RAM 0x24786 (scripts/converters/naka_type_welcome_steps.py). */
typedef struct __attribute__((packed)) {
    uint32_t timer;     /* +0 SetApTimer interval (AcWelcomScreen_Select_StartTimer) */
    uint16_t x;         /* +4 where the op draws (0xFFFF in an empty slot) */
    uint16_t y;         /* +6 */
    uint16_t op;        /* +8 0..12, AcWelcomScreen_Select_CaseTable */
    uint16_t arg;       /* +10 the op's argument; 0xFFFF = nothing drawn yet */
} AcWelcomScreen_Step_t;

"""

OLD_MEMBERS = """\
    /* Naka_DrawbarControl_Table: 28 pointers (cut from ptrs_2 by split_naka_pointer_arrays.py) */
    uint32_t Part_CaptionStrPtrs[28];
    uint16_t field_0d3c;
    uint16_t field_0d3e;
    uint16_t field_0d40;
    uint16_t field_0d42;
    uint8_t pad_169[4];  /* zero padding */
    uint16_t field_0d48;
    uint16_t field_0d4a;
    uint16_t field_0d4c;
    uint16_t field_0d4e;
    uint8_t pad_170[4];  /* zero padding */
    uint16_t field_0d54;
    uint16_t field_0d56;
    uint16_t field_0d58;
    uint16_t field_0d5a;
"""

NEW_MEMBERS = """\
    /* the part captions by part number ("RIGHT 1:" .. "METRO :"); the accordion and drawbar part
     * views draw entry [PART_SELECT] (27 parts) */
    uint32_t Part_CaptionStrPtrs[27];
    /* AcWelcomScreen_Select's saved steps (RAM 0x3EA0C, 0x3EA18, 0x3EA24): [0] / [1] op 2's slots
     * (by its argument), [2] ops 9 / 12's (the COLOR / COLOUR word); each holds the last step drawn
     * there, so the next one can blit it away */
    AcWelcomScreen_Step_t AcWelcomScreen_SavedSteps[3];
"""

OLD_INIT = """\
        NAKA_ADDR(NakaInst_METRO),
        0x00000000,
    },

    .field_0d3c = NAKA_NONE,

    .field_0d3e = NAKA_NONE,

    .field_0d40 = 0x0002,

    .field_0d42 = NAKA_NONE,

    .pad_169 = { 0 },

    .field_0d48 = NAKA_NONE,

    .field_0d4a = NAKA_NONE,

    .field_0d4c = 0x0002,

    .field_0d4e = NAKA_NONE,

    .pad_170 = { 0 },

    .field_0d54 = NAKA_NONE,

    .field_0d56 = NAKA_NONE,

    .field_0d58 = 0x0009,

    .field_0d5a = NAKA_NONE,
"""

NEW_INIT = """\
        NAKA_ADDR(NakaInst_METRO),
    },

    .AcWelcomScreen_SavedSteps = {
        { .timer = 0, .x = 0xFFFF, .y = 0xFFFF, .op = 2, .arg = NAKA_NONE },
        { .timer = 0, .x = 0xFFFF, .y = 0xFFFF, .op = 2, .arg = NAKA_NONE },
        { .timer = 0, .x = 0xFFFF, .y = 0xFFFF, .op = 9, .arg = NAKA_NONE },
    },
"""

OLD_ASM = """\
	.long NakaInst_METRO
	.long 0x00000000
	.long 0xFFFFFFFF
	.long 0xFFFF0002
	.long 0x00000000
	.long 0xFFFFFFFF
	.long 0xFFFF0002
	.long 0x00000000
; [nakarest] naka_sequencer_channels+0xd54  +0xd54..+0xd5c (0xeeedcc, 8 B)
; [nakarest] purpose not established: layout of 8 B at 0xeeedcc not derived; readers below
; [nakarest] Readers: work-RAM image: Boot_InitWorkRAM copies these bytes to RAM
; [nakarest] 0x3ea28..0x3ea30 (its ld xde/xhl/xbc + ldir blocks); no literal RAM reference into
; [nakarest] that copy was found.
	.incbin "includes/generated/naka_sequencer_channels.bin", 0xD54, 0x8
"""

NEW_ASM = """\
	.long NakaInst_METRO
; AcWelcomScreen_SavedSteps -- 3 WELCOME-script steps of 12 bytes (+0 u32 SetApTimer interval, +4 x,
;   +6 y, +8 op, +10 argument), the power-on image of RAM 0x3EA0C / 0x3EA18 / 0x3EA24: the last step
;   AcWelcomScreen_Select's op 2 drew in its slot 0 / 1 (`lda xwa, (0x03ea0c:24)` + 12 * argument) and
;   ops 9 / 12 drew at 0x3EA24, which the next one blits away unless +10 is 0xFFFF.  Empty steps of
;   those ops.  Basis: readers + bytes (scripts/converters/naka_type_welcome_steps.py).
AcWelcomScreen_SavedSteps:
	.long	0
	.short	0xffff, 0xffff, 2, 0xffff
	.long	0
	.short	0xffff, 0xffff, 2, 0xffff
	.long	0
	.short	0xffff, 0xffff, 9, 0xffff
"""

OLD_ASM_HEAD = '"CONTROL:", "METRO :" -- then 0;'
NEW_ASM_HEAD = '"CONTROL:", "METRO :" (the 0 after them is AcWelcomScreen_SavedSteps[0].timer);'


def rd(p):
    return open(p, 'rb').read().decode('latin-1')


def wr(p, t):
    open(p, 'wb').write(t.encode('latin-1'))


def once(old, new, text, what):
    n = text.count(old)
    if n != 1:
        sys.exit('naka_type_welcome_steps: %s found %d times (want 1)' % (what, n))
    return text.replace(old, new)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7'])
    a = ap.parse_args()
    c = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_sequencer_channels.c')
    s = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'sequencer_channel_containers.s')
    ct, st = rd(c), rd(s)
    if 'AcWelcomScreen_Step_t' in ct:
        sys.exit('naka_type_welcome_steps: %s already converted' % a.tree)
    # the typedef goes in front of the image's own struct
    end = ct.index('} naka_sequencer_channels_t;')
    start = ct.rindex('typedef struct __attribute__((packed)) {\n', 0, end)
    ct = ct[:start] + TYPEDEF + ct[start:]
    ct = once(OLD_MEMBERS, NEW_MEMBERS, ct, 'members')
    ct = once(OLD_INIT, NEW_INIT, ct, 'initializers')
    st = once(OLD_ASM, NEW_ASM, st, 'asm rows')
    st = once(OLD_ASM_HEAD, NEW_ASM_HEAD, st, 'asm caption comment')
    wr(c, ct)
    wr(s, st)
    print('naka_type_welcome_steps %s: 12 field_XX + 2 pads -> AcWelcomScreen_SavedSteps[3]' % a.tree)


if __name__ == '__main__':
    main()
