/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_28c.c (2026-11-19-41-sub-r28a)
   sha256 0c1e784df034ac7017738e0d01c6b94482bc32b3be4d8298dad70d6be417226a (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_4136e[];
extern unsigned char ram_45210[];
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
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
