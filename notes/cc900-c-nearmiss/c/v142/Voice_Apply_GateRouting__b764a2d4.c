/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10c.c (2026-11-16-90-sub-r10)
   sha256 b764a2d4f2a686ba767b16d3e964743b67ea75bd744e3f4404b12656041742eb (name+funcs); compiled at -Xr
   cc900-name: Voice_ApplyGateRouting_u8=Voice_Apply_GateRouting */
extern unsigned char ram_4138d[];
unsigned int Voice_ApplyGateRouting_u8(unsigned char part, unsigned int g)
{
    switch (ram_4138d[(int)part * 287] & 0xf) {
    case 0:
        g |= 0xe00;
        break;
    case 2:
        g &= 0xf1ff;
        g |= 0x200;
        break;
    }
    switch (ram_4138d[(int)part * 287] & 0xf0) {
    case 0:
        g |= 0x7000;
        break;
    case 0x20:
        g &= 0x8fff;
        g |= 0x1000;
        break;
    }
    return g;
}
