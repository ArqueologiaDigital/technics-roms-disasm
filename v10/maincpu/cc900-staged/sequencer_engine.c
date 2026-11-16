/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit). */
extern unsigned char __near ram_42e;
extern unsigned int __near ram_28c3, SEQ_COUNT_IN;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
void SeqAcc_UpdateEndPosition(void) { unsigned int e = ram_28c3; if (SEQ_COUNT_IN > e) SEQ_COUNT_IN = e; }
