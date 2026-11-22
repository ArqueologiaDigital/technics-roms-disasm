/* lane_p6 helper H, round 26r1, form b: module 250 (sequencer/accompaniment_engine.s), the pair
   AccPatch_SeekToPosition (f60230, 31 B) and AccPatch_PrepareSequencePlayback (f60388, 31 B).
   Form b: plain __near cells, each copy through a local (AccCh1_SaveState's -Xr idiom).
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
    unsigned char c;
    unsigned int w;
    AccPatch_SeekForwardSteps();
    c = ram_3706;
    ram_36f8 = c;
    AccPatch_ParseSequenceHeader();
    w = ACC_PATCH_CURSOR_BLOCK;
    ram_35de = w;
    w = ACC_PATCH_CURSOR_OFFSET;
    ram_35e0 = w;
}

void AccPatch_PrepSequencePlayback(void)
{
    unsigned char c;
    unsigned int w;
    AccPatch_SeekForwardSteps();
    c = ram_3706;
    ram_36f8 = c;
    AccPatch_ParseSequenceHeader();
    w = ACC_PATCH_CURSOR_BLOCK;
    ram_35e2 = w;
    w = ACC_PATCH_CURSOR_OFFSET;
    ram_35e4 = w;
}
