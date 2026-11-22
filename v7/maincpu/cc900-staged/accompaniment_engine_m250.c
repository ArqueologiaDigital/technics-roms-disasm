/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccPatch_ParseSequenceHeader AccPatch_SeekForwardSteps */   /* scripts/analysis/cc900/module_calls.py v10 */

extern volatile unsigned char __near ram_366a;
extern volatile unsigned char __near ram_365c;
extern volatile unsigned int __near ACC_PATCH_CURSOR_BLOCK;
extern volatile unsigned int __near ACC_PATCH_CURSOR_OFFSET;
extern volatile unsigned int __near ram_3546;
extern volatile unsigned int __near ram_3548;
extern void AccPatch_SeekForwardSteps(void);
extern void AccPatch_ParseSequenceHeader(void);
extern void AccPatch_PrepSequencePlayback(void);
extern volatile unsigned int __near ram_3542;
extern volatile unsigned int __near ram_3544;
extern void AccPatch_SeekToPosition(void);

/* cc900-name: AccPatch_PrepSequencePlayback=AccPatch_PrepareSequencePlayback */
void AccPatch_PrepSequencePlayback(void)
{
    AccPatch_SeekForwardSteps();
    ram_365c = ram_366a;
    AccPatch_ParseSequenceHeader();
    ram_3546 = ACC_PATCH_CURSOR_BLOCK;
    ram_3548 = ACC_PATCH_CURSOR_OFFSET;
}

void AccPatch_SeekToPosition(void)
{
    AccPatch_SeekForwardSteps();
    ram_365c = ram_366a;
    AccPatch_ParseSequenceHeader();
    ram_3542 = ACC_PATCH_CURSOR_BLOCK;
    ram_3544 = ACC_PATCH_CURSOR_OFFSET;
}
