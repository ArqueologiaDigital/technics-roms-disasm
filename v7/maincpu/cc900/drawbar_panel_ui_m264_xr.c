/* Functions of ui/drawbar_panel_ui.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/



int SdpartLookupPartId(unsigned int *p, unsigned int v)
{
	int n = 0;

	while (*p != 0xffff) {
		if (*p == v) break;
		p++;
		n++;
	}
	if (*p != 0xffff) return n;
	return -1;
}

extern unsigned int ram_247ce[];
extern unsigned int ram_247e0;
extern unsigned int ram_247e2;
extern unsigned int ram_247e4;
extern unsigned int ram_247e6;
extern unsigned int ram_247e8;
extern unsigned int ram_247ea;
extern unsigned int DemoMenu_WorkspaceReturn(unsigned int i);

/* cc900-data: DemoMenu_WorkspaceReturn 1 = DemoMenu_DescriptorFunc_CaseTable */
unsigned int DemoMenu_WorkspaceReturn(unsigned int i)
{
	if (i <= 8)
		return *(unsigned int *)(void *)(ram_247ce + (unsigned long)i);
	switch (i) {
	case 9: return ram_247e0;
	case 10: return ram_247e2;
	case 11: return ram_247e4;
	case 12: return ram_247e6;
	case 13: return ram_247e8;
	case 14: return ram_247ea;
	}
	return 0;
}

extern unsigned int *ram_3ea34;
extern unsigned int PsMixer_ReadWordArrayEntry(int i);
extern long ram_3ea30;
extern void Util_StorePartArrayBase(long p);

unsigned int PsMixer_ReadWordArrayEntry(int i)
{
  return ram_3ea34[i];
}
void Util_StorePartArrayBase(long p)
{
  ram_3ea30 = p;
}
