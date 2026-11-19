/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w2a.c (2026-11-19-10-sub-r23w-asm)
   sha256 e04d516c1baebeef27d3fce9fb29433aae9266dda8f08006a5ed9f55fe405a8e (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: TG_WriteExtParam_1C0_Single=ToneGen_WriteExtParam_1C0_Single */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void TG_WriteExtParam_1C0_Single(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x1c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
