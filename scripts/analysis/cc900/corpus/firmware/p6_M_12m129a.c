/* Phase 6, lane_p6 helper M, round 12, module 129 (audio/semenu_routines.s), form a: the PITCH page's side rows and
   switch (SePitPit1_*), in the matched shapes.  Rows 4 / 5 on switch 0 step part parameter 13 down to 1 / up to 4
   (the frame byte decremented / incremented in memory), store it and redraw title field 13; otherwise select part
   3 / 4.  Rows 1 and 3: an if / else of two tail calls. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEPITENV1 0x28
#define TT_SEPITLFO1 0x2a

extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
extern void SePitPit1_OnSideRow1(unsigned char a);
extern void SePitPit1_OnSideRow2(unsigned char a);
extern void SePitPit1_OnSideRow3(unsigned char a);
extern void SePitPit1_OnSideRow4(unsigned char a);
extern void SePitPit1_OnSideRow5(unsigned char a);
extern void SePitPit1_OnSwitch15(unsigned char a);

void SePitPit1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEPITENV1, 0);
}

void SePitPit1_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(39, 1, 1);
}

void SePitPit1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITLFO1, 0);
	else
		SeMenu_SelectPartAndRedraw(39, 2, 1);
}

void SePitPit1_OnSideRow4(unsigned char a)
{
	unsigned char v;

	if (a == 0) {
		SeMenu_LoadPartParam(13, &v);
		if (v > 1) {
			v--;
			SeMenu_StorePartParam(13, v);
			SeTitle_DrawField(39, 13);
		}
	} else
		SeMenu_SelectPartAndRedraw(39, 3, 1);
}

void SePitPit1_OnSideRow5(unsigned char a)
{
	unsigned char v;

	if (a == 0) {
		SeMenu_LoadPartParam(13, &v);
		if (v < 4) {
			v++;
			SeMenu_StorePartParam(13, v);
			SeTitle_DrawField(39, 13);
		}
	} else
		SeMenu_SelectPartAndRedraw(39, 4, 1);
}

void SePitPit1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
