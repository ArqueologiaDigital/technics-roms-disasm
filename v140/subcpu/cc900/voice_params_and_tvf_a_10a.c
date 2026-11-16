/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int __near ram_2940;
extern int ram_412fb;
extern int ram_4130e;
extern unsigned int ram_4518e;
extern unsigned char ram_41300;
extern unsigned char ram_41341[];
unsigned int Pitch_Saturate_15bit(unsigned int a);
unsigned int Voice_Apply_GateRouting(int part, unsigned int g);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
void Pitch_Emit_Reg400(unsigned char *v);
unsigned int Voice_ApplyGateRouting_u8(unsigned char part, unsigned int g);
void Voice_Build_GateCommand(unsigned char *v);
void Voice_PitchPack_RouteC(unsigned char *v);

/* cc900-name: Voice_ApplyGateRouting_u8=Voice_Apply_GateRouting */
/* cc900-module: Pitch_Saturate_15bit TVF_Calc_Cutoff_NoKeyFollow Voice_Apply_GateRouting */
void Pitch_Emit_Reg400(unsigned char *v)
{
    int d;
    d = (*(int *)((v) + (10))) + ram_412fb;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x10) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x20) d -= (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
        else d += (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
    }
    if ((*(unsigned int *)((v) + (1))) & 0x400) d += ram_4130e;
    ram_4518e = Pitch_Saturate_15bit(d);
}

unsigned int Voice_ApplyGateRouting_u8(unsigned char part, unsigned int g)
{
    switch (ram_41341[(int)part * 287] & 0xf) {
    case 0:
        g |= 0xe00;
        break;
    case 2:
        g &= 0xf1ff;
        g |= 0x200;
        break;
    case 1:
        break;
    }
    switch (ram_41341[(int)part * 287] & 0xf0) {
    case 0:
        g |= 0x7000;
        break;
    case 0x20:
        g &= 0x8fff;
        g |= 0x1000;
        break;
    case 0x10:
        break;
    }
    return g;
}

void Voice_Build_GateCommand(unsigned char *v)
{
    unsigned int g;
    g = 0xff - (((unsigned int)(*(unsigned char **)((v) + (23)))[0] & 0x3f) << 2);
    if ((*(unsigned char **)((v) + (23)))[0] != 0) g |= 0x100;
    if ((*(unsigned char **)((v) + (35)))[18] != 0) {
        switch (ram_41300) {
        case 0:
        case 5:
        case 6:
            (*(int *)((v) + (45))) = g | 0xfe00;
            break;
        default:
            (*(int *)((v) + (45))) = g | 0xf000;
            break;
        }
    } else (*(int *)((v) + (45))) = g | 0xf000;
    (*(int *)((v) + (45))) = Voice_Apply_GateRouting(v[4], (*(int *)((v) + (45))));
}

void Voice_PitchPack_RouteC(unsigned char *v)
{
    unsigned char *t;
    int r;
    unsigned int x;
    t = (*(unsigned char **)((v) + (23)));
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10);
    (*(int *)((v) + (66))) = r | x;
    (*(int *)((v) + (68))) = r;
    ram_2940 = 0;
}
