/* lane_p6 helper N, round 4, form a: module 249 (sequencer/accompaniment_engine.s), retry of p6_N_2m249a
   (p6-r43 O3Xr: +13).  AccVoice_IncrementBarWithSave_Helper:
   - the rhythm ROM base is 0x94860 (608352; round 2 had 0x948a0 by mistake);
   - the ROM has its own AccInit call in every branch and shares only the final copy call (V4.23 cross-jumps from a
     call onward, cf. DispatchSpecialType): AccInit and the copy call written in each branch;
   - the program lookup's result goes straight into the LoadAllParts call (the ROM moves XHL to XWA at once and
     tests the ending in C), the count as a conditional expression.
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
				AccTuning_CopyAllPartsFromStyle_Wrap(p);
			} else {
				AccVoice_BarCntBcData_Helper9();
				AccInit_AllPartPositions_Wrap(ram_3426);
				AccTuning_CopyAllPartsFromStyle_Wrap(ram_3426);
			}
		} else {
			if (ACC_BEATS_PER_BAR == ram_336c) {
				p = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[ram_336d];
				AccInit_AllPartPositions_Wrap(p);
				AccTuning_CopyAllPartsFromStyle_Wrap(p);
			} else {
				AccVoice_BarCntBcData_Helper8();
				AccInit_AllPartPositions_Wrap(ram_3426);
				AccTuning_CopyAllPartsFromStyle_Wrap(ram_3426);
			}
		}
	} else {
		d = ram_33f2;
		s[0] = d[16];
		s[1] = d[17];
		w = (unsigned int)s[1] << 8;
		if ((w | s[0]) != 0x208 && (w | s[0]) != 0x318)
			AccTone_ValidateAndClamp(s);
		AccVoice_LoadAllParts_Wrap(AccTone_LookupByProgram_Dispatch(s[0], s[1]),
		                           (ACC_PENDING_ENDING != 1 && ACC_PENDING_ENDING == 2) ? 1060 : 36);
		AccTuning_CopyAllPartsFromStyle_Wrap(ram_33f2);
	}
	ACC_LANES_RESYNC |= 63;
}
