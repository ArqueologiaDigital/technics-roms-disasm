/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeCtr2_StepPartField SeMenu_BindDialToColumn SeMenu_BitShiftMask SeMenu_BitShiftMask_End SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_LoadObjEntries SeMenu_RegisterElement_Extended SeMenu_SMD_Sec3End SeMenu_SetupDisplayObject_Alt1 SeMenu_SetupMenuDisplay SeMenu_SetupMenuDisplay_Finalize SeMenu_SetupMenuDisplay_Section3_End */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_SMD_Sec3End(int on);
extern void SeMenu_SetupMenuDisplay_Finalize(unsigned char *solo);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_DrawSoloButton(void);
extern void SeMenu_ToggleSolo(void);
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);
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
