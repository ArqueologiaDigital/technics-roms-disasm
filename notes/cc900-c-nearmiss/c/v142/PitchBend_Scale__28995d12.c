/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18a.c (2026-11-17-7-sub-r18)
   sha256 28995d12564daee79c182a1ebc86ab804043dda38b11687ee466a817e53c36e2 (name+funcs); compiled at -Xr
   cc900-name: PBend_Scale=PitchBend_Scale */
extern char PitchBend_ScaleCoeff_Table[];
extern unsigned char Voice_DepthMirror_Table[];
int PBend_Scale(char a, unsigned char b, unsigned char e)
{
    int k;
    int r;
    b &= 0x7f;
    if (a < 0) {
        b = (unsigned int)Voice_DepthMirror_Table[b];
        a = ~a + 1;
    }
    k = a;
    r = PitchBend_ScaleCoeff_Table[b];
    r = r * k;
    r >>= e;
    return r;
}
