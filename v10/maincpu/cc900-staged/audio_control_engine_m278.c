/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ram_347b;
extern unsigned int __near LED_REQUEST_2;
extern void MidiChOut_DetectChanges(void);

void MidiChOut_DetectChanges(void)
{
	if (ACC_TRANSPORT_STATE & 4) return;
	if (!((PLAY_TRANSPORT_STATE ^ ram_347b) & 4)) return;
	LED_REQUEST_2 |= 4;
	ram_347b = PLAY_TRANSPORT_STATE;
}
