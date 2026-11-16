/* Functions of core/02_audio_system_init.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct bcfg { int a; int b; int c; int d; long e; };
extern int DSP_DispatchData(int d, int chip);
extern int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code);

int __cdecl Audio_CmdHandler_20_3F(unsigned char cmd, unsigned char *d) { return 0; }

int __cdecl Audio_CmdHandler_40_5F(char n, unsigned char *d)
{
    while (n--)
        ;
    return 0;
}

void Audio_InitRingBuffers(void)
{
    RingBuf_Init_1K();
    RingBuf_Init_256();
    RingBuf_Init_512();
}

void Task2_NeverSpawned(void) { }
