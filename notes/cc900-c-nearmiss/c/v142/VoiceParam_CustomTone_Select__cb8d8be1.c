/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr */
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
        rec = (unsigned char *)((unsigned long)k * 21) + (int)sel * 80;
        rec += (unsigned long)ram_4531c;
        rec += 19127;
        q = ram_44fce + ((unsigned long)k * 5 + 500);
        *q = rec[15] & 7;
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}
