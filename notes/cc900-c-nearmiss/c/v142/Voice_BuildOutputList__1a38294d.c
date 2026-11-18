/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20b.c (2026-11-18-18-sub-r21a)
   sha256 1a38294d9608c2cdcfb43a7ec910017dec23940711db7c62016a80b94617f566 (tar-sha256); compiled at -Xr */
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
    unsigned char i;
    unsigned char h;
    unsigned char t;

    m = ~e;
    g = c & m;
    q = ram_1e4d + (int)a * 27;
    out = ram_27e9;
    for (i = 0; i < 27; i++) {
        t = q[i];
        if (t < 0xc0) {
            if (((h = Voice_CommandIndexTable[i]) & m) == g)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, Voice_PolyphonyLimits_Table[h & 0x1f]);
        }
    }
    *out = 0xffff;
    return ram_27e9;
}
