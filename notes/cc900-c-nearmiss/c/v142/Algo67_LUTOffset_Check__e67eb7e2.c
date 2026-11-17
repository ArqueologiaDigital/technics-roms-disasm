/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_9c.c (2026-11-16-86-sub-r9)
   sha256 e67eb7e2c0c66eb6b52a53b2f206995f13036598ffdb92b26d1921ab65cda84b (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[][39];
unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k)
{
    unsigned int r;
    unsigned char t;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        if (DSP_AlgoDescriptor_Records[t][k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0x40) {
                if (DSP_AlgoDescriptor_Records[t][k * 5 + 0x13] & 2)
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
