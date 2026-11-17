/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_12a.c (2026-11-16-97-sub-r12)
   sha256 632f36ebe69f7a22a220395dce58f1f93ba077735e2cb207e7dbb5ab563ccd64 (name+funcs); compiled at -Xr */
extern unsigned int Voice_GlobalFlags;
extern char Instrument_OctaveShift_Semitones[];
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
