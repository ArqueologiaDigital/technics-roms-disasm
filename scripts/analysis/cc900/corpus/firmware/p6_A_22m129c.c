/* cc900-module: SeLfo_GetSelectedLfo SeMenu_GetLfoPartSwitchParamId SeMenu_IsPartEnabled SeMenu_LoadPartParam SeMenu_RegisterElement_Extended SeMenu_StorePartParam */
/* Phase 6, lane_p6 helper A, round 22, form c: module 129 (audio/semenu_routines.s), SeMenu_CyclePartLfoState:
   round 21c (val unsigned char[3], the ROM's 14-byte frame) with the third argument of
   SeMenu_RegisterElement_Extended spelled as (char *)val to a char * parameter, so that it is computed before the 4th is pushed. */
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out);
extern void SeMenu_GetLfoPartSwitchParamId(unsigned char kind, unsigned char *id);
extern void SeMenu_RegisterElement_Extended(int, int, char *, unsigned int);
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
        SeMenu_RegisterElement_Extended(part, id, (char *)val, 240);
        SeMenu_StorePartParam(p, val[0]);
        SeTitle_DrawField(42, p);
    }
}
