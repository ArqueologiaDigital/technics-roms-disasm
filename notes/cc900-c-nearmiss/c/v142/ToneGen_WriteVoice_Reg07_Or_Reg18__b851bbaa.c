/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w1a.c (2026-11-19-10-sub-r23w-asm)
   sha256 b851bbaa02d7911b1b3dee44c3ef57ae1a8f0085d908b79e17152045f9ddaddf (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WriteVoice_Reg07_Or_18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
struct tgv { unsigned int w[36]; };
void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, register struct tgv *p)
{
    if (ch < 64) {
        ram_18 &= ~0x80; ram_100000 = (ch + 448); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        ram_18 &= ~0x80; ram_100000 = (ch + 1536); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}
