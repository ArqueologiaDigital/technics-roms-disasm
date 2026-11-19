/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_4m276a.c (2026-11-19-29-p6-r46)
   sha256 ce527fb0045e87c6c85f0d0b4293051468b9e0868979831aaa51df1ab3854865 (tar-sha256); compiled at -O3 -Xr */
#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern volatile unsigned char __near FDC_ERROR_CODE;
extern long ApPostEvent(long, long, long);
void FDC_CommandAndPostEvent(void)
{
	struct fdccmd cmd;

	cmd.op = 3;
	FDC_CommandEntry(&cmd);
	if (FDC_ERROR_CODE == 0xfc)
		ApPostEvent(-1, EVT_PAGE_CHANGE, 2);
	else
		ApPostEvent(-1, EVT_PAGE_CHANGE, 1);
}
