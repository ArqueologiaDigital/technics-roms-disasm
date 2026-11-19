/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: SndTable_CalcSectorPosition */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fdccmd { int op; int f2; int b; int a; int c; int count; long buf; };
extern void SndTable_CalcSectorPosition(unsigned int n, int *c, int *b, int *a);
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern int FDC_ExecuteSectorCommand(unsigned int n, void *buf);

int FDC_ExecuteSectorCommand(unsigned int n, void *buf)
{
	int c;
	int b;
	int a;
	struct fdccmd cmd;
	int *pc;
	int *pb;

	pc = &c;
	pb = &b;
	SndTable_CalcSectorPosition(n, pc, pb, &a);
	cmd.op = 3;
	cmd.f2 = 0;
	cmd.b = b;
	cmd.a = a;
	cmd.c = c;
	cmd.count = 1;
	cmd.buf = (long)buf;
	return FDC_CommandEntry(&cmd);
}
