/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20b.c (2026-11-18-18-sub-r21a)
   sha256 1a38294d9608c2cdcfb43a7ec910017dec23940711db7c62016a80b94617f566 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_24e6[];
extern unsigned char __near ram_2129[];
extern unsigned int __near ram_286b[];
extern unsigned char Voice_CommandIndexTable[];
unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g);
unsigned int *Voice_Build_PartSlot_List(unsigned char a, unsigned char c, unsigned char e)
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
    q = ram_24e6 + (int)a * 12;
    out = ram_286b;
    for (i = 0; i < 4; i++) {
        t = q[(int)i + 8];
        if (t < 0xc0) {
            if (((h = Voice_CommandIndexTable[ram_2129[(int)t * 5]]) & m) == g)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, i);
        }
    }
    *out = 0xffff;
    return ram_286b;
}
