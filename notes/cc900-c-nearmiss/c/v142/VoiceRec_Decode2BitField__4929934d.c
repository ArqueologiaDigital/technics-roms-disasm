/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
extern unsigned char ram_4308f[];
unsigned char VoiceRec_Decode2BitField(unsigned char n)
{
    switch (*(unsigned int *)&ram_4308f[n * 71] & 0xc0) {
    case 0: return 0;
    case 0x40: return 1;
    case 0x80: return 2;
    case 0xc0: return 3;
    }
}
