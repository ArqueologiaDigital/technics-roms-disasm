/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_21b.c (2026-11-18-29-sub-r21f)
   sha256 0c88b057db4df86d1242b8b0aeb50e8e69981a7373919757e71b282266e1d268 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_1e4d[];
extern unsigned int __near ram_27e9[];
extern unsigned char Voice_CommandIndexTable[];
extern unsigned char Voice_PolyphonyLimits_Table[];
unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g);
unsigned int *Voice_BuildOutputList(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char g;
    unsigned char m;
    unsigned int *out;
    unsigned char h;
    unsigned char i;
    unsigned char t;

    m = ~e;
    g = c & m;
    q = ram_1e4d + (int)a * 27;
    out = ram_27e9;
    for (i = 0; i < 27; i++) {
        t = q[i];
        if (t < (unsigned char)0xc0) {
            if (((h = Voice_CommandIndexTable[i]) & m) == g)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, Voice_PolyphonyLimits_Table[h & 0x1f]);
        }
    }
    *out = 0xffff;
    return ram_27e9;
}
