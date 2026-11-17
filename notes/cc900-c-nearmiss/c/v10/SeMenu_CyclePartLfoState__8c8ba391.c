/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m129a.c (2026-11-16-128-p6-r27)
   sha256 8c8ba391c64a17365075a0923e7a410784c02f6a4fc163182071aed13bfe385f (tar-sha256); compiled at -O3 -Xr */
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out);
extern void SeMenu_GetLfoPartSwitchParamId(unsigned char kind, unsigned char *id);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
void SeMenu_CyclePartLfoState(unsigned char kind, unsigned char part)
{
    unsigned char spare;
    unsigned char val;
    unsigned char lfo;
    unsigned char id;
    unsigned char p;
    unsigned char *pv;
    if (SeMenu_IsPartEnabled(part) != 0) {
        p = part + 4;
        SeMenu_LoadPartParam(p, &val);
        pv = &val;
        if ((*pv & 0x20) == 0) {
            *pv |= 0x20;
            SeLfo_GetSelectedLfo(kind, &lfo);
            pv = &val;
            *pv &= 0x3f;
            *pv |= (unsigned char)(lfo - 1) << 6;
        } else if (*pv & 0x10)
            *pv &= 0x0f;
        else
            *pv |= 0x10;
        SeMenu_GetLfoPartSwitchParamId(kind, &id);
        pv = &val;
        SeMenu_RegisterElement_Extended(part, id, &val, 240);
        SeMenu_StorePartParam(p, val);
        SeTitle_DrawField(42, p);
    }
}
