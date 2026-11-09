/* Guessed C for tiny KN5000 v10 firmware functions (proxy-route test, phase 6 preview). */
extern long LSW_FILTER; extern void *ROOT_OBJECT; extern unsigned char g8d3e; extern char g35140;
void SetLswFilter(long a, long b) { LSW_FILTER = a + b; }
void SetRootObject(void *p) { ROOT_OBJECT = p; }
void BitMapOut_StorePresetValue(unsigned char v) { g8d3e = v; }
void SmfMedley_RawData(char c) { g35140 = (c != 0); }
void TrimPad_NullTerminate(char *p) { *p = 0; }
void FmtNum_WriteSpacePad(char *p, char c) { *p++ = c; *p++ = ' '; *p = ' '; }
