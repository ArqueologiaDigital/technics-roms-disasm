/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_7a.c (2026-11-16-79-sub-r7)
   sha256 143de7409dae35d7976fc4f35166d64c5f696ce04cd1c3c30aec77c5887d93f4 (name+funcs); compiled at -Xr */
extern unsigned char ram_4502b;
extern void VoiceAlloc_CheckAndInit();
void VoiceAlloc_WithRoutingFlag(unsigned char part, unsigned char flag)
{
    VoiceAlloc_CheckAndInit(part);
    if (flag != 0) ram_4502b |= 0x80;
    else ram_4502b &= ~0x80;
}
