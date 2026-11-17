/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22m129b.c (2026-11-17-16-p6-r31)
   sha256 e3ad69d8037ca74e0a4ef95e68d5503424a8a242a846318e1684fb5b2481cc29 (tar-sha256); compiled at -O3 -XS -Xr */
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out);
extern void SeMenu_GetLfoPartSwitchParamId(unsigned char kind, unsigned char *id);
extern void SeMenu_RegisterElement_Extended(int, int, void *, unsigned int);
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
        SeMenu_RegisterElement_Extended(part, id, (void *)val, 240);
        SeMenu_StorePartParam(p, val[0]);
        SeTitle_DrawField(42, p);
    }
}
