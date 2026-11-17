/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5b.c (2026-11-16-45-p6-r9)
   sha256 02668fddc4a7ae9f0dcae741aab0cb2afb9cebcd20d58654e0aa4bfa1965ed0a (tar-sha256); compiled at -Xr */
extern void DeleteEvent(long, long);
extern long ApPostEvent(long, long, long);
void UI_InterruptTitleByIndex(unsigned char i)
{
	DeleteEvent(-1L, 0x1c00016L);
	ApPostEvent(-1L, 0x1c00016L, 0x1a00000L + i);
}
