/* lane_sub helper AF, round 21, form e (KN5000 sub-CPU payload v1.42): form d without `(void)&tbl;` (does V4.23
   put tbl on the stack by itself?).  Form d's notes:
   - Written from the built DSP_VoiceCoeffRoute2 (dsp_algo_select_t_18c.c): from `ld hl,13` on the ROM bytes of the
     two functions are identical (unidasm of both), and the index / table arithmetic before it is the same shape.
   - s = e & 15 lives across the call (the ROM keeps it in QIZH); the record pointer the call returns is advanced in
     place, `q = &q[(int)s * 21 + 16]` (`lda xhl,xhl+wa`).
   - x and y through `(unsigned char)` casts (idiom (aa): the ROM loads the byte into A, then E / C, and extends).
   - one switch body for the four values of (q[2] & 192) (compares in reverse source order).
   - tbl is the ROM's 4-byte stack slot (xsp+4): `(void)&tbl;` (idiom (ab)); the row base t = ToneDB_RelBase +
     tbl is an unsigned long the loop indexes (the ROM's XIX).
   - void, as DSP_VoiceCoeffRoute2: n ends in HL, which the caller reads. */

struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char ram_4136e[];
extern unsigned char *ToneDB_Find_SubToneRecord();

void DSP_SetCoeff_RouteWithCallback(unsigned char a, unsigned char c, unsigned char e);

void DSP_SetCoeff_RouteWithCallback(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char s;
    unsigned char *q;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    unsigned long t;
    s = e;
    s &= 15;
    q = ToneDB_Find_SubToneRecord(*(unsigned char **)&ram_4136e[(a) * 0x11f], c, a);
    q = &q[(int)s * 21 + 16];
    x = (unsigned char)q[1];
    x &= 127;
    y = (unsigned char)q[2];
    y &= 15;
    switch ((int)q[2] & 192) {
    case 0x00:
    case 0x40:
    case 0x80:
    case 0xc0:
        tbl = (unsigned char *)ToneDB_RootPtr[19];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)tbl + ToneDB_RelBase);
    tbl = (unsigned char *)ToneDB_RootPtr[35];
    t = ToneDB_RelBase;
    t += (unsigned long)tbl;
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = ((unsigned char *)t)[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((struct r16 *)((unsigned char *)t + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}
