/* Phase 6, lane_p6 helper L, round 4, form b: module 276, FDC_CommandAndPostEvent with the error code copied to a
   local before the compare (form a uses a volatile cell). */
/* (no module-local callee) */

#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern unsigned char __near FDC_ERROR_CODE;
extern long ApPostEvent(long, long, long);
extern void FDC_CommandAndPostEvent(void);

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
