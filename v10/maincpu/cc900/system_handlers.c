/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned int ram_1fa97, ram_1e547, ram_1f783, ram_1f379;
extern char ram_1e53e;

unsigned int SeqBuf3_GetTimingValue(void) { return ram_1fa97; }
unsigned int SeqBuf_GetWritePos(void) { return ram_1e547; }
unsigned int SeqBuf_MidiOut_GetTimingValue(void) { return ram_1f783; }
unsigned int SeqMain_GetTimingValue(void) { return ram_1f379; }
void SubCPU_PayloadErrorStore(void) { ram_1e53e = -1; }
int SubCPU_Payload_GetErrorFlag(void) { return ram_1e53e; }
