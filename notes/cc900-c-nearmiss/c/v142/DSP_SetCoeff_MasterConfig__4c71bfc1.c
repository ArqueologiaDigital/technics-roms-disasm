/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AF_20a.c (2026-11-18-8-sub-r20b-staged)
   sha256 4c71bfc153aa3f5c7eecd686fa34b80bcc6d759f588a4a2527d8051eea475a43 (tar-sha256); compiled at -Xr */
extern unsigned char ram_45216[];
extern unsigned char *ram_4531c;
extern int DSP_EffectStateQuery();
extern char CheckStatusBits_40();
extern void Voice_Slot_CalcArticParams();
extern int DSP_AlgoSelect();
extern int DSP_MixSendConfig();
extern int DSP_RouteCoeffs_TypeA();
extern int DSP_RouteCoeffs_TypeB();
extern int DSP_CopyCoeffs_TypeA();
extern int DSP_CopyCoeffs_TypeB();
extern int DSP_VoiceCoeffRoute();
extern int DSP_VoiceCoeffRoute2();
extern int DSP_AlgoCoeffLookup();
extern void DSP_VoiceParamReadWrite();
extern int DSP_ReadVoiceParam5D();
extern int DSP_VoiceParam_Dispatch();
extern int DSP_SetCoeff_CopyDirect();
extern int DSP_SetCoeff_RouteComplex();
extern int DSP_SetCoeff_CopyDirect2();
extern int DSP_SetCoeff_RouteWithCallback();
extern int DSP_SetCoeff_FullPipeline();
extern int DSP_SetCoeff_WriteParams();
int DSP_SetCoeff_MasterConfig(unsigned char *p)
{
    unsigned int i;
    int n;
    (void)&p;
    (void)&i;
    i = 0;
    n = 0;
    switch (p[2] & 0x7f) {
    case 0:
        n = DSP_EffectStateQuery(p[1], ram_45216);
        break;
    case 1:
        if (CheckStatusBits_40(p[1]))
            Voice_Slot_CalcArticParams(p[1]);
        n = DSP_AlgoSelect(p[1], p[3], ram_45216);
        break;
    case 4:
        n = DSP_MixSendConfig(p[3], p[1], ram_45216);
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
            DSP_VoiceParamReadWrite(p[1], i, (unsigned char *)0x45210 + (i + 6));
        break;
    case 13:
        n = DSP_ReadVoiceParam5D(p[3], p[1], ram_45216);
        break;
    case 14:
        n = DSP_VoiceParam_Dispatch(p[3], p[1], ram_45216);
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
        n = DSP_SetCoeff_RouteWithCallback(p[1], ram_4531c[29351], p[3]);
        break;
    case 19:
        n = DSP_SetCoeff_FullPipeline(p[1], ram_4531c[29351], p[3]);
        break;
    case 23:
        n = DSP_SetCoeff_WriteParams(p[1]);
        break;
    }
    return n;
}
