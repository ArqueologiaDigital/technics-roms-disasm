/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5a.c (2026-11-16-45-p6-r9)
   sha256 0a24d3abb3ad01135d3ba1544257bdeae1dc14fc21da9794d409ad64bba47312 (tar-sha256); compiled at -O3 -Xr */
extern void DeleteEvent(long, long);
extern long ApPostEvent(long, long, long);
void UI_ChangeTitleByIndex(unsigned char i)
{
	DeleteEvent(-1L, 0x1c00015L);
	ApPostEvent(-1L, 0x1c00015L, (unsigned long)i + 0x1a00000L);
}
