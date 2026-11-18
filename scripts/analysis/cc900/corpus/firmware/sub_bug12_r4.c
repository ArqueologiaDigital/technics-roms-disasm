/* r4: as r1 without the pointer local q (the store goes straight to ram_100002).
   V4.23 bug candidate 12 reproducer, r1 (lane_sub, 2026-11-18): helper AI's ToneGen_ReadPitch_AndScale alone, as it
   stood in sub_AI_20a.c, which made V4.23 stop with a page fault (read access to 0x630) in run 2026-11-18-18-sub-r21a
   and lose the whole file.  It names the pseudo-register __IZ, keeps a pointer local q (a constant address) and
   multiplies __IZ by a long (a runtime call while __IZ is live).  r2 is the same without __IZ; r3 keeps __IZ but
   drops the long multiply; r4 keeps __IZ and the multiply but drops q.
   cc900-options: -Xr */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_430bb[];

void ToneGen_ReadPitch_AndScale(unsigned int reg, unsigned char *p)
{
    __IZ = reg;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0xc0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)(p + 6);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *(unsigned int *)((unsigned long)ram_430bb + (unsigned long)__IZ * 0x47) & 0x7fff;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
