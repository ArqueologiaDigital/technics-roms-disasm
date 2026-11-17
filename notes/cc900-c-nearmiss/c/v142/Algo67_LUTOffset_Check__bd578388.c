/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11b.c (2026-11-16-94-sub-r11)
   sha256 bd5783887b95ef5eafc767a653a0a38f9363723a2758927b050ad92af2b06c6f (name+funcs); compiled at -Xr */
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
        if (((unsigned char *)((unsigned long)DSP_AlgoDescriptor_Records + (long)((int)t * 39)))[(int)k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0x40) {
                if (((unsigned char *)((unsigned long)DSP_AlgoDescriptor_Records + (long)((int)t * 39)))[(int)k * 5 + 0x13] & 2)
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
