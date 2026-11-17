/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17b.c (2026-11-16-126-sub-r17)
   sha256 0e0a840326316c81afba23a05abfb073bad3f8133f4552d566393030e1a46134 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Offset_Both(unsigned char *v)
{
    int d;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) d = (int)(((*(unsigned int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31]);
        else d = (int)(((*(unsigned int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31]);
        d = TVF_Clamp_Cutoff(d);
        ram_451d4 = ((*(unsigned int *)((v) + (66))) & 0xff80) | (unsigned int)d;
        ram_451d6 = ((*(int *)((v) + (68))) & 0xff80) | d;
    } else {
        ram_451d4 = (*(int *)((v) + (66)));
        ram_451d6 = (*(int *)((v) + (68)));
    }
}
