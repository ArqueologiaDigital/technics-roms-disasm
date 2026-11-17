/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18a.c (2026-11-17-7-sub-r18)
   sha256 5581a94b8744c554c7810133a024cbd218f46e7ca66812c682e8dd6f7e0a7d38 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern void Voice_DSP_OutputConfig(unsigned int part, unsigned int slot);
extern void Voice_DSP_SimpleCopy(unsigned int part);
void Voice_DSPOut_Second_A(unsigned char part)
{
    switch ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf) {
    case 4: case 5:
        Voice_DSP_OutputConfig(part, 1);
        break;
    case 6:
        Voice_DSP_SimpleCopy(part);
        break;
    case 7:
        if (*(unsigned int *)(ram_41372 + part * 0x11f) & 0x4000)
            Voice_DSP_OutputConfig(part, 1);
        break;
    case 10: case 11:
        Voice_DSP_OutputConfig(part, 0);
        break;
    case 8: case 9:
        break;
    }
}
