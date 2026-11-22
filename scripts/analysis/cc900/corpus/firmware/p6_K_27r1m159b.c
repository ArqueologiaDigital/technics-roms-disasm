/* lane_p6 helper K, round 27r1, form b (row 0 by a switch, cases 0x500, 0x600 in source order): module 159 (storage/flash_floppy_handlers.s), family of 2 x 197 B:
   DualVoice_ScanAllColumns / DualVoice_ScanAllColumnsAlt.  Clear the slot table (0x6d4 / 0x73a), then for the ten
   columns read row 0 (its value is kept when bits 8-10 are 5 or 6) and rows 1-4 (a value whose low byte is 0x80 or
   more is inserted into the table, by a conditional call).  The column counter is a byte register (QIZ); the grid
   reader takes promoted byte arguments, so it is declared without a prototype.  Form a: row 0 by an || test.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SlotTable_InitBank1748 SlotTable_InitBank1850 Util_FrameSetup10 */

extern unsigned int __near ram_6d4;
extern unsigned int __near ram_73a;
extern void SlotTable_InitBank1748(void);
extern void SlotTable_InitBank1850(void);
extern void SlotTable_Insert1748(unsigned int);
extern void SlotTable_Insert1850(unsigned int);
extern unsigned int Util_FrameSetup10();
extern void DualVoice_ScanAllColumns(unsigned char a);
extern void DualVoice_ScanAllColumnsAlt(unsigned char a);

void DualVoice_ScanAllColumns(unsigned char a)
{
	unsigned char n;
	unsigned int v;

	SlotTable_InitBank1748();
	for (n = 0; n < 10; n++) {
		v = Util_FrameSetup10(a, n, 0);
		switch (v & 0x700) {
		case 0x500:
		case 0x600:
			ram_6d4 = v;
		}
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
		switch (v & 0x700) {
		case 0x500:
		case 0x600:
			ram_73a = v;
		}
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
