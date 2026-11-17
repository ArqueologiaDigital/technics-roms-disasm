/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_8c.c (2026-11-16-82-sub-r8)
   sha256 59f7cd102d33d2589991b614c982a6d170c222696864131c7f870e198fc4160b (name+funcs); compiled at -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void Debug_Print_Word(unsigned int);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, unsigned long);
void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p)
{
    int t;

    if (idx != 0x63) {
        Debug_Print_String(Str_EffVolume_Prefix);
        Debug_Print_Byte(slot + 1);
        Debug_Print_String(Str_EffVolume_Suffix);
        Debug_Print_Word(((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6]);
        if (((struct slot *)(p + ((unsigned long)slot * 56 + 8)))->on != 0)
            DSP_WriteParameter(slot, b, idx, p);
        else {
            t = ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6];
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = 0;
            DSP_WriteParameter(slot, b, idx, p);
            ((int *)(((unsigned long)slot * 56 + (unsigned long)idx * 2) + p))[6] = t;
        }
    }
}
