/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10c.c (2026-11-16-90-sub-r10)
   sha256 ecd659e02d856f795e8e5bc4d2071af22ef5d0dc0758d1b8896dd134179ad82d (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k)
{
    unsigned int r;
    unsigned char t;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        if ((DSP_AlgoDescriptor_Records + (int)t * 39)[(int)k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0x40) {
                if ((DSP_AlgoDescriptor_Records + (int)t * 39)[(int)k * 5 + 0x13] & 2)
                    r = 0xc000;
                else
                    r = 0x4000;
            } else
                r = 0x4000;
        }
        break;
    }
    return r;
}
