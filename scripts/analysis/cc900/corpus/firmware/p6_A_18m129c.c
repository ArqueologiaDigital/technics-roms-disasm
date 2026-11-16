/* cc900-module: SeCtr2_StepPartField SeMenu_BindDialToColumn SeMenu_BitShiftMask SeMenu_BitShiftMask_End SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_SetupMenuDisplay SeMenu_SetupMenuDisplay_Finalize SeMenu_SetupMenuDisplay_Section3_End */
/* cc900-module: SeMenu_SMD_Sec3End */
/* Phase 6, lane_p6 helper A, round 18, form c: module 129 (audio/semenu_routines.s).
   Record builders, clear-loop set-up per function, in file order: S1 p = r; e = p; e += 9; / S8 q = r; p = q; e = q + 9; / S6 e = r; p = e; e += 9; / S7 q = r; p = q; e = q + 9;.
   SeMenu_InitDisplayColumn: q = r; p = q; e = q + 9; (unsigned char *p, *e, *q;).
   SeCtr2_OnPartColumn: the flag by ?:.
   SeMenu_ToggleSolo: the second cc900-module line names the short C name (cc900-name) of
   SeMenu_SetupMenuDisplay_Section3_End: asm_vs_rom.py's module test sees the listing's C name, so round 17's
   call to it was checked as `call` where the ROM has calr (its +18 is exactly there).
   SeMenu_StepParamFieldUnsigned / Signed (new): a byte pointer indexed r[0] .. r[10], locals declared step first. */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);

void SeMenu_SetDisplayValue(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *p, *e;
    p = r;
    e = p;
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
    r[3] = 0;
    r[4] = 1;
    r[5] = v;
    SeMenu_FlushDisplayObj(r);
}

void SeMenu_RegisterValueDisplay(unsigned char a, unsigned char c)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *e, *p;
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
    unsigned char *q, *p, *e;
    q = r;
    p = q;
    e = q + 9;
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
    unsigned char *p, *e, *q;
    q = r;
    p = q;
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
    f = (bank & 0x7f) ? 1 : 0;
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
    on = 1;
    if (s != 0)
        on = 0;
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

int SeMenu_StepParamFieldUnsigned(unsigned char *r)
{
    signed char step;
    unsigned char min;
    unsigned char max;
    unsigned char shift;
    unsigned char mask;
    unsigned char *dst;
    unsigned char orig;
    dst = &r[3];
    mask = r[6];
    shift = r[7];
    max = r[8];
    min = r[9];
    step = r[10];
    orig = r[0];
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    r[0] = SeMenu_BitShiftMask_End(r[0], shift);
    r[0] &= mask;
    if (step > 0) {
        if (r[0] == max)
            return 0;
        if ((unsigned char)(max - r[0]) > (unsigned char)step)
            r[0] += step;
        else
            r[0] = max;
    } else {
        if (r[0] == min)
            return 0;
        if ((unsigned char)(min - step) < r[0])
            r[0] += step;
        else
            r[0] = min;
    }
    *dst = SeMenu_BitShiftMask(r[0] & mask, shift);
    *dst |= orig;
    return 1;
}

int SeMenu_StepParamFieldSigned(signed char *r)
{
    signed char step;
    signed char min;
    signed char max;
    unsigned char shift;
    unsigned char mask;
    signed char *dst;
    signed char orig;
    dst = &r[3];
    mask = r[6];
    shift = r[7];
    max = r[8];
    min = r[9];
    step = r[10];
    orig = r[0];
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    r[0] = SeMenu_BitShiftMask_End(r[0], shift);
    r[0] &= mask;
    if (step > 0) {
        if (r[0] == max)
            return 0;
        if ((unsigned char)(max - r[0]) > (unsigned char)step)
            r[0] += step;
        else
            r[0] = max;
    } else {
        if (r[0] == min)
            return 0;
        if ((signed char)(min - step) < r[0])
            r[0] += step;
        else
            r[0] = min;
    }
    *dst = SeMenu_BitShiftMask(r[0] & mask, shift);
    *dst |= orig;
    return 1;
}
