/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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

/* cc900-module: CheckStatusBits_40 DSP_AlgoCoeffLookup DSP_AlgoSelect DSP_CopyCoeffs_TypeA DSP_CopyCoeffs_TypeB DSP_EffectStateQuery DSP_MixSendConfig DSP_ReadVoiceParam5D DSP_RouteCoeffs_TypeA DSP_RouteCoeffs_TypeB DSP_SetCoeff_CopyDirect DSP_SetCoeff_CopyDirect2 DSP_SetCoeff_FullPipeline DSP_SetCoeff_RouteComplex DSP_SetCoeff_RouteWithCallback DSP_SetCoeff_WriteParams DSP_VoiceCoeffRoute DSP_VoiceCoeffRoute2 DSP_VoiceParamReadWrite DSP_VoiceParam_Dispatch */
/* cc900-data: DSP_SetCoeff_MasterConfig 1 = DSP_SETCOEFF_MASTERCONFIG_JUMPTABLE */
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
        n = DSP_EffectStateQuery(p[1], &ram_45216[0]);
        break;
    case 1:
        if (CheckStatusBits_40(p[1]))
            Voice_Slot_CalcArticParams(p[1]);
        n = DSP_AlgoSelect(p[1], p[3], &ram_45216[0]);
        break;
    case 4:
        n = DSP_MixSendConfig(p[3], p[1], &ram_45216[0]);
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
        n = DSP_ReadVoiceParam5D(p[3], p[1], &ram_45216[0]);
        break;
    case 14:
        n = DSP_VoiceParam_Dispatch(p[3], p[1], &ram_45216[0]);
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
