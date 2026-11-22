/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r2m287b.c (2026-11-21-5-p6-r60)
   sha256 102b0cfd6c654432c5507cc96c8d0ac7d3f128e0f979e4951c82467ca5a3e9c2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct mq;
typedef struct mq *mqp;
typedef void (*cmdfn)(void);
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern unsigned char __near ram_bd1c;
extern cmdfn SeqChan_WriteFieldHandlers[];
void MidiPkt_XferOnGroupEnd(void)
{
	if (((unsigned char *)MIDISEQ_SPARE_BUF_PTR)[3] < 22) {
		SeqChan_WriteFieldHandlers[((unsigned char *)MIDISEQ_SPARE_BUF_PTR)[3]]();
		ram_bd1c &= ~0x80;
	}
}
