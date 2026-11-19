/* lane_sub, round 23: sub_C_7g.c respelled by notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23w.py, form b: inline assembly as `__asm` (V4.23 then keeps values live across it in XIZ, as the ROM does), and no `register` storage class.  The original file follows unchanged otherwise.
   cc900-options: -Xr */

/* lane_sub probe round 7, helper C, bisection file g: tone-generator writers of the KN5000 sub-CPU payload v1.42
   (core/08_voice_noteon_and_tonegen.s) with ONE suspect spelling for round 6's V4.23 crash (page fault, read at
   0x630, in files holding __IZ plus a record pointer kept in memory): `(void)&p` alone, no pseudo-(control for 7d).
   7d = __IZ + (void)&p, 7e = __IZ + array, 7f = local, 7g = (void)&p alone, 7h = array alone. */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

void ToneGen_WriteExtParams_56_Alt(unsigned int reg, unsigned int *p)
{
    (void)&p;
    if (p[30] & 0x8000) {
        ram_18 &= ~0x80;
        ram_100000 = reg + 0x580;
        __asm(" nop");
        ram_18 |= 0x80;
        ram_100002 = p[30];
        __asm(" jr $+2");
        __asm(" nop");
        __asm(" nop");
        __asm(" nop");
    }
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x580;
    __asm(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[30] & ~0x8000;
    __asm(" jr $+2");
    __asm(" nop");
    __asm(" nop");
    __asm(" nop");
}
