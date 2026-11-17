/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17c.c (2026-11-16-126-sub-r17)
   sha256 bd67878aa1a0f366ab5645d3437f1f797cce2b2e9dbc7116c6bff2282d78e494 (name+funcs); compiled at -Xr
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
    r = PitchBend_ScaleCoeff_Table[b] * k;
    return r >> e;
}
