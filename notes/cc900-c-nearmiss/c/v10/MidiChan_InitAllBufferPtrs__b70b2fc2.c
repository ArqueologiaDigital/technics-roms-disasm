/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m288a.c (2026-11-19-19-p6-r43)
   sha256 b70b2fc2ddbafb9f4cc54642ac4fc7d807953b82a381e220437b7b14e90b2650 (tar-sha256); compiled at -O3 -XS -Xr */
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
