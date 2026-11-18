/* Phase 6, lane_p6 helper J, round 4, module 233, form b: SeqVoice_ProcessAndAssign with if / else calls (for
   -O3 cross-jumping to share the calr) and the mask in its own int. */
/* cc900-module: ToneVoice_AssignChannel */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_2324;
extern unsigned char __near ram_2322;
extern unsigned int __near SEQ_RECORDING_TRACKS;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern void ToneVoice_AssignChannel(int ch, unsigned char *ev, int kind);

void SeqVoice_ProcessAndAssign(unsigned char *ev)
{
	unsigned char c;
	int m;

	if (*ev == 0x80) {
		c = ram_2324;
		if (c != 0xff) {
			m = 1 << (c - 1);
			if (m & SEQ_RECORDING_TRACKS) {
				if (SEQ_CYCLE_FLAGS & 2)
					ToneVoice_AssignChannel(0x12, ev, 4);
				else
					ToneVoice_AssignChannel(c, ev, 4);
			}
		}
	}
	if (*ev == 0x85 || *ev == 0x86) {
		c = ram_2324;
		if (c != 0xff) {
			m = 1 << (c - 1);
			if (m & SEQ_RECORDING_TRACKS) {
				if (SEQ_CYCLE_FLAGS & 2)
					ToneVoice_AssignChannel(0x12, ev, 2);
				else
					ToneVoice_AssignChannel(c, ev, 2);
			}
		}
		c = ram_2322;
		if (c != 0xff) {
			m = 1 << (c - 1);
			if (m & SEQ_RECORDING_TRACKS) {
				if (SEQ_CYCLE_FLAGS & 2)
					ToneVoice_AssignChannel(0x12, ev, 2);
				else
					ToneVoice_AssignChannel(c, ev, 2);
			}
		}
	}
}
