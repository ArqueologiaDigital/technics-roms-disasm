/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20c.c (2026-11-18-18-sub-r21a)
   sha256 20f295f1a7daba8b8ff3bf14a9131cd59ec75deaa591308614be60cd673027d0 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_24e6[][12];
extern unsigned char __near ram_2129[];
extern unsigned int __near ram_286b[];
extern unsigned char Voice_CommandIndexTable[];
unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g);
unsigned int *Voice_Build_PartSlot_List(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned int *out;
    unsigned char i;
    unsigned char h;
    unsigned char t;

    e = ~e;
    c &= e;
    q = (unsigned char *)(ram_24e6 + a);
    out = ram_286b;
    for (i = 0; i < 4; i++) {
        t = q[(int)i + 8];
        if (t < 0xc0) {
            if (((h = Voice_CommandIndexTable[ram_2129[(int)t * 5]]) & e) == c)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, i);
        }
    }
    *out = 0xffff;
    return ram_286b;
}
