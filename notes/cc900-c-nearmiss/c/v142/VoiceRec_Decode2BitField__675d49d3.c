/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
extern unsigned char ram_4308f[];
unsigned char VoiceRec_Decode2BitField(unsigned char n)
{
    unsigned char r;
    switch (*(unsigned int *)(ram_4308f + n * 71) & 0xc0) {
    case 0: r = 0; break;
    case 0x40: r = 1; break;
    case 0x80: r = 2; break;
    case 0xc0: r = 3; break;
    }
    return r;
}
