/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_ToggleTlvBits SwbtWr_FlushAndAppendParams */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToneParam_DispHnd_Join5(void);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_VoiceCM3_Join2(void);
extern void ExtData_VoiceCM3_Join3(void);
extern void ExtData_VoiceCM3_Join4(void);
extern void ExtData_VoiceCM3_Join5(void);
extern void ExtData_VoiceCM3_Join6(void);
extern void ExtData_VoiceCM3_Join7(void);

/* cc900-name: ExtData_ToneParam_DispHnd_Join5=ExtData_ToneParam_DispatchHandler_Join5 */
void ExtData_ToneParam_DispHnd_Join5(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join2=ExtData_Voice_CheckMode3_Helper_Join2 */
void ExtData_VoiceCM3_Join2(void)
{
	ExtData_SetTlvField(127);
	ExtData_ToggleTlvBits(128);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join3=ExtData_Voice_CheckMode3_Helper_Join3 */
void ExtData_VoiceCM3_Join3(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join4=ExtData_Voice_CheckMode3_Helper_Join4 */
void ExtData_VoiceCM3_Join4(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join5=ExtData_Voice_CheckMode3_Helper_Join5 */
void ExtData_VoiceCM3_Join5(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join6=ExtData_Voice_CheckMode3_Helper_Join6 */
void ExtData_VoiceCM3_Join6(void)
{
	ExtData_SetTlvField(255);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join7=ExtData_Voice_CheckMode3_Helper_Join7 */
void ExtData_VoiceCM3_Join7(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-module: PanelEvent_Post */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
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
extern unsigned char __near ram_918d[];
extern unsigned char __near PART_SELECT;
extern void ExtDev_SndParam_ConfigAndWrite(unsigned char *e);
extern int SndParam_LookupReadOnly(long);
extern unsigned char BitMapOut_PrepRender_CheckBit1(void);
extern void ExtDev_SndParam_DispatchComplex(unsigned char *e, unsigned char c);
extern void ExtDev_SndParam_Write48_Block(unsigned char *e);
extern void ExtDev_SndParam_Write98_Block(unsigned char *e);
extern void NakaData_WidgetInit1(unsigned char *e);
extern unsigned char __near ram_34cd;
extern unsigned char __near ram_90fb[];
extern void PanelAction_PedalFn_Code40(unsigned char *e);

void ExtDev_SndParam_Block48_Var02(unsigned char *e)
{
	if (CURRENT_MODE == 16) return;
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 2;
	else e[2] = 0;
	e[3] = 2;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block48_Var04(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block48_Var04_B(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 6;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block48_Var40(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block48_Var80(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block70_Var04(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 112;
	e[1] = 0;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block98_Var40(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block98_Var40_B(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 11;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Block98_Var80(unsigned char *e)
{
	ram_90f9 |= 2;
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
		ram_90f9 |= 2;
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
	ram_90f9 |= 2;
	e[0] = PART_SELECT;
	e[1] = 5;
	if (SndParam_LookupViaEncode(PART_SELECT, 93) == 0) e[2] = ram_918d[PART_SELECT];
	else e[2] = 0;
	e[3] = 127;
	PanelEvent_Post(e);
}
/* cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1 */
void ExtDev_SndParam_DispatchComplex(unsigned char *e, unsigned char c)
{
	unsigned char m, r;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	r = BitMapOut_PrepRender_CheckBit1();
	r <<= 3;
	e[2] = c - 191 + r;
	e[3] = 127;
	PanelEvent_Post(e);
}
void ExtDev_SndParam_Write48_Block(unsigned char *e)
{
	if (SndParam_LookupReadOnly(192) != 0) return;
	ram_90f9 |= 2;
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
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}
void NakaData_WidgetInit1(unsigned char *e)
{
	ram_90f9 |= 2;
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
	if (ram_34cd & 8) return;
	ram_90f9 |= 2;
	a = e[2] & e[3];
	v = 0;
	if (a != 0) v = 8;
	i = 0;
	do {
		if (ram_90fb[i] == 255) break;
		if (SndParam_LookupViaEncode(ram_90fb[i], 0x601) == 1) {
			e[0] = ram_90fb[i];
			e[1] = 4;
			e[2] = v;
			e[3] = 8;
			PanelEvent_Post(e);
		}
	} while (++i < 16);
}
