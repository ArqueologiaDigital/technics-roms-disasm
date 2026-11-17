/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3b.c (2026-11-16-58-sub-r3)
   sha256 e14e6b6d5c368715cf8ab076373270904387a8c8c479bba7f55ed229322f8ab3 (name+funcs); compiled at -Xr
   cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
#define TG_WAIT2 __ASM("	db	0x68,0x00"); __ASM("	nop"); __ASM("	nop"); __ASM("	nop")
#define TG_WRITE(r, v) ram_18 &= ~0x80; ram_100000 = (r); __ASM("	nop"); ram_18 |= 0x80; ram_100002 = (v); TG_WAIT2
void TG_WriteExtParam_Mute_TypeDisp(unsigned int reg)
{
    if (reg < 0x40) {
        TG_WRITE(reg + 0x540, 0x8100);
    } else {
        TG_WRITE(reg + 0x580, 0x8100);
    }
}
