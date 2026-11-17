/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_21m129c.c (2026-11-17-2-p6-r29)
   sha256 c6b2ec8a160670b59e7d6e0e89de2bfe48d63b708385b4aea75c2e35e76e5b2c (tar-sha256); compiled at -O3 -Xr */
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out);
extern void SeMenu_GetLfoPartSwitchParamId(unsigned char kind, unsigned char *id);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
void SeMenu_CyclePartLfoState(unsigned char kind, unsigned char part)
{
    unsigned char val[3];
    unsigned char lfo;
    unsigned char id;
    unsigned char p;
    unsigned char *pv;
    if (SeMenu_IsPartEnabled(part) != 0) {
        p = part + 4;
        SeMenu_LoadPartParam(p, val);
        pv = val;
        if ((*pv & 0x20) == 0) {
            *pv |= 0x20;
            SeLfo_GetSelectedLfo(kind, &lfo);
            pv = val;
            *pv &= 0x3f;
            *pv |= (unsigned char)(lfo - 1) << 6;
        } else if (*pv & 0x10)
            *pv &= 0x0f;
        else
            *pv |= 0x10;
        SeMenu_GetLfoPartSwitchParamId(kind, &id);
        SeMenu_RegisterElement_Extended(part, id, val, 240);
        SeMenu_StorePartParam(p, val[0]);
        SeTitle_DrawField(42, p);
    }
}
