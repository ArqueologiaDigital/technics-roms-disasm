/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeCtr2_StepPartField SeMenu_BindDialToColumn SeMenu_BitShiftMask SeMenu_FillObjTable SeMenu_IsPartEnabled SeMenu_PostDialEnable SeMenu_PostEditUpDownSet SeMenu_SetCurrentPart SeMenu_SetupMenuDisplay SeMenu_SetupMenuDisplay_Finalize SeMenu_SetupMenuDisplay_Section3_End SeMenu_SetupPartDisplay SeMenu_StepParamFieldSigned SeMenu_StepParamFieldUnsigned SeMenu_StoreEventId SeMenu_ValidatePartNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
extern void SeMenu_BindDialToColumn(unsigned char col);
extern void UI_ChangeTitleByIndex(unsigned char i);
extern void UI_PostRefreshEvent(void);
extern void SeMenu_StoreEventId(unsigned char id);
extern void SeMenu_SendEvent(unsigned char title, unsigned char refresh);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_InitObjEntry(unsigned char *e);

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
