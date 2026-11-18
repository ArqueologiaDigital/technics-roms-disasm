/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/dsp_voice_params_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 eef901762ac2aa7fd14d6bfe327b3f2db23fd0d8aa054337e34b36061071915d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41356[];
extern unsigned char ram_41352[];
extern unsigned char ram_4135a[];
extern unsigned char ram_413d6[];
extern unsigned char ram_413fb[];
extern unsigned char ram_41420[];
extern unsigned char ram_41445[];
void Partial_Build_Present_Word(unsigned char part)
{
    unsigned int w;
    unsigned char l;
    w = (*(unsigned int *)(ram_41352 + (part) * 0x11f)) & 0xffff3ff0;
    l = (*(unsigned char **)(ram_41356 + (part) * 0x11f))[18];
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 1) w |= 1;
    else if ((*(unsigned int *)(ram_4135a + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 4) {
            switch ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x4001;
            }
        }
    }
    if ((l & 3) == 1) (*(unsigned int *)((ram_413d6) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413d6) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 4) w |= 2;
    else if ((*(unsigned int *)(ram_4135a + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 1) {
            switch ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x8002;
            }
        }
    }
    if ((l & 0xc) == 4) (*(unsigned int *)((ram_413fb) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413fb) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 0x10) w |= 4;
    if ((l & 0x30) == 0x10) (*(unsigned int *)((ram_41420) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_41420) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_41356 + (part) * 0x11f))[17] & 0x40) w |= 8;
    if ((l & 0xc0) == 0x40) (*(unsigned int *)((ram_41445) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_41445) + (part) * 0x11f)) &= 0x7fff;
    (*(unsigned int *)(ram_41352 + (part) * 0x11f)) = w;
}
