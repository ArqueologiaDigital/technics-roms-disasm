/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern void TVF_Emit_Offset_Reg100(unsigned char *v);
extern void TVF_Emit_Offset_Both(unsigned char *v);
extern int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Registers(unsigned char *v);
void TVF_Emit_Registers_Type2(unsigned char *v);

/* cc900-module: TVF_Clamp_Cutoff TVF_Emit_Offset_Both TVF_Emit_Offset_Reg100 */
/* cc900-data: TVF_Emit_Registers 1 = TVF_Emit_Registers_CaseOffsets */
/* cc900-data: TVF_Emit_Registers_Type2 1 = TVF_Emit_Registers_Type2_CaseOffsets */
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

void TVF_Emit_Registers_Type2(unsigned char *v)
{
    unsigned int d;
    unsigned int e;
    switch ((*(unsigned char **)(v + 23))[15] & 7) {
    default:
    case 0:
        ram_451d4 = *(int *)(v + 66);
        ram_451d6 = *(int *)(v + 68);
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
                d = (*(int *)(v + 66) & 0x7f) - (*(char **)(v + 35))[31];
                e = (*(int *)(v + 68) & 0x7f) - (*(char **)(v + 35))[31];
            } else {
                d = (*(int *)(v + 66) & 0x7f) + (*(char **)(v + 35))[31];
                e = (*(int *)(v + 68) & 0x7f) + (*(char **)(v + 35))[31];
            }
            ram_451d4 = (*(int *)(v + 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (*(int *)(v + 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = *(int *)(v + 66);
            ram_451d6 = *(int *)(v + 68);
        }
        break;
    }
}
