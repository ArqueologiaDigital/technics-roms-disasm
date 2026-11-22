/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccPatch_ParseSequenceHeader AccPatch_SeekForwardSteps */   /* scripts/analysis/cc900/module_calls.py v10 */

extern volatile unsigned char __near ram_364e;
extern volatile unsigned char __near ram_3640;
extern volatile unsigned int __near ACC_PATCH_CURSOR_BLOCK;
extern volatile unsigned int __near ACC_PATCH_CURSOR_OFFSET;
extern volatile unsigned int __near ram_352a;
extern volatile unsigned int __near ram_352c;
extern void AccPatch_SeekForwardSteps(void);
extern void AccPatch_ParseSequenceHeader(void);
extern void AccPatch_PrepSequencePlayback(void);
extern volatile unsigned int __near ram_3526;
extern volatile unsigned int __near ram_3528;
extern void AccPatch_SeekToPosition(void);

/* cc900-name: AccPatch_PrepSequencePlayback=AccPatch_PrepareSequencePlayback */
void AccPatch_PrepSequencePlayback(void)
{
    AccPatch_SeekForwardSteps();
    ram_3640 = ram_364e;
    AccPatch_ParseSequenceHeader();
    ram_352a = ACC_PATCH_CURSOR_BLOCK;
    ram_352c = ACC_PATCH_CURSOR_OFFSET;
}

void AccPatch_SeekToPosition(void)
{
    AccPatch_SeekForwardSteps();
    ram_3640 = ram_364e;
    AccPatch_ParseSequenceHeader();
    ram_3526 = ACC_PATCH_CURSOR_BLOCK;
    ram_3528 = ACC_PATCH_CURSOR_OFFSET;
}
