/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3b.c (2026-11-16-37-p6-r5)
   sha256 87e701e28dc0ffe6e2c00b6fe7f01531d2c1c5e103ce52a0a7404b5d93a5dc63 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *PanelTlv_CompanionByPart[];
extern unsigned char __near PANEL_VARI_STYLE[];
unsigned char *PanelTlv_CompanionOfPart(unsigned char a)
{
	if (a < 0x20) return PanelTlv_CompanionByPart[a];
	else if (a == 0x48) return PANEL_VARI_STYLE;
	else return (unsigned char *)0xffffffffL;
}
