/* Phase 6, probe m8 (form b): larger leaf functions of v10 (semenu_routines.s, sequencer_engine.s).  Each file
   holds one C form of each function under its firmware name, so that asm_vs_rom.py can compare V4.23 with the ROM.
   The reference model writes some of them differently (res vs and, a byte computed in A, WA vs BC, a memory-to-
   memory move) or refuses them (an indexed byte store from a parameter). */
extern unsigned char ram_20c33, ram_20c35, ram_20bf3[], ram_6c1[], ram_42e, SEQ_ERROR_CODE, SEQ_RTMCFG;
extern unsigned int ram_28c3, SEQ_COUNT_IN;
extern unsigned char SeqData_ErrorCodeRemap[];
int SeMenu_CheckObjEnabled(unsigned char a) { int r = -1; if (ram_20c33 == a) r = 0; return r; }
void SeMenu_SetEditEnable(unsigned char a) { if (a == 1) SEQ_RTMCFG |= 0x04; else SEQ_RTMCFG &= 0xfb; }
unsigned char Rhythm_CheckHighBitFlag(void) { unsigned char v = ram_42e & 0x80; v >>= 7; return v; }
void SeqAcc_UpdateEndPosition(void) { if (SEQ_COUNT_IN > ram_28c3) SEQ_COUNT_IN = ram_28c3; }
void SeqPlay_WriteErrorToVoiceTable(void) { unsigned char *t = SeqData_ErrorCodeRemap; SEQ_ERROR_CODE = t[SEQ_ERROR_CODE]; }
void SeMenu_SetNameBufferChar(unsigned char i, unsigned char c) { if (i <= 15) ram_20bf3[i] = c; }
void SeMenu_StoreEffectCoeff(unsigned char i, unsigned char c) { unsigned char *p = ram_6c1; p[i] = c; }
