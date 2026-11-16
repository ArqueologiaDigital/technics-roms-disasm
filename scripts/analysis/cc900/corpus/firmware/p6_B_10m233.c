/* Phase 6, helper B, round 10, module 233 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   PartCtrl_SwapIndexedEntries, which calls PartCtrl_ReleaseVoiceChain with calr.
   A cursor is {block, offset} in the part-control block chain; 0x282c is the edit cursor. */
/* cc900-module: PartCtrl_ReleaseVoiceChain */

struct cur { unsigned int blk, off; };
extern struct cur __near ram_282c;
extern unsigned int Part_ReadWord_Indexed(unsigned int, unsigned int);
extern unsigned int Part_ReadByte_Indexed(unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern unsigned int Part_LinkVoiceToChain(unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
extern void PartCtrl_ReleaseVoiceChain(unsigned int);
extern unsigned char PartCtrl_ReadByteExtended(unsigned int, unsigned int);
extern void PartCtrl_WriteByte_ZeroExtended(unsigned int, unsigned int, unsigned int);
extern void BmDrEdit_DecrementAndValidateCounter(unsigned int *, unsigned int *);

/* Moves track a's event data forward by n1 whole blocks and n2 bytes: the old position (c) is copied byte by byte
   to the new one (b) until the copy reaches the saved edit cursor (s), which then takes the new position. */
int PartCtrl_SwapIndexedEntries(unsigned char a, unsigned int n1, unsigned int n2)
{
  struct cur c, b, s;
  unsigned char done;
  unsigned int i, t;
  if (n1 == 0 && n2 == 0) return 0;
  s = ram_282c;
  c.blk = Part_ReadWord_Indexed(0, a);
  c.off = Part_ReadByte_Indexed(0, a);
  b = c;
  for (i = 0; i < n1; i++) {
    t = Part_LinkVoiceToChain(b.blk);
    if (t == 0xffff) { SeqData_SetErrorCode(0x66); PartCtrl_ReleaseVoiceChain(c.blk); return -1; }
    b.blk = t;
  }
  i = c.off + n2;
  if (i >= 0x100) {
    t = Part_LinkVoiceToChain(b.blk);
    if (t == 0xffff) { SeqData_SetErrorCode(0x67); PartCtrl_ReleaseVoiceChain(c.blk); return -1; }
    b.blk = t;
    b.off = (unsigned char)(i - 0xfb);
  } else b.off = (unsigned char)i;
  Part_WriteWord_Indexed(0, a, b.blk);
  Part_WriteByte_Indexed(0, a, b.off);
  done = 0;
  do {
    if (s.blk == c.blk && s.off == c.off) { ram_282c = b; done = 1; }
    PartCtrl_WriteByte_ZeroExtended(b.blk, b.off, PartCtrl_ReadByteExtended(c.blk, c.off));
    BmDrEdit_DecrementAndValidateCounter(&c.blk, &c.off);
    BmDrEdit_DecrementAndValidateCounter(&b.blk, &b.off);
  } while (done == 0);
  return 0;
}
