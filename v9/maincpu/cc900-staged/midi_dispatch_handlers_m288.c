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
extern struct mq __near ram_b7f4;
extern struct mq __near ram_b90c;
extern struct mq __near ram_ba24;
extern struct mq __near ram_bb3c;
extern struct tmpl16 __near ram_bc6c;
extern struct tmpl16 __near ram_bc7c;
extern struct tmpl16 __near ram_bc8c;
extern struct tmpl16 __near ram_bc9c;
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern tqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BLOCK_PTR;
extern tqp __near MIDISEQ_SPARE_BUF_PTR;
extern mqp __near ram_bc5c;
extern tqp __near ram_bcb4;
extern mqp __near ram_bc60;
extern tqp __near ram_bcb8;
extern void ArpQueue_InitBuffer(struct mq *q, struct tmpl16 *t);
extern void MidiChan_InitAllBufferPtrs(void);

void MidiChan_InitAllBufferPtrs(void)
{
	MIDISEQ_ACTIVE_BLOCK_PTR = &ram_b7f4;
	MIDISEQ_ACTIVE_BUF_PTR = &ram_bc6c;
	MIDISEQ_SPARE_BLOCK_PTR = &ram_b90c;
	MIDISEQ_SPARE_BUF_PTR = &ram_bc7c;
	ram_bc5c = &ram_ba24;
	ram_bcb4 = &ram_bc8c;
	ram_bc60 = &ram_bb3c;
	ram_bcb8 = &ram_bc9c;
	ArpQueue_InitBuffer(MIDISEQ_ACTIVE_BLOCK_PTR, MIDISEQ_ACTIVE_BUF_PTR);
	ArpQueue_InitBuffer(MIDISEQ_SPARE_BLOCK_PTR, MIDISEQ_SPARE_BUF_PTR);
	ArpQueue_InitBuffer(ram_bc5c, ram_bcb4);
	ArpQueue_InitBuffer(ram_bc60, ram_bcb8);
}
