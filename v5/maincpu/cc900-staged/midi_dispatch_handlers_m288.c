/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ArpQueue_InitBuffer */   /* scripts/analysis/cc900/module_calls.py v10 */

struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
struct tmpl16 { unsigned int w[8]; };
typedef struct mq *mqp;
typedef struct tmpl16 *tqp;
extern struct mq __near ram_b734;
extern struct mq __near ram_b84c;
extern struct mq __near ram_b964;
extern struct mq __near ram_ba7c;
extern struct tmpl16 __near ram_bbac;
extern struct tmpl16 __near ram_bbbc;
extern struct tmpl16 __near ram_bbcc;
extern struct tmpl16 __near ram_bbdc;
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern tqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BLOCK_PTR;
extern tqp __near MIDISEQ_SPARE_BUF_PTR;
extern mqp __near ram_bb9c;
extern tqp __near ram_bbf4;
extern mqp __near ram_bba0;
extern tqp __near ram_bbf8;
extern void ArpQueue_InitBuffer(struct mq *q, struct tmpl16 *t);
extern void MidiChan_InitAllBufferPtrs(void);

void MidiChan_InitAllBufferPtrs(void)
{
	MIDISEQ_ACTIVE_BLOCK_PTR = &ram_b734;
	MIDISEQ_ACTIVE_BUF_PTR = &ram_bbac;
	MIDISEQ_SPARE_BLOCK_PTR = &ram_b84c;
	MIDISEQ_SPARE_BUF_PTR = &ram_bbbc;
	ram_bb9c = &ram_b964;
	ram_bbf4 = &ram_bbcc;
	ram_bba0 = &ram_ba7c;
	ram_bbf8 = &ram_bbdc;
	ArpQueue_InitBuffer(MIDISEQ_ACTIVE_BLOCK_PTR, MIDISEQ_ACTIVE_BUF_PTR);
	ArpQueue_InitBuffer(MIDISEQ_SPARE_BLOCK_PTR, MIDISEQ_SPARE_BUF_PTR);
	ArpQueue_InitBuffer(ram_bb9c, ram_bbf4);
	ArpQueue_InitBuffer(ram_bba0, ram_bbf8);
}
