/* Phase 6, probe m8 (form a): larger leaf functions of v10 (semenu_routines.s, sequencer_engine.s).  Each file
   holds one C form of each function under its firmware name, so that asm_vs_rom.py can compare V4.23 with the ROM.
   The reference model writes some of them differently (res vs and, a byte computed in A, WA vs BC, a memory-to-
   memory move) or refuses them (an indexed byte store from a parameter). */
extern unsigned char ram_20c33, ram_20c35, ram_20bf3[], ram_6c1[], ram_42e, SEQ_ERROR_CODE, SEQ_RTMCFG;
extern unsigned int ram_28c3, SEQ_COUNT_IN;
extern unsigned char SeqData_ErrorCodeRemap[];
int SeMenu_CheckObjEnabled(unsigned char a) { if (ram_20c33 != a) return -1; return 0; }
void SeMenu_SetEditEnable(unsigned char a) { if (a == 1) SEQ_RTMCFG |= 0x04; else SEQ_RTMCFG &= ~0x04; }
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
void SeqAcc_UpdateEndPosition(void) { unsigned int e = ram_28c3; if (SEQ_COUNT_IN > e) SEQ_COUNT_IN = e; }
void SeqPlay_WriteErrorToVoiceTable(void) { SEQ_ERROR_CODE = SeqData_ErrorCodeRemap[SEQ_ERROR_CODE]; }
void SeMenu_SetNameBufferChar(unsigned char i, unsigned char c) { if (i > 15) return; ram_20bf3[i] = c; }
void SeMenu_StoreEffectCoeff(unsigned char i, unsigned char c) { ram_6c1[i] = c; }
