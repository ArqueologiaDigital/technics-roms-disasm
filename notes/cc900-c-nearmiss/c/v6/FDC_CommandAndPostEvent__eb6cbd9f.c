/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_mode_handlers_m276.c (2026-11-19-43-p6-r48)
   sha256 eb6cbd9f9f410c80677f13f0a56e507fbbb5758929519b2e2acf129b591bd0c1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern unsigned char __near FDC_ERROR_CODE;
extern long ApPostEvent(long, long, long);
void FDC_CommandAndPostEvent(void)
{
	struct fdccmd cmd;
	unsigned char e;

	cmd.op = 3;
	FDC_CommandEntry(&cmd);
	e = FDC_ERROR_CODE;
	if (e == 0xfc)
		ApPostEvent(-1, EVT_PAGE_CHANGE, 2);
	else
		ApPostEvent(-1, EVT_PAGE_CHANGE, 1);
}
