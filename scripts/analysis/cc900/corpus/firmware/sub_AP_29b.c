/* lane_sub helper AP, round 29, form b: form a with the one access macro changed to an index,
   `#define AT(r, k) ((r)[k])` (row pointer indexed by the unsigned int offset).  Form a's notes follow.
   Round 29, form a (KN5000 sub-CPU payload v1.42, core/05).
   Dropped (no movement in two rounds): Voice_Calc_LevelPair_Mono (+65 in rounds 27 and 28: neither declaration
   order, `register`, nor unsigned types gave d IZ and lv QIZ as the ROM has them) and
   Voice_Calc_LevelPair_FixedAtk (+225 in rounds 27 and 28: the ROM copies b to BC before the shift at v+64, every
   spelling shifted b in place or moved the table byte).
   One idiom for three functions: the ROM computes a column offset as an unsigned int first (HL / IY / IX), then a
   row address base + (int)row * stride with a signed multiply, then copies the offset into a fresh register, zero-
   extends it and adds the row to it (`ld ix,iy; extz xix; add xix,xhl`).  The attempts so far either folded row and
   column into one index (2-D arrays) or widened the offset as soon as it was computed (`(unsigned long)row +
   (unsigned int)c`).  This form: pointer plus unsigned int, the row kept apart by Route2's (unsigned long) cast,
   `AT(R(a), (unsigned int)c)`, R(a) = (unsigned char *)(unsigned long)(ram_24e6 + (int)a * 12).
   - VoiceState_FullReset (sub_AH_20c / 28, +9): phases 1 and 3 in that spelling; phases 2 and 4 as 20c (they match).
   - VoiceState_SwapSlot_HL_IY (sub_U_18b, +4) and VoiceState_SwapSlot_DE_BC (sub_A_4c, +6): every row access in
     that spelling (offset 0 = the prev byte, 4 = the next byte).
   Voice_Build_SoundingVoiceList not taken: bad_lines.py (a copy with its `untranslated` split fixed, scratch
   bad_lines_ap.py) shows V4.23's sub_AM_23a compares `cp L,QC`, a byte register to_llvm cannot name; the ROM
   compares `cp A,QC` (cpb_erp a, 230): a translator gap first (lane_vmb), then the L-vs-A register choice.
   cc900-options: -Xr
*/

extern unsigned char __near ram_24e6[];
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_2129[];
extern unsigned char __near ram_212a[];

unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void VoiceState_FullReset(void);
void VoiceState_SwapSlot_HL_IY(unsigned char a, unsigned char c, unsigned char e);
void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c);

#define R(a) ((unsigned char *)(unsigned long)(ram_24e6 + (int)(a) * 12))
#define R27(a) ((unsigned char *)(unsigned long)(ram_1e4d + (int)(a) * 27))
#define AT(r, k) ((r)[k])

/* cc900-module: Quad_Decode_A_To_L VoiceSlot_UpdateNoteSource VoiceState_FullReset */
void VoiceState_FullReset(void)
{
    unsigned char i;
    unsigned char j;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            AT(R(i), ((unsigned int)j + 8)) = 0xff;
            AT(R(i), (unsigned int)j) = i;
            AT(R(i), ((unsigned int)j + 4)) = i;
        }
    for (i = 0; i < 0xc0; i++) {
        ram_2126[(int)i * 5] = i;
        ram_2127[(int)i * 5] = i;
        ram_2128[(int)i * 5] = 0;
        ram_2129[(int)i * 5] = 0;
        ram_212a[(int)i * 5] = 0xff;
    }
    for (i = 0; i < 27; i++)
        for (j = 0; j < 27; j++)
            AT(R27(i), (unsigned int)j) = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}

void VoiceState_SwapSlot_HL_IY(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char x, y;
    x = AT(R(a), (unsigned int)c);
    y = AT(R(a), ((unsigned int)c + 4));
    AT(R(y), (unsigned int)c) = x;
    AT(R(x), ((unsigned int)c + 4)) = y;
    y = AT(R(e), ((unsigned int)c + 4));
    AT(R(y), (unsigned int)c) = a;
    AT(R(a), ((unsigned int)c + 4)) = y;
    AT(R(a), (unsigned int)c) = e;
    AT(R(e), ((unsigned int)c + 4)) = a;
}

void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = AT(R(a), (unsigned int)c);
    y = AT(R(a), ((unsigned int)c + 4));
    AT(R(y), (unsigned int)c) = x;
    AT(R(x), ((unsigned int)c + 4)) = y;
    AT(R(a), (unsigned int)c) = a;
    AT(R(a), ((unsigned int)c + 4)) = a;
}
