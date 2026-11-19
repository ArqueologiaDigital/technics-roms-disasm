/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/drawbar_panel_ui_m264_xr.c (2026-11-19-92-p6-r57)
   sha256 3ccec0a810dd93bde40d94107b2cc0ceca443b5e1ba437722dacab454f8c7b38 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned int ram_247ce[];
extern unsigned int ram_247e0;
extern unsigned int ram_247e2;
extern unsigned int ram_247e4;
extern unsigned int ram_247e6;
extern unsigned int ram_247e8;
extern unsigned int ram_247ea;
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
