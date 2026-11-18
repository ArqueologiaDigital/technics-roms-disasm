/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_voice_params_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 d68d789e222c7a4099fe82ccae37476ff3deaf711abe498a3f40ecc63889a54d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41322[];
extern unsigned char ram_4131e[];
extern unsigned char ram_41326[];
extern unsigned char ram_413a2[];
extern unsigned char ram_413c7[];
extern unsigned char ram_413ec[];
extern unsigned char ram_41411[];
void Partial_Build_Present_Word(unsigned char part)
{
    unsigned int w;
    unsigned char l;
    w = (*(unsigned int *)(ram_4131e + (part) * 0x11f)) & 0xffff3ff0;
    l = (*(unsigned char **)(ram_41322 + (part) * 0x11f))[18];
    if ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[17] & 1) w |= 1;
    else if ((*(unsigned int *)(ram_41326 + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[17] & 4) {
            switch ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x4001;
            }
        }
    }
    if ((l & 3) == 1) (*(unsigned int *)((ram_413a2) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413a2) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[17] & 4) w |= 2;
    else if ((*(unsigned int *)(ram_41326 + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[17] & 1) {
            switch ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x8002;
            }
        }
    }
    if ((l & 0xc) == 4) (*(unsigned int *)((ram_413c7) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413c7) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[17] & 0x10) w |= 4;
    if ((l & 0x30) == 0x10) (*(unsigned int *)((ram_413ec) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413ec) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41322 + (part) * 0x11f))[17] & 0x40) w |= 8;
    if ((l & 0xc0) == 0x40) (*(unsigned int *)((ram_41411) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_41411) + (part) * 0x11f)) &= 0x7fff;
    (*(unsigned int *)(ram_4131e + (part) * 0x11f)) = w;
}
