/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_voice_params_af_21a.c (2026-11-18-23-sub-r21e-staged)
   sha256 19a9356d9243885a7288d44ba00351f52975a786536b44b7dc12a152bb92b0f7 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_451c4[];
extern unsigned char ram_451ca[];
extern unsigned char *ram_452d0;
extern unsigned int DSP_EffectStateQuery();
extern char CheckStatusBits_40();
extern void Voice_Slot_CalcArticParams();
extern unsigned int DSP_AlgoSelect();
extern unsigned int DSP_MixSendConfig();
extern unsigned int DSP_RouteCoeffs_TypeA();
extern unsigned int DSP_RouteCoeffs_TypeB();
extern unsigned int DSP_CopyCoeffs_TypeA();
extern unsigned int DSP_CopyCoeffs_TypeB();
extern unsigned int DSP_VoiceCoeffRoute();
extern unsigned int DSP_VoiceCoeffRoute2();
extern unsigned int DSP_AlgoCoeffLookup();
extern void DSP_VoiceParamReadWrite();
extern unsigned int DSP_ReadVoiceParam5D();
extern unsigned int DSP_VoiceParam_Dispatch();
extern unsigned int DSP_SetCoeff_CopyDirect();
extern unsigned int DSP_SetCoeff_RouteComplex();
extern unsigned int DSP_SetCoeff_CopyDirect2();
extern unsigned int DSP_SetCoeff_RouteWithCallback();
extern unsigned int DSP_SetCoeff_FullPipeline();
extern unsigned int DSP_SetCoeff_WriteParams();
unsigned int DSP_SetCoeff_MasterConfig(unsigned char *p)
{
    unsigned int i;
    unsigned int n;
    (void)&p;
    (void)&i;
    i = 0;
    n = 0;
    switch (p[2] & 0x7f) {
    case 0:
        n = DSP_EffectStateQuery(p[1], &ram_451ca[0]);
        break;
    case 1:
        if (CheckStatusBits_40(p[1]))
            Voice_Slot_CalcArticParams(p[1]);
        n = DSP_AlgoSelect(p[1], p[3], &ram_451ca[0]);
        break;
    case 4:
        n = DSP_MixSendConfig(p[3], p[1], &ram_451ca[0]);
        break;
    case 5:
        n = DSP_RouteCoeffs_TypeA(p[3], p[1]);
        break;
    case 6:
        n = DSP_RouteCoeffs_TypeB(p[3], p[1]);
        break;
    case 7:
        n = DSP_CopyCoeffs_TypeA(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 8:
        n = DSP_CopyCoeffs_TypeB(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 9:
        n = DSP_VoiceCoeffRoute(p[1], p[3]);
        break;
    case 10:
        n = DSP_VoiceCoeffRoute2(p[1], p[3]);
        break;
    case 11:
        n = DSP_AlgoCoeffLookup(p[3]);
        break;
    case 12:
        for (n = 8; i < n; i++)
            DSP_VoiceParamReadWrite(p[1], i, &ram_451c4[i + 6]);
        break;
    case 13:
        n = DSP_ReadVoiceParam5D(p[3], p[1], &ram_451ca[0]);
        break;
    case 14:
        n = DSP_VoiceParam_Dispatch(p[3], p[1], &ram_451ca[0]);
        break;
    case 15:
        n = DSP_SetCoeff_CopyDirect(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 16:
        n = DSP_SetCoeff_RouteComplex(p[1], p[3]);
        break;
    case 17:
        n = DSP_SetCoeff_CopyDirect2(((unsigned int)p[1] << 8) | (unsigned int)p[3]);
        break;
    case 18:
        n = DSP_SetCoeff_RouteWithCallback(p[1], ram_452d0[29351], p[3]);
        break;
    case 19:
        n = DSP_SetCoeff_FullPipeline(p[1], ram_452d0[29351], p[3]);
        break;
    case 23:
        n = DSP_SetCoeff_WriteParams(p[1]);
        break;
    }
    return n;
}
