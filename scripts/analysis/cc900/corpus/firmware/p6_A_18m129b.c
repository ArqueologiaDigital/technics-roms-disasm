/* cc900-module: SeCtr2_StepPartField SeMenu_BindDialToColumn SeMenu_BitShiftMask SeMenu_BitShiftMask_End SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_SetupMenuDisplay SeMenu_SetupMenuDisplay_Finalize SeMenu_SetupMenuDisplay_Section3_End */
/* cc900-module: SeMenu_SMD_Sec3End */
/* Phase 6, lane_p6 helper A, round 18, form b: module 129 (audio/semenu_routines.s).
   Record builders, clear-loop set-up per function, in file order: S8 q = r; p = q; e = q + 9; / S7 q = r; p = q; e = q + 9; / S4 e = r; p = r; e += 9; / S5 p = r; e = r; e += 9;.
   SeMenu_InitDisplayColumn: p = q = r; e = q + 9; (unsigned char *q, *p, *e;).
   SeCtr2_OnPartColumn: the flag by if/else.
   SeMenu_ToggleSolo: the second cc900-module line names the short C name (cc900-name) of
   SeMenu_SetupMenuDisplay_Section3_End: asm_vs_rom.py's module test sees the listing's C name, so round 17's
   call to it was checked as `call` where the ROM has calr (its +18 is exactly there).
   SeMenu_StepParamFieldUnsigned / Signed (new): a record struct, locals declared in the order they are filled. */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);

void SeMenu_SetDisplayValue(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *q, *e, *p;
    q = r;
    p = q;
    e = q + 9;
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
    unsigned char *q, *p, *e;
    q = r;
    p = q;
    e = q + 9;
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
    unsigned char *p, *e;
    e = r;
    p = r;
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
    unsigned char *p, *e;
    p = r;
    e = r;
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
    unsigned char *q, *p, *e;
    p = q = r;
    e = q + 9;
    do
        *p++ = 0;
    while (p < e);
    q[0] = 0x80;
    q[1] = 0;
    q[2] = 0xb;
    q[3] = a;
    q[4] = 1;
    q[5] = c;
    SeMenu_FlushDisplayObj(q);
}

void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank)
{
    unsigned char f;
    if (bank & 0x7f)
        f = 1;
    else
        f = 0;
    SeCtr2_StepPartField(part, f);
    SeMenu_BindDialToColumn(part + 4);
}

/* The callee's label is 36 characters and agrees with Section3_Loop in 31: a short C name. */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern void SeMenu_SMD_Sec3End(int on);
extern void SeMenu_SetupMenuDisplay_Finalize(unsigned char *solo);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_DrawSoloButton(void);

void SeMenu_ToggleSolo(void)
{
    unsigned char s;
    int on;
    SeMenu_SetupMenuDisplay_Finalize(&s);
    if (s != 0)
        on = 0;
    else
        on = 1;
    SeMenu_SMD_Sec3End(on);
    SeMenu_SetupMenuDisplay(1);
    SeMenu_DrawSoloButton();
}

/* An edit record: +0 the field's byte (the working value), +3 the merged result, +6 mask, +7 shift, +8 max, +9 min,
   +10 signed step.  The unsigned copy compares unsigned, the signed copy (min < 0) signed. */
struct editrecu { unsigned char val, b1, b2, out, b4, b5, mask, shift, max, min; signed char step; };
struct editrecs { signed char val, b1, b2, out, b4, b5; unsigned char mask, shift; signed char max, min, step; };
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);

int SeMenu_StepParamFieldUnsigned(struct editrecu *r)
{
    unsigned char *dst;
    unsigned char mask;
    unsigned char shift;
    unsigned char max;
    unsigned char min;
    signed char step;
    unsigned char orig;
    dst = &r->out;
    mask = r->mask;
    shift = r->shift;
    max = r->max;
    min = r->min;
    step = r->step;
    orig = r->val;
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    r->val = SeMenu_BitShiftMask_End(r->val, shift);
    r->val &= mask;
    if (step > 0) {
        if (r->val == max)
            return 0;
        if ((unsigned char)(max - r->val) > (unsigned char)step)
            r->val += step;
        else
            r->val = max;
    } else {
        if (r->val == min)
            return 0;
        if ((unsigned char)(min - step) < r->val)
            r->val += step;
        else
            r->val = min;
    }
    *dst = SeMenu_BitShiftMask(r->val & mask, shift);
    *dst |= orig;
    return 1;
}

int SeMenu_StepParamFieldSigned(struct editrecs *r)
{
    signed char *dst;
    unsigned char mask;
    unsigned char shift;
    signed char max;
    signed char min;
    signed char step;
    signed char orig;
    dst = &r->out;
    mask = r->mask;
    shift = r->shift;
    max = r->max;
    min = r->min;
    step = r->step;
    orig = r->val;
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    r->val = SeMenu_BitShiftMask_End(r->val, shift);
    r->val &= mask;
    if (step > 0) {
        if (r->val == max)
            return 0;
        if ((unsigned char)(max - r->val) > (unsigned char)step)
            r->val += step;
        else
            r->val = max;
    } else {
        if (r->val == min)
            return 0;
        if ((signed char)(min - step) < r->val)
            r->val += step;
        else
            r->val = min;
    }
    *dst = SeMenu_BitShiftMask(r->val & mask, shift);
    *dst |= orig;
    return 1;
}
