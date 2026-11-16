/* Phase 6, helper B, round 12, module 233 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   PartCtrl_SwapIndexedEntries (refined from round 10: cursor copies field by field, the copied byte in a
   temporary).  Calls PartCtrl_ReleaseVoiceChain with calr. */
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

int PartCtrl_SwapIndexedEntries(unsigned char a, unsigned int n1, unsigned int n2)
{
  struct cur c, b, s;
  unsigned char done, v;
  unsigned int i, t;
  if (n1 == 0 && n2 == 0) return 0;
  s.blk = ram_282c.blk;
  s.off = ram_282c.off;
  c.blk = Part_ReadWord_Indexed(0, a);
  c.off = Part_ReadByte_Indexed(0, a);
  b.blk = c.blk;
  b.off = c.off;
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
    if (s.blk == c.blk && s.off == c.off) {
      ram_282c.blk = b.blk;
      ram_282c.off = b.off;
      done = 1;
    }
    v = PartCtrl_ReadByteExtended(c.blk, c.off);
    PartCtrl_WriteByte_ZeroExtended(b.blk, b.off, v);
    BmDrEdit_DecrementAndValidateCounter(&c.blk, &c.off);
    BmDrEdit_DecrementAndValidateCounter(&b.blk, &b.off);
  } while (done == 0);
  return 0;
}
