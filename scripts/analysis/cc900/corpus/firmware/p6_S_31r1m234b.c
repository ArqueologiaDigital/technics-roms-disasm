/* lane_p6 helper S, round 31r1: sequencer/sequencer_engine.s (module 234), form b.
   Part_ValidateAndSetupVoiceChannel with prototypes (the callee Part_ValidateVoiceChannel as the built twin declares
   it, taking an int; its own definition is in p6_S_31r1m234c.c), and the no-data path nested instead of a goto.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord PartCtrl_ReadWord_Off1 PartCtrl_SetClearBit7 PartCtrl_TestBit7 PartCtrl_WriteByteToBuf PartCtrl_WriteWord PartCtrl_WriteWord_Off1 Part_DeallocVoices1And2 Part_ReadVoiceBit7 Part_ReadVoiceWord Part_UnlinkVoiceFromChain Part_ValidateVoiceChannel Part_WriteVoiceWord Part_WriteWordBlock_OffsetAF Part_WriteWord_Indexed SeqData_ReadNextByte SeqPlay_AllocBuffersAndInit */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_f218[];
extern unsigned int __near ram_f1f8[];
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void Part_ValidateVoiceChannel(unsigned int);
extern void Part_ValidateAndSetupVoiceChannel(unsigned char a);

void Part_ValidateAndSetupVoiceChannel(unsigned char a)
{
  unsigned char e;
  unsigned char o;
  unsigned int b;

  Part_ValidateVoiceChannel(a);
  e = SEQ_ERROR_CODE;
  if (e != 0) {
    if (e == 1)
      SEQ_ERROR_CODE = 0;
    return;
  }
  SEQ_ERROR_CODE = 0;
  o = ram_f218[(unsigned char)(a - 1)];
  if (o >= 5) {
    b = ram_f1f8[(unsigned char)(a - 1)];
    if (b > 0x4d8) {
      SEQ_ERROR_CODE = 10;
      return;
    }
    if (PartCtrl_TestBit7(b) != 0) {
      SEQ_DATA_BLOCK = b;
      SEQ_DATA_OFFSET = o;
      if (SeqData_ReadNextByte() == 0x84)
        SEQ_ERROR_CODE = 6;
      return;
    }
  }
  SEQ_ERROR_CODE = 11;
}

/* SeqVoice_FindChannelSetup, form b: the current-song test without the char cast. */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned long __near SEQ_BLOCK_POOL;
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void Part_UnlinkVoiceFromChain(void);
extern void Part_DeallocVoices1And2(void);
extern void SeqVoice_FindChannelSetup(void);

void SeqVoice_FindChannelSetup(void)
{
  unsigned char s, p, x, found;
  unsigned int w, b, t;
  unsigned char *ps;
  unsigned long os;
  unsigned char *pd;
  unsigned long od;
  unsigned int i;
  found = 0;
  s = 1;
  do {
    if (SEQ_CURRENT_SONG + 1 == s) x = 0;
    else x = s;
    p = 1;
    do {
      if (Part_ReadVoiceBit7(x, p) == 0) continue;
      w = Part_ReadVoiceWord(x, p);
      if (w == 0xffff) continue;
      if (w == 0xffff) continue;
      do {
        if (w == 1 || w == 2) {
          found = 1;
          b = SEQ_FREE_LIST_HEAD;
          while (b == 1 || b == 2) b = PartCtrl_ReadWord(b);
          t = PartCtrl_ReadWord(b);
          PartCtrl_WriteWord_Off1(t, 0);
          Part_WriteWordBlock_OffsetAF(t);
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
  if (found == 1) {
    PartCtrl_SetClearBit7(1, 1);
    PartCtrl_WriteWord_Off1(1, 0);
    PartCtrl_WriteWord(1, 0xffff);
    PartCtrl_WriteByteToBuf(1, 5, 0x82);
    PartCtrl_SetClearBit7(2, 1);
    PartCtrl_WriteWord_Off1(2, 0);
    PartCtrl_WriteWord(2, 0xffff);
    PartCtrl_WriteByteToBuf(2, 5, 0x82);
  } else if (SEQ_FREE_LIST_HEAD == 1)
    Part_UnlinkVoiceFromChain();
  else
    Part_DeallocVoices1And2();
}

/* SeqPlay_HandleVoiceReassign, form b: the flag update in one expression, the last test as one if. */
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near ACC_RUN_FLAGS;
extern unsigned char __near ram_1d90;
extern unsigned char __near ram_11f4;
extern unsigned char __near ram_1d5e;
extern unsigned char __near ram_1da0;
extern void SeqRestart_CheckAndDispatch(void);
extern void BitMapOut_PrepareAndRender(int);
extern void SeqPlay_AllocBuffersAndInit(void);
extern void SeqPlay_CheckStartConditions(void);
extern void SeqPlay_HandleVoiceReassign(void);

void SeqPlay_HandleVoiceReassign(void)
{
  if ((SEQ_CONTROL_FLAGS & 0x04) && !(PANEL_STYLE[5] & 0x30)) {
    SeqRestart_CheckAndDispatch();
    SEQ_CONTROL_FLAGS = (SEQ_CONTROL_FLAGS & ~0x04) | 0x10;
  }
  if (ram_1d90 != 0 && !(ACC_TRANSPORT_STATE & 0x04) && !(SEQ_TRANSPORT_STATE & 0x14)) {
    ram_11f4 = 0;
    BitMapOut_PrepareAndRender(0);
    ram_1d90 = 0;
  }
  if ((SEQ_CONTROL_FLAGS & 0x10) && !(ACC_TRANSPORT_STATE & 0x04) && !(SEQ_TRANSPORT_STATE & 0x14)
      && ram_1d5e == 0 && !(ACC_RUN_FLAGS & 0x02)) {
    SeqPlay_AllocBuffersAndInit();
    SEQ_CONTROL_FLAGS &= ~0x10;
  }
  if (ram_1da0 != 0 && !(SEQ_TRANSPORT_STATE & 0x1c)) {
    SeqPlay_CheckStartConditions();
    ram_1da0 = 0;
  }
}
