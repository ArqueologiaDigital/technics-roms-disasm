/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_4m129a.c (2026-11-18-33-p6-r37)
   sha256 43952f168b42b010e660ce18623079c4bb68db978b14cfbb102abbacd4a046ce (tar-sha256); compiled at -O3 -XS -Xr */
extern void SeMenu_LoadSoundBankCfg(unsigned char *c);
extern void SeMenu_LoadFilterParam2(unsigned char *t);
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_LoadFilterType(unsigned char *a);
extern void SeMenu_LoadEditParam(unsigned char *b);
extern void SeMenu_SetFilterParam1(int);
extern void SeMenu_SetFilterCoeff(int);
extern void SeMenu_SetSoundBank(int);
extern void SeMenu_SetFilterMode(int);
extern unsigned char SndParam_UpdateChannelTuning(int, int, int);
void SeMenu_SetupSoundBankPair(unsigned char *a, unsigned char *b)
{
    unsigned char m;
    unsigned char c;
    unsigned char t;

    SeMenu_LoadSoundBankCfg(&c);
    if (c == 0) {
        *a = 0x24;
        *b = 0x24;
        SeMenu_SetFilterParam1(*a);
        SeMenu_SetFilterCoeff(*b);
        SeMenu_SetSoundBank(1);
    } else {
        SeMenu_LoadFilterParam2(&t);
        if (t == 1) {
            SeMenu_LoadMasterPtr(&m);
            *a = SndParam_UpdateChannelTuning(m, 0, 0);
            *b = SndParam_UpdateChannelTuning(m, 0, 1);
            if (*a == 0xff)
                *b = *a = SndParam_UpdateChannelTuning(m, 1, 1);
            if (*a != 0xff) {
                SeMenu_SetFilterParam1(*a);
                SeMenu_SetFilterCoeff(*b);
            }
            SeMenu_SetFilterMode(0);
        } else {
            SeMenu_LoadFilterType(a);
            SeMenu_LoadEditParam(b);
        }
    }
}
