/* lane_p6 helper H, round 26r1, form c: module 250 (sequencer/accompaniment_engine.s), the pair
   AccPatch_SeekToPosition (f60230, 31 B) and AccPatch_PrepareSequencePlayback (f60388, 31 B).
   Form c: plain (not volatile) __near cells, direct assignments: does V4.23 at -Xr load + store or move memory to
   memory?
   cc900-options: -Xr
*/
/* cc900-module: AccPatch_ParseSequenceHeader AccPatch_SeekForwardSteps */
/* cc900-name: AccPatch_PrepSequencePlayback=AccPatch_PrepareSequencePlayback */

extern unsigned char __near ram_3706;
extern unsigned char __near ram_36f8;
extern unsigned int __near ACC_PATCH_CURSOR_BLOCK;
extern unsigned int __near ACC_PATCH_CURSOR_OFFSET;
extern unsigned int __near ram_35de;
extern unsigned int __near ram_35e0;
extern unsigned int __near ram_35e2;
extern unsigned int __near ram_35e4;
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
