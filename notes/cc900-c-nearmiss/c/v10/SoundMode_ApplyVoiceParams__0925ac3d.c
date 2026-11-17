/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5b.c (2026-11-16-40-p6-r8)
   sha256 0925ac3d7624e564a79643524eac0977811cc2828328dc740296e5ffc2f35240 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_918d[];
extern void SysEx_ApplyVoiceParam_49(int, unsigned char *);
extern void SysEx_ApplyVoiceParam_4B(int, unsigned char *);
void SoundMode_ApplyVoiceParams(void)
{
    unsigned char *p, *e;
    SysEx_ApplyVoiceParam_49(2, (unsigned char *)0xf980);
    SysEx_ApplyVoiceParam_4B(4, (unsigned char *)0xf980);
    p = ram_918d;
    e = p + 31;
    do *p++ = 0x23; while (p <= e);
}
