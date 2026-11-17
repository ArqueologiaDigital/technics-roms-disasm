/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5a.c (2026-11-16-40-p6-r8)
   sha256 f87946baf95982e11078f1ac542bfcae2d882549a42730c571b8582dbb6869d2 (tar-sha256); compiled at -O3 -Xr */
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
