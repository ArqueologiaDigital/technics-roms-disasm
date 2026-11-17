/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_2c.c (2026-11-16-47-sub-r2)
   sha256 8cd4fefd68ad70b9dc67bfe3d8b0d3cdfce1efdc96fb5e437917f1f9fb3aad0e (name+funcs); compiled at -Xr */
extern long DSP_FreqParamCurve_Algo0[];
extern long DSP_FreqParamCurve_Algo1[];
extern long DSP_FreqParamCurve_Algo2[];
long DSP_ParamFetch_AlgoTypeTable(unsigned char **pp, unsigned long i)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p) {
    case 0:
        r = DSP_FreqParamCurve_Algo0[i];
        break;
    case 1:
        r = DSP_FreqParamCurve_Algo1[i];
        break;
    case 2:
        r = DSP_FreqParamCurve_Algo2[i];
        break;
    }
    *pp = p + 1;
    return r;
}
