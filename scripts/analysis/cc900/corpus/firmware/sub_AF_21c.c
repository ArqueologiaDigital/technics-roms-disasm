/* lane_sub helper AF, round 21, form c (KN5000 sub-CPU payload v1.42).
   - DSP_SetCoeff_MasterConfig: form a (n, the callees and the function unsigned int) with
     * the reply-buffer argument as `(unsigned char *)(unsigned long)ram_45216` (the built EFF_WriteHeader's
       spelling of an address argument V4.23 builds in XWA and copies);
     * the case-12 pointer `&ram_45210[i + 6]` as in form a. */
/* cc900-data: DSP_SetCoeff_MasterConfig 1 = DSP_SETCOEFF_MASTERCONFIG_JUMPTABLE */
/* cc900-module: DSP_EffectStateQuery */
/* cc900-module: CheckStatusBits_40 */
/* cc900-module: DSP_AlgoSelect */
/* cc900-module: DSP_MixSendConfig */
/* cc900-module: DSP_RouteCoeffs_TypeA */
/* cc900-module: DSP_RouteCoeffs_TypeB */
/* cc900-module: DSP_CopyCoeffs_TypeA */
/* cc900-module: DSP_CopyCoeffs_TypeB */
/* cc900-module: DSP_VoiceCoeffRoute */
/* cc900-module: DSP_VoiceCoeffRoute2 */
/* cc900-module: DSP_AlgoCoeffLookup */
/* cc900-module: DSP_VoiceParamReadWrite */
/* cc900-module: DSP_ReadVoiceParam5D */
/* cc900-module: DSP_VoiceParam_Dispatch */
/* cc900-module: DSP_SetCoeff_CopyDirect */
/* cc900-module: DSP_SetCoeff_RouteComplex */
/* cc900-module: DSP_SetCoeff_CopyDirect2 */
/* cc900-module: DSP_SetCoeff_RouteWithCallback */
/* cc900-module: DSP_SetCoeff_FullPipeline */
/* cc900-module: DSP_SetCoeff_WriteParams */

extern unsigned char ram_45210[];
extern unsigned char ram_45216[];
extern unsigned char *ram_4531c;

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

unsigned int DSP_SetCoeff_MasterConfig(unsigned char *p);

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
        n = DSP_EffectStateQuery(p[1], (unsigned char *)(unsigned long)ram_45216);
        break;
    case 1:
        if (CheckStatusBits_40(p[1]))
            Voice_Slot_CalcArticParams(p[1]);
        n = DSP_AlgoSelect(p[1], p[3], (unsigned char *)(unsigned long)ram_45216);
        break;
    case 4:
        n = DSP_MixSendConfig(p[3], p[1], (unsigned char *)(unsigned long)ram_45216);
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
            DSP_VoiceParamReadWrite(p[1], i, &ram_45210[i + 6]);
        break;
    case 13:
        n = DSP_ReadVoiceParam5D(p[3], p[1], (unsigned char *)(unsigned long)ram_45216);
        break;
    case 14:
        n = DSP_VoiceParam_Dispatch(p[3], p[1], (unsigned char *)(unsigned long)ram_45216);
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
