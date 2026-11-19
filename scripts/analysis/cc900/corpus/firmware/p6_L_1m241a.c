/* Phase 6, lane_p6 helper L, round 1, form a: module 241 (sequencer/smf_event_processor.s).
   - FDC_ExecuteSectorCommand: SndTable_CalcSectorPosition(sector, &c, &b, &a) (4th argument on the stack, callee
     pops), a 16-byte floppy command block {3, 0, b, a, c, 1, buf} in the frame, run by the __cdecl
     FDC_CommandEntry.  The three address-taken ints are declared highest slot first (reverse declaration order). */
/* cc900-module: SndTable_CalcSectorPosition */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern void SndTable_CalcSectorPosition(unsigned int n, int *c, int *b, int *a);
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern int FDC_ExecuteSectorCommand(unsigned int n, void *buf);

int FDC_ExecuteSectorCommand(unsigned int n, void *buf)
{
	int c;
	int b;
	int a;
	struct fdccmd cmd;

	SndTable_CalcSectorPosition(n, &c, &b, &a);
	cmd.op = 3;
	cmd.f2 = 0;
	cmd.b = b;
	cmd.a = a;
	cmd.c = c;
	cmd.count = 1;
	cmd.buf = buf;
	return FDC_CommandEntry(&cmd);
}
