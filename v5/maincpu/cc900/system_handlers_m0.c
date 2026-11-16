/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char LIVE_PANEL_BLOCK;
extern unsigned int NMI_CHECKSUM_REGION1;
extern unsigned int NMI_CHECKSUM_REGION2;
extern char ram_1e53e;
extern unsigned int Checksum_ComputeComplement(unsigned char *, unsigned int);
extern void __cdecl SeqBuf_DspSysEx_WriteByte(int);
extern void __cdecl SeqBuf_DmaChan0_WriteByte(int);
extern void __cdecl SeqBuf_SoundEdit_BytecodeBlock(int);
extern void __cdecl SeqBuf_VoiceMap_WriteByte(int);

void Seq_InitStub_Nop1(void)
{
}

void Seq_InitStub_Nop2(void)
{
}

void Seq_InitStub_Nop3(void)
{
}

void SubCPU_Payload_Verify(void)
{
    unsigned int s = Checksum_ComputeComplement((unsigned char *)0xf180, 0x800);
    unsigned char *p = &LIVE_PANEL_BLOCK;
    if (s == NMI_CHECKSUM_REGION1) {
        ram_1e53e = 0;
        if (Checksum_ComputeComplement(p, 0x280) != NMI_CHECKSUM_REGION2) ram_1e53e = -1;
    } else {
        ram_1e53e = -1;
        if (Checksum_ComputeComplement(p, 0x280) == NMI_CHECKSUM_REGION2) ram_1e53e = 1;
    }
}

void SeqDMA_MultiWrite_DspSysEx(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_DspSysEx_WriteByte(*p++);
}

void SeqDMA_MultiWrite_NoteEvent(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_DmaChan0_WriteByte(*p++);
}

void SeqDMA_MultiWrite_SoundEdit(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_SoundEdit_BytecodeBlock(*p++);
}

void SeqDMA_MultiWrite_VoiceMap(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_VoiceMap_WriteByte(*p++);
}

void SeqDMA_Nop(void)
{
}
