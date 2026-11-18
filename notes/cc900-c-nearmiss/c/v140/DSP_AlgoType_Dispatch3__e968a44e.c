/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_voice_params_af_20a.c (2026-11-18-9-sub-r20c-staged)
   sha256 e968a44e272b27f2402c5a7ae31bd6da43a60831a40a77e1a83f3fbde75e8bbd (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41322[];
extern unsigned char DSP_AlgoDescriptor_Records[];
struct algorec { unsigned char b[40]; };
unsigned int DSP_AlgoType_Dispatch3(unsigned char part, unsigned char ch, unsigned char e)
{
    unsigned int r;
    unsigned char t;
    r = 0;
    t = (*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3: case 4: case 5: case 7:
        if (e == 0) {
            if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 0x80) {
                if ((*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0x40) {
                    if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 8)
                        r = 0xc0;
                    else
                        r = 0x40;
                } else
                    r = 0x40;
            }
        } else {
            if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 0x40) {
                if ((*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0x40) {
                    if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 4)
                        r = 0xc0;
                    else
                        r = 0x40;
                } else
                    r = 0x40;
            }
        }
        break;
    case 10: case 11:
        if (e == 0) {
            if ((*(unsigned char **)&ram_41322[(part) * 0x11f])[94] != 0) {
                if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)ch * 5 + 0x13] & 8)
                    r = 0xc0;
                else
                    r = 0x40;
            }
        }
        break;
    }
    return r;
}
