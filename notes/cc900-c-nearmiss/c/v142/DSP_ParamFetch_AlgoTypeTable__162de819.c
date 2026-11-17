/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_2b.c (2026-11-16-47-sub-r2)
   sha256 162de819f54cf9ec9603635f20562168dba6600f421b81838c9e376a9705aded (name+funcs); compiled at -Xr */
extern long DSP_FreqParamCurve_Algo0[];
extern long DSP_FreqParamCurve_Algo1[];
extern long DSP_FreqParamCurve_Algo2[];
long DSP_ParamFetch_AlgoTypeTable(unsigned char **pp, long i)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p) {
    case 2:
        r = DSP_FreqParamCurve_Algo2[i];
        break;
    case 1:
        r = DSP_FreqParamCurve_Algo1[i];
        break;
    case 0:
        r = DSP_FreqParamCurve_Algo0[i];
        break;
    }
    p++;
    *pp = p;
    return r;
}
