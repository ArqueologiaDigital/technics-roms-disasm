/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

typedef unsigned int *uip;
extern unsigned char __near ram_654;
extern unsigned char __near ram_62c[];
extern uip __near ram_656;
extern unsigned long __near ram_642;

void Flash_AccumWrite_Word(unsigned char a)
{
    ram_62c[ram_654] = a;
    if (ram_654++ == 1) {
        Flash_ProgramWord(1, ram_656++, *(unsigned int *)ram_62c);
        ram_654 = 0;
    }
    ram_642 += 1;
}

extern unsigned char LIVE_PANEL_BLOCK;
extern unsigned int NMI_CHECKSUM_REGION1;
extern unsigned int NMI_CHECKSUM_REGION2;
extern char ram_1e53e;
extern unsigned char HDAE5000_PPI__PORT_A;
extern unsigned int CUSTOM_DATA_FLASH__BASE_ADDR;
extern unsigned int ram_200000;
extern unsigned long __near SYSTEM_TIMESTAMP;

void Flash_BurnWithProgress(void)
{
    int x = 0x32;
    SYSTEM_TIMESTAMP = 0;
    TableDataFlash_ChipErase();
    while (HDAE5000_Status_Check() == -1) {
        if (SYSTEM_TIMESTAMP > 500) {
            x += 8;
            VRAM_FillRect(x, 0xb4, 5);
            SYSTEM_TIMESTAMP = 0;
        }
    }
}

void HDAE5000_ProgramCustomDataFlash(void)
{
    unsigned int *src;
    unsigned int *dst = &CUSTOM_DATA_FLASH__BASE_ADDR;
    unsigned char bank;
    unsigned long i;
    bank = 0;
    do {
        HDAE5000_PPI__PORT_A = bank;
        src = &ram_200000;
        i = 0;
        do {
            Flash_ProgramWord(1, dst++, *src++);
            i++;
        } while (i < 0x40000);
        bank++;
    } while (bank < 2);
}

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
