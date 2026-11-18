/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20c.c (2026-11-18-18-sub-r21a)
   sha256 20f295f1a7daba8b8ff3bf14a9131cd59ec75deaa591308614be60cd673027d0 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_1e4d[][27];
extern unsigned int __near ram_27e9[];
extern unsigned char Voice_CommandIndexTable[];
extern unsigned char Voice_PolyphonyLimits_Table[];
unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g);
unsigned int *Voice_BuildOutputList(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned int *out;
    unsigned char h;
    unsigned char i;
    unsigned char t;

    e = ~e;
    c &= e;
    q = (unsigned char *)(ram_1e4d + a);
    out = ram_27e9;
    for (i = 0; i < 27; i++) {
        t = q[i];
        if (t < 0xc0) {
            if (((h = Voice_CommandIndexTable[i]) & e) == c)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, Voice_PolyphonyLimits_Table[h & 0x1f]);
        }
    }
    *out = 0xffff;
    return ram_27e9;
}
