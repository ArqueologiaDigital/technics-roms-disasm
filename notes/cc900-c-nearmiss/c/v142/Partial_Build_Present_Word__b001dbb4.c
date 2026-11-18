/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/dsp_voice_params_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 b001dbb4de4506e7a85e41d2f2bc68d43f2af2b6a120f969e8630ff3d7d904e9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_4136a[];
extern unsigned char ram_41372[];
extern unsigned char ram_413ee[];
extern unsigned char ram_41413[];
extern unsigned char ram_41438[];
extern unsigned char ram_4145d[];
void Partial_Build_Present_Word(unsigned char part)
{
    unsigned int w;
    unsigned char l;
    w = (*(unsigned int *)(ram_4136a + (part) * 0x11f)) & 0xffff3ff0;
    l = (*(unsigned char **)(ram_4136e + (part) * 0x11f))[18];
    if ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[17] & 1) w |= 1;
    else if ((*(unsigned int *)(ram_41372 + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[17] & 4) {
            switch ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x4001;
            }
        }
    }
    if ((l & 3) == 1) (*(unsigned int *)((ram_413ee) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_413ee) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[17] & 4) w |= 2;
    else if ((*(unsigned int *)(ram_41372 + (part) * 0x11f)) & 0x8000L) {
        if ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[17] & 1) {
            switch ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[93] & 0xf) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
                w |= 0x8002;
            }
        }
    }
    if ((l & 0xc) == 4) (*(unsigned int *)((ram_41413) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_41413) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[17] & 0x10) w |= 4;
    if ((l & 0x30) == 0x10) (*(unsigned int *)((ram_41438) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_41438) + (part) * 0x11f)) &= 0x7fff;
    if ((*(unsigned char **)(ram_4136e + (part) * 0x11f))[17] & 0x40) w |= 8;
    if ((l & 0xc0) == 0x40) (*(unsigned int *)((ram_4145d) + (part) * 0x11f)) |= 0x8000;
    else (*(unsigned int *)((ram_4145d) + (part) * 0x11f)) &= 0x7fff;
    (*(unsigned int *)(ram_4136a + (part) * 0x11f)) = w;
}
