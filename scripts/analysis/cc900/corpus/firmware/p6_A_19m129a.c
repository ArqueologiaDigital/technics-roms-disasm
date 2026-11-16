/* cc900-module: SeLfo_GetSelectedLfo SeMenu_BitShiftMask SeMenu_BitShiftMask_End SeMenu_FlushDisplayObj SeMenu_GetLfoPartSwitchParamId SeMenu_IsPartEnabled SeMenu_LoadMasterPtr SeMenu_LoadPartParam SeMenu_RegisterElement_Extended SeMenu_StorePartParam */
/* Phase 6, lane_p6 helper A, round 19, form a: module 129 (audio/semenu_routines.s).
   Record builders, clear-loop set-up in file order: R1 register unsigned char *e; unsigned char *p; e = r; p = e; e += 9; / R2 unsigned char *p; register unsigned char *e; p = r; e = p + 9; / R3 register unsigned char *p, *e; e = r; p = e; e += 9; / R4 char *p, *e; e = (char *)r; p = e; e += 9;.
   SeMenu_InitDisplayColumn: no base pointer (p = r; e = p + 9), writes through r.
   SeMenu_StepParamFieldUnsigned / Signed: locals declared in the ROM's slot order (lowest first), record struct, v = &r->val, `>=` min branch. */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);

void SeMenu_SetDisplayValue(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    register unsigned char *e;
    unsigned char *p;
    e = r;
    p = e;
    e += 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[2] = 0xc;
    r[3] = 0;
    r[4] = 1;
    r[5] = v;
    SeMenu_FlushDisplayObj(r);
}

void SeMenu_RegisterParamDisplay(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *p;
    register unsigned char *e;
    p = r;
    e = p + 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[3] = 0;
    r[4] = 1;
    r[5] = v;
    SeMenu_FlushDisplayObj(r);
}

void SeMenu_RegisterValueDisplay(unsigned char a, unsigned char c)
{
    unsigned char m;
    unsigned char r[9];
    register unsigned char *p, *e;
    e = r;
    p = e;
    e += 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[2] = 0x10;
    r[3] = a;
    r[4] = 1;
    r[5] = c;
    SeMenu_FlushDisplayObj(r);
}

void SeEasy_SendParamValue(unsigned char row, unsigned char *val)
{
    unsigned char m;
    unsigned char r[9];
    char *p, *e;
    e = (char *)r;
    p = e;
    e += 9;
    do
        *p++ = 0;
    while (p < e);
    SeMenu_LoadMasterPtr(&m);
    r[0] = 136;
    r[1] = m;
    r[2] = 11;
    r[3] = row - 1;
    r[4] = *val;
    r[5] = 255;
    SeMenu_FlushDisplayObj(r);
}

void SeMenu_InitDisplayColumn(unsigned char a, unsigned char c)
{
    unsigned char r[9];
    unsigned char *p, *e;
    p = r;
    e = p + 9;
    do
        *p++ = 0;
    while (p < e);
    r[0] = 0x80;
    r[1] = 0;
    r[2] = 0xb;
    r[3] = a;
    r[4] = 1;
    r[5] = c;
    SeMenu_FlushDisplayObj(r);
}

/* An edit record: +0 the field's byte (the working value), +3 the merged result, +6 mask, +7 shift, +8 max, +9 min,
   +10 signed step.  The unsigned copy compares unsigned, the signed copy (min < 0) signed. */
struct editrecu { unsigned char val, b1, b2, out, b4, b5, mask, shift, max, min; signed char step; };
struct editrecs { signed char val, b1, b2, out, b4, b5; unsigned char mask, shift; signed char max, min, step; };
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);

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
        if ((unsigned char)(max - *v) > (unsigned char)step)
            *v += step;
        else
            *v = max;
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

int SeMenu_StepParamFieldSigned(struct editrecs *r)
{
    signed char orig;
    signed char *dst;
    unsigned char mask;
    unsigned char shift;
    signed char max;
    signed char min;
    signed char step;
    signed char *v;
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
        if ((unsigned char)(max - *v) > (unsigned char)step)
            *v += step;
        else
            *v = max;
    } else {
        if (*v == min)
            return 0;
        if ((signed char)(min - step) >= *v)
            *v = min;
        else
            *v += step;
    }
    *dst = SeMenu_BitShiftMask(*v & mask, shift);
    *dst |= orig;
    return 1;
}

/* SeMenu_CyclePartLfoState (new): the LFO pages' part switch, off -> on (bit 5, bits 6-7 = the kind's LFO number
   - 1) -> on + bit 4 -> off; then redraw, store, post (SeTitle_DrawField 42). */
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out);
extern void SeMenu_GetLfoPartSwitchParamId(unsigned char kind, unsigned char *id);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);

void SeMenu_CyclePartLfoState(unsigned char kind, unsigned char part)
{
    unsigned char val;
    unsigned char lfo;
    unsigned char id;
    unsigned char p;
    if (SeMenu_IsPartEnabled(part) != 0) {
        p = part + 4;
        SeMenu_LoadPartParam(p, &val);
        if ((val & 0x20) == 0) {
            val |= 0x20;
            SeLfo_GetSelectedLfo(kind, &lfo);
            val &= 0x3f;
            val |= (unsigned char)(lfo - 1) << 6;
        } else if (val & 0x10)
            val &= 0x0f;
        else
            val |= 0x10;
        SeMenu_GetLfoPartSwitchParamId(kind, &id);
        SeMenu_RegisterElement_Extended(part, id, &val, 240);
        SeMenu_StorePartParam(p, val);
        SeTitle_DrawField(42, p);
    }
}
