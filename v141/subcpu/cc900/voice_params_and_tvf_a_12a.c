/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_451bc;
extern unsigned int ram_451be;
extern unsigned int Voice_GlobalFlags;
extern char Instrument_OctaveShift_Semitones[];
int TVF_Set_Bypass(unsigned char *v);
void TVF_Build_Short(unsigned char *v);
void Voice_PitchPack_RouteB(unsigned char *v);
void Voice_PitchPack_RouteC(unsigned char *v);
void Voice_PitchPack_RouteD(unsigned char *v);
void Voice_PitchPack_RouteE(unsigned char *v);
int Pitch_Get_Patch_Octave_Shift(unsigned char a, unsigned char c);
void TVF_BuildEmit_Short_Dispatch(unsigned char *v);

/* cc900-module: TVF_Build_Short TVF_Set_Bypass Voice_PitchPack_RouteB Voice_PitchPack_RouteC Voice_PitchPack_RouteD Voice_PitchPack_RouteE */
/* cc900-data: TVF_BuildEmit_Short_Dispatch 1 = TVF_BuildEmit_Short_CaseOffsets */
/* cc900-data: Pitch_Get_Patch_Octave_Shift 1 = Pitch_OctaveShift_CaseOffsets */
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
            r = (int)Instrument_OctaveShift_Semitones[c & 0xf] << 8;
            break;
        }
    }
    return r;
}

void TVF_BuildEmit_Short_Dispatch(unsigned char *v)
{
    switch ((*(unsigned char **)((v) + (23)))[15] & 7) {
    default:
    case 0:
        TVF_Set_Bypass(v);
        ram_451bc = (*(int *)((v) + (66)));
        ram_451be = (*(int *)((v) + (68)));
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
