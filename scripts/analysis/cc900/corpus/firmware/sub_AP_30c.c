/* lane_sub helper AP, round 30, form c: form a with the offset local declared `register unsigned int k;`.
   Form a's notes follow.
   Round 30, form a (KN5000 sub-CPU payload v1.42, core/05).
   Run 2026-11-19-44-sub-r29a: every round-29 spelling gave the same code (offset widened at once, row added
   into the row's register).  Read again, the ROM's offset is a VARIABLE: it is built in a temporary, moved into
   its own register and only then incremented (`ld e,c; extz de; ld ix,de; inc 4,ix`; FullReset `ld hl,wa;
   inc 8,hl`), and at each access V4.23's variable-plus-pointer copy follows (`ld hl,ix; extz xhl; add xhl,xde`).
   So each access is preceded by an assignment to an unsigned int local k, and the row access reads
   `*(R(a) + k)` with R(a) = (unsigned char *)(unsigned long)(ram_24e6 + (int)a * 12) as in round 29.
   Form a: `k = (unsigned int)c + 4;` statements before each access.  Same idea in all three functions
   (VoiceState_FullReset phases 1 and 3; VoiceState_SwapSlot_HL_IY; VoiceState_SwapSlot_DE_BC).
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
#define K0(c) k = (c)
#define K4(c) k = (unsigned int)(c) + 4
#define K8(c) k = (unsigned int)(c) + 8

/* cc900-module: Quad_Decode_A_To_L VoiceSlot_UpdateNoteSource VoiceState_FullReset */
void VoiceState_FullReset(void)
{
    unsigned char i;
    unsigned char j;
    register unsigned int k;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            K8(j);
            *(R(i) + k) = 0xff;
            K0(j);
            *(R(i) + k) = i;
            K4(j);
            *(R(i) + k) = i;
        }
    for (i = 0; i < 0xc0; i++) {
        ram_2126[(int)i * 5] = i;
        ram_2127[(int)i * 5] = i;
        ram_2128[(int)i * 5] = 0;
        ram_2129[(int)i * 5] = 0;
        ram_212a[(int)i * 5] = 0xff;
    }
    for (i = 0; i < 27; i++)
        for (j = 0; j < 27; j++) {
            K0(j);
            *(R27(i) + k) = 0xff;
        }
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}

void VoiceState_SwapSlot_HL_IY(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char x, y;
    register unsigned int k;
    K0(c);
    x = *(R(a) + k);
    K4(c);
    y = *(R(a) + k);
    K0(c);
    *(R(y) + k) = x;
    K4(c);
    *(R(x) + k) = y;
    K4(c);
    y = *(R(e) + k);
    K0(c);
    *(R(y) + k) = a;
    K4(c);
    *(R(a) + k) = y;
    K0(c);
    *(R(a) + k) = e;
    K4(c);
    *(R(e) + k) = a;
}

void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    register unsigned int k;
    K0(c);
    x = *(R(a) + k);
    K4(c);
    y = *(R(a) + k);
    K0(c);
    *(R(y) + k) = x;
    K4(c);
    *(R(x) + k) = y;
    K0(c);
    *(R(a) + k) = a;
    K4(c);
    *(R(a) + k) = a;
}
