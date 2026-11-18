/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeMenu_LoadEditParam SeMenu_LoadFilterParam2 SeMenu_LoadFilterType SeMenu_LoadMasterPtr SeMenu_LoadSoundBankCfg SeMenu_SetFilterCoeff SeMenu_SetFilterMode SeMenu_SetFilterParam1 SeMenu_SetSoundBank */   /* scripts/analysis/cc900/module_calls.py v10 */

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
