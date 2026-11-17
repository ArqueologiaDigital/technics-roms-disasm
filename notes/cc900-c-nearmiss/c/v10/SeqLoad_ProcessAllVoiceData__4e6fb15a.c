/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SEQ_CURRENT_SONG;
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern unsigned long __near SEQ_BLOCK_POOL;
void SeqLoad_ProcessAllVoiceData(void)
{
  unsigned char s, p;
  unsigned int w, b, t;
  unsigned char *ps;
  unsigned long os;
  unsigned char *pd;
  unsigned long od;
  unsigned int i;
  s = 1;
  do {
    p = 1;
    do {
      if (Part_ReadVoiceBit7(s, p) == 0) continue;
      w = Part_ReadVoiceWord(s, p);
      if (w == 0xffff) continue;
      if (w == 0xffff) continue;
      do {
        if (w == 1 || w == 2) {
          do {
            b = Part_ProcessAndDecrementVoice();
            if (b > 0x4d8) return;
          } while (b == 1 || b == 2);
          ps = (unsigned char *)SEQ_BLOCK_POOL;
          os = ((unsigned long)w - 1) << 8;
          pd = (unsigned char *)SEQ_BLOCK_POOL;
          od = ((unsigned long)b - 1) << 8;
          i = 0;
          do { pd[i + od] = ps[i + os]; i++; } while (i < 0x100);
          t = PartCtrl_ReadWord_Off1(w);
          if (t != 0) PartCtrl_WriteWord(t, b);
          else {
            Part_WriteVoiceWord(s, p, b);
            if ((unsigned char)(s - 1) == SEQ_CURRENT_SONG) Part_WriteVoiceWord(0, p, b);
          }
          t = PartCtrl_ReadWord(w);
          if (t != 0xffff) PartCtrl_WriteWord_Off1(t, b);
          else {
            Part_WriteWord_Indexed(s, p, b);
            if ((unsigned char)(s - 1) == SEQ_CURRENT_SONG) Part_WriteWord_Indexed(0, p, b);
          }
        }
        w = PartCtrl_ReadWord(w);
      } while (w != 0xffff);
    } while (++p <= 16);
  } while (++s <= 10);
  PartCtrl_SetClearBit7(1, 1);
  PartCtrl_WriteWord_Off1(1, 0);
  PartCtrl_WriteWord(1, 0xffff);
  PartCtrl_WriteByteToBuf(1, 5, 0x82);
  PartCtrl_SetClearBit7(2, 1);
  PartCtrl_WriteWord_Off1(2, 0);
  PartCtrl_WriteWord(2, 0xffff);
  PartCtrl_WriteByteToBuf(2, 5, 0x82);
}
