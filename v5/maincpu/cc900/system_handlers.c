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

typedef unsigned char *ucp;
extern unsigned int __near INTERCPU_XFER_COUNT;
extern ucp __near INTERCPU_XFER_PTR;
extern unsigned char INTER_CPU_COMM_LATCHES;
extern unsigned int ram_1e751;
extern unsigned int ram_204dd;
extern unsigned int ram_1fca1;
extern unsigned int ram_1ef5b;

long *TableData_ROM_Verify(long *p, long *end)
{
    if (*p == -1) do {
        p += 16;
        if (p == end) return 0;
    } while (*p == -1);
    return p;
}
void Audio_DMA_Transfer(void)
{
    unsigned long i, n;
    unsigned char d;
    n = INTERCPU_XFER_COUNT;
    if (INTERCPU_XFER_COUNT == 0) n = 0x10000;
    for (i = 0; i < n; i++) {
        INTER_CPU_COMM_LATCHES = *INTERCPU_XFER_PTR++;
        d = 0;
        do d++; while (d < 3);
    }
}
unsigned int RhythmBuf_BytecodeSnippet(void) { return ram_1ef5b; }
unsigned int SeqBuf_DspSysEx_OrphanData(void) { return ram_1fca1; }
unsigned int SeqBuf_NoteEvent_OrphanData(void) { return ram_204dd; }
unsigned int TempoRingBuf_BytecodeSnippet2(void) { return ram_1e751; }
