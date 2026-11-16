/* cc900-module: SeCtr2_StepPartField SeMenu_BindDialToColumn SeMenu_BitShiftMask SeMenu_FillObjTable SeMenu_IsPartEnabled SeMenu_PostDialEnable SeMenu_PostEditUpDownSet SeMenu_SetCurrentPart SeMenu_SetupMenuDisplay SeMenu_SetupMenuDisplay_Finalize SeMenu_SetupMenuDisplay_Section3_End SeMenu_SetupPartDisplay SeMenu_StepParamFieldSigned SeMenu_StepParamFieldUnsigned SeMenu_StoreEventId SeMenu_ValidatePartNumber */
/* Phase 6, lane_p6 helper A, round 14, form a: module 129 of modules_v10.tsv (audio/semenu_routines.s), small
   sound-editor routines that call each other with calr.  Char arguments are widened at the call, as V4.23 does. */
struct sfrec { unsigned char old, f1, f2, merged, f4, f5, mask, shift, max; signed char min, step; };
extern unsigned char __near SEMENU_PART_MASK;
extern unsigned int __near ram_6b0;
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
extern unsigned char SeMenu_BitShiftMask(int v, int n);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_SetCurrentPart(unsigned char part);
extern void SeMenu_SetupMenuDisplay_Finalize(unsigned char *solo);
extern void SeMenu_SetupMenuDisplay_Section3_End(int on);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_DrawSoloButton(void);
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void UI_ChangeTitleByIndex(unsigned char i);
extern void UI_PostRefreshEvent(void);
extern void SeMenu_StoreEventId(unsigned char id);
extern unsigned char SeMenu_StepParamFieldUnsigned(struct sfrec *r);
extern unsigned char SeMenu_StepParamFieldSigned(struct sfrec *r);
extern void SeMenu_FillObjTable(unsigned char *t);
extern void SeMenu_SetupPartDisplay(int mode, unsigned char *t, int n);

void SeMenu_BindDialToColumn(unsigned char col)
{
    SeMenu_PostDialEnable(1);
    SeMenu_PostEditUpDownSet(0, col, 0);
    SeMenu_PostEditUpDownSet(1, col, 128);
}

int SeMenu_IsPartEnabled(unsigned char a)
{
    if (a < 1 || a > 4)
        return 0;
    return (SEMENU_PART_MASK & SeMenu_BitShiftMask(1, (unsigned char)(a + a - 2))) != 0;
}

unsigned char SeMenu_SelectPartIfEnabled(unsigned char p)
{
    unsigned char cur;
    SeMenu_ValidatePartNumber(&cur);
    if (cur != p && SeMenu_IsPartEnabled(p) != 0) {
        SeMenu_SetCurrentPart(p);
        return 1;
    }
    return 0;
}

void SeMenu_ToggleSolo(void)
{
    unsigned char s;
    SeMenu_SetupMenuDisplay_Finalize(&s);
    SeMenu_SetupMenuDisplay_Section3_End(s != 0 ? 0 : 1);
    SeMenu_SetupMenuDisplay(1);
    SeMenu_DrawSoloButton();
}

void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank)
{
    SeCtr2_StepPartField(part, (bank & 0x7f) != 0);
    SeMenu_BindDialToColumn(part + 4);
}

void SeMenu_SendEvent(unsigned char title, unsigned char refresh)
{
    if (refresh == 0)
        UI_ChangeTitleByIndex(title);
    else
        UI_PostRefreshEvent();
    SeMenu_StoreEventId(refresh);
}

void SeMenu_InitObjEntry(unsigned char *e)
{
    unsigned char p;
    SeMenu_ValidatePartNumber(&p);
    *e = p;
    *e = p << 4;
    (*e)++;
}

unsigned char SeMenu_StepParamField(struct sfrec *r)
{
    unsigned char c;
    if (r->mask == 0 || r->shift > 7 || r->step == 0)
        return 0;
    if (r->min < 0)
        c = SeMenu_StepParamFieldSigned(r);
    else
        c = SeMenu_StepParamFieldUnsigned(r);
    return c;
}

void SeMenu_ApplySynthParam(void)
{
    unsigned char t[36];
    SeMenu_FillObjTable(t);
    SeMenu_SetupPartDisplay(1, t, 0xd);
    ram_6b0 = ((unsigned int)t[15] << 8) + t[14];
}
