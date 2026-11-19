/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct s426 { unsigned int w[0xd5]; };
extern unsigned long ram_4531c;
extern unsigned char ram_7800[];
unsigned char *DSP1_ResolveStreamPtr(unsigned int n);
unsigned int DSP_WriteCount_Compute(void);
void DSP_ResetAlgoDefaults(void);
void DSP_FlushAllSlots(int a, int c);
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n);
extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);
void DSP_Reinit_VoiceSlots(unsigned char a, unsigned char c);

/* cc900-module: DSP1_ResolveStreamPtr DSP_FlushAllSlots DSP_InitChannelSlot DSP_Reinit_VoiceSlots DSP_ResetAlgoDefaults DSP_WriteCount_Compute */
void DSP_Reinit_VoiceSlots(unsigned char a, unsigned char c)
{
    unsigned char *p;
    unsigned int n;
    unsigned int i;
    if (a < 0x40) {
        if (c != 0xff) {
            i = (unsigned int)a * 0x14 + (unsigned int)c;
            p = DSP1_ResolveStreamPtr(i);
            *(struct s426 *)(+((unsigned long)(i) * 0x1d6 + 0x10) + ram_4531c) = *(struct s426 *)p;
        } else {
            n = (unsigned int)a * 0x14;
            for (i = n; i < n + 0x14; i++) {
                p = DSP1_ResolveStreamPtr(i);
                *(struct s426 *)(+((unsigned long)(i) * 0x1d6 + 0x10) + ram_4531c) = *(struct s426 *)p;
            }
        }
        *(unsigned int *)(((unsigned char *)ram_4531c) + 29352) = DSP_WriteCount_Compute();
    } else if (a != 0xff) {
        if (c != 0xff) DSP_InitChannelSlot(((unsigned char *)ram_4531c) + 18816, c);
        else {
            for (i = n; i < 0x80; i++)
                DSP_InitChannelSlot(((unsigned char *)ram_4531c) + 18816, i);
        }
        *(unsigned int *)(((unsigned char *)ram_4531c) + 29352) = DSP_WriteCount_Compute();
    } else {
        DSP_ResetAlgoDefaults();
        for (n = 0; n < 0x28; n++) {
            p = DSP1_ResolveStreamPtr(n);
            *(struct s426 *)(+((unsigned long)(n) * 0x1d6 + 0x10) + ram_4531c) = *(struct s426 *)p;
        }
        DSP_FlushAllSlots(0, 0x40);
        *(unsigned int *)(((unsigned char *)ram_4531c) + 29352) = DSP_WriteCount_Compute();
    }
    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, (unsigned char *)0x1e0000);
}
