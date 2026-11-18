/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_21c.c (2026-11-18-29-sub-r21f)
   sha256 0f9f6b50e681ccdd0c79fa69a634212ad02f882d1981a6abb66195cad3ab5ac6 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_1e4d[];
extern unsigned int __near ram_27e9[];
extern unsigned char Voice_CommandIndexTable[];
extern unsigned char Voice_PolyphonyLimits_Table[];
unsigned char ExtVoice_Fold_SlotNumber();
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
        if ((unsigned char)t < 0xc0) {
            if (((h = Voice_CommandIndexTable[i]) & m) == g)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, Voice_PolyphonyLimits_Table[h & 0x1f]);
        }
    }
    *out = 0xffff;
    return ram_27e9;
}
