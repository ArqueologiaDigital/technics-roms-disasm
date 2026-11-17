/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_K_16a.c (2026-11-16-112-sub-r16)
   sha256 0dd0b6eeed5c6a54476ccb99223cdb0df25da8942b516f612d6d27be01083fe5 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern void TVF_Emit_Offset_Reg100(unsigned char *v);
extern void TVF_Emit_Offset_Both(unsigned char *v);
extern int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Registers(unsigned char *v)
{
    int d;
    int e;
    switch ((*(unsigned char **)(v + 23))[54] & 7) {
    default:
    case 0:
        ram_451d4 = *(unsigned int *)(v + 66);
        ram_451d6 = *(unsigned int *)(v + 68);
        break;
    case 1:
    case 2:
        TVF_Emit_Offset_Reg100(v);
        break;
    case 3:
        if (*(unsigned int *)(*(unsigned char **)(v + 35) + 2) & 0x200) TVF_Emit_Offset_Reg100(v);
        else TVF_Emit_Offset_Both(v);
        break;
    case 4:
        TVF_Emit_Offset_Both(v);
        break;
    case 5:
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x40) {
            if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x80) {
                d = (*(unsigned int *)(v + 66) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
                e = (*(unsigned int *)(v + 68) & 0x7f) - (char)(*(unsigned char **)(v + 35))[31];
            } else {
                d = (*(unsigned int *)(v + 66) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
                e = (*(unsigned int *)(v + 68) & 0x7f) + (char)(*(unsigned char **)(v + 35))[31];
            }
            ram_451d4 = (*(unsigned int *)(v + 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (*(unsigned int *)(v + 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = *(unsigned int *)(v + 66);
            ram_451d6 = *(unsigned int *)(v + 68);
        }
        break;
    }
}
