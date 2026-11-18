/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_22c.c (2026-11-18-29-sub-r21f)
   sha256 aa65228827b5c13d4928aa081d6d0eccf2afdbc117c3d98aab0a4910a2ba5af8 (tar-sha256); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned char *s);
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
void Audio_Cmd_ToneEdit_Field_Write_And_Reply(unsigned char *m)
{
    unsigned char *r;
    unsigned char t;

    r = ToneDB_Find_SubToneRecord(PART_PATCH(m[1]), ram_4531c[29351], m[1]);
    t = (m[2] & 0xc0) >> 6;
    r = &r[(int)t * 21 + 16];
    r = WaveSel_StageA1_FromToneSlot(t, r, ram_4531c[29351], m[1]);
    r += m[2] & 63;
    *r = m[4];
    InterCPU_E1_DMA_Transfer(r, 1,
        (unsigned char *)((unsigned long)((unsigned char *)0x1e0000 + ((int)ram_4531c[29351] * 80 + (int)t * 11)) + 19169)
        + (m[2] & 63));
}
