/* Phase 6, lane_p6 helper L, round 2, form a: module 288 (midi/midi_dispatch_handlers.s).
   - MidiChan_InitAllBufferPtrs: point the four (queue, template) pointer pairs at their __near buffers, then
     ArpQueue_InitBuffer each pair (the last a tail jr).  The ROM passes the first pair from the registers it just
     stored (store-to-load forwarding at -O3) and reloads the other three after each call.  Types as the matched
     cc900/midi_dispatch_handlers.c declares them. */
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
