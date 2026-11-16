/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): these call the C runtime (C9H_mulls / C9H_divls ...), whose
   names the build does not map to the payload's Math_Multiply32 / Long_SignedDiv yet.
*/



extern unsigned char ram_4131c[];
extern unsigned char ram_41322[];
extern unsigned char ram_41326[];
extern void Voice_DSP_OutputConfig2(unsigned int part, unsigned int slot);
#define PART_FLAGS(p)   (*(unsigned int *)(ram_4131c + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_41326 + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_41322 + (p) * 0x11f))





extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
#define TG_WAIT2 __ASM("	db	0x68,0x00"); __ASM("	nop"); __ASM("	nop"); __ASM("	nop")
#define TG_WRITE(r, v) ram_18 &= ~0x80; ram_100000 = (r); __ASM("	nop"); ram_18 |= 0x80; ram_100002 = (v); TG_WAIT2

/* cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */








int CheckStatusBits_40(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41322 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0x40;
}

int CheckStatusBits_80(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41322 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0x80;
}





int Voice_Part_Mode_Is_C0(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41322 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0xc0;
}
