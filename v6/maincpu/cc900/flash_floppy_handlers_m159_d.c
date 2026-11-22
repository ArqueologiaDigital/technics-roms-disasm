/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SlotTable_InitBank1748 SlotTable_InitBank1850 Util_FrameSetup10 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_6d4;
extern void SlotTable_InitBank1748(void);
extern void SlotTable_Insert1748(unsigned int);
extern unsigned int Util_FrameSetup10();
extern void DualVoice_ScanAllColumns(unsigned char a);
extern unsigned int __near ram_73a;
extern void SlotTable_InitBank1850(void);
extern void SlotTable_Insert1850(unsigned int);
extern void DualVoice_ScanAllColumnsAlt(unsigned char a);

void DualVoice_ScanAllColumns(unsigned char a)
{
	unsigned char n;
	unsigned int v;

	SlotTable_InitBank1748();
	for (n = 0; n < 10; n++) {
		v = Util_FrameSetup10(a, n, 0);
		if ((v & 0x700) == 0x600 || (v & 0x700) == 0x500)
			ram_6d4 = v;
		v = Util_FrameSetup10(a, n, 1);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1748(v);
		v = Util_FrameSetup10(a, n, 2);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1748(v);
		v = Util_FrameSetup10(a, n, 3);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1748(v);
		v = Util_FrameSetup10(a, n, 4);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1748(v);
	}
}

void DualVoice_ScanAllColumnsAlt(unsigned char a)
{
	unsigned char n;
	unsigned int v;

	SlotTable_InitBank1850();
	for (n = 0; n < 10; n++) {
		v = Util_FrameSetup10(a, n, 0);
		if ((v & 0x700) == 0x600 || (v & 0x700) == 0x500)
			ram_73a = v;
		v = Util_FrameSetup10(a, n, 1);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1850(v);
		v = Util_FrameSetup10(a, n, 2);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1850(v);
		v = Util_FrameSetup10(a, n, 3);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1850(v);
		v = Util_FrameSetup10(a, n, 4);
		if ((v & 0xff) >= 0x80)
			SlotTable_Insert1850(v);
	}
}
