/* lane_p6 helper H, round 26r1, form a: module 250 (sequencer/accompaniment_engine.s), the pair
   AccPatch_SeekToPosition (f60230, 31 B) and AccPatch_PrepareSequencePlayback (f60388, 31 B).
   Both seek the patch-sequence reader (AccPatch_SeekForwardSteps), copy the limit byte 0x3706 to 0x36f8, parse the
   header (AccPatch_ParseSequenceHeader) and save the reader position (block / offset) in 0x35de / 0x35e0 or
   0x35e2 / 0x35e4.
   Form a: direct assignments between volatile __near cells (load + store, AccTuning_SaveState's idiom).
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccPatch_ParseSequenceHeader AccPatch_SeekForwardSteps */
/* cc900-name: AccPatch_PrepSequencePlayback=AccPatch_PrepareSequencePlayback */

extern volatile unsigned char __near ram_3706;
extern volatile unsigned char __near ram_36f8;
extern volatile unsigned int __near ACC_PATCH_CURSOR_BLOCK;
extern volatile unsigned int __near ACC_PATCH_CURSOR_OFFSET;
extern volatile unsigned int __near ram_35de;
extern volatile unsigned int __near ram_35e0;
extern volatile unsigned int __near ram_35e2;
extern volatile unsigned int __near ram_35e4;
extern void AccPatch_SeekForwardSteps(void);
extern void AccPatch_ParseSequenceHeader(void);

void AccPatch_SeekToPosition(void)
{
    AccPatch_SeekForwardSteps();
    ram_36f8 = ram_3706;
    AccPatch_ParseSequenceHeader();
    ram_35de = ACC_PATCH_CURSOR_BLOCK;
    ram_35e0 = ACC_PATCH_CURSOR_OFFSET;
}

void AccPatch_PrepSequencePlayback(void)
{
    AccPatch_SeekForwardSteps();
    ram_36f8 = ram_3706;
    AccPatch_ParseSequenceHeader();
    ram_35e2 = ACC_PATCH_CURSOR_BLOCK;
    ram_35e4 = ACC_PATCH_CURSOR_OFFSET;
}
