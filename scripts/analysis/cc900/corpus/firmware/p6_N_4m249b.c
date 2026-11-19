/* lane_p6 helper N, round 4, form b: module 249 (sequencer/accompaniment_engine.s), retry of p6_N_2m249a.
   AccVoice_IncrementBarWithSave_Helper, form b against a: round 2's shape (one pointer p, one copy call at the
   end) with only the base fixed (0x94860), the lookup result passed straight on, and the second program test
   spelled `w | *s`: the ROM rebuilds the OR for the second compare and re-reads s[0], where V4.23 reused the first.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccVoice_BarCounterBytecodeData_Helper8 AccVoice_BarCounterBytecodeData_Helper9 */
/* cc900-name: AccVoice_BarCntBcData_Helper8=AccVoice_BarCounterBytecodeData_Helper8 */
/* cc900-name: AccVoice_BarCntBcData_Helper9=AccVoice_BarCounterBytecodeData_Helper9 */

extern unsigned long RhythmTiming_OffsetTable[];
extern unsigned char __near ram_3363;
extern unsigned char __near ACC_PENDING_ENDING;
extern unsigned char __near ACC_BEATS_PER_BAR;
extern unsigned char __near ram_336c;
extern unsigned char __near ram_336d;
extern unsigned char __near ram_336e;
extern unsigned char __near ram_336f;
extern unsigned char *__near ram_3426;
extern unsigned char *__near ram_33f2;
extern unsigned char __near ACC_LANES_RESYNC;
extern void AccVoice_BarCntBcData_Helper8(void);
extern void AccVoice_BarCntBcData_Helper9(void);
extern void AccInit_AllPartPositions_Wrap(unsigned char *);
extern void AccTuning_CopyAllPartsFromStyle_Wrap(unsigned char *);
extern void AccVoice_LoadAllParts_Wrap(unsigned char *, unsigned int);
extern unsigned char *AccTone_LookupByProgram_Dispatch(unsigned int, unsigned int);
extern void AccTone_ValidateAndClamp(unsigned char *);

void AccVoice_IncrementBarWithSave_Helper(void)
{
	unsigned char s[2];
	unsigned char *p;
	unsigned char *d;
	unsigned char e;
	unsigned int w;

	if (ram_3363 & 0x01) {
		e = ACC_PENDING_ENDING;
		if (e != 1 && e == 2) {
			if (ACC_BEATS_PER_BAR == ram_336e) {
				p = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[ram_336f];
				AccInit_AllPartPositions_Wrap(p);
			} else {
				AccVoice_BarCntBcData_Helper9();
				AccInit_AllPartPositions_Wrap(ram_3426);
				p = ram_3426;
			}
		} else {
			if (ACC_BEATS_PER_BAR == ram_336c) {
				p = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[ram_336d];
				AccInit_AllPartPositions_Wrap(p);
			} else {
				AccVoice_BarCntBcData_Helper8();
				AccInit_AllPartPositions_Wrap(ram_3426);
				p = ram_3426;
			}
		}
	} else {
		d = ram_33f2;
		s[0] = d[16];
		s[1] = d[17];
		w = (unsigned int)s[1] << 8;
		if ((w | s[0]) != 0x208 && (w | *s) != 0x318)
			AccTone_ValidateAndClamp(s);
		AccVoice_LoadAllParts_Wrap(AccTone_LookupByProgram_Dispatch(s[0], s[1]),
		                           (ACC_PENDING_ENDING != 1 && ACC_PENDING_ENDING == 2) ? 1060 : 36);
		p = ram_33f2;
	}
	AccTuning_CopyAllPartsFromStyle_Wrap(p);
	ACC_LANES_RESYNC |= 63;
}
