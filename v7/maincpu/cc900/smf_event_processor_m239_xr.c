/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: SeqStep_ParseVariableHeader */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rq { unsigned char drv; char p1; char p2; unsigned char fl3; unsigned char b4; unsigned char unit; };
extern int __cdecl SeqStep_ParseVariableHeader(int op, int dev, int b, int a, int c, int d, unsigned char *buf);
extern int __cdecl SeqChan_ByteBlockD(struct rq *r, int a, int b, int c, int d, unsigned char *buf);

int __cdecl SeqChan_ByteBlockD(struct rq *r, int a, int b, int c, int d, unsigned char *buf)
{
	return SeqStep_ParseVariableHeader(4, r->b4, b, a, c, d, buf);
}
