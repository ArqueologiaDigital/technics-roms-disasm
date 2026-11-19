/* lane_sub, round 23, form p3 (KN5000 sub-CPU payload v1.42), 2026-11-19.
   As sub_lane_23p2.c with the plain keyword `asm("...")`.  A file of its own.
   cc900-options: -Xr */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */

void ToneGen_WriteVoice_Reg07(unsigned int ch, unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 448;
    asm(" nop");
    ram_18 |= 0x80;
    ram_100002 = p[28];
    asm(" jr $+2");
    asm(" nop");
    asm(" nop");
    asm(" nop");
}
