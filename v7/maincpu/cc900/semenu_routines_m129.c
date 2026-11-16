/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char ram_20c39[], ram_20bf3[];
extern unsigned char __near ram_6ba[];
extern unsigned char GUI_DisplayStructData_0x1129[];

unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n)
{
	unsigned char r = a;
	unsigned int i;

	for (i = 0; i < n; i++) r >>= 1;
	return r;
}

void SeMenu_CopyNameChars(unsigned char *d, unsigned char *s, unsigned char n)
{
	unsigned char i;

	for (i = 0; i < n; i++) *d++ = *s++;
}

void SeMenu_GetNameBufferChar(unsigned char i, unsigned char *out)
{
	if (i > 15) return;
	*out = ram_20bf3[i];
}

void SeMenu_LoadParamByte(unsigned char n, unsigned char *out)
{
	*out = ram_6ba[(unsigned char)(n - 1)];
}

void SeMenu_NameCharIndexToChar(unsigned char c, unsigned char *out)
{
	if (c >= 97) {
		*out = 32;
		return;
	}
	*out = GUI_DisplayStructData_0x1129[c];
}

/* cc900-module: SeCtr2_StepPartField SeMenu_BindDialToColumn SeMenu_BitShiftMask SeMenu_FillObjTable SeMenu_FlushDisplayObj SeMenu_IsPartEnabled SeMenu_LoadMasterPtr SeMenu_PostDialEnable SeMenu_PostEditUpDownSet SeMenu_SetCurrentPart SeMenu_SetupMenuDisplay SeMenu_SetupMenuDisplay_Finalize SeMenu_SetupMenuDisplay_Section3_End SeMenu_SetupPartDisplay SeMenu_StepParamFieldSigned SeMenu_StepParamFieldUnsigned SeMenu_StoreEventId SeMenu_ValidatePartNumber */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern int SeMenu_IsPartEnabled(unsigned char a);
extern void SeMenu_SetCurrentPart(unsigned char part);
extern unsigned char SeMenu_SelectPartIfEnabled(unsigned char p);
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
extern void SeMenu_BindDialToColumn(unsigned char col);
extern void UI_ChangeTitleByIndex(unsigned char i);
extern void UI_PostRefreshEvent(void);
extern void SeMenu_StoreEventId(unsigned char id);
extern void SeMenu_SendEvent(unsigned char title, unsigned char refresh);
extern void SeMenu_InitObjEntry(unsigned char *e);

unsigned char SeMenu_SelectPartIfEnabled(unsigned char p)
{
    unsigned char cur;
    SeMenu_ValidatePartNumber(&cur);
    if (cur == p || SeMenu_IsPartEnabled(p) == 0)
        return 0;
    SeMenu_SetCurrentPart(p);
    return 1;
}
void SeMenu_BindDialToColumn(unsigned char col)
{
    SeMenu_PostDialEnable(1);
    SeMenu_PostEditUpDownSet(0, col, 0);
    SeMenu_PostEditUpDownSet(1, col, 128);
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
    *e <<= 4;
    ++*e;
}

/* cc900-module: SeMenu_BitShiftMask_End SeMenu_LoadObjEntries SeMenu_RegisterElement_Extended SeMenu_SMD_Sec3End SeMenu_SetupDisplayObject_Alt1 */
extern void SeMenu_SMD_Sec3End(int on);
extern void SeMenu_SetupMenuDisplay_Finalize(unsigned char *solo);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_DrawSoloButton(void);
extern void SeMenu_ToggleSolo(void);
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern unsigned char SeMenu_BitShiftMask(int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_SetupDisplayObject_Alt1(int, int, unsigned char *, unsigned int);
extern unsigned char __near SEMENU_PART_MASK;
extern void SeMenu_SetPartEnabled(unsigned char part, unsigned char on);

/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
void SeMenu_ToggleSolo(void)
{
    unsigned char s;
    SeMenu_SetupMenuDisplay_Finalize(&s);
    if (s != 0)
        SeMenu_SMD_Sec3End(0);
    else
        SeMenu_SMD_Sec3End(1);
    SeMenu_SetupMenuDisplay(1);
    SeMenu_DrawSoloButton();
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
void SeMenu_SetPartEnabled(unsigned char part, unsigned char on)
{
	unsigned char v;
	unsigned char obj;
	unsigned char m;

	if (part < 1 || part > 4) return;
	SeMenu_LoadObjEntries(&obj);
	m = SeMenu_BitShiftMask(1, (unsigned char)(part + part - 2));
	if (on == 0) SEMENU_PART_MASK &= ~m;
	else SEMENU_PART_MASK |= m;
	v = SEMENU_PART_MASK;
	if (obj == 0) SeMenu_RegisterElement_Extended(0, 17, &v, m);
	else SeMenu_SetupDisplayObject_Alt1(0, 13, &v, m);
}
