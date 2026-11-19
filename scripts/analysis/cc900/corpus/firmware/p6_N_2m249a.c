/* lane_p6 helper N, round 2, form a: module 249 (sequencer/accompaniment_engine.s).
   AccVoice_IncrementBarWithSave_Helper: with a latched ending (bit 0 of 0x3363) starts its pattern -- from the
   rhythm ROM (0x948a0 + RhythmTiming_OffsetTable[...]) when the style's beats per bar match the saved ones, else
   from the record at 0x3426 after clearing the ending request (Helper8 / Helper9); otherwise reloads the program
   of the style record at 0x33f2.  Then copies all parts and resyncs the six lanes.  The pointer built from the
   rhythm ROM follows the built AccTone_LookupByProgram (cc900/accompaniment_engine.c).
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
				p = (unsigned char *)0x948a0 + RhythmTiming_OffsetTable[ram_336f];
				AccInit_AllPartPositions_Wrap(p);
			} else {
				AccVoice_BarCntBcData_Helper9();
				AccInit_AllPartPositions_Wrap(ram_3426);
				p = ram_3426;
			}
		} else {
			if (ACC_BEATS_PER_BAR == ram_336c) {
				p = (unsigned char *)0x948a0 + RhythmTiming_OffsetTable[ram_336d];
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
		if ((w | s[0]) != 0x208 && (w | s[0]) != 0x318)
			AccTone_ValidateAndClamp(s);
		p = AccTone_LookupByProgram_Dispatch(s[0], s[1]);
		e = ACC_PENDING_ENDING;
		if (e != 1 && e == 2)
			w = 1060;
		else
			w = 36;
		AccVoice_LoadAllParts_Wrap(p, w);
		p = ram_33f2;
	}
	AccTuning_CopyAllPartsFromStyle_Wrap(p);
	ACC_LANES_RESYNC |= 63;
}
