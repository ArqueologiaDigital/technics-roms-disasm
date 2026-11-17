/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m129.c (2026-11-17-19-p6-r32-staged)
   sha256 2ead46483960692c098a54217a4389b03bed252b2975e31f466d2117638a435f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
        SeMenu_RegisterElement_Extended(part, id, &val[0], 240);
        SeMenu_StorePartParam(p, val[0]);
        SeTitle_DrawField(42, p);
    }
}
