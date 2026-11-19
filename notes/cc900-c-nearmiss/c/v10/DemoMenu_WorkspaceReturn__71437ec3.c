/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_8m264a.c (2026-11-19-68-p6-r52)
   sha256 71437ec395fa09c84f905670810b8a0ad419745eb8d026a065ccdfce186508cc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int ram_247e0;
extern unsigned int ram_247e2;
extern unsigned int ram_247e4;
extern unsigned int ram_247e6;
extern unsigned int ram_247e8;
extern unsigned int ram_247ea;
unsigned int DemoMenu_WorkspaceReturn(unsigned int i)
{
	if (i <= 8)
		return ((unsigned int *)0x247ceL)[i];
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
