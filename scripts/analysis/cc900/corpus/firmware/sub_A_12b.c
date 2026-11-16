/* lane_sub helper A, round 12, form b (alternatives to form a): the jump-table switches of the KN5000 sub-CPU payload v1.42
   (v142/subcpu, core/05).  Each switch's table is placed at the ROM's own table (data comments below).  ram_<hex> is a RAM
   cell (sub-CPU address) the tree has not named; records are read through char pointers (W / SW / P). */

/* cc900-module: TVF_Set_Bypass */
/* cc900-module: TVF_Build_Full */
/* cc900-module: Voice_PitchPack_Mode2 */
/* cc900-module: Voice_PitchPack_Mode3 */
/* cc900-module: Voice_PitchPack_Mode4_Single */
/* cc900-module: Voice_PitchPack_Mode5_Dual */
/* cc900-module: TVF_Build_Short */
/* cc900-module: Voice_PitchPack_RouteB */
/* cc900-module: Voice_PitchPack_RouteC */
/* cc900-module: Voice_PitchPack_RouteD */
/* cc900-module: Voice_PitchPack_RouteE */
/* cc900-module: TVF_Emit_Offset_Reg100 */
/* cc900-module: TVF_Emit_Offset_Both */
/* cc900-module: TVF_Clamp_Cutoff */
/* cc900-data: TVF_Build_Dispatch 1 = TVF_Build_CaseOffsets */
/* cc900-data: TVF_BuildEmit_Short_Dispatch 1 = TVF_BuildEmit_Short_CaseOffsets */
/* cc900-data: TVF_Emit_Registers 1 = TVF_Emit_Registers_CaseOffsets */
/* cc900-data: TVF_Emit_Registers_Type2 1 = TVF_Emit_Registers_Type2_CaseOffsets */
/* cc900-data: Pitch_Get_Patch_Octave_Shift 1 = Pitch_OctaveShift_CaseOffsets */

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int Voice_GlobalFlags;
extern char Instrument_OctaveShift_Semitones[];

int TVF_Set_Bypass(unsigned char *v);
int TVF_Build_Full(unsigned char *v);
int Voice_PitchPack_Mode2(unsigned char *v);
int Voice_PitchPack_Mode3(unsigned char *v);
int Voice_PitchPack_Mode4_Single(unsigned char *v);
void Voice_PitchPack_Mode5_Dual(unsigned char *v);
void TVF_Build_Short(unsigned char *v);
void Voice_PitchPack_RouteB(unsigned char *v);
void Voice_PitchPack_RouteC(unsigned char *v);
void Voice_PitchPack_RouteD(unsigned char *v);
void Voice_PitchPack_RouteE(unsigned char *v);
void TVF_Emit_Offset_Reg100(unsigned char *v);
void TVF_Emit_Offset_Both(unsigned char *v);
int TVF_Clamp_Cutoff(int a);

int TVF_Build_Dispatch(unsigned char *v)
{
    int k;
    k = P(v, 23)[54] & 7;
    switch (k) {
    default:
    case 0:
        return TVF_Set_Bypass(v);
    case 1:
        return TVF_Build_Full(v);
    case 2:
        return Voice_PitchPack_Mode2(v);
    case 3:
        return Voice_PitchPack_Mode3(v);
    case 4:
        return Voice_PitchPack_Mode4_Single(v);
    case 5:
        Voice_PitchPack_Mode5_Dual(v);
        break;
    }
    return 0;
}

void TVF_BuildEmit_Short_Dispatch(unsigned char *v)
{
    switch (P(v, 23)[15] & 7) {
    default:
    case 0:
        TVF_Set_Bypass(v);
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
        break;
    case 1:
        TVF_Build_Short(v);
        break;
    case 2:
        Voice_PitchPack_RouteB(v);
        break;
    case 3:
        Voice_PitchPack_RouteC(v);
        break;
    case 4:
        Voice_PitchPack_RouteD(v);
        break;
    case 5:
        Voice_PitchPack_RouteE(v);
        break;
    }
}

void TVF_Emit_Registers(unsigned char *v)
{
    int e, d;
    switch (P(v, 23)[54] & 7) {
    default:
    case 0:
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
        break;
    case 1:
    case 2:
        TVF_Emit_Offset_Reg100(v);
        break;
    case 3:
        if (W(P(v, 35), 2) & 0x200) TVF_Emit_Offset_Reg100(v);
        else TVF_Emit_Offset_Both(v);
        break;
    case 4:
        TVF_Emit_Offset_Both(v);
        break;
    case 5:
        if (W(P(v, 39), 24) & 0x40) {
            if (W(P(v, 39), 24) & 0x80) {
                d = (SW(v, 66) & 0x7f) - (char)P(v, 35)[31];
                e = (SW(v, 68) & 0x7f) - (char)P(v, 35)[31];
            } else {
                d = (SW(v, 66) & 0x7f) + (char)P(v, 35)[31];
                e = (SW(v, 68) & 0x7f) + (char)P(v, 35)[31];
            }
            ram_451d4 = (SW(v, 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (SW(v, 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = SW(v, 66);
            ram_451d6 = SW(v, 68);
        }
        break;
    }
}

void TVF_Emit_Registers_Type2(unsigned char *v)
{
    int e, d;
    switch (P(v, 23)[15] & 7) {
    default:
    case 0:
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
        break;
    case 1:
    case 2:
        TVF_Emit_Offset_Reg100(v);
        break;
    case 3:
        if (W(P(v, 35), 2) & 0x200) TVF_Emit_Offset_Reg100(v);
        else TVF_Emit_Offset_Both(v);
        break;
    case 4:
        TVF_Emit_Offset_Both(v);
        break;
    case 5:
        if (W(P(v, 39), 24) & 0x40) {
            if (W(P(v, 39), 24) & 0x80) {
                d = (SW(v, 66) & 0x7f) - (char)P(v, 35)[31];
                e = (SW(v, 68) & 0x7f) - (char)P(v, 35)[31];
            } else {
                d = (SW(v, 66) & 0x7f) + (char)P(v, 35)[31];
                e = (SW(v, 68) & 0x7f) + (char)P(v, 35)[31];
            }
            ram_451d4 = (SW(v, 66) & 0xff80) | TVF_Clamp_Cutoff(d);
            ram_451d6 = (SW(v, 68) & 0xff80) | TVF_Clamp_Cutoff(e);
        } else {
            ram_451d4 = SW(v, 66);
            ram_451d6 = SW(v, 68);
        }
        break;
    }
}

int Pitch_Get_Patch_Octave_Shift(unsigned char a, unsigned char c)
{
    int r;
    if (Voice_GlobalFlags & 2) r = 0;
    else {
        switch (a) {
        case 0x10:
        case 0x11:
        case 0x12:
        case 0x13:
        case 0x15:
        case 0x16:
        case 0x17:
        case 0x18:
        case 0x19:
            r = 0;
            break;
        default:
            c &= 0xf;
            r = (int)Instrument_OctaveShift_Semitones[c] << 8;
            break;
        }
    }
    return r;
}
