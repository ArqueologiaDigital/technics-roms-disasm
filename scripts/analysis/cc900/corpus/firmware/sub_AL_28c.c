/* sub_AL_28c.c, form c.  Changes from form a: FindVelSplit's three masks in one statement each,
   `z = (unsigned int)c & 0x7f;`; FullPipeline's k a plain local declared after j.  Form a's head follows.

   sub_AL_28a.c -- lane_sub helper AL, round 28, form a (KN5000 sub-CPU payload v1.42; core/10_dsp_voice_params.s).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.
   Audio_Cmd_DSPUnit_Param, Audio_Cmd_ToneEdit_Write_And_Reply and Audio_Cmd_EffectParam_Dispatch are set aside
   (their last difference, the shadow-store / reply-address order, did not move in rounds 24-27).

   - WaveSel_StageA1_FindVelSplit (369 B, never compiled): its built callers (WaveSel_StageA1_FromPatchBlock,
     _FromToneSlot, CustomTone_CopySubUnitRecord) pass (slot, x, y, utidx, part), the last two on the stack
     (utidx at +10, part at +8: pushed left to right).  The ROM keeps the two stack parameters in A and W for the
     whole body (no call clobbers them before their last use) and spills only the first parameter: the stack
     parameters are register candidates, used directly here.  z = c & 0x7f in IZ (the only saved register,
     `pushw iz`), y = e & 0xf in IY, x = e & 0xc0 in IX.  Outer switch on e & 0x30 (compares 0x10, 0x30, 0x20, 0
     = reverse source order), inner switch on x (0x40, 0xc0, 0x80, 0).  Every path returns its pointer (the
     epilogue loads nothing).  The bank test compares the patch pointer with the ADDRESS of ToneDB_RamBankB's cell
     (lda), then part == 0xff.  The drum path's 0x2927 product is the long multiply (Math_Multiply32).
     Form a: z, y, x assigned in two statements each (`z = c; z &= 0x7f;`: ROM ld IZL,C / extz iz / and iz).
   - DSP_SetCoeff_FullPipeline (519 B in the pool; the function itself ends at its `ret`, DSP_SetCoeff_WithDispatch
     after it is dead code of its own): the built DSP_SetCoeff_RouteComplex's (ai_22a.c) structure, the row taken
     from WaveSel_StageA1_FromToneSlot(k, ToneDB_Find_SubToneRecord(...) + k * 21 + 16, c, part); k = e & 0xf in
     QIZH (`register` here, declared after j), j = (e & 0xf0) >> 4 and off on the stack (off declared first: the
     lower slot); the patch pointer read as round 24b's ToneEdit (`(unsigned char *)*(unsigned long *)`, loaded at
     once into XHL); the routing switch on the masked flag byte (0, 0x40, 0x80, 0xc0 all set off; compares
     0xc0, 0x80, 0x40, 0 = reverse source order).

   cc900-options: -Xr
*/

struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_45210[];
extern unsigned char *ram_45318;
extern unsigned char *ram_4531c;

unsigned char *WaveSel_StageA1_SelectTables(unsigned int a, unsigned int b, unsigned int sel);
unsigned char *WaveSel_StageA1_FindVelSplit(unsigned char p, unsigned char c, unsigned char e, unsigned char ut,
                                            unsigned char part);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
void DSP_SetCoeff_FullPipeline(unsigned char part, unsigned char c, unsigned char e);

/* cc900-module: WaveSel_StageA1_SelectTables */

unsigned char *WaveSel_StageA1_FindVelSplit(unsigned char p, unsigned char c, unsigned char e, unsigned char ut,
                                            unsigned char part)
{
    unsigned int z;
    unsigned int y;
    unsigned int x;

    z = (unsigned int)c & 0x7f;
    y = (unsigned int)e & 0xf;
    x = (unsigned int)e & 0xc0;
    switch (e & 0x30) {
    case 0:
    case 0x20:
    case 0x30:
        return WaveSel_StageA1_SelectTables(z, y, x);
    case 0x10:
        switch (x) {
        case 0:
        case 0x80:
        case 0xc0:
            if (*(unsigned char **)(ram_4136e + part * 0x11f) < (unsigned char *)&ram_45318 || part == 0xff)
                return ram_4531c + ((int)ut * 0x1d6 + (int)p * 11) + 442;
            return ram_45318 + ((int)ut * 0x1d6 + (int)p * 11) + 442;
        case 0x40:
            if (*(unsigned char **)(ram_4136e + part * 0x11f) < (unsigned char *)&ram_45318 || part == 0xff)
                return ram_4531c + ((int)ut * 0x50 + (int)p * 11) + 19169;
            z = (int)ut * 0x50;
            return (unsigned long)ram_41381[part * 0x11f] * 0x2927 + z + ram_45318 + ((int)p * 11 + 0x4ae1);
        }
    }
}

void DSP_SetCoeff_FullPipeline(unsigned char part, unsigned char c, unsigned char e)
{
    unsigned long off;
    unsigned char j;
    unsigned char k;
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char *p;
    unsigned int x;
    unsigned int y;
    unsigned int i;

    k = e;
    k &= 15;
    j = (e & 0xf0) >> 4;
    p = WaveSel_StageA1_FromToneSlot(k, ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)part * 287),
                                                                  c, part) + ((int)k * 21 + 16),
                                     c, part);
    x = p[(int)j * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&p[(int)j * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&p[(int)j * 2 + 3] + 1) & 0xc0) {
    case 0:
    case 0x40:
    case 0x80:
    case 0xc0:
        off = ToneDB_RootPtr[24];
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + off + ToneDB_RelBase);
    off = ToneDB_RootPtr[37];
    tbl = (unsigned char *)(ToneDB_RelBase + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}
