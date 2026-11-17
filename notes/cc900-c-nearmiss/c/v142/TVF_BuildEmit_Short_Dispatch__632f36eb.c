/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_12a.c (2026-11-16-97-sub-r12)
   sha256 632f36ebe69f7a22a220395dce58f1f93ba077735e2cb207e7dbb5ab563ccd64 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Set_Bypass(unsigned char *v);
void TVF_Build_Short(unsigned char *v);
void Voice_PitchPack_RouteB(unsigned char *v);
void Voice_PitchPack_RouteC(unsigned char *v);
void Voice_PitchPack_RouteD(unsigned char *v);
void Voice_PitchPack_RouteE(unsigned char *v);
void TVF_BuildEmit_Short_Dispatch(unsigned char *v)
{
    switch (P(v, 23)[15] & 7) {
    default:
    case 0:
        TVF_Set_Bypass(v);
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
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
