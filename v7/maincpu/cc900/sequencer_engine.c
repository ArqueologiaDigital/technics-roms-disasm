/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char __near ram_1d60;

void SeqData_SetErrorCode(unsigned char e) { if (ram_1d60 == 0) ram_1d60 = e; }

extern unsigned char __near ram_28a1;
int Seq_ValidatePartNumber(unsigned char a) { if (a < 1 || a > ram_28a1) return -1; return 0; }
int Seq_ValidateTempoValue(unsigned int t) { if (t < 1 || t > 999) return -1; return 0; }
void SeqScan_ClearNoteRange(unsigned char *e) { unsigned char *p = e; e += 6; do *p++ = 0; while (p < e); }
