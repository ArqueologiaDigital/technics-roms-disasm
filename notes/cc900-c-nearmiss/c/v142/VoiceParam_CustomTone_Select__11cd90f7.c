/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18c.c (2026-11-17-7-sub-r18)
   sha256 11cd90f719c686bf95df843efa1165d230f4ca93f1f4a74de11f60b2fcf7bbb8 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
void VoiceParam_CustomTone_Select(unsigned char sel)
{
    unsigned int k;
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;

    ram_4531c[29351] = sel;
    for (k = 0; k < 2; k++) {
        rec = ((unsigned long)k * 21 + (long)((int)sel * 80)) + ram_4531c;
        rec += 19127;
        q = ram_44fce + ((unsigned long)k * 5 + 500);
        *q = rec[15] & 7;
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}
