/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m278.c (2026-11-16-118-p6-r23)
   sha256 2ed2a4df7583813870d785efeb5dcaadc2229c9ed384e1d30b8a8156b979bdd3 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ram_347b;
extern unsigned int __near LED_REQUEST_2;
void MidiChOut_DetectChanges(void)
{
	if (ACC_TRANSPORT_STATE & 4) return;
	if (!((PLAY_TRANSPORT_STATE ^ ram_347b) & 4)) return;
	LED_REQUEST_2 |= 4;
	ram_347b = PLAY_TRANSPORT_STATE;
}
