/* Phase 6, lane_p6 helper I, round 4, module 129 (audio/semenu_routines.s, -O3 -Xr), form a.  New.
   SeMenu_SetupSoundBankPair(a, b): fills the pair *a / *b of the sound editor's filter page: bank config 0 gives
   0x24 / 0x24 and sound bank 1; filter mode 1 asks SndParam_UpdateChannelTuning(master, 0, 0 / 1) for the pair
   (falling back to (master, 1, 1) for both when the first is 0xff) and sets them when valid, then filter mode 0;
   any other mode loads the pair directly (SeMenu_LoadFilterType / SeMenu_LoadEditParam).
   Read from the hand assembly: a in XIZ, b in the frame (+10); the three byte locals all address-taken, so they
   sit in reverse declaration order (the last declared lowest: t +4, c +6, m +8); byte arguments widened (extz:
   int parameters).  Form b: the fallback written as two separate stores of one result. */
/* cc900-module: SeMenu_LoadFilterParam2 SeMenu_LoadFilterType SeMenu_LoadEditParam SeMenu_LoadMasterPtr SeMenu_LoadSoundBankCfg SeMenu_SetFilterCoeff SeMenu_SetFilterMode SeMenu_SetFilterParam1 SeMenu_SetSoundBank */

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
extern void SeMenu_SetupSoundBankPair(unsigned char *a, unsigned char *b);

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
