/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelEvent_Post */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_9039;
extern unsigned char __near CURRENT_MODE;
extern void ExtDev_SndParam_Block48_Var02(unsigned char *e);
extern void ExtDev_SndParam_Block48_Var04(unsigned char *e);
extern void ExtDev_SndParam_Block48_Var04_B(unsigned char *e);
extern void ExtDev_SndParam_Block48_Var40(unsigned char *e);
extern void ExtDev_SndParam_Block48_Var80(unsigned char *e);
extern void ExtDev_SndParam_Block70_Var04(unsigned char *e);
extern void ExtDev_SndParam_Block98_Var40(unsigned char *e);
extern void ExtDev_SndParam_Block98_Var40_B(unsigned char *e);
extern void ExtDev_SndParam_Block98_Var80(unsigned char *e);
extern unsigned char __near CURRENT_TITLE;
extern void ExtDev_SndParam_BlockA9_Var02(unsigned char *e);
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near ram_90cd[];
extern unsigned char __near PART_SELECT;
extern void ExtDev_SndParam_ConfigAndWrite(unsigned char *e);
extern int SndParam_LookupReadOnly(long);
extern void ExtDev_SndParam_Write48_Block(unsigned char *e);
extern void ExtDev_SndParam_Write98_Block(unsigned char *e);
extern void NakaData_WidgetInit1(unsigned char *e);
extern unsigned char __near ram_3415;
extern unsigned char __near ram_903b[];
extern void PanelAction_PedalFn_Code40(unsigned char *e);

void ExtDev_SndParam_Block48_Var02(unsigned char *e)
{
	if (CURRENT_MODE == 16) return;
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 2;
	else e[2] = 0;
	e[3] = 2;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04_B(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 6;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var40(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var80(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block70_Var04(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 112;
	e[1] = 0;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var40(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var40_B(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 152;
	e[1] = 11;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var80(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 152;
	e[1] = 11;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_BlockA9_Var02(unsigned char *e)
{
	if (CURRENT_TITLE == 135) {
		ram_9039 |= 2;
		e[0] = 0xa9;
		e[1] = 10;
		if (e[2] & e[3]) e[2] = 2;
		else e[2] = 0;
		e[3] = 2;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_ConfigAndWrite(unsigned char *e)
{
	if (!(e[2] & e[3])) return;
	ram_9039 |= 2;
	e[0] = PART_SELECT;
	e[1] = 5;
	if (SndParam_LookupViaEncode(PART_SELECT, 93) == 0) e[2] = ram_90cd[PART_SELECT];
	else e[2] = 0;
	e[3] = 127;
	PanelEvent_Post(e);
}

/* cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1 */

void ExtDev_SndParam_Write48_Block(unsigned char *e)
{
	if (SndParam_LookupReadOnly(192) != 0) return;
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 4;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Write98_Block(unsigned char *e)
{
	if (SndParam_LookupViaEncode(PART_SELECT, 1539) != 1) return;
	ram_9039 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void NakaData_WidgetInit1(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 1;
	else e[2] = 0;
	e[3] = 1;
	PanelEvent_Post(e);
}

void PanelAction_PedalFn_Code40(unsigned char *e)
{
	unsigned char v, a;
	unsigned int i;

	if (CURRENT_MODE == 17) return;
	if (ram_3415 & 8) return;
	ram_9039 |= 2;
	a = e[2] & e[3];
	v = 0;
	if (a != 0) v = 8;
	i = 0;
	do {
		if (ram_903b[i] == 255) break;
		if (SndParam_LookupViaEncode(ram_903b[i], 0x601) == 1) {
			e[0] = ram_903b[i];
			e[1] = 4;
			e[2] = v;
			e[3] = 8;
			PanelEvent_Post(e);
		}
	} while (++i < 16);
}
