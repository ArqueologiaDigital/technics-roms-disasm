/* cc900-module: SeLfo_GetSelectedLfo SeMenu_BitShiftMask SeMenu_BitShiftMask_End SeMenu_GetLfoPartSwitchParamId SeMenu_IsPartEnabled SeMenu_LoadPartParam SeMenu_RegisterElement_Extended SeMenu_StorePartParam */
/* Phase 6, lane_p6 helper A, round 20, form c: module 129 (audio/semenu_routines.s).
   SeMenu_CyclePartLfoState: an unused int declared first and kept by `&spare;`; the third argument through pv.
   SeMenu_StepParamFieldUnsigned: as a.
   SeMenu_StepParamFieldSigned: as a with round 19's max branch (`>`), to isolate the cast. */
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out);
extern void SeMenu_GetLfoPartSwitchParamId(unsigned char kind, unsigned char *id);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
/* An edit record: +0 the field's byte (the working value), +3 the merged result, +6 mask, +7 shift, +8 max, +9 min,
   +10 signed step. */
struct editrecu { unsigned char val, b1, b2, out, b4, b5, mask, shift, max, min; signed char step; };
struct editrecs { signed char val, b1, b2, out, b4, b5; unsigned char mask, shift; signed char max, min, step; };
struct editrecx { unsigned char val, b1, b2, out, b4, b5, mask, shift; signed char max, min, step; };
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);

void SeMenu_CyclePartLfoState(unsigned char kind, unsigned char part)
{
    int spare;
    unsigned char val;
    unsigned char lfo;
    unsigned char id;
    unsigned char p;
    unsigned char *pv;
    if (SeMenu_IsPartEnabled(part) != 0) {
        &spare;
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
        SeMenu_RegisterElement_Extended(part, id, pv, 240);
        SeMenu_StorePartParam(p, val);
        SeTitle_DrawField(42, p);
    }
}

int SeMenu_StepParamFieldUnsigned(struct editrecu *r)
{
    unsigned char orig;
    unsigned char *dst;
    unsigned char mask;
    unsigned char shift;
    unsigned char max;
    unsigned char min;
    signed char step;
    unsigned char *v;
    v = &r->val;
    dst = &r->out;
    mask = r->mask;
    shift = r->shift;
    max = r->max;
    min = r->min;
    step = r->step;
    orig = *v;
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    *v = SeMenu_BitShiftMask_End(*v, shift);
    *v &= mask;
    if (step > 0) {
        if (*v == max)
            return 0;
        if ((unsigned char)(max - *v) <= (unsigned char)step)
            *v = max;
        else
            *v += step;
    } else {
        if (*v == min)
            return 0;
        if ((unsigned char)(min - step) >= *v)
            *v = min;
        else
            *v += step;
    }
    *dst = SeMenu_BitShiftMask(*v & mask, shift);
    *dst |= orig;
    return 1;
}

int SeMenu_StepParamFieldSigned(struct editrecx *r)
{
    unsigned char orig;
    unsigned char *dst;
    unsigned char mask;
    unsigned char shift;
    signed char max;
    signed char min;
    signed char step;
    unsigned char *v;
    v = &r->val;
    dst = &r->out;
    mask = r->mask;
    shift = r->shift;
    max = r->max;
    min = r->min;
    step = r->step;
    orig = *v;
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    *v = SeMenu_BitShiftMask_End(*v, shift);
    *v &= mask;
    if (step > 0) {
        if ((signed char)*v == max)
            return 0;
        if ((unsigned char)(max - (signed char)*v) > (unsigned char)step)
            *v += step;
        else
            *v = max;
    } else {
        if ((signed char)*v == min)
            return 0;
        if ((signed char)(min - step) >= (signed char)*v)
            *v = min;
        else
            *v += step;
    }
    *dst = SeMenu_BitShiftMask(*v & mask, shift);
    *dst |= orig;
    return 1;
}
