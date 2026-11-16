/* Phase 6, probe m11: larger leaf functions of v10's sequencer/sequencer_engine.s, each under its firmware name.
   PartCtrl_*: 256-byte part records at 0xb0000, part n's record at 0xb0000 + (n - 1) * 256; the ROM loads the base
   with ld XR,imm (integer arithmetic) in the word accessors and with lda (a constant pointer) in TestBit7 /
   ReadByte. */
extern unsigned char ram_28a1, ram_42d, ram_42e, PANEL_GM[];
unsigned int PartCtrl_ReadWord(unsigned int n) { return *(unsigned int *)(0xb0000L + (((unsigned long)(n - 1) << 8) + 3)); }
unsigned int PartCtrl_ReadWord_Off1(unsigned int n) { return *(unsigned int *)(0xb0000L + (((unsigned long)(n - 1) << 8) + 1)); }
void PartCtrl_WriteWord(unsigned int n, unsigned int v) { *(unsigned int *)(0xb0000L + (((unsigned long)(n - 1) << 8) + 3)) = v; }
void PartCtrl_WriteWord_Off1(unsigned int n, unsigned int v) { *(unsigned int *)(0xb0000L + (((unsigned long)(n - 1) << 8) + 1)) = v; }
unsigned char PartCtrl_TestBit7(unsigned int n) { return *((unsigned char *)0xb0000 + ((unsigned long)(n - 1) << 8)) & 0x80; }
unsigned char PartCtrl_ReadByte(unsigned int n, unsigned char o) { return *((unsigned char *)0xb0000 + (((unsigned long)(n - 1) << 8) + o)); }
int Seq_ValidatePartNumber(unsigned char a) { if (a < 1 || a > ram_28a1) return -1; return 0; }
int Seq_ValidateTempoValue(unsigned int t) { if (t < 1 || t > 999) return -1; return 0; }
int Rhythm_ComputeNoteIndex(void) { return (ram_42d & 0x7f) + ((ram_42e & 0x7f) << 7); }
void SeqScan_ClearNoteRange(unsigned char *e) { unsigned char *p = e; e += 6; do *p++ = 0; while (p < e); }
void VoiceAlloc_InitBitMap(void) { unsigned char *e = (unsigned char *)0x29f8; unsigned char *p = e; e += 155; do *p++ = 0; while (p < e); }
void SeqBuf_ClearRange(void) { unsigned char *e = (unsigned char *)0x2732; unsigned char *p = e; unsigned char *q = (unsigned char *)0x272c; e += 6; do { *q++ = 0; *p++ = 0; } while (p < e); }
void SeqStatus_SetOrClearBit(unsigned char m, unsigned char on) { unsigned char *p = &PANEL_GM[3]; if (on) *p |= m; else *p &= ~m; }
