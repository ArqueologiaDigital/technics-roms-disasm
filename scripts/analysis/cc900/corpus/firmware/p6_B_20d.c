/* Phase 6, helper B, round 20, form d: v10 sequencer/sequencer_engine.s.  SeqPos_AdvanceWithWrap alone: it calls
   PartCtrl_ReadWord by calr (module-local), where the other round-20 files call it absolute, and a file has one
   module line.  The ROM subtracts 0x100 and then adds 5 as two steps, written so here. */
/* cc900-module: PartCtrl_ReadWord */

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);

/* moves the playback position forward by a bytes; past 0xff it continues in the next block at offset
   (old - 0x100) + 5, after the 5-byte block header */
void SeqPos_AdvanceWithWrap(unsigned char a)
{
  unsigned int o;
  o = SEQ_DATA_OFFSET + a;
  SEQ_DATA_OFFSET = o;
  if (o > 0xff) {
    o -= 0x100;
    o += 5;
    SEQ_DATA_OFFSET = o;
    SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
  }
}
