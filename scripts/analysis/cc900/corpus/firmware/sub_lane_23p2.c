/* lane_sub, round 23, form p2 (KN5000 sub-CPU payload v1.42), 2026-11-19.
   As sub_lane_23p1.c (the record pointer in XIZ across the inline nops), but V4.23 does not know `#pragma asm`
   (run 2026-11-19-7: THC1-Warning-618 Unknown #pragma).  Here the lower-case keyword `__asm("...")` instead of
   __ASM, in case V4.23 treats it as a block that clobbers the scratch registers.  A file of its own.
   cc900-options: -Xr */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

void ToneGen_WriteVoice_Reg07(unsigned int ch, unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 448;
    __asm(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[28];
    __asm(" jr $+2");
    __asm(" nop");
    __asm(" nop");
    __asm(" nop");
}
