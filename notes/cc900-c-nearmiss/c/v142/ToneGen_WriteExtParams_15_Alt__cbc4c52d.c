/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w7b.c (2026-11-19-10-sub-r23w-asm)
   sha256 cbc4c52d84f4739fcac6a3db41e34aee9e4164046fba1f3bcddcb4bc99a0bbe7 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    if (q[0][29] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = reg + 0x540;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = q[0][29];
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x540;
    __asm(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][29] & ~0x8000;
    __asm(" jr $+2");
    __asm(" nop");
    __asm(" nop");
    __asm(" nop");
}
